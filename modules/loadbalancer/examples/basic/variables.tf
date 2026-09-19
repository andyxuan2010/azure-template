variable "name" {
  description = "Name of the internal Load Balancer."
  type        = string
  default     = "lb-orders-dev"
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

variable "frontend_subnet_id" {
  description = "Resource ID of the existing frontend subnet."
  type        = string
}

variable "frontend_private_ip_address" {
  description = "Available static private IP address in the frontend subnet."
  type        = string
}
