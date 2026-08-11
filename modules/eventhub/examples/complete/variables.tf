variable "name" {
  description = "Globally unique Event Hubs namespace name."
  type        = string
  default     = "evhns-telemetry-prod-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for Event Hubs."
  type        = string
  default     = "canadacentral"
}

variable "capture_storage_account_id" {
  description = "Resource ID of the Capture Storage Account."
  type        = string
}

variable "capture_container_name" {
  description = "Existing Blob container receiving captured events."
  type        = string
  default     = "eventhub-capture"
}

variable "private_endpoint_subnet_id" {
  description = "Resource ID of the private-endpoint subnet."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Resource ID of the privatelink.servicebus.windows.net zone."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  type        = string
}

variable "producer_principal_id" {
  description = "Optional producer service-principal object ID."
  type        = string
  default     = null
}

variable "consumer_principal_id" {
  description = "Optional consumer service-principal object ID."
  type        = string
  default     = null
}
