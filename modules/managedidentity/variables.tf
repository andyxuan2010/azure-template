variable "name" {
  description = "User-assigned managed identity name."
  type        = string

  validation {
    condition     = trimspace(var.name) != ""
    error_message = "name cannot be empty."
  }
}

variable "resource_group_name" {
  description = "Resource group where the managed identity will be created."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  description = "Azure region for the managed identity."
  type        = string

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location cannot be empty."
  }
}

variable "federated_identity_credentials" {
  description = "Map of federated identity credentials keyed by credential name."
  type = map(object({
    audience = list(string)
    issuer   = string
    subject  = string
  }))
  default = {}
}

variable "role_assignments" {
  description = "Map of role assignments keyed by assignment name."
  type = map(object({
    scope                = string
    role_definition_name = string
  }))
  default = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the managed identity."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}
