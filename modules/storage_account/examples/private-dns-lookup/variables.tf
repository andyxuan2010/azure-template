variable "resource_group_name" {
  description = "Existing resource group for the Storage account."
  type        = string
}

variable "name" {
  description = "Globally unique Storage account name."
  type        = string
}

variable "private_endpoint_subnet_name" {
  description = "Existing private-endpoint subnet name."
  type        = string
}

variable "private_endpoint_vnet_name" {
  description = "Existing VNet name containing the private-endpoint subnet."
  type        = string
}

variable "private_endpoint_network_resource_group_name" {
  description = "Resource group containing the VNet."
  type        = string
}

variable "private_dns_zone_resource_group_name" {
  description = "Resource group containing the shared Blob private DNS zone."
  type        = string
}

variable "location" {
  description = "Azure region for the Storage account."
  type        = string
  default     = "canadacentral"
}

variable "tags" {
  description = "Tags applied to Storage resources."
  type        = map(string)
  default     = {}
}
