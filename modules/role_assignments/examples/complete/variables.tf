variable "subscription_id" {
  description = "Subscription resource ID used as the Reader assignment scope."
  type        = string
}

variable "resource_group_id" {
  description = "Resource group ID used as the Contributor assignment scope."
  type        = string
}

variable "platform_reader_group_name" {
  description = "Unique Entra group display name resolved to an object ID."
  type        = string
}

variable "contributor_role_definition_id" {
  description = "Contributor or custom role definition resource ID."
  type        = string
}

variable "application_principal_id" {
  description = "Service principal or managed identity object ID."
  type        = string
}
