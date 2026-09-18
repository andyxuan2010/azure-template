variable "name" {
  description = "Optional Log Analytics workspace name override. Leave empty to generate one from the naming convention."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[A-Za-z0-9-]{4,63}$", trimspace(var.name)))
    error_message = "name must be empty or 4-63 characters using letters, numbers, or hyphens."
  }
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

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into Log Analytics resources."
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
  description = "Deprecated compatibility input. Supply workload tags explicitly through tags."

  validation {
    condition     = length(trimspace(var.workload)) > 0
    error_message = "workload cannot be empty."
  }
}

variable "app_env" {
  type        = string
  default     = "dev"
  description = "Deployment environment retained for naming and policy compatibility."

  validation {
    condition     = contains(["prod", "staging", "dev", "qa", "sbx", "poc", "test"], var.app_env)
    error_message = "app_env must be one of: prod, staging, dev, qa, sbx, poc, test."
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

variable "sku" {
  description = "Workspace SKU."
  type        = string
  default     = "PerGB2018"

  validation {
    condition     = contains(["Free", "PerNode", "Premium", "Standard", "Standalone", "Unlimited", "CapacityReservation", "PerGB2018", "LACluster"], var.sku)
    error_message = "sku must be a supported Log Analytics workspace SKU."
  }
}

variable "retention_in_days" {
  description = "Workspace retention in days."
  type        = number
  default     = 30

  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
    error_message = "retention_in_days must be between 30 and 730."
  }
}

variable "daily_quota_gb" {
  description = "Workspace daily ingestion quota in GB. Use -1 for unlimited."
  type        = number
  default     = -1

  validation {
    condition     = var.daily_quota_gb == -1 || var.daily_quota_gb >= 0
    error_message = "daily_quota_gb must be -1 or a non-negative number."
  }
}

variable "internet_ingestion_enabled" {
  description = "Whether public ingestion is enabled."
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Whether public query is enabled."
  type        = bool
  default     = true
}

variable "local_authentication_disabled" {
  description = "Whether local auth is disabled."
  type        = bool
  default     = false
}

variable "reservation_capacity_in_gb_per_day" {
  description = "Optional commitment tier in GB/day."
  type        = number
  default     = null

  validation {
    condition = var.reservation_capacity_in_gb_per_day == null ? true : contains(
      [100, 200, 300, 400, 500, 1000, 2000, 5000],
      var.reservation_capacity_in_gb_per_day
    )
    error_message = "reservation_capacity_in_gb_per_day must be null or a supported commitment tier."
  }
}

variable "allow_resource_only_permissions" {
  description = "Whether resource-context queries can be authorized using resource permissions."
  type        = bool
  default     = true
}

variable "cmk_for_query_forced" {
  description = "Whether queries must use customer-managed keys."
  type        = bool
  default     = false
}

variable "data_collection_rule_id" {
  description = "Optional default Data Collection Rule resource ID."
  type        = string
  default     = null

  validation {
    condition = var.data_collection_rule_id == null || can(
      regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Insights/dataCollectionRules/.+$", var.data_collection_rule_id)
    )
    error_message = "data_collection_rule_id must be null or a valid Data Collection Rule resource ID."
  }
}

variable "immediate_data_purge_on_30_days_enabled" {
  description = "Whether data is immediately purged after 30 days when retention is 30 days."
  type        = bool
  default     = false
}

variable "identity" {
  description = "Optional managed identity configuration."
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null

  validation {
    condition = var.identity == null ? true : contains(
      ["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"],
      var.identity.type
    )
    error_message = "identity.type must be SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }
}

variable "timeouts" {
  description = "Optional create/read/update/delete timeouts."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

check "loganalytics_input_consistency" {
  assert {
    condition     = var.reservation_capacity_in_gb_per_day == null || var.sku == "CapacityReservation"
    error_message = "reservation_capacity_in_gb_per_day requires sku = CapacityReservation."
  }

  assert {
    condition     = !var.immediate_data_purge_on_30_days_enabled || var.retention_in_days == 30
    error_message = "immediate_data_purge_on_30_days_enabled requires retention_in_days = 30."
  }

  assert {
    condition = var.identity == null ? true : (
      !contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type) || (
        length(coalesce(var.identity.identity_ids, [])) > 0 &&
        alltrue([
          for id in coalesce(var.identity.identity_ids, []) :
          can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.ManagedIdentity/userAssignedIdentities/.+$", id))
        ])
      )
    )
    error_message = "UserAssigned identity types require valid identity_ids."
  }
}

variable "tags" {
  description = "Tags applied to the workspace."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}
