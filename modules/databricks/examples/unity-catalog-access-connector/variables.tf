variable "name" {
  description = "Globally unique Azure Databricks workspace name."
  type        = string
  default     = "dbw-catalog-prod-001"
}

variable "resource_group_name" {
  description = "Name of the existing workspace resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the workspace and access connector."
  type        = string
  default     = "canadacentral"
}

variable "external_storage_account_id" {
  description = "Resource ID of the external Storage Account used by Unity Catalog."
  type        = string
}
