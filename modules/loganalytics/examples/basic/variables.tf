variable "name" {
  description = "Globally unique Log Analytics workspace name."
  type        = string
  default     = "law-orders-dev"
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
