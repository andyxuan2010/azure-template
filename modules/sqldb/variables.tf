variable "sql_server_name" {
  description = "Name of the SQL Server (must be globally unique)"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]{1,63}$", var.sql_server_name))
    error_message = "SQL Server name must be 1-63 chars, lowercase letters, numbers, and hyphens only."
  }
}

variable "sql_database_name" {
  description = "Name of the SQL Database"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,128}$", var.sql_database_name))
    error_message = "Database name must be 1-128 chars, alphanumeric, underscore, hyphen only."
  }
}

variable "sql_max_size_gb" {
  description = "Maximum size of the database in GB"
  type        = number
  validation {
    condition     = var.sql_max_size_gb > 0 && var.sql_max_size_gb <= 4096
    error_message = "Database max size must be between 1 and 4096 GB."
  }
}

variable "sql_server_version" {
  description = "SQL Server version"
  type        = string
  default     = "12.0"
  validation {
    condition     = contains(["12.0"], var.sql_server_version)
    error_message = "SQL Server version must be 12.0 (SQL Server 2014) or later."
  }
}

variable "sql_collation" {
  description = "Database collation setting"
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
  validation {
    condition     = can(regex("^[A-Za-z0-9_]+$", var.sql_collation))
    error_message = "Collation must be a valid SQL Server collation."
  }
}

variable "sql_zone_redundant" {
  description = "Whether the database is zone redundant"
  type        = bool
  default     = false
}

variable "sql_admin_username" {
  description = "Admin username for SQL Server"
  type        = string
  validation {
    condition     = length(var.sql_admin_username) > 0 && can(regex("^[a-zA-Z][a-zA-Z0-9_@.-]{0,127}$", var.sql_admin_username))
    error_message = "Admin username must start with letter and be 1-128 chars."
  }
  sensitive = true
}

variable "sql_admin_password" {
  description = "Admin password for SQL Server"
  type        = string
  validation {
    condition     = length(var.sql_admin_password) >= 8
    error_message = "Admin password must be at least 8 characters long."
  }
  sensitive = true
}

variable "sql_ad_admin" {
  description = "AD Admin username for SQL Server"
  type        = string
  validation {
    condition     = length(var.sql_ad_admin) > 0
    error_message = "AD Admin username cannot be empty."
  }
}

variable "sql_ad_admin_id" {
  description = "AD Admin id (Object ID) for SQL Server"
  type        = string
  validation {
    condition     = can(regex("^[0-9a-f-]{36}$", var.sql_ad_admin_id))
    error_message = "AD Admin ID must be a valid Azure Object ID (UUID format)."
  }
}

variable "sql_sku_name" {
  description = "SKU for the SQL Database (e.g., S0, S1, P1, GP_Gen5_2)"
  type        = string
  validation {
    condition     = can(regex("^(S[0-2]|P[1-6]|GP_Gen[45]|BC_Gen[45]|HS_Gen[45]|DW|DC)\\d*$", var.sql_sku_name))
    error_message = "SKU must be a valid SQL Database SKU (e.g., S0, S1, P1, GP_Gen5_2)."
  }
}

variable "sql_rg_name" {
  description = "Resource Group for SQL resources"
  type        = string
  validation {
    condition     = trimspace(var.sql_rg_name) != "" && can(regex("^[a-zA-Z0-9._()-]{1,90}$", var.sql_rg_name))
    error_message = "Resource group name must be 1-90 chars, alphanumeric, period, underscore, hyphen, parentheses."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = ""
  validation {
    condition     = var.location == "" || can(regex("^[a-z0-9-]+$", var.location))
    error_message = "Location must be empty or a valid Azure region identifier."
  }
}

variable "app_env" {
  description = "Deployment environment (dev, staging, prod, sbx, test, qa)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod", "sbx", "test", "qa"], var.app_env)
    error_message = "Environment must be one of: dev, staging, prod, sbx, test, qa."
  }
}

variable "tags" {
  description = "Customized tags for resources"
  type        = map(string)
  default     = {}
  validation {
    condition = alltrue([
      for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""
    ])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

variable "app_admin_group" {
  description = "List of Microsoft Entra group display names or object IDs that should receive Contributor access to the SQL Server resource."
  type        = list(string)
  default     = []
}

variable "app_user_group" {
  description = "List of Microsoft Entra group display names or object IDs that should receive Reader access to the SQL Server resource."
  type        = list(string)
  default     = []
}

variable "enable_private_endpoint" {
  description = "Whether to enable private endpoint for SQL Server"
  type        = bool
  default     = true
}
variable "private_endpoint_subnet_id" {
  description = "Subnet ID for the private endpoint"
  type        = string
  default     = ""
  validation {
    condition     = var.private_endpoint_subnet_id == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/.+$", var.private_endpoint_subnet_id))
    error_message = "Subnet ID must be empty or a valid Azure resource ID."
  }
}

variable "public_network_enabled" {
  description = "Enable public network access to SQL Server"
  type        = bool
  default     = false
}

variable "sql_minimum_tls_version" {
  description = "Minimum TLS version for SQL Server (1.0, 1.1, 1.2)"
  type        = string
  default     = "1.2"
  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.sql_minimum_tls_version)
    error_message = "Minimum TLS version must be 1.0, 1.1, or 1.2."
  }
}

