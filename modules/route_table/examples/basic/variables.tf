variable "name" {
  description = "Route table name."
  type        = string
  default     = "rt-application-cc-dev-001"
}

variable "resource_group_name" {
  description = "Existing network resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the route table."
  type        = string
  default     = "canadacentral"
}

variable "subnet_id" {
  description = "Existing subnet resource ID to associate."
  type        = string
}

variable "tags" {
  description = "Tags applied to the route table."
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
