variable "name" {
  description = "Application Gateway name."
  type        = string
  default     = "agw-platform-dev"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Application Gateway."
  type        = string
  default     = "canadacentral"
}

variable "subnet_id" {
  description = "Resource ID of the dedicated Application Gateway subnet."
  type        = string
}

variable "backend_ip_addresses" {
  description = "Backend IP addresses reachable from the gateway subnet."
  type        = list(string)
  default     = ["192.0.2.10"]
}
