variable "name" {
  description = "Globally unique Web App name."
  type        = string
  default     = "app-orders-dev"
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
