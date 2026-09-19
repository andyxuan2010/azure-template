variable "resource_group_name" {
  description = "Resource group containing the existing VNet."
  type        = string
}

variable "virtual_network_name" {
  description = "Existing VNet name."
  type        = string
}

variable "application_address_prefix" {
  description = "Network-aligned CIDR for the application subnet."
  type        = string
  default     = "10.20.1.0/24"
}

variable "data_address_prefix" {
  description = "Network-aligned CIDR for the data subnet."
  type        = string
  default     = "10.20.2.0/24"
}
