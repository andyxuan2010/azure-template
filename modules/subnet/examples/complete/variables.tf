variable "resource_group_name" {
  description = "Resource group containing the existing VNet."
  type        = string
}

variable "virtual_network_name" {
  description = "Existing VNet name."
  type        = string
}

variable "virtual_network_id" {
  description = "Existing VNet resource ID used as the RBAC scope."
  type        = string
}

variable "network_security_group_id" {
  description = "Existing NSG resource ID for the application subnet."
  type        = string
}

variable "route_table_id" {
  description = "Existing route table resource ID for the application subnet."
  type        = string
}

variable "application_address_prefix" {
  description = "Network-aligned CIDR for the application subnet."
  type        = string
  default     = "10.20.1.0/24"
}

variable "private_endpoint_address_prefix" {
  description = "Network-aligned CIDR for the private endpoint subnet."
  type        = string
  default     = "10.20.2.0/24"
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
