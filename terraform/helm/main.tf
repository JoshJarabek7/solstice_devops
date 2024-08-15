terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.15.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.32.0"
    }
  }
  required_version = ">= 1.9.4"
}

data "terraform_remote_state" "aks" {
  backend = "local"
  config = {
    path = "../azure/terraform.tfstate"
  }
}

locals {
  kube_config            = data.terraform_remote_state.aks.outputs.kube_config
  host                   = regex("server: (https://[^\n]+)", local.kube_config)[0]
  client_certificate     = base64decode(regex("client-certificate-data: ([^\n]+)", local.kube_config)[0])
  client_key             = base64decode(regex("client-key-data: ([^\n]+)", local.kube_config)[0])
  cluster_ca_certificate = base64decode(regex("certificate-authority-data: ([^\n]+)", local.kube_config)[0])
}

provider "kubernetes" {
  host                   = local.host
  client_certificate     = local.client_certificate
  client_key             = local.client_key
  cluster_ca_certificate = local.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = local.host
    client_certificate     = local.client_certificate
    client_key             = local.client_key
    cluster_ca_certificate = local.cluster_ca_certificate
  }
}

resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.11.1"
  namespace        = "ingress-nginx"
  create_namespace = true

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
    value = "false"
  }
  timeout = 600
}

resource "null_resource" "wait_for_ingress" {
  depends_on = [helm_release.nginx_ingress]

  provisioner "local-exec" {
    command = <<EOT
      kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=300s

      while [ -z "$(kubectl get services ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')" ]; do
        echo "Waiting for Ingress IP..."
        sleep 10
      done
    EOT
  }
}

data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  depends_on = [null_resource.wait_for_ingress]
}


resource "kubernetes_ingress_v1" "vault_ingress" {
  metadata {
    name = "vault-ingress"
    annotations = {
      "kubernetes.io/ingress.class"                    = "nginx"
      "cert-manager.io/cluster-issuer"                 = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "true"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      # "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTPS"
    }
  }

  spec {
    tls {
      hosts       = ["vault.parakeet.ventures"]
      secret_name = "vault-tls-secret"
    }
    rule {
      host = "vault.parakeet.ventures"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "vault"
              port {
                number = 8200
              }
            }
          }
        }
      }
    }
  }
  depends_on = [null_resource.create_cluster_issuer]
}

resource "kubernetes_ingress_v1" "keycloak_ingress" {
  metadata {
    name = "keycloak-ingress"
    annotations = {
      "kubernetes.io/ingress.class"                    = "nginx"
      "cert-manager.io/cluster-issuer"                 = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "true"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      # "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTPS"
    }
  }

  spec {
    tls {
      hosts       = ["auth.parakeet.ventures"]
      secret_name = "keycloak-tls-secret"
    }
    rule {
      host = "auth.parakeet.ventures"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "keycloak-http"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
  depends_on = [null_resource.create_cluster_issuer]
}

output "ingress_nginx_ip" {
  value = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].ip
}


resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.15.2"
  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
  timeout = 600
}

resource "null_resource" "wait_for_crds" {
  depends_on = [helm_release.cert_manager]

  provisioner "local-exec" {
    command = <<EOT
      kubectl wait --for=condition=Established --all crd --timeout=300s
    EOT
  }
}


resource "null_resource" "create_cluster_issuer" {
  depends_on = [null_resource.wait_for_crds]

  provisioner "local-exec" {
    command = <<EOT
      cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: ${var.cert_manager_issuer_email}
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod-account-key
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
    EOT
  }
}

resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = "default"

  set {
    name  = "server.dev.enabled"
    value = "true"
  }

  set {
    name  = "ui.enabled"
    value = "true"
  }
}

resource "helm_release" "keycloak" {
  name       = "keycloak"
  repository = "https://codecentric.github.io/helm-charts"
  chart      = "keycloak"
  namespace  = "default"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "service.port"
    value = "8080"
  }

  set {
    name  = "https.enabled"
    value = "false"
  }
}
