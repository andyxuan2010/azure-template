variable "name" {
  type        = string
  description = "SQL Managed Instance name."

  validation {
    condition     = can(regex("^[a-z0-9-]{1,63}$", var.name))
    error_message = "name must be 1-63 characters and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Resource group where the SQL Managed Instance will be created."

  validation {
    condition     = can(regex("^[A-Za-z0-9._()/-]{1,90}$", var.resource_group_name))
    error_message = "resource_group_name must be 1-90 characters and use valid Azure resource group name characters."
  }
}

variable "location" {
  type        = string
  description = "Azure region for the SQL Managed Instance. If empty, the resource group's location is used."
  default     = ""

  validation {
    condition     = trimspace(var.location) == "" || can(regex("^[a-z0-9-]+$", var.location))
    error_message = "location must be empty or a valid Azure region identifier."
  }
}

variable "subnet_id" {
  type        = string
  description = "Delegated subnet resource ID for the SQL Managed Instance."

  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/.+$", var.subnet_id))
    error_message = "subnet_id must be a valid subnet resource ID."
  }
}

variable "administrator_login" {
  type        = string
  description = "SQL administrator login name."

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]{0,127}$", var.administrator_login))
    error_message = "administrator_login must start with a letter and contain only letters, numbers, or underscores."
  }
}

variable "administrator_login_password" {
  type        = string
  description = "SQL administrator login password."
  sensitive   = true

  validation {
    condition     = length(var.administrator_login_password) >= 16
    error_message = "administrator_login_password must be at least 16 characters."
  }
}

variable "sku_name" {
  type        = string
  description = "SQL Managed Instance SKU name, for example GP_Gen5 or BC_Gen5."

  validation {
    condition     = contains(["GP_Gen5", "BC_Gen5"], var.sku_name)
    error_message = "sku_name must be GP_Gen5 or BC_Gen5."
  }
}

variable "license_type" {
  type        = string
  description = "License type for SQL Managed Instance."
  default     = "BasePrice"

  validation {
    condition     = contains(["BasePrice", "LicenseIncluded"], var.license_type)
    error_message = "license_type must be BasePrice or LicenseIncluded."
  }
}

variable "vcores" {
  type        = number
  description = "Number of vCores for the SQL Managed Instance."

  validation {
    condition     = var.vcores >= 4
    error_message = "vcores must be at least 4."
  }
}

variable "storage_size_in_gb" {
  type        = number
  description = "Storage size in GB for the SQL Managed Instance."

  validation {
    condition     = var.storage_size_in_gb >= 32
    error_message = "storage_size_in_gb must be at least 32."
  }
}

variable "collation" {
  type        = string
  description = "SQL Managed Instance collation."
  default     = "SQL_Latin1_General_CP1_CI_AS"

  validation {
    condition     = trimspace(var.collation) != ""
    error_message = "collation cannot be empty."
  }
}

variable "minimum_tls_version" {
  type        = string
  description = "Minimum TLS version."
  default     = "1.2"

  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "minimum_tls_version must be 1.0, 1.1, or 1.2."
  }
}

variable "timezone_id" {
  type        = string
  description = "Timezone ID for SQL Managed Instance."
  default     = "UTC"

  validation {
    condition     = trimspace(var.timezone_id) != ""
    error_message = "timezone_id cannot be empty."
  }
}

variable "public_data_endpoint_enabled" {
  type        = bool
  description = "Whether the public data endpoint is enabled."
  default     = false
}

variable "proxy_override" {
  type        = string
  description = "Connection type override for SQL Managed Instance."
  default     = "Proxy"

  validation {
    condition     = contains(["Default", "Proxy", "Redirect"], var.proxy_override)
    error_message = "proxy_override must be Default, Proxy, or Redirect."
  }
}

variable "storage_account_type" {
  type        = string
  description = "Underlying storage account type."
  default     = "GRS"

  validation {
    condition     = contains(["GRS", "LRS", "ZRS"], var.storage_account_type)
    error_message = "storage_account_type must be GRS, LRS, or ZRS."
  }
}

variable "maintenance_configuration_name" {
  type        = string
  description = "Optional maintenance configuration resource name."
  default     = null

  validation {
    condition     = var.maintenance_configuration_name == null || try(trimspace(var.maintenance_configuration_name), "") != ""
    error_message = "maintenance_configuration_name must be null or a non-empty string."
  }
}

