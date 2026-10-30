variable "role_definition_scope" {
  description = "Existing resource group ID where the role definition is managed and made assignable."
  type        = string
}

variable "assignment_scope" {
  description = "Resource group or route table ID where the custom role is granted."
  type        = string
}

variable "managed_identity_principal_id" {
  description = "Object/principal ID of the existing managed identity. Do not use its client ID or resource ID."
  type        = string
}
