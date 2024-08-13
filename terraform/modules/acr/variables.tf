variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "resource_group_location" {
  description = "The location of the resource group"
  type        = string
}

variable "acr_sku" {
  description = "The SKU tier for the Azure Container Registry"
  type        = string
}

variable "acr_admin_enabled" {
  description = "Enable admin user for the Azure Container Registry"
  type        = bool
}

variable "acr_name" {
  description = "The name of the Azure Container Registry"
  type        = string
}
