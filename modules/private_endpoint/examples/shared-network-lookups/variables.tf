variable "resource_group_name" {
  description = "Existing workload resource group for the Private Endpoint."
  type        = string
}

variable "location" {
  description = "Azure region for the Private Endpoint."
  type        = string
  default     = "canadacentral"
}

variable "private_connection_resource_id" {
  description = "Target PaaS resource ID."
  type        = string
}

variable "subresource_name" {
  description = "Target service subresource name."
  type        = string
  default     = "vault"
}

variable "subnet_name" {
  description = "Shared Private Endpoint subnet name."
  type        = string
  default     = "snet-private-endpoints"
}

variable "virtual_network_name" {
  description = "Shared virtual network name."
  type        = string
}

variable "virtual_network_resource_group_name" {
  description = "Shared virtual network resource group."
  type        = string
}

variable "private_dns_zone_name" {
  description = "Shared Private DNS zone name."
  type        = string
  default     = "privatelink.vaultcore.azure.net"
}

variable "private_dns_zone_resource_group_name" {
  description = "Shared Private DNS zone resource group."
  type        = string
}

variable "workload" {
  description = "Workload segment used for generated naming."
  type        = string
  default     = "application"
}

variable "environment" {
  description = "Environment segment used for generated naming."
  type        = string
  default     = "prod"
}

variable "instance" {
  description = "Instance segment used for generated naming."
  type        = string
  default     = "001"
}
