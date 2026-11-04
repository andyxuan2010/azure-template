variable "name" {
  description = "Globally unique Azure Databricks workspace name."
  type        = string
  default     = "dbw-lakehouse-prod-001"
}

variable "resource_group_name" {
  description = "Name of the existing workspace resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the workspace."
  type        = string
  default     = "canadacentral"
}

variable "virtual_network_id" {
  description = "Resource ID of the VNet containing the injection subnets."
  type        = string
}

variable "public_subnet_name" {
  description = "Name of the Databricks public injection subnet."
  type        = string
}

variable "private_subnet_name" {
  description = "Name of the Databricks private injection subnet."
  type        = string
}

variable "public_subnet_nsg_association_id" {
  description = "Resource ID of the public subnet NSG association."
  type        = string
}

variable "private_subnet_nsg_association_id" {
  description = "Resource ID of the private subnet NSG association."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Resource ID of the private-endpoint subnet."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Resource ID of the privatelink.azuredatabricks.net zone."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  type        = string
}

variable "platform_operator_principal_id" {
  description = "Optional Microsoft Entra group object ID for Azure read access."
  type        = string
  default     = null
}