variable "zone_redundant_enabled" {
  type        = bool
  description = "Whether zone redundancy is enabled."
  default     = false
}

variable "dns_zone_partner_id" {
  type        = string
  description = "Optional partner managed instance ID for DNS zone sharing."
  default     = null

  validation {
    condition = (
      var.dns_zone_partner_id == null ||
      try(trimspace(var.dns_zone_partner_id), "") == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Sql/managedInstances/.+$", var.dns_zone_partner_id))
    )
    error_message = "dns_zone_partner_id must be null, empty, or a valid SQL Managed Instance resource ID."
  }
}

variable "identity_type" {
  type        = string
  description = "Managed identity type for SQL Managed Instance."
  default     = "SystemAssigned"

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "identity_type must be SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }
}

variable "identity_ids" {
  type        = set(string)
  description = "User-assigned identity resource IDs."
  default     = []

  validation {
    condition = alltrue([
      for value in var.identity_ids :
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.ManagedIdentity/userAssignedIdentities/.+$", value))
    ])
    error_message = "identity_ids must contain only valid user-assigned identity resource IDs."
  }
}

variable "app_admin_group" {
  type        = list(string)
  description = "List of Microsoft Entra group display names or object IDs that should receive Contributor access to the SQL Managed Instance resource."
  default     = []
}

variable "app_user_group" {
  type        = list(string)
  description = "List of Microsoft Entra group display names or object IDs that should receive Reader access to the SQL Managed Instance resource."
  default     = []
}

variable "azure_active_directory_administrator" {
  description = "Optional Microsoft Entra administrator configuration."
  type = object({
    login_username                      = string
    object_id                           = string
    principal_type                      = string
    tenant_id                           = optional(string)
    azuread_authentication_only_enabled = optional(bool, false)
  })
  default = null

  validation {
    condition = var.azure_active_directory_administrator == null ? true : (
      trimspace(try(var.azure_active_directory_administrator.login_username, "")) != "" &&
      can(regex("^[0-9a-fA-F-]{36}$", try(var.azure_active_directory_administrator.object_id, ""))) &&
      contains(["User", "Group", "Application"], try(var.azure_active_directory_administrator.principal_type, "")) &&
      (
        try(var.azure_active_directory_administrator.tenant_id, null) == null ||
        can(regex("^[0-9a-fA-F-]{36}$", try(var.azure_active_directory_administrator.tenant_id, "")))
      )
    )
    error_message = "azure_active_directory_administrator must include a login_username, a valid GUID object_id, principal_type of User/Group/Application, and an optional GUID tenant_id."
  }
}

variable "enable_diagnostics" {
  type        = bool
  description = "Whether to create a diagnostic setting for the SQL Managed Instance."
  default     = false
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace resource ID for diagnostics."
  default     = ""

  validation {
    condition = (
      trimspace(var.log_analytics_workspace_id) == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.OperationalInsights/workspaces/.+$", var.log_analytics_workspace_id))
    )
    error_message = "log_analytics_workspace_id must be empty or a valid Log Analytics workspace resource ID."
  }
}

variable "diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable for SQL Managed Instance."
  default     = ["ResourceUsageStats", "SQLSecurityAuditEvents", "DevOpsOperationsAudit"]

  validation {
    condition = alltrue([
      for value in var.diagnostic_log_categories : trimspace(value) != ""
    ])
    error_message = "diagnostic_log_categories cannot contain empty values."
  }
}

variable "diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable for SQL Managed Instance."
  default     = ["AllMetrics"]

  validation {
    condition = alltrue([
      for value in var.diagnostic_metric_categories :
      trimspace(value) != "" && contains(["AllMetrics"], value)
    ])
    error_message = "diagnostic_metric_categories must contain only supported metric categories."
  }
}

variable "tags" {
  type        = map(string)
  description = "Custom tags to apply to the SQL Managed Instance."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

check "sqlmi_input_consistency" {
  assert {
    condition     = !contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type) || length(var.identity_ids) > 0
    error_message = "identity_ids must be provided when identity_type includes UserAssigned."
  }

  assert {
    condition     = var.identity_type != "SystemAssigned" || length(var.identity_ids) == 0
    error_message = "identity_ids can only be set with identity_type UserAssigned or SystemAssigned, UserAssigned."
  }

  assert {
    condition     = !var.enable_diagnostics || trimspace(var.log_analytics_workspace_id) != ""
    error_message = "log_analytics_workspace_id must be set when enable_diagnostics is true."
  }
}
