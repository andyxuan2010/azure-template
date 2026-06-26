variable "name" {
  type        = string
  description = "Resource group name. If empty, the module auto-generates a name."
  default     = ""

  validation {
    condition     = var.name == "" || can(regex("^[a-zA-Z0-9._()\\-]{1,90}$", var.name))
    error_message = "name must be empty or 1-90 characters and contain only letters, digits, periods, underscores, hyphens, or parentheses."
  }
}

variable "name_prefix" {
  type        = string
  description = "Prefix used when the resource group name is generated."
  default     = "rg"

  validation {
    condition     = can(regex("^[a-zA-Z0-9._()\\-]{1,20}$", var.name_prefix))
    error_message = "name_prefix must be 1-20 characters and contain only letters, digits, periods, underscores, hyphens, or parentheses."
  }
}

variable "workload_name" {
  type        = string
  description = "Optional workload or application segment used when the resource group name is generated."
  default     = ""

  validation {
    condition     = var.workload_name == "" || can(regex("^[a-zA-Z0-9-]{1,40}$", var.workload_name))
    error_message = "workload_name must be empty or 1-40 characters using only letters, digits, or hyphens."
  }
}

variable "workload" {
  type        = string
  default     = "project"
  description = "Deprecated compatibility input. Supply workload tags explicitly through tags."

  validation {
    condition     = length(trimspace(var.workload)) > 0
    error_message = "workload cannot be empty."
  }
}

variable "app_env" {
  type        = string
  description = "Deployment environment used for standard tags and optional generated naming."
  default     = "dev"

  validation {
    condition     = contains(["prod", "staging", "dev", "qa", "sbx", "test", "poc"], var.app_env)
    error_message = "app_env must be one of: prod, staging, dev, qa, sbx, test, poc."
  }
}

variable "include_environment_in_name" {
  type        = bool
  description = "Whether to include app_env in generated resource group names."
  default     = true
}

variable "location_code" {
  type        = string
  description = "Optional short location code used when the resource group name is generated. When empty, the module derives a code from location."
  default     = ""

  validation {
    condition     = var.location_code == "" || can(regex("^[a-z0-9-]{2,20}$", var.location_code))
    error_message = "location_code must be empty or 2-20 lowercase letters, digits, or hyphens."
  }
}

variable "instance" {
  type        = string
  description = "Optional instance segment used when the resource group name is generated and random suffixes are disabled."
  default     = "001"

  validation {
    condition     = var.instance == "" || can(regex("^[a-zA-Z0-9-]{1,10}$", var.instance))
    error_message = "instance must be empty or 1-10 characters using only letters, digits, or hyphens."
  }
}

variable "use_random_suffix" {
  type        = bool
  description = "Whether generated names should include a random suffix. Set false for deterministic generated names."
  default     = true
}

variable "location" {
  type        = string
  description = "The Azure region where the resource group will be deployed."

  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "location cannot be empty."
  }
}

variable "enable_lock" {
  type        = bool
  description = "Whether to create a management lock on the resource group."
  default     = false
}

variable "lock_name" {
  type        = string
  description = "Optional management lock name. When empty, the module uses <resource-group-name>-lock."
  default     = ""

  validation {
    condition     = var.lock_name == "" || can(regex("^[a-zA-Z0-9._()\\-]{1,90}$", var.lock_name))
    error_message = "lock_name must be empty or 1-90 characters and contain only letters, digits, periods, underscores, hyphens, or parentheses."
  }
}

variable "lock_level" {
  type        = string
  description = "Management lock level when enable_lock is true."
  default     = "CanNotDelete"

  validation {
    condition     = contains(["CanNotDelete", "ReadOnly"], var.lock_level)
    error_message = "lock_level must be either CanNotDelete or ReadOnly."
  }
}

variable "lock_notes" {
  type        = string
  description = "Optional notes to attach to the management lock."
  default     = ""
}

variable "app_admin_group" {
  type        = list(string)
  description = "List of Entra group display names or object IDs that should receive Contributor access to the resource group. Prefer object IDs when display names are not unique."
  default     = []

  validation {
    condition = var.app_admin_group == null || alltrue([
      for value in var.app_admin_group :
      trimspace(value) != ""
    ])
    error_message = "app_admin_group must not contain empty values."
  }

  validation {
    condition = var.app_admin_group == null || length([
      for value in var.app_admin_group : trimspace(value)
      ]) == length(toset([
        for value in var.app_admin_group : trimspace(value)
    ]))
    error_message = "app_admin_group must not contain duplicate values after trimming whitespace."
  }
}

variable "app_user_group" {
  type        = list(string)
  description = "List of Entra group display names or object IDs that should receive Reader access to the resource group. Prefer object IDs when display names are not unique."
  default     = []

  validation {
    condition = var.app_user_group == null || alltrue([
      for value in var.app_user_group :
      trimspace(value) != ""
    ])
    error_message = "app_user_group must not contain empty values."
  }

  validation {
    condition = var.app_user_group == null || length([
      for value in var.app_user_group : trimspace(value)
      ]) == length(toset([
        for value in var.app_user_group : trimspace(value)
    ]))
    error_message = "app_user_group must not contain duplicate values after trimming whitespace."
  }
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource group."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

variable "managed_by" {
  type        = string
  description = "Optional resource ID that manages this resource group, typically used by Azure managed applications."
  default     = null

  validation {
    condition     = var.managed_by == null || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/.+$", var.managed_by))
    error_message = "managed_by must be null or a valid Azure resource ID."
  }
}

variable "role_assignments" {
  description = "Additional role assignments to create at the resource group scope, keyed by a stable name."
  type = map(object({
    principal_id                           = string
    role_definition_name                   = optional(string)
    role_definition_id                     = optional(string)
    principal_type                         = optional(string)
    description                            = optional(string)
    name                                   = optional(string)
    condition                              = optional(string)
    condition_version                      = optional(string)
    delegated_managed_identity_resource_id = optional(string)
    skip_service_principal_aad_check       = optional(bool, false)
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for assignment in var.role_assignments :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", assignment.principal_id))
    ])
    error_message = "Each role_assignments principal_id must be a valid GUID."
  }

  validation {
    condition = alltrue([
      for assignment in var.role_assignments :
      (try(trimspace(assignment.role_definition_name), "") != "") != (try(trimspace(assignment.role_definition_id), "") != "")
    ])
    error_message = "Each role_assignments entry must set exactly one of role_definition_name or role_definition_id."
  }

  validation {
    condition = alltrue([
      for assignment in var.role_assignments :
      assignment.principal_type == null || contains(["User", "Group", "ServicePrincipal", "ForeignGroup"], assignment.principal_type)
    ])
    error_message = "role_assignments principal_type must be null, User, Group, ServicePrincipal, or ForeignGroup."
  }

  validation {
    condition = alltrue([
      for assignment in var.role_assignments :
      assignment.name == null || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", assignment.name))
    ])
    error_message = "role_assignments name values must be null or valid GUIDs."
  }
}

variable "timeouts" {
  description = "Optional timeouts for resource group create, read, update, and delete operations."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}
