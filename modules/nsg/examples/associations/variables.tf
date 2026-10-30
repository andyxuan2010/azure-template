variable "name" {
  description = "Name of the Network Security Group."
  type        = string
  default     = "nsg-shared-prod-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the NSG."
  type        = string
  default     = "canadacentral"
}

variable "application_subnet_id" {
  description = "Resource ID of the subnet associated with the NSG."
  type        = string
}

variable "management_network_interface_id" {
  description = "Resource ID of the NIC associated with the NSG."
  type        = string
}
