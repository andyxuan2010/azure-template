variable "resource_group_name" {
  description = "Name of the existing resource group in which to create the registry."
  type        = string
}

variable "location" {
  description = "Azure region for the registry."
  type        = string
  default     = "canadacentral"
}

variable "app_env" {
  description = "Deployment environment used by module naming and tagging."
  type        = string
  default     = "dev"
}
