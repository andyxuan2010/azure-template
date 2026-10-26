variable "name" {
  description = "Globally unique Azure AI Search service name."
  type        = string
  default     = "srch-platform-dev-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for Azure AI Search."
  type        = string
  default     = "canadacentral"
}
