variable "name" {
  description = "Name of the public Load Balancer."
  type        = string
  default     = "lb-orders-prod"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Load Balancer."
  type        = string
  default     = "canadacentral"
}

variable "public_ip_address_id" {
  description = "Resource ID of an existing Standard public IP."
  type        = string
}
