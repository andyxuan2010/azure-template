variable "name" {
  description = "Name of the custom policy definition or assignment."
  type        = string

  validation {
    condition     = trimspace(var.name) != ""
    error_message = "name cannot be empty."
  }
}

variable "display_name" {
  description = "Display name of the policy definition."
  type        = string

  validation {
    condition     = trimspace(var.display_name) != ""
    error_message = "display_name cannot be empty."
  }
}

variable "description" {
  description = "Optional description for the policy definition."
  type        = string
  default     = ""
}

variable "management_group_id" {
  description = "Optional management group ID used as the definition scope."
  type        = string
  default     = null
}

variable "policy_rule" {
  description = "JSON policy rule string."
  type        = string

  validation {
    condition     = can(jsondecode(var.policy_rule))
    error_message = "policy_rule must be valid JSON."
  }
}

variable "parameters" {
  description = "Optional JSON parameters schema string."
  type        = string
  default     = "{}"

  validation {
    condition     = can(jsondecode(var.parameters))
    error_message = "parameters must be valid JSON."
  }
}

variable "metadata" {
  description = "Optional JSON metadata string."
  type        = string
  default     = "{}"

  validation {
    condition     = can(jsondecode(var.metadata))
    error_message = "metadata must be valid JSON."
  }
}

variable "policy_type" {
  description = "Policy type for the definition."
  type        = string
  default     = "Custom"

  validation {
    condition     = contains(["BuiltIn", "Custom", "NotSpecified", "Static"], var.policy_type)
    error_message = "policy_type must be BuiltIn, Custom, NotSpecified, or Static."
  }
}

variable "mode" {
  description = "Policy mode."
  type        = string
  default     = "All"

  validation {
    condition     = trimspace(var.mode) != ""
    error_message = "mode cannot be empty."
  }
}

variable "create_assignment" {
  description = "Whether to create a policy assignment in the same module."
  type        = bool
  default     = false
}

variable "assignment_scope" {
  description = "Scope used for the assignment when create_assignment is true."
  type        = string
  default     = null

  validation {
    condition     = var.create_assignment ? try(trimspace(var.assignment_scope), "") != "" : true
    error_message = "assignment_scope must be set when create_assignment is true."
  }
}

variable "assignment_display_name" {
  description = "Optional display name for the policy assignment."
  type        = string
  default     = null
}

variable "assignment_description" {
  description = "Optional description for the policy assignment."
  type        = string
  default     = ""
}

variable "assignment_parameters" {
  description = "Optional JSON parameters for the policy assignment."
  type        = string
  default     = "{}"

  validation {
    condition     = can(jsondecode(var.assignment_parameters))
    error_message = "assignment_parameters must be valid JSON."
  }
}

variable "enforcement_mode" {
  description = "Whether the assignment should enforce policy or remain disabled."
  type        = bool
  default     = true
}

variable "location" {
  description = "Azure location required for assignments with identities."
  type        = string
  default     = null

  validation {
    condition     = var.identity_type != null ? try(trimspace(var.location), "") != "" : true
    error_message = "location must be set when identity_type is provided."
  }
}

variable "identity_type" {
  description = "Optional managed identity type for the assignment."
  type        = string
  default     = null

  validation {
    condition     = var.identity_type == null ? true : contains(["SystemAssigned"], var.identity_type)
    error_message = "identity_type must be null or SystemAssigned."
  }

  validation {
    condition     = var.identity_type != null ? var.create_assignment : true
    error_message = "identity_type can only be set when create_assignment is true."
  }
}
