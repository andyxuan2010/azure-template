variable "primary_namespace_name" {
  description = "Globally unique primary Event Hubs namespace name."
  type        = string
  default     = "evhns-stream-primary-prod-001"
}

variable "resource_group_name" {
  description = "Name of the existing primary resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the primary namespace."
  type        = string
  default     = "canadacentral"
}

variable "secondary_namespace_id" {
  description = "Resource ID of an existing secondary Event Hubs namespace."
  type        = string
}

variable "alias_name" {
  description = "Geo-Disaster Recovery alias name."
  type        = string
  default     = "evhns-stream-prod"
}
