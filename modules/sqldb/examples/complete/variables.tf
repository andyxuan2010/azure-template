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
  default     = "orders"
}

variable "ad_admin_login_name" {
  description = "Microsoft Entra administrator group display name."
  type        = string
}

variable "ad_admin_object_id" {
  description = "Microsoft Entra administrator group object ID."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Existing Private Endpoint subnet ID."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Existing privatelink.database.windows.net zone ID."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Existing Log Analytics workspace ID."
  type        = string
}

variable "app_admin_group_object_ids" {
  description = "Microsoft Entra group object IDs receiving the configured admin Azure role."
  type        = list(string)
  default     = []
}

variable "app_user_group_object_ids" {
  description = "Microsoft Entra group object IDs receiving the configured user Azure role."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to SQL resources."
  type        = map(string)
  default = {
    Environment = "prod"
    ManagedBy   = "Terraform"
    Service     = "Database"
  }
}
