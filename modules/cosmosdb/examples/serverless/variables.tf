variable "name" {
  description = "Globally unique Cosmos DB account name."
  type        = string
  default     = "cosmos-events-sbx-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Single Azure region for the serverless account."
  type        = string
  default     = "canadacentral"
}
