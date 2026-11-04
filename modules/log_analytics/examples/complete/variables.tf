variable "name" {
  description = "Optional Log Analytics workspace name override. Leave empty to generate one from the naming convention."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[A-Za-z0-9-]{4,63}$", trimspace(var.name)))
    error_message = "name must be empty or 4-63 characters using letters, numbers, or hyphens."
  }
  nullable = false
}

variable "resource_group_name" {
  description = "Resource group where the workspace will be created."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  description = "Azure region for the workspace."
  type        = string

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location cannot be empty."
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
  nullable = false
}

variable "app_env" {
  type        = string
  default     = "dev"
  description = "Deployment environment retained for naming and policy compatibility."

  validation {
    condition     = contains(["prod", "staging", "dev", "qa", "sbx", "poc", "test"], var.app_env)
    error_message = "app_env must be one of: prod, staging, dev, qa, sbx, poc, test."
  }
  nullable = false
}

variable "tags" {
  description = "Tags applied to the workspace."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
  nullable = false
}
