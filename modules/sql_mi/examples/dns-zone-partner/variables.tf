variable "name" {
  description = "SQL Managed Instance name."
  type        = string
  default     = "sqlmi-data-dr-cc-prod-001"
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

variable "dns_zone_partner_id" {
  description = "Existing SQL Managed Instance ID whose DNS zone this instance joins."
  type        = string
}

variable "tags" {
  description = "Tags applied to the Managed Instance."
  type        = map(string)
  default = {
    Environment = "prod"
    ManagedBy   = "Terraform"
    Role        = "DisasterRecovery"
  }
}
