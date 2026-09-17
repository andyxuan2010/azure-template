variable "name" {
  description = "Azure Firewall name."
  type        = string
  default     = "afw-hub-prod-001"
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

variable "workload_source_cidrs" {
  description = "Workload CIDRs permitted by the example egress rules."
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "approved_destination_fqdns" {
  description = "Approved HTTPS destinations for the example workload."
  type        = list(string)
  default     = ["*.microsoft.com"]
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  type        = string
}

variable "operator_principal_id" {
  description = "Optional Microsoft Entra group object ID for read-only access."
  type        = string
  default     = null
}
