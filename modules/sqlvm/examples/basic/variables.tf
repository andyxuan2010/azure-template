variable "resource_group_name" {
  description = "Existing resource group for the SQL VM."
  type        = string
}

variable "subnet_id" {
  description = "Existing subnet resource ID for the SQL VM NIC."
  type        = string
}

variable "admin_username" {
  description = "Local Windows administrator username."
  type        = string
}

variable "admin_password" {
  description = "Local Windows administrator password supplied through a protected input."
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Azure region for the SQL VM."
  type        = string
  default     = "canadacentral"
}

variable "workload_name" {
  description = "Workload segment used for generated naming."
  type        = string
  default     = "app"
}

variable "app_env" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags applied to SQL VM resources."
  type        = map(string)
  default     = {}
}
