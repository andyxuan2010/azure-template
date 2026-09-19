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

variable "log_analytics_workspace_id" {
  description = "Existing Log Analytics workspace ID."
  type        = string
}

variable "app_admin_group_object_ids" {
  description = "Microsoft Entra group object IDs receiving database Contributor and parent Reader."
  type        = list(string)
  default     = []
}

variable "app_user_group_object_ids" {
  description = "Microsoft Entra group object IDs receiving database and parent Reader."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to the managed database."
  type        = map(string)
  default = {
    Environment = "prod"
    ManagedBy   = "Terraform"
    Service     = "Database"
  }
}
