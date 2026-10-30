variable "name" {
  description = "Optional Recovery Services vault name. Leave empty to generate one from workload, region, environment, and instance."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[A-Za-z][A-Za-z0-9-]{1,49}$", trimspace(var.name)))
    error_message = "name must be empty or 2-50 characters, start with a letter, and contain only letters, numbers, or hyphens."
  }
}

variable "resource_group_name" {
  description = "Existing resource group where the Recovery Services vault will be created."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  description = "Azure region for the Recovery Services vault. Place the vault in the same region as the protected data sources."
  type        = string

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location cannot be empty."
  }
}

variable "sku" {
  description = "Recovery Services vault SKU. Standard is the usual choice for Azure Backup."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "RS0"], var.sku)
    error_message = "sku must be Standard or RS0."
  }
}

variable "storage_mode_type" {
  description = "Vault backup storage redundancy: GeoRedundant, LocallyRedundant, or ZoneRedundant. Choose before protecting data sources because changing redundancy later has restrictions."
  type        = string
  default     = "GeoRedundant"

  validation {
    condition     = contains(["GeoRedundant", "LocallyRedundant", "ZoneRedundant"], var.storage_mode_type)
    error_message = "storage_mode_type must be GeoRedundant, LocallyRedundant, or ZoneRedundant."
  }
}

variable "cross_region_restore_enabled" {
  description = "Enable cross-region restore. This requires GeoRedundant storage and cannot be disabled after backup protection begins without replacing the vault."
  type        = bool
  default     = false

  validation {
    condition     = !var.cross_region_restore_enabled || var.storage_mode_type == "GeoRedundant"
    error_message = "cross_region_restore_enabled requires storage_mode_type = GeoRedundant."
  }
}

variable "public_network_access_enabled" {
  description = "Allow the vault to be accessed from public networks. Set false only after configuring supported private endpoint connectivity for the protected workloads."
  type        = bool
  default     = true
}

variable "immutability" {
  description = "Vault immutability mode: Disabled, Unlocked, or Locked. Locked is irreversible; review retention and deletion workflows before selecting it."
  type        = string
  default     = "Unlocked"

  validation {
    condition     = contains(["Disabled", "Unlocked", "Locked"], var.immutability)
    error_message = "immutability must be Disabled, Unlocked, or Locked."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into the vault."
  default     = true
}

variable "inherited_resource_group_tags" {
  type        = map(string)
  description = "Optional plan-known resource group tags supplied by the root composition. When null and tag inheritance is enabled, the module reads the resource group."
  default     = null
}

variable "workload" {
  description = "Workload identifier used when the vault name is generated."
  type        = string
  default     = "project"

  validation {
    condition     = length(trimspace(var.workload)) > 0
    error_message = "workload cannot be empty."
  }
}

variable "app_env" {
  description = "Deployment environment used when the vault name is generated."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["prod", "staging", "dev", "qa", "sbx", "poc", "test"], var.app_env)
    error_message = "app_env must be one of: prod, staging, dev, qa, sbx, poc, test."
  }
}

variable "instance" {
  description = "Instance identifier used when the vault name is generated."
  type        = string
  default     = "001"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,12}$", trimspace(var.instance)))
    error_message = "instance must be 1-12 lowercase letters, numbers, or hyphens."
  }
}

variable "tags" {
  description = "Tags applied to the Recovery Services vault."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for key, value in var.tags : trimspace(key) != "" && trimspace(value) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}
