variable "name" {
  description = "Globally unique Function App name."
  type        = string
  default     = "func-orders-dev-001"
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

variable "storage_account_access_key" {
  description = "Access key for the existing Function storage account."
  type        = string
  sensitive   = true
}
