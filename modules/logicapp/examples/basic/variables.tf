variable "name" {
  description = "Globally unique Logic App Standard host name."
  type        = string
  default     = "logic-orders-dev-001"
}

variable "resource_group_name" {
  description = "Name of the existing Logic App resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Logic App Standard host."
  type        = string
  default     = "canadacentral"
}

variable "service_plan_id" {
  description = "Resource ID of an existing Workflow Standard App Service Plan."
  type        = string
}

variable "storage_account_name" {
  description = "Name of the existing Logic App storage account."
  type        = string
}

variable "storage_account_resource_group_name" {
  description = "Resource group containing the Logic App storage account."
  type        = string
}
