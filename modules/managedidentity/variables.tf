variable "name" {
  description = "User-assigned managed identity name."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9-_]{3,128}$", trimspace(var.name)))
    error_message = "name must be 3-128 characters using letters, numbers, hyphens, or underscores."
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
    condition     = can(regex("^[a-z0-9-]+$", trimspace(var.location)))
    error_message = "location must be a valid Azure region identifier."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into managed identity resources."
  default     = true
}

variable "inherited_resource_group_tags" {
  type        = map(string)
  description = "Optional plan-known resource group tags supplied by the root composition. When null and inherit_resource_group_tags is true, the module falls back to reading the resource group."
  default     = null
}

variable "workload" {
  type        = string
  default     = "project"
  description = "Workload identifier used in tagging."

  validation {
    condition     = length(trimspace(var.workload)) > 0
    error_message = "workload cannot be empty."
  }
}

variable "app_env" {
  type        = string
  default     = "dev"
  description = "Deployment environment metadata retained for interface compatibility."

  validation {
    condition     = contains(["prod", "staging", "dev", "qa", "sbx", "poc", "test"], var.app_env)
    error_message = "app_env must be one of: prod, staging, dev, qa, sbx, poc, test."
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

  validation {
    condition = alltrue([
      for name, credential in var.federated_identity_credentials :
      can(regex("^[A-Za-z0-9-_]{3,120}$", name)) &&
      length(credential.audience) > 0 &&
      length(distinct([for audience in credential.audience : trimspace(audience)])) == length(credential.audience) &&
      alltrue([for audience in credential.audience : trimspace(audience) != ""]) &&
      can(regex("^https://", trimspace(credential.issuer))) &&
      trimspace(credential.subject) != ""
    ])
    error_message = "Federated credentials require a valid 3-120 character name, unique non-empty audiences, an HTTPS issuer, and a non-empty subject."
  }
}

variable "role_assignments" {
  description = "Map of role assignments keyed by assignment name."
  type = map(object({
    scope                = string
    role_definition_name = optional(string)
    role_definition_id   = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for assignment in values(var.role_assignments) :
      can(regex("^/subscriptions/.+", assignment.scope)) &&
      (
        (try(trimspace(assignment.role_definition_name), "") != "") !=
        (try(trimspace(assignment.role_definition_id), "") != "")
      )
    ])
    error_message = "Role assignments require a valid Azure scope and exactly one of role_definition_name or role_definition_id."
  }
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
