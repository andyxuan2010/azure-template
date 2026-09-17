variable "resource_group_name" {
  description = "Name of the existing network resource group."
  type        = string
}

variable "location" {
  description = "Azure region for FortiGate."
  type        = string
  default     = "canadacentral"
}

variable "name_prefix" {
  description = "Prefix used for FortiGate resource names."
  type        = string
  default     = "fgt-hub-dev"
}

variable "admin_ssh_public_key" {
  description = "SSH public key used for private FortiGate administration."
  type        = string
  sensitive   = true
}

variable "external_subnet_id" {
  description = "Resource ID of the external-side private subnet."
  type        = string
}

variable "internal_subnet_id" {
  description = "Resource ID of the internal-side private subnet."
  type        = string
}

variable "external_private_ip_address" {
  description = "Static external-side NIC address."
  type        = string
  default     = "10.20.0.4"
}

variable "internal_private_ip_address" {
  description = "Static internal-side NIC address."
  type        = string
  default     = "10.20.1.4"
}
