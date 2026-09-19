variable "name" {
  description = "Globally unique Azure OpenAI account and subdomain name."
  type        = string
  default     = "oai-orders-prod-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure OpenAI-supported Azure region."
  type        = string
  default     = "canadacentral"
}

variable "deployments" {
  description = "Reviewed Azure OpenAI deployments supported by the selected region and available quota."
  type = map(object({
    model_format           = string
    model_name             = string
    model_version          = optional(string)
    sku_name               = string
    sku_capacity           = optional(number)
    version_upgrade_option = optional(string)
  }))
}

variable "private_endpoint_subnet_id" {
  description = "Resource ID of the existing private endpoint subnet."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Resource ID of the existing privatelink.openai.azure.com zone."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the existing Log Analytics workspace."
  type        = string
}

variable "admin_group_object_ids" {
  description = "Microsoft Entra group object IDs granted the configured Azure OpenAI admin role."
  type        = list(string)
  default     = []
}

variable "user_group_object_ids" {
  description = "Microsoft Entra group object IDs granted Cognitive Services OpenAI User."
  type        = list(string)
  default     = []
}
