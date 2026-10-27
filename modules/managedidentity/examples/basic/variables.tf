variable "name" {
  description = "Name of the user-assigned managed identity."
  type        = string
  default     = "id-orders-dev-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the managed identity."
  type        = string
  default     = "canadacentral"
}
