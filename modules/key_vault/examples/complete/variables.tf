variable "name" {
  description = "Globally unique Key Vault name."
  type        = string
  default     = "kv-orders-prod-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Key Vault."
  type        = string
  default     = "canadacentral"
}

variable "private_endpoint_subnet_id" {
  description = "Resource ID of the private endpoint subnet."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Resource ID of the existing privatelink.vaultcore.azure.net zone."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the existing Log Analytics workspace."
  type        = string
}

variable "admin_group_object_ids" {
  description = "Microsoft Entra group object IDs granted Key Vault Administrator."
  type        = list(string)
  default     = []
}

variable "user_group_object_ids" {
  description = "Microsoft Entra group object IDs granted Key Vault Secrets User."
  type        = list(string)
  default     = []
}

variable "certificate_contact_email" {
  description = "Email address used for certificate lifecycle notifications."
  type        = string
}
