variable "name" {
  description = "Globally unique Event Hubs namespace name."
  type        = string
  default     = "evhns-telemetry-dev-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for Event Hubs."
  type        = string
  default     = "canadacentral"
}
