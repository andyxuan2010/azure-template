variable "managed_instance_name" {
  description = "Existing SQL Managed Instance name."
  type        = string
}

variable "managed_instance_resource_group_name" {
  description = "Resource group containing the existing Managed Instance."
  type        = string
}

variable "workload" {
  description = "Workload component used in the generated database name."
  type        = string
  default     = "orders"
}

variable "app_env" {
  description = "Environment component used in the generated database name."
  type        = string
  default     = "dev"
}

variable "instance" {
  description = "Instance component used in the generated database name."
  type        = string
  default     = "001"
}

variable "tags" {
  description = "Tags applied to the managed database."
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
