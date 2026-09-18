variable "name" {
  description = "Automation Account name."
  type        = string
  default     = "aa-operations-prod"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Automation Account and private endpoints."
  type        = string
  default     = "canadacentral"
}

variable "private_endpoint_subnet_id" {
  description = "Resource ID of the existing private endpoint subnet."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Resource ID of the existing privatelink.azure-automation.net private DNS zone."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the existing Log Analytics workspace."
  type        = string
}

variable "encryption_identity_id" {
  description = "Resource ID of the existing user-assigned identity authorized to use the encryption key."
  type        = string
}

variable "key_vault_key_id" {
  description = "Versioned resource ID of the existing Key Vault key used for Automation encryption."
  type        = string
}

variable "app_admin_group_object_ids" {
  description = "Microsoft Entra group object IDs granted Contributor on the Automation Account."
  type        = list(string)
  default     = []
}

variable "app_user_group_object_ids" {
  description = "Microsoft Entra group object IDs granted Reader on the Automation Account."
  type        = list(string)
  default     = []
}

variable "managed_identity_target_scope" {
  description = "Optional Azure resource scope at which the Automation Account identity receives Reader."
  type        = string
  default     = null
  nullable    = true
}
