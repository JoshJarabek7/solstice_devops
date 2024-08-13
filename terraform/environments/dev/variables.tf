variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "resource_group_location" {
  description = "The location of the resource group."
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, prod)."
  type        = string
}

variable "vnet_name" {
  description = "The name of the virtual network."
  type        = string
}

variable "vnet_address_space" {
  description = "The address space for the virtual network."
  type        = list(string)
}

variable "subnet_name" {
  description = "The name of the subnet."
  type        = string
}

variable "subnet_address_prefix" {
  description = "The address prefix for the subnet."
  type        = string
}

variable "aks_cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
}

variable "aks_dns_prefix" {
  description = "The DNS prefix for the AKS cluster."
  type        = string
}

variable "aks_vm_size" {
  description = "The VM size for the AKS node pool."
  type        = string
}

variable "kubernetes_version" {
  description = "The Kubernetes version for the AKS cluster."
  type        = string
}

variable "node_count" {
  description = "The number of nodes in the default node pool."
  type        = number
}

variable "default_node_pool_name" {
  description = "The name of the default node pool."
  type        = string
}

variable "acr_name" {
  description = "The name of the Azure Container Registry."
  type        = string
}

variable "acr_sku" {
  description = "The SKU for the Azure Container Registry."
  type        = string
}

variable "acr_admin_enabled" {
  description = "Enable admin user for the Azure Container Registry."
  type        = bool
}

variable "db_disk_size_gb" {
  description = "The size of the managed disk for database in GB."
  type        = number
}

variable "messaging_disk_size_gb" {
  description = "The size of the managed disk for messaging service in GB."
  type        = number
}

variable "backup_storage_account_name" {
  description = "The name of the storage account for backups."
  type        = string
}

variable "backup_container_name" {
  description = "The name of the container in the storage account for backups."
  type        = string
}

variable "db_disk_name" {
  description = "The name of the database disk."
  type        = string
}

variable "messaging_disk_name" {
  description = "The name of the messaging disk."
  type        = string
}

variable "backup_container_access_type" {
  description = "Public/Private access to backup container."
  type        = string
}

variable "identity_type" {
  description = "The identity type for access and authorization to cluster."
  type        = string
}

variable "sku_tier" {
  description = "The SKU tier for the AKS cluster."
  type        = string
}

variable "availability_zones" {
  description = "The availability zones for the AKS cluster."
  type        = list(string)
}

variable "open_service_mesh_enabled" {
  description = "Enable Open Service Mesh addon."
  type        = bool
}

variable "http_application_routing_enabled" {
  description = "Enable HTTP Application Routing addon."
  type        = bool
}

variable "azure_policy_enabled" {
  description = "Enable Azure Policy addon."
  type        = bool
}

variable "enable_auto_scaling" {
  description = "Enable auto scaling for the default pool."
  type        = bool
}

variable "min_node_count" {
  description = "The minimum node count for the default pool."
  type        = number
}

variable "max_node_count" {
  description = "The maximum node count for the default pool."
  type        = number
}

variable "network_plugin" {
  description = "The network plugin for the AKS cluster."
  type        = string
}

variable "load_balancer_sku" {
  description = "The load balancer SKU for the AKS cluster."
  type        = string
}

variable "messaging_disk_storage_account_type" {
  description = "The storage account type for the messaging disk."
  type        = string
}

variable "messaging_disk_create_option" {
  description = "The create option for the messaging disk."
  type        = string
}

variable "db_disk_storage_account_type" {
  description = "The storage account type for the database disk."
  type        = string
}

variable "db_disk_create_option" {
  description = "The create option for the database disk."
  type        = string
}

variable "service_cidr" {
  description = "CIDR notation IP range from which to assign service cluster IPs."
  type        = string
}

variable "backup_storage_account_tier" {
  description = "The tier for the backup storage account."
  type        = string
}

variable "backup_storage_account_replication_type" {
  description = "The replication type for the backup storage account."
  type        = string
}

variable "auto_scaler_profile_balance_similar_node_groups" {
  description = "Whether to balance similar node groups."
  type        = bool
}

variable "auto_scaler_profile_expander" {
  description = "The expander profile."
  type        = string
}

variable "auto_scaler_scale_down_utilization_threshold" {
  description = "The scale down utilization threshold."
  type        = number
}

variable "aks_kube_config_sensitive" {
  description = "Whether to mark kube config as sensitive."
  type        = bool
}

variable "dns_service_ip" {
  description = "IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)."
  type        = string
}

variable "acr_skip_service_principal_aad_check" {
  description = "Whether to skip service principal aad check."
  type        = bool
}

variable "acr_role_definition_name" {
  description = "The role definition name for acr."
  type        = string
}