# Backup & Disaster Recovery
variable "backup_retention_days" {
  description = "Backup retention period in days (7-35)"
  type        = number
  default     = 7
  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "Backup retention must be between 7 and 35 days."
  }
}

variable "enable_long_term_retention" {
  description = "Enable long-term retention backups"
  type        = bool
  default     = false
}

variable "long_term_retention_policy" {
  description = "Long-term retention policy (weekly, monthly, yearly backups to keep)"
  type = object({
    weekly_retention  = optional(number, 0)
    monthly_retention = optional(number, 0)
    yearly_retention  = optional(number, 0)
  })
  default = {}
  validation {
    condition = alltrue([
      var.long_term_retention_policy.weekly_retention >= 0 && var.long_term_retention_policy.weekly_retention <= 520,
      var.long_term_retention_policy.monthly_retention >= 0 && var.long_term_retention_policy.monthly_retention <= 120,
      var.long_term_retention_policy.yearly_retention >= 0 && var.long_term_retention_policy.yearly_retention <= 10,
    ])
    error_message = "LTR values: weekly 0-520, monthly 0-120, yearly 0-10."
  }
}

# Threat Detection & Audit
variable "enable_threat_detection" {
  description = "Enable threat detection for the database"
  type        = bool
  default     = true
}

variable "enable_audit" {
  description = "Enable audit logging for SQL Server"
  type        = bool
  default     = true
}

variable "audit_retention_days" {
  description = "Audit log retention in days (0=indefinite, 1-2147483647)"
  type        = number
  default     = 30
  validation {
    condition     = var.audit_retention_days == 0 || (var.audit_retention_days >= 1 && var.audit_retention_days <= 2147483647)
    error_message = "Audit retention must be 0 (indefinite) or 1-2147483647 days."
  }
}

# Monitoring & Diagnostics
variable "enable_diagnostics" {
  description = "Enable diagnostic settings for the database"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics (required if enable_diagnostics=true)"
  type        = string
  default     = ""
  validation {
    condition     = var.log_analytics_workspace_id == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.OperationalInsights/workspaces/.+$", var.log_analytics_workspace_id))
    error_message = "Workspace ID must be empty or a valid Azure resource ID."
  }
}

variable "diagnostic_log_categories" {
  description = "Diagnostic log categories to enable for the SQL database."
  type        = list(string)
  default = [
    "SQLInsights",
    "AutomaticTuning",
    "QueryStoreRuntimeStatistics",
    "QueryStoreWaitStatistics",
    "Errors",
  ]

  validation {
    condition = alltrue([
      for value in var.diagnostic_log_categories :
      contains(["SQLInsights", "AutomaticTuning", "QueryStoreRuntimeStatistics", "QueryStoreWaitStatistics", "Errors"], value)
    ])
    error_message = "diagnostic_log_categories must contain only supported Azure SQL Database log categories."
  }

  validation {
    condition     = alltrue([for value in var.diagnostic_log_categories : trimspace(value) != ""])
    error_message = "diagnostic_log_categories cannot contain empty values."
  }
}

variable "diagnostic_metric_categories" {
  description = "Diagnostic metric categories to enable for the SQL database."
  type        = list(string)
  default     = ["AllMetrics"]

  validation {
    condition = alltrue([
      for value in var.diagnostic_metric_categories :
      contains(["AllMetrics"], value)
    ])
    error_message = "diagnostic_metric_categories must contain only supported Azure SQL Database metric categories."
  }

  validation {
    condition     = alltrue([for value in var.diagnostic_metric_categories : trimspace(value) != ""])
    error_message = "diagnostic_metric_categories cannot contain empty values."
  }
}

check "sqldb_input_consistency" {
  assert {
    condition     = !var.enable_diagnostics || trimspace(var.log_analytics_workspace_id) != ""
    error_message = "log_analytics_workspace_id must be set when enable_diagnostics is true."
  }

  assert {
    condition     = !var.enable_private_endpoint || trimspace(var.private_endpoint_subnet_id) != ""
    error_message = "private_endpoint_subnet_id must be set when enable_private_endpoint is true."
  }

  assert {
    condition     = !contains(["prod"], var.app_env) || !var.enable_long_term_retention || var.enable_diagnostics
    error_message = "Production long-term retention requires enable_diagnostics = true."
  }

  assert {
    condition = !var.enable_long_term_retention || (
      try(var.long_term_retention_policy.weekly_retention, 0) > 0 ||
      try(var.long_term_retention_policy.monthly_retention, 0) > 0 ||
      try(var.long_term_retention_policy.yearly_retention, 0) > 0
    )
    error_message = "When enable_long_term_retention is true, set at least one non-zero long_term_retention_policy value."
  }
}
