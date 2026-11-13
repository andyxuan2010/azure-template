variable "name" {
  description = "Name of the Network Security Group."
  type        = string
  default     = "nsg-orders-dev-001"
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

variable "gateway_subnet_prefix" {
  description = "Approved application gateway subnet CIDR."
  type        = string
  default     = "10.20.0.0/24"
}
