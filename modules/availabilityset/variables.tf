variable "name" {
  description = "Optional Availability Set name override. Leave empty to generate one from the naming convention."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[a-zA-Z0-9._-]{1,80}$", trimspace(var.name)))
    error_message = "name must be empty or 1-80 characters using only letters, digits, periods, underscores, or hyphens."
  }
}

variable "name_prefix" {
  description = "Prefix used when the Availability Set name is generated."
  type        = string
  default     = "avail"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,20}$", trimspace(var.name_prefix)))
    error_message = "name_prefix must be 1-20 lowercase letters, digits, or hyphens."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group where the Availability Set is deployed."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  description = "Azure region. Leave empty to read the target resource group's location."
  type        = string
  default     = ""
}

variable "location_code" {
  description = "Optional short location code used when the Availability Set name is generated."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.location_code) == "" || can(regex("^[a-z0-9-]{2,20}$", trimspace(var.location_code)))
    error_message = "location_code must be empty or 2-20 lowercase letters, digits, or hyphens."
  }
}

variable "workload_name" {
  description = "Optional workload segment used when the Availability Set name is generated."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.workload_name) == "" || can(regex("^[a-zA-Z0-9-]{1,40}$", trimspace(var.workload_name)))
    error_message = "workload_name must be empty or 1-40 letters, digits, or hyphens."
  }
}

variable "workload" {
  type        = string
  default     = "project"
  description = "Deprecated compatibility input. Supply workload_name or workload tags explicitly where possible."

  validation {
    condition     = length(trimspace(var.workload)) > 0
    error_message = "workload cannot be empty."
  }
}

variable "app_env" {
  description = "Deployment environment used for generated naming."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod", "sbx", "test", "qa", "poc"], var.app_env)
    error_message = "app_env must be one of: dev, staging, prod, sbx, test, qa, poc."
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

variable "platform_fault_domain_count" {
  description = "Number of fault domains for the Availability Set."
  type        = number
  default     = 2

  validation {
    condition     = var.platform_fault_domain_count >= 1 && var.platform_fault_domain_count <= 3
    error_message = "platform_fault_domain_count must be between 1 and 3."
  }
}

variable "platform_update_domain_count" {
  description = "Number of update domains for the Availability Set."
  type        = number
  default     = 5

  validation {
    condition     = var.platform_update_domain_count >= 1 && var.platform_update_domain_count <= 20
    error_message = "platform_update_domain_count must be between 1 and 20."
  }
}

variable "managed" {
  description = "Whether the Availability Set is managed. Use true for VMs with managed disks."
  type        = bool
  default     = true
}

variable "proximity_placement_group_id" {
  description = "Optional proximity placement group resource ID."
  type        = string
  default     = null

  validation {
    condition     = var.proximity_placement_group_id == null || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.Compute/proximityPlacementGroups/.+$", var.proximity_placement_group_id))
    error_message = "proximity_placement_group_id must be null or a valid Azure proximity placement group resource ID."
  }
}

variable "inherit_resource_group_tags" {
  description = "Whether to merge tags from the target resource group into the Availability Set."
  type        = bool
  default     = true
}

variable "inherited_resource_group_tags" {
  description = "Optional plan-known resource group tags supplied by the root composition. When null and inherit_resource_group_tags is true, the module reads the resource group."
  type        = map(string)
  default     = null
}

variable "tags" {
  description = "Tags for the Availability Set."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

variable "timeouts" {
  description = "Optional timeouts for Availability Set create, read, update, and delete operations."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}
