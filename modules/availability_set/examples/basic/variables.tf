variable "name" {
  description = "Availability Set name."
  type        = string
  default     = "avail-payments-cc-dev-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Availability Set."
  type        = string
  default     = "canadacentral"
}
