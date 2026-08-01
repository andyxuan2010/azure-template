variable "name" {
  description = "Globally unique Windows Web App name."
  type        = string
  default     = "app-orders-windows-dev"
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
  description = "Resource ID of an existing Windows App Service Plan."
  type        = string
}
