variable "resource_group_name" {
  description = "Existing resource group for the Service Bus namespace."
  type        = string
}

variable "location" {
  description = "Azure region for the namespace."
  type        = string
  default     = "canadacentral"
}

variable "name" {
  description = "Globally unique Service Bus namespace name."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Existing Private Endpoint subnet ID."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Existing privatelink.servicebus.windows.net zone ID."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Existing Log Analytics workspace ID."
  type        = string
}

variable "app_admin_group_object_ids" {
  description = "Microsoft Entra group object IDs receiving namespace Contributor."
  type        = list(string)
  default     = []
}

variable "app_user_group_object_ids" {
  description = "Microsoft Entra group object IDs receiving namespace Reader."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to the namespace and Private Endpoint."
  type        = map(string)
  default = {
    Environment = "prod"
    ManagedBy   = "Terraform"
    Service     = "Messaging"
  }
}
