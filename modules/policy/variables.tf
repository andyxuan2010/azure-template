variable "name" {
  description = "Optional name override for the custom policy definition or assignment. Leave empty to generate one from the global naming convention."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[A-Za-z0-9_.-]{1,64}$", trimspace(var.name)))
    error_message = "name must be empty or 1-64 characters using letters, numbers, underscores, periods, or hyphens."
  }
}

variable "display_name" {
  description = "Optional display name of the policy definition. Leave empty to use the effective policy name."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.display_name) == "" || length(trimspace(var.display_name)) <= 128
    error_message = "display_name must be empty or 128 characters or less."
  }
}

variable "workload" {
  description = "Workload identifier used when name is not provided."
  type        = string
  default     = "platform"

  validation {
    condition     = length(trimspace(var.workload)) > 0
    error_message = "workload cannot be empty."
  }
}

variable "app_env" {
  description = "Deployment environment used when name is not provided."
  type        = string
  default     = "dev"

  validation {
    condition     = length(trimspace(var.app_env)) > 0
    error_message = "app_env cannot be empty."
  }
}

variable "instance" {
  description = "Instance identifier used when name is not provided."
  type        = string
  default     = "001"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,12}$", trimspace(var.instance)))
    error_message = "instance must be 1-12 lowercase letters, numbers, or hyphens."
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

variable "assignment_metadata" {
  description = "Optional JSON metadata for the policy assignment."
  type        = string
  default     = "{}"

  validation {
    condition     = can(jsondecode(var.assignment_metadata))
    error_message = "assignment_metadata must be valid JSON."
  }
}

variable "assignment_not_scopes" {
  description = "Optional child scopes excluded from policy evaluation."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for scope in var.assignment_not_scopes : startswith(scope, "/")])
    error_message = "assignment_not_scopes must contain Azure resource IDs."
  }
}

variable "non_compliance_messages" {
  description = "Optional non-compliance messages for the assignment."
  type = list(object({
    content                        = string
    policy_definition_reference_id = optional(string)
  }))
  default = []

  validation {
    condition     = alltrue([for message in var.non_compliance_messages : trimspace(message.content) != ""])
    error_message = "non_compliance_messages content cannot be empty."
  }
}

variable "assignment_timeouts" {
  description = "Optional create/read/update/delete timeouts for the assignment."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
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

check "policy_input_consistency" {
  assert {
    condition     = !var.create_assignment || local.assignment_scope_kind != "unsupported"
    error_message = "assignment_scope must be a management group, subscription, or resource group resource ID."
  }

  assert {
    condition     = var.create_assignment || length(var.assignment_not_scopes) == 0
    error_message = "assignment_not_scopes can only be set when create_assignment is true."
  }

  assert {
    condition     = var.create_assignment || length(var.non_compliance_messages) == 0
    error_message = "non_compliance_messages can only be set when create_assignment is true."
  }
}
