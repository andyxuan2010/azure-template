variable "name" {
  description = "Globally unique Azure OpenAI account and subdomain name."
  type        = string
  default     = "oai-orders-dev-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure OpenAI-supported Azure region."
  type        = string
  default     = "canadacentral"
}
