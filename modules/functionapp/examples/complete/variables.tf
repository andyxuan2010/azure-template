variable "name" {
  description = "Globally unique Function App name."
  type        = string
  default     = "func-orders-prod-001"
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
  description = "Resource ID of an existing Linux App Service Plan."
  type        = string
}

variable "storage_account_name" {
  description = "Name of the existing Function storage account."
  type        = string
}

variable "integration_subnet_id" {
  description = "Resource ID of the delegated Function VNet integration subnet."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Resource ID of the private endpoint subnet."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Resource ID of the existing privatelink.azurewebsites.net zone."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the existing Log Analytics workspace."
  type        = string
}

variable "admin_group_object_ids" {
  description = "Microsoft Entra group object IDs granted Contributor."
  type        = list(string)
  default     = []
}

variable "user_group_object_ids" {
  description = "Microsoft Entra group object IDs granted Reader."
  type        = list(string)
  default     = []
}
