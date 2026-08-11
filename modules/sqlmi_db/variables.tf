variable "app_sqlmi" {
  description = "Name of the SQL Managed Instance to reference"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]{1,63}$", var.app_sqlmi))
    error_message = "Managed Instance name must be 1-63 chars, lowercase letters, numbers, and hyphens only."
  }
}

variable "name" {
  description = "Optional managed database name override. Leave empty to generate one from the global naming convention."
  type        = string
  default     = ""
  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[a-zA-Z0-9_-]{1,128}$", trimspace(var.name)))
    error_message = "name must be empty or 1-128 chars, alphanumeric, underscore, hyphen only."
  }
}

variable "app_sqlmi_db" {
  description = "Deprecated alias for name. Use name for the managed database name override."
  type        = string
  default     = ""
  validation {
    condition     = trimspace(var.app_sqlmi_db) == "" || can(regex("^[a-zA-Z0-9_-]{1,128}$", trimspace(var.app_sqlmi_db)))
    error_message = "app_sqlmi_db must be empty or 1-128 chars, alphanumeric, underscore, hyphen only."
  }
}

variable "app_sqlmi_rg" {
  description = "Resource group where the managed instance resides"
  type        = string
  validation {
    condition     = can(regex("^[A-Za-z0-9._()/-]{1,90}$", var.app_sqlmi_rg))
    error_message = "Managed Instance resource group must be 1-90 chars and use valid Azure resource group name characters."
  }
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
  description = "Deployment environment used when name is not provided."

  validation {
    condition     = contains(["prod", "staging", "dev", "qa", "sbx", "poc", "test"], var.app_env)
    error_message = "app_env must be one of: prod, staging, dev, qa, sbx, poc, test."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the SQL Managed Instance resource group into SQL Managed Database resources."
  default     = true
}

variable "inherited_resource_group_tags" {
  type        = map(string)
  description = "Optional plan-known resource group tags supplied by the root composition. When null and inherit_resource_group_tags is true, the module falls back to reading the SQL Managed Instance resource group."
  default     = null
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

variable "tags" {
  type        = map(string)
  description = "Additional resource-specific tags applied to the SQL Managed Database. These override inherited resource group tags."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "tags must contain only non-empty keys and values."
  }
}

variable "app_admin_group" {
  description = "List of Microsoft Entra group display names or object IDs that should receive Contributor access to the SQL Managed Database resource."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for value in var.app_admin_group : trimspace(value) != ""])
    error_message = "app_admin_group cannot contain empty values."
  }
}

variable "app_user_group" {
  description = "List of Microsoft Entra group display names or object IDs that should receive Reader access to the SQL Managed Database resource."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for value in var.app_user_group : trimspace(value) != ""])
    error_message = "app_user_group cannot contain empty values."
  }
}

# variable "cicdvms" {
#   type    = list(string)
#   default = ["AZUWASHA001", "AZULASHA001"]
# }

# Diagnostics
variable "enable_diagnostics" {
  description = "Enable diagnostic settings for the managed database"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics (resource ID)"
  type        = string
  default     = ""
  validation {
    condition     = var.log_analytics_workspace_id == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.OperationalInsights/workspaces/.+$", var.log_analytics_workspace_id))
    error_message = "Workspace ID must be empty or a valid Azure resource ID."
  }
}

variable "diagnostic_log_categories" {
  description = "Diagnostic log categories to enable for the managed database."
  type        = list(string)
  default     = ["SQLSecurityAuditEvents"]

  validation {
    condition = alltrue([
      for value in var.diagnostic_log_categories :
      trimspace(value) != "" && contains(["SQLSecurityAuditEvents"], value)
    ])
    error_message = "diagnostic_log_categories must contain only supported SQL Managed Database log categories."
  }
}

variable "diagnostic_metric_categories" {
  description = "Diagnostic metric categories to enable for the managed database."
  type        = list(string)
  default     = ["AllMetrics"]

  validation {
    condition = alltrue([
      for value in var.diagnostic_metric_categories :
      trimspace(value) != "" && contains(["AllMetrics"], value)
    ])
    error_message = "diagnostic_metric_categories must contain only supported SQL Managed Database metric categories."
  }
}

check "sqlmi_db_input_consistency" {
  assert {
    condition     = !var.enable_diagnostics || trimspace(var.log_analytics_workspace_id) != ""
    error_message = "log_analytics_workspace_id must be set when enable_diagnostics is true."
  }
}
