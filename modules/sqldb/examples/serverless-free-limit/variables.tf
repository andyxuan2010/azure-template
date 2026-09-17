variable "resource_group_name" {
  description = "Existing resource group for SQL resources."
  type        = string
}

variable "location" {
  description = "Azure region for SQL resources."
  type        = string
  default     = "canadacentral"
}

variable "server_name" {
  description = "Globally unique Azure SQL logical server name."
  type        = string
}

variable "database_name" {
  description = "Azure SQL database name."
  type        = string
  default     = "sandbox"
}

variable "ad_admin_login_name" {
  description = "Microsoft Entra administrator group display name."
  type        = string
}

variable "ad_admin_object_id" {
  description = "Microsoft Entra administrator group object ID."
  type        = string
}

variable "tags" {
  description = "Tags applied to SQL resources."
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
    Purpose     = "Sandbox"
  }
}
