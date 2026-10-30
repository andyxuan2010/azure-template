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
  default     = "fgt-hub-prod"
}

variable "admin_ssh_public_key" {
  description = "SSH public key used for private FortiGate administration."
  type        = string
  sensitive   = true
}

variable "external_subnet_id" {
  description = "Resource ID of the external-side subnet."
  type        = string
}

variable "internal_subnet_id" {
  description = "Resource ID of the internal-side subnet."
  type        = string
}

variable "ha_subnet_id" {
  description = "Resource ID of the dedicated HA subnet."
  type        = string
}

variable "management_subnet_id" {
  description = "Resource ID of the private management subnet."
  type        = string
}

variable "availability_zones" {
  description = "FortiGate instance zones supported in the target region."
  type        = map(string)
  default = {
    a = "1"
    b = "2"
  }
}

variable "load_balancer_frontend_zones" {
  description = "Zones for the private load-balancer frontends."
  type        = list(string)
  default     = ["1", "2", "3"]
}
