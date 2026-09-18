variable "assignments" {
  description = "Role assignments keyed by assignment name."
  type = map(object({
    scope                = string
    role_definition_name = optional(string)
    role_definition_id   = optional(string)
    principal_id         = optional(string)
    principal_name       = optional(string)
    principal_type       = optional(string)
    condition            = optional(string)
    condition_version    = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for _, assignment in var.assignments :
      trimspace(assignment.scope) != ""
    ])
    error_message = "Each assignment must define a non-empty scope."
  }
}

check "role_assignments_consistency" {
  assert {
    condition = alltrue([
      for _, assignment in var.assignments :
      (
        try(trimspace(assignment.role_definition_name), "") != "" ||
        try(trimspace(assignment.role_definition_id), "") != ""
        ) && (
        try(trimspace(assignment.principal_id), "") != "" ||
        try(trimspace(assignment.principal_name), "") != ""
      )
    ])
    error_message = "Each assignment must define a role_definition_name or role_definition_id, and a principal_id or principal_name."
  }

  assert {
    condition = alltrue([
      for _, assignment in var.assignments :
      !(
        try(trimspace(assignment.role_definition_name), "") != "" &&
        try(trimspace(assignment.role_definition_id), "") != ""
      )
    ])
    error_message = "Each assignment must define either role_definition_name or role_definition_id, but not both."
  }

  assert {
    condition = alltrue([
      for _, assignment in var.assignments :
      !(
        try(trimspace(assignment.principal_id), "") != "" &&
        try(trimspace(assignment.principal_name), "") != ""
      )
    ])
    error_message = "Each assignment must define either principal_id or principal_name, but not both."
  }

  assert {
    condition = alltrue([
      for _, assignment in var.assignments :
      contains(["", "User", "Group", "ServicePrincipal", "ForeignGroup", "Device"], try(trimspace(assignment.principal_type), ""))
    ])
    error_message = "principal_type must be User, Group, ServicePrincipal, ForeignGroup, Device, or omitted."
  }

  assert {
    condition = alltrue([
      for _, assignment in var.assignments :
      (try(trimspace(assignment.condition), "") == "") ==
      (try(trimspace(assignment.condition_version), "") == "")
    ])
    error_message = "condition and condition_version must be supplied together."
  }

  assert {
    condition = alltrue([
      for _, assignment in var.assignments :
      try(trimspace(assignment.condition_version), "") == "" ||
      assignment.condition_version == "2.0"
    ])
    error_message = "condition_version must be 2.0 when a condition is supplied."
  }

}
