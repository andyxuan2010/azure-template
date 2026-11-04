variable "name" {
  description = "Automation Account name."
  type        = string
  default     = "aa-operations-dev"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Automation Account."
  type        = string
  default     = "canadacentral"
}
