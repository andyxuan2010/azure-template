variable "name" {
  description = "Globally unique Azure AI Services account name."
  type        = string
  default     = "ais-platform-prod-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for Azure AI Services and the model deployment."
  type        = string
  default     = "canadacentral"
}

variable "private_endpoint_subnet_id" {
  description = "Resource ID of the private-endpoint subnet."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Resource ID of the private DNS zone selected for the account kind."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  type        = string
}

variable "workload_principal_id" {
  description = "Optional application service-principal object ID for data-plane access."
  type        = string
  default     = null
}

variable "deployment_name" {
  description = "Stable model deployment name consumed by applications."
  type        = string
  default     = "chat"
}

variable "model_name" {
  description = "Model name available in the target region."
  type        = string
  default     = "gpt-4o-mini"
}

variable "model_version" {
  description = "Model version available in the target region."
  type        = string
  default     = "2024-07-18"
}

variable "deployment_sku_name" {
  description = "Deployment SKU supported for the selected model."
  type        = string
  default     = "GlobalStandard"
}

variable "deployment_capacity" {
  description = "Deployment capacity in provider-defined units."
  type        = number
  default     = 10
}

variable "version_upgrade_option" {
  description = "Model version upgrade behavior."
  type        = string
  default     = "OnceNewDefaultVersionAvailable"
}
