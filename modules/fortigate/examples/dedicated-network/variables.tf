variable "resource_group_name" {
  description = "Name of the existing resource group receiving the dedicated network."
  type        = string
}

variable "location" {
  description = "Azure region for the dedicated network and FortiGate."
  type        = string
  default     = "canadacentral"
}

variable "name_prefix" {
  description = "Prefix used for FortiGate resource names."
  type        = string
  default     = "fgt-isolated-sbx"
}

variable "virtual_network_name" {
  description = "Name of the dedicated VNet."
  type        = string
  default     = "vnet-fortigate-sbx"
}

variable "admin_ssh_public_key" {
  description = "SSH public key used for private FortiGate administration."
  type        = string
  sensitive   = true
}
