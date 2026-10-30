variable "resource_group_name" {
  description = "Existing resource group for the VNet."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Existing Log Analytics workspace resource ID."
  type        = string
}

variable "name" {
  description = "VNet name."
  type        = string
  default     = "vnet-spoke-prod"
}

variable "address_space" {
  description = "Non-overlapping VNet address spaces."
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "application_address_prefix" {
  description = "Application subnet CIDR."
  type        = string
  default     = "10.20.1.0/24"
}

variable "private_endpoint_address_prefix" {
  description = "Private endpoint subnet CIDR."
  type        = string
  default     = "10.20.2.0/24"
}

variable "dns_servers" {
  description = "Custom DNS resolver addresses."
  type        = list(string)
  default     = []
}

variable "app_admin_group_object_ids" {
  description = "Microsoft Entra group object IDs granted Contributor on the VNet."
  type        = list(string)
  default     = []
}

variable "app_user_group_object_ids" {
  description = "Microsoft Entra group object IDs granted Reader on the VNet."
  type        = list(string)
  default     = []
}

variable "location" {
  description = "Azure region for the VNet."
  type        = string
  default     = "canadacentral"
}

variable "inherited_resource_group_tags" {
  description = "Plan-known resource-group tags to inherit."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags applied to the VNet."
  type        = map(string)
  default     = {}
}
