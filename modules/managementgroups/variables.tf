variable "name" {
  description = "Management group ID. If empty, a unique ID is generated from display_name."
  type        = string
  default     = ""

  validation {
    condition     = var.name == "" || can(regex("^[A-Za-z0-9._()\\-]{1,90}$", var.name))
    error_message = "name must be empty or 1-90 characters using letters, numbers, periods, underscores, hyphens, or parentheses."
  }
}

variable "display_name" {
  description = "Display name of the management group."
  type        = string

  validation {
    condition     = trimspace(var.display_name) != ""
    error_message = "display_name cannot be empty."
  }
}

variable "parent_management_group_id" {
  description = "Optional parent management group resource ID."
  type        = string
  default     = null

  validation {
    condition = (
      var.parent_management_group_id == null ||
      try(trimspace(var.parent_management_group_id), "") == "" ||
      can(regex("^/providers/Microsoft\\.Management/managementGroups/[^/]+$", var.parent_management_group_id))
    )
    error_message = "parent_management_group_id must be null, empty, or a valid management group resource ID."
  }
}

variable "subscription_ids" {
  description = "Optional list of subscription IDs to associate with the management group."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for value in var.subscription_ids :
      can(regex("^[0-9a-fA-F-]{36}$", value))
    ])
    error_message = "subscription_ids must contain only Azure subscription GUIDs."
  }
}

variable "app_env" {
  description = "Deployment environment used for the generated Environment tag."
  type        = string
  default     = "dev"

  validation {
    condition     = length(trimspace(var.app_env)) > 0
    error_message = "app_env cannot be empty."
  }
}

variable "workload" {
  description = "Workload identifier used in tagging."
  type        = string
  default     = "platform"

  validation {
    condition     = length(trimspace(var.workload)) > 0
    error_message = "workload cannot be empty."
  }
}

variable "tags" {
  description = "Optional tags exposed as metadata for documentation and downstream consumers."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}
