variable "iac_resource_group_name" {
  description = "Existing resource group containing shared IaC services."
  type        = string
}

variable "iac_key_vault_name" {
  description = "Existing shared IaC Key Vault containing required bootstrap secrets."
  type        = string
}

variable "iac_storage_account_name" {
  description = "Existing shared IaC Storage account containing bootstrap assets."
  type        = string
}

variable "application_resource_group_name" {
  description = "Existing resource group for the SHIR VM."
  type        = string
}

variable "network_resource_group_name" {
  description = "Existing resource group containing the VNet."
  type        = string
}

variable "virtual_network_name" {
  description = "Existing VNet name."
  type        = string
}

variable "subnet_name" {
  description = "Existing private subnet name."
  type        = string
}

variable "data_factory_id" {
  description = "Azure Data Factory resource ID for SHIR RBAC and registration."
  type        = string
}

variable "admin_username" {
  description = "Local Windows administrator username."
  type        = string
}

variable "admin_password" {
  description = "Local Windows administrator password supplied through a protected input."
  type        = string
  sensitive   = true
}

variable "name" {
  description = "Windows VM base name before the instance suffix."
  type        = string
  default     = "winshir"
}

variable "location" {
  description = "Azure region for the VM."
  type        = string
  default     = "canadacentral"
}

variable "app_env" {
  description = "Deployment environment."
  type        = string
  default     = "prod"
}

variable "tags" {
  description = "Tags applied to VM resources."
  type        = map(string)
  default     = {}
}
