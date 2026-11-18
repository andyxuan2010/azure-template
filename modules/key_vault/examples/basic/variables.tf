variable "name" {
  description = "Globally unique Key Vault name."
  type        = string
  default     = "kv-orders-dev-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Key Vault."
  type        = string
  default     = "canadacentral"
}
