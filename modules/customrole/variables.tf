variable "name" {
  description = "Display name of the custom role definition."
  type        = string

  validation {
    condition     = trimspace(var.name) != ""
    error_message = "name must not be empty."
  }
}

variable "scope" {
  description = "Management group, subscription, resource group, or resource ID where the role definition is managed."
  type        = string

  validation {
    condition     = startswith(trimspace(var.scope), "/")
    error_message = "scope must be an Azure resource ID beginning with '/'."
  }
}

variable "description" {
  description = "Description of the permissions and intended use of the custom role."
  type        = string

  validation {
    condition     = trimspace(var.description) != ""
    error_message = "description must not be empty."
  }
}

variable "actions" {
  description = "Allowed Azure control-plane actions for the role."
  type        = list(string)
  default     = []
}

variable "not_actions" {
  description = "Control-plane actions excluded from actions."
  type        = list(string)
  default     = []
}

variable "data_actions" {
  description = "Allowed Azure data-plane actions for the role."
  type        = list(string)
  default     = []
}

variable "not_data_actions" {
  description = "Data-plane actions excluded from data_actions."
  type        = list(string)
  default     = []
}

variable "assignable_scopes" {
  description = "Scopes where this role may be assigned. Include the role definition scope."
  type        = list(string)

  validation {
    condition = (
      length(var.assignable_scopes) > 0 &&
      alltrue([for scope in var.assignable_scopes : startswith(trimspace(scope), "/")]) &&
      contains(var.assignable_scopes, var.scope)
    )
    error_message = "assignable_scopes must contain Azure resource IDs and include scope."
  }
}

variable "role_definition_id" {
  description = "Optional stable UUID/GUID for the role definition. Azure generates one when omitted."
  type        = string
  default     = null

  validation {
    condition = var.role_definition_id == null ? true : can(regex(
      "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$",
      var.role_definition_id
    ))
    error_message = "role_definition_id must be a UUID/GUID when specified."
  }
}

check "permissions_configured" {
  assert {
    condition     = length(var.actions) + length(var.data_actions) > 0
    error_message = "At least one actions or data_actions entry is required."
  }
}
