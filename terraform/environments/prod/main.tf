terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.115.0"
    }
  }
  required_version = ">= 1.9.4"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
  tags     = { Environment = var.environment }
}

module "networking" {
  source                  = "../../modules/networking"
  vnet_name               = var.vnet_name
  vnet_address_space      = var.vnet_address_space
  subnet_name             = var.subnet_name
  subnet_address_prefix   = var.subnet_address_prefix
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
}

module "aks" {
  source                                          = "../../modules/aks"
  resource_group_name                             = var.resource_group_name
  resource_group_location                         = var.resource_group_location
  aks_cluster_name                                = var.aks_cluster_name
  aks_dns_prefix                                  = var.aks_dns_prefix
  aks_vm_size                                     = var.aks_vm_size
  kubernetes_version                              = var.kubernetes_version
  node_count                                      = var.node_count
  availability_zones                              = var.availability_zones
  enable_auto_scaling                             = var.enable_auto_scaling
  min_node_count                                  = var.min_node_count
  max_node_count                                  = var.max_node_count
  identity_type                                   = var.identity_type
  network_plugin                                  = var.network_plugin
  load_balancer_sku                               = var.load_balancer_sku
  service_cidr                                    = var.service_cidr
  dns_service_ip                                  = var.dns_service_ip
  environment                                     = var.environment
  acr_role_definition_name                        = var.acr_role_definition_name
  acr_skip_service_principal_aad_check            = var.acr_skip_service_principal_aad_check
  sku_tier                                        = var.sku_tier
  open_service_mesh_enabled                       = var.open_service_mesh_enabled
  http_application_routing_enabled                = var.http_application_routing_enabled
  azure_policy_enabled                            = var.azure_policy_enabled
  backup_container_access_type                    = var.backup_container_access_type
  backup_storage_account_name                     = var.backup_storage_account_name
  db_disk_name                                    = var.db_disk_name
  messaging_disk_name                             = var.messaging_disk_name
  db_disk_storage_account_type                    = var.db_disk_storage_account_type
  messaging_disk_storage_account_type             = var.messaging_disk_storage_account_type
  db_disk_create_option                           = var.db_disk_create_option
  messaging_disk_create_option                    = var.messaging_disk_create_option
  auto_scaler_profile_balance_similar_node_groups = var.auto_scaler_profile_balance_similar_node_groups
  auto_scaler_profile_expander                    = var.auto_scaler_profile_expander
  auto_scaler_scale_down_utilization_threshold    = var.auto_scaler_scale_down_utilization_threshold
  aks_kube_config_sensitive                       = var.aks_kube_config_sensitive
  db_disk_size_gb                                 = var.db_disk_size_gb
  messaging_disk_size_gb                          = var.messaging_disk_size_gb
  backup_container_name                           = var.backup_container_name
  default_node_pool_name                          = var.default_node_pool_name
  backup_storage_account_replication_type         = var.backup_storage_account_replication_type
  backup_storage_account_tier                     = var.backup_storage_account_tier
  subnet_id                                       = module.networking.subnet_id
  acr_id                                          = module.acr.acr_id
}

module "acr" {
  source                  = "../../modules/acr"
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
  acr_sku                 = var.acr_sku
  acr_admin_enabled       = var.acr_admin_enabled
  acr_name                = var.acr_name
}
