variable "name" {
  description = "Globally unique Azure Databricks workspace name."
  type        = string
  default     = "dbw-lakehouse-dev-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the workspace."
  type        = string
  default     = "canadacentral"
}
