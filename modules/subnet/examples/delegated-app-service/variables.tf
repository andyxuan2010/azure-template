variable "resource_group_name" {
  description = "Resource group containing the existing VNet."
  type        = string
}

variable "virtual_network_name" {
  description = "Existing VNet name."
  type        = string
}

variable "address_prefix" {
  description = "Network-aligned CIDR for the delegated subnet."
  type        = string
  default     = "10.20.3.0/24"
}
