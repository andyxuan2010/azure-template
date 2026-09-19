variable "name" {
  description = "Globally unique Azure AI Services account name."
  type        = string
  default     = "ais-platform-dev-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for Azure AI Services."
  type        = string
  default     = "canadacentral"
}
