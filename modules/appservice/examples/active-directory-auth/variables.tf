variable "name" {
  description = "Globally unique Web App name whose callback URI is registered in Microsoft Entra."
  type        = string
  default     = "app-orders-auth-dev"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Web App."
  type        = string
  default     = "canadacentral"
}

variable "app_service_plan_id" {
  description = "Resource ID of an existing Linux App Service Plan."
  type        = string
}

variable "active_directory_client_id" {
  description = "Client ID of the Microsoft Entra application configured for App Service Easy Auth."
  type        = string
}

variable "client_secret_key_vault_uri" {
  description = "Versioned Key Vault secret URI containing the Entra application client secret."
  type        = string
}
