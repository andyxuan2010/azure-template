variable "name" {
  description = "Globally unique Web App name."
  type        = string
  default     = "app-orders-prod"
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
  description = "Resource ID of an existing Premium Linux App Service Plan."
  type        = string
}

variable "vnet_integration_subnet_id" {
  description = "Resource ID of an existing subnet delegated to Microsoft.Web/serverFarms."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Resource ID of the existing private endpoint subnet."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Resource ID of the existing privatelink.azurewebsites.net private DNS zone."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the existing Log Analytics workspace."
  type        = string
}
