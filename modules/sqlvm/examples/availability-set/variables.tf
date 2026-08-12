variable "resource_group_name" {
  description = "Existing resource group for the SQL VMs."
  type        = string
}

variable "subnet_id" {
  description = "Existing subnet resource ID for the SQL VM NICs."
  type        = string
}

variable "availability_set_id" {
  description = "Existing Availability Set resource ID."
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
  description = "Azure region for the SQL VMs and Availability Set."
  type        = string
  default     = "canadacentral"
}

variable "workload_name" {
  description = "Workload naming segment."
  type        = string
  default     = "app"
}

variable "app_env" {
  description = "Deployment environment."
  type        = string
  default     = "prod"
}

variable "tags" {
  description = "Tags applied to SQL VM resources."
  type        = map(string)
  default     = {}
}
