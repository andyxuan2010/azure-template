variable "name" {
  description = "Globally unique Flex Consumption Function App name."
  type        = string
  default     = "func-orders-flex-dev"
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
  description = "Resource ID of an existing Linux FC1 Flex Consumption App Service Plan."
  type        = string
}

variable "runtime_name" {
  description = "Flex runtime name."
  type        = string
  default     = "python"
}

variable "runtime_version" {
  description = "Flex runtime version."
  type        = string
  default     = "3.11"
}

variable "storage_container_endpoint" {
  description = "Blob container endpoint or resource ID containing the deployment package."
  type        = string
}

variable "storage_access_key" {
  description = "Storage account access key for the deployment container."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags applied to the Function App."
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
