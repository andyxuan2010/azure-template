variable "iac_resource_group_name" {
  description = "Existing resource group containing shared IaC services."
  type        = string
}

variable "iac_key_vault_name" {
  description = "Existing shared IaC Key Vault name."
  type        = string
}

variable "iac_storage_account_name" {
  description = "Existing shared IaC Storage account name and bootstrap assets."
  type        = string
}

variable "application_resource_group_name" {
  description = "Existing resource group for the VMs."
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
  description = "Existing subnet name."
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

variable "private_ip_addresses" {
  description = "Two available static private IP addresses in VM order."
  type        = list(string)
}

variable "log_analytics_workspace_id" {
  description = "Existing Log Analytics workspace resource ID."
  type        = string
}

variable "app_admin_group_object_ids" {
  description = "Microsoft Entra group object IDs granted VM administrator access."
  type        = list(string)
  default     = []
}

variable "app_user_group_object_ids" {
  description = "Microsoft Entra group object IDs granted VM user access."
  type        = list(string)
  default     = []
}

variable "bootstrap_content_hash" {
  description = "Hash that forces VM Run Command replacement when external bootstrap content changes."
  type        = string
  default     = ""
}

variable "name" {
  description = "Windows VM base name before the instance suffix."
  type        = string
  default     = "winapp"
}

variable "location" {
  description = "Azure region for the VMs."
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
