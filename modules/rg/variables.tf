variable "name" {
  type        = string
  description = "Resource group name. If empty, the module auto-generates a name."
  default     = ""

  validation {
    condition     = var.name == "" || can(regex("^[a-zA-Z0-9._()\\-]{1,90}$", var.name))
    error_message = "name must be empty or 1-90 characters and contain only letters, digits, periods, underscores, hyphens, or parentheses."
  }
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
  default     = null

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
  default     = null

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
