variable "name" {
  description = "Globally unique Web App name."
  type        = string
  default     = "app-orders-storage-dev"
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

variable "storage_account_name" {
  description = "Name of the existing Storage Account."
  type        = string
}

variable "storage_share_name" {
  description = "Name of the existing Azure Files share."
  type        = string
}

variable "storage_access_key" {
  description = "Storage Account access key used by the App Service mount."
  type        = string
  sensitive   = true
}
