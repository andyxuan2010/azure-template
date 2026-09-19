variable "name" {
  description = "Globally unique Azure AI Search service name."
  type        = string
  default     = "srch-firewall-dev-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for Azure AI Search."
  type        = string
  default     = "canadacentral"
}

variable "allowed_ips" {
  description = "Trusted public IPv4 addresses or CIDR ranges. Replace the documentation range before use."
  type        = list(string)
  default     = ["203.0.113.0/24"]
}
