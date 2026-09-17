variable "name" {
  description = "Resource group name."
  type        = string
  default     = "rg-orders-cc-dev-001"
}

variable "location" {
  description = "Azure region for the resource group."
  type        = string
  default     = "canadacentral"
}

variable "environment" {
  description = "Environment used by module metadata and optional naming."
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Complete resource group tag set."
  type        = map(string)
  default = {
    Environment = "dev"
    Owner       = "orders-team"
    ManagedBy   = "Terraform"
  }
}
