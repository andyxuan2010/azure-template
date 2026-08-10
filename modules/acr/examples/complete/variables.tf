variable "resource_group_name" {
  description = "Name of the existing resource group in which to create the registry."
  type        = string
}

variable "location" {
  description = "Primary Azure region for the registry."
  type        = string
  default     = "canadacentral"
}

variable "secondary_location" {
  description = "Secondary Azure region for geo-replication."
  type        = string
  default     = "canadaeast"
}

variable "registry_name" {
  description = "Globally unique, alphanumeric Azure Container Registry name."
  type        = string
}

variable "app_env" {
  description = "Deployment environment used by module naming and tagging."
  type        = string
  default     = "prod"
}

variable "private_endpoint_subnet_id" {
  description = "Resource ID of the existing private endpoint subnet."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Resource ID of the existing privatelink.azurecr.io private DNS zone."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace used for diagnostics."
  type        = string
}
