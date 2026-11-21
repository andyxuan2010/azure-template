variable "name" {
  description = "Azure Firewall name."
  type        = string
  default     = "afw-hub-dev-001"
}

variable "resource_group_name" {
  description = "Name of the existing network resource group."
  type        = string
}

variable "location" {
  description = "Azure region for Azure Firewall."
  type        = string
  default     = "canadacentral"
}

variable "azure_firewall_subnet_id" {
  description = "Resource ID of the dedicated AzureFirewallSubnet."
  type        = string
}

variable "zones" {
  description = "Availability zones supported in the target region."
  type        = list(string)
  default     = ["1", "2", "3"]
}
