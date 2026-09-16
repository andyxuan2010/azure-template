variable "name" {
  description = "Globally unique Azure AI Search service name."
  type        = string
  default     = "srch-platform-prod-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for Azure AI Search."
  type        = string
  default     = "canadacentral"
}

variable "private_endpoint_subnet_id" {
  description = "Resource ID of the private-endpoint subnet."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Resource ID of the privatelink.search.windows.net private DNS zone."
  type        = string
}

variable "content_storage_account_id" {
  description = "Resource ID of the Storage Account reached through a shared private link."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  type        = string
}

variable "workload_principal_id" {
  description = "Optional application service-principal object ID for query access."
  type        = string
  default     = null
}
