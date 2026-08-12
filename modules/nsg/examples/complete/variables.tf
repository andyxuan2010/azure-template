variable "name" {
  description = "Name of the Network Security Group."
  type        = string
  default     = "nsg-orders-prod-001"
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
}

variable "application_subnet_id" {
  description = "Resource ID of the application subnet owned by this NSG association."
  type        = string
}
