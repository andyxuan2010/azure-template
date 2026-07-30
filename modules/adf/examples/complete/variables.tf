variable "resource_group_name" {
  description = "Name of the existing resource group in which to create Data Factory."
  type        = string
}

variable "location" {
  description = "Azure region for Data Factory."
  type        = string
  default     = "canadacentral"
}

variable "private_endpoint_subnet_id" {
  description = "Resource ID of the existing private endpoint subnet."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Resource ID of the existing privatelink.datafactory.azure.net private DNS zone."
  type        = string
}

variable "storage_account_id" {
  description = "Resource ID of the storage account targeted by the managed private endpoint."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace used for diagnostics."
  type        = string
}
