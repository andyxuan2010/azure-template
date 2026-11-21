variable "data_factory_resource_group_name" {
  description = "Name of the existing resource group in which to create Data Factory."
  type        = string
}

variable "application_resource_group_name" {
  description = "Name of the resource group in which to create the SHIR VM."
  type        = string
}

variable "network_resource_group_name" {
  description = "Name of the resource group containing the SHIR virtual network."
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the existing virtual network for the SHIR VM."
  type        = string
}

variable "subnet_name" {
  description = "Name of the existing subnet for the SHIR VM."
  type        = string
}

variable "vm_name" {
  description = "Base name for the SHIR Windows VM."
  type        = string
}

variable "shared_iac_resource_group_name" {
  description = "Name of the shared IaC resource group."
  type        = string
}

variable "shared_key_vault_name" {
  description = "Name of the shared Key Vault used for SHIR secrets."
  type        = string
}

variable "shared_storage_account_name" {
  description = "Name of the shared storage account used for VM bootstrap assets."
  type        = string
}

variable "location" {
  description = "Azure region for Data Factory and the SHIR VM."
  type        = string
  default     = "canadacentral"
}

variable "app_env" {
  description = "Deployment environment used by module naming and tagging."
  type        = string
  default     = "prod"
}
