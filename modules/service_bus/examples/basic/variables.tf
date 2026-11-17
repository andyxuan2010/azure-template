variable "resource_group_name" {
  description = "Existing resource group for the Service Bus namespace."
  type        = string
}

variable "location" {
  description = "Azure region for the namespace."
  type        = string
  default     = "canadacentral"
}

variable "name" {
  description = "Globally unique Service Bus namespace name."
  type        = string
}

variable "tags" {
  description = "Tags applied to the namespace."
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
