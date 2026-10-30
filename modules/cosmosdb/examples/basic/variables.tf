variable "name" {
  description = "Globally unique Cosmos DB account name."
  type        = string
  default     = "cosmos-orders-dev-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Primary Azure region for Cosmos DB."
  type        = string
  default     = "canadacentral"
}
