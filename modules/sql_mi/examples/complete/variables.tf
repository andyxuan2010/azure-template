variable "name" {
  description = "SQL Managed Instance name."
  type        = string
  default     = "sqlmi-data-cc-prod-001"
}

variable "resource_group_name" {
  description = "Existing resource group for the Managed Instance."
  type        = string
}

variable "location" {
  description = "Azure region for the Managed Instance."
  type        = string
  default     = "canadacentral"
}

variable "subnet_id" {
  description = "Existing dedicated subnet ID delegated to Microsoft.Sql/managedInstances."
  type        = string
}

variable "administrator_login" {
  description = "SQL administrator login."
  type        = string
  default     = "sqladminuser"
}

variable "administrator_login_password" {
  description = "SQL administrator password supplied through an approved secret workflow."
  type        = string
  sensitive   = true
}

variable "license_type" {
  description = "LicenseIncluded or BasePrice when Azure Hybrid Benefit eligibility is confirmed."
  type        = string
  default     = "LicenseIncluded"
}

variable "user_assigned_identity_id" {
  description = "Existing user-assigned managed identity ID."
  type        = string
}

variable "entra_admin_login_name" {
  description = "Microsoft Entra administrator group display name."
  type        = string
}

variable "entra_admin_object_id" {
  description = "Microsoft Entra administrator group object ID."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Existing Log Analytics workspace ID."
  type        = string
}

variable "app_admin_group_object_ids" {
  description = "Microsoft Entra group object IDs receiving Managed Instance Contributor."
  type        = list(string)
  default     = []
}

variable "app_user_group_object_ids" {
  description = "Microsoft Entra group object IDs receiving Managed Instance Reader."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to the Managed Instance."
  type        = map(string)
  default = {
    Environment = "prod"
    ManagedBy   = "Terraform"
    Service     = "Database"
  }
}
