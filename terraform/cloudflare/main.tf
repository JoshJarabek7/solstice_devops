# terraform/cloudflare/main.tf

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.39.0"
    }
  }
  required_version = ">= 1.9.4"
}

provider "cloudflare" {
  api_key = var.cloudflare_api_key
  email   = var.cloudflare_email
}

data "terraform_remote_state" "aks" {
  backend = "local"
  config = {
    path = "../azure/terraform.tfstate"
  }
}

data "terraform_remote_state" "helm" {
  backend = "local"
  config = {
    path = "../helm/terraform.tfstate"
  }
}

locals {
  ingress_ip = data.terraform_remote_state.helm.outputs.ingress_nginx_ip
}

resource "cloudflare_record" "apex" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  content = local.ingress_ip
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "vault" {
  zone_id = var.cloudflare_zone_id
  name    = "vault"
  content = local.ingress_ip
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "auth" {
  zone_id = var.cloudflare_zone_id
  name    = "auth"
  content = local.ingress_ip
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "wildcard" {
  zone_id = var.cloudflare_zone_id
  name    = "*"
  content = local.ingress_ip
  type    = "A"
  proxied = true
}
