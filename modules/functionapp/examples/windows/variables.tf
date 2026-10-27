variable "name" {
  description = "Globally unique Function App name."
  type        = string
  default     = "func-billing-prod-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Function App."
  type        = string
  default     = "canadacentral"
}

variable "service_plan_id" {
  description = "Resource ID of an existing Windows App Service Plan."
  type        = string
}

variable "storage_key_vault_secret_id" {
  description = "Versioned Key Vault secret ID containing the Function storage connection string."
  type        = string
}
