variable "name" {
  description = "Globally unique Cosmos DB account name."
  type        = string
  default     = "cosmos-orders-prod-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "primary_location" {
  description = "Primary Cosmos DB region."
  type        = string
  default     = "canadacentral"
}

variable "secondary_location" {
  description = "Secondary Cosmos DB region."
  type        = string
  default     = "canadaeast"
}

variable "private_endpoint_subnet_id" {
  description = "Resource ID of the private-endpoint subnet."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Resource ID of the SQL API privatelink.documents.azure.com zone."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  type        = string
}

variable "operator_principal_id" {
  description = "Optional Microsoft Entra group object ID for read-only control-plane access."
  type        = string
  default     = null
}
