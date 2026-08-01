variable "name" {
  description = "Globally unique Azure OpenAI account and subdomain name."
  type        = string
  default     = "oai-orders-cmk-prod-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure OpenAI-supported Azure region."
  type        = string
  default     = "canadacentral"
}

variable "user_assigned_identity_id" {
  description = "Resource ID of the existing identity authorized to use the Key Vault key."
  type        = string
}

variable "user_assigned_identity_client_id" {
  description = "Client ID of the user-assigned identity used for customer-managed encryption."
  type        = string
}

variable "key_vault_key_id" {
  description = "Versioned Key Vault key ID used for Azure OpenAI encryption."
  type        = string
}
