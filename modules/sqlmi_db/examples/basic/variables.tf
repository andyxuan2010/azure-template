variable "managed_instance_name" {
  description = "Existing SQL Managed Instance name."
  type        = string
}

variable "managed_instance_resource_group_name" {
  description = "Resource group containing the existing Managed Instance."
  type        = string
}

variable "database_name" {
  description = "Managed database name."
  type        = string
  default     = "orders"
}

variable "tags" {
  description = "Tags applied to the managed database."
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
