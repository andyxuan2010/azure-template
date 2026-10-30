variable "name" {
  description = "Optional Event Grid System Topic name override. Leave empty to generate one from the naming convention."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[A-Za-z0-9-]{3,50}$", trimspace(var.name)))
    error_message = "name must be empty or 3-50 characters using letters, numbers, or hyphens."
  }
}

variable "name_prefix" {
  description = "Prefix used when the Event Grid System Topic name is generated."
  type        = string
  default     = "egt"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,20}$", trimspace(var.name_prefix)))
    error_message = "name_prefix must be 1-20 lowercase letters, numbers, or hyphens."
  }
}

variable "resource_group_name" {
  description = "Name of the existing resource group where the Event Grid System Topic is deployed."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  description = "Azure region for the Event Grid System Topic. Leave empty to use the existing resource group's location."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.location) == "" || can(regex("^[a-z0-9-]+$", trimspace(var.location)))
    error_message = "location must be empty or a valid Azure region identifier."
  }
}

variable "location_code" {
  description = "Optional short location code used when the Event Grid System Topic name is generated."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.location_code) == "" || can(regex("^[a-z0-9-]{2,20}$", trimspace(var.location_code)))
    error_message = "location_code must be empty or 2-20 lowercase letters, numbers, or hyphens."
  }
}

variable "workload_name" {
  description = "Optional workload segment used when the Event Grid System Topic name is generated."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.workload_name) == "" || can(regex("^[A-Za-z0-9-]{1,40}$", trimspace(var.workload_name)))
    error_message = "workload_name must be empty or 1-40 letters, numbers, or hyphens."
  }
}

variable "workload" {
  description = "Compatibility workload segment used when workload_name is empty."
  type        = string
  default     = "project"

  validation {
    condition     = can(regex("^[A-Za-z0-9-]{1,40}$", trimspace(var.workload)))
    error_message = "workload must be 1-40 letters, numbers, or hyphens."
  }
}

variable "app_env" {
  description = "Deployment environment used when the Event Grid System Topic name is generated."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod", "sbx", "test", "qa", "poc"], var.app_env)
    error_message = "app_env must be one of: dev, staging, prod, sbx, test, qa, poc."
  }
}

variable "instance" {
  description = "Instance identifier used when the Event Grid System Topic name is generated."
  type        = string
  default     = "001"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,12}$", trimspace(var.instance)))
    error_message = "instance must be 1-12 lowercase letters, numbers, or hyphens."
  }
}

variable "topic_type" {
  description = "Event Grid topic type associated with the source resource, such as Microsoft.Storage.StorageAccounts."
  type        = string

  validation {
    condition     = trimspace(var.topic_type) != "" && can(regex("^Microsoft\\.[A-Za-z0-9]+(?:\\.[A-Za-z0-9]+)+$", trimspace(var.topic_type)))
    error_message = "topic_type must be a non-empty Azure resource topic type such as Microsoft.Storage.StorageAccounts."
  }
}

variable "source_resource_id" {
  description = "Full Azure resource ID for the resource that emits events to this system topic."
  type        = string

  validation {
    condition = (
      can(regex("^/subscriptions/[^/]+$", trimspace(var.source_resource_id))) ||
      can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/[^/]+/[^/]+(?:/.*)?$", trimspace(var.source_resource_id)))
    )
    error_message = "source_resource_id must be a subscription ID or a full Azure resource ID."
  }
}

variable "identity_type" {
  description = "Optional managed identity type for the Event Grid System Topic."
  type        = string
  default     = null

  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "identity_type must be null, SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }
}

variable "identity_ids" {
  description = "User-assigned managed identity resource IDs used when identity_type includes UserAssigned."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for identity_id in var.identity_ids : can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.ManagedIdentity/userAssignedIdentities/.+$", identity_id))])
    error_message = "identity_ids must contain valid user-assigned managed identity resource IDs."
  }
}

variable "inherit_resource_group_tags" {
  description = "Whether to merge tags from the target resource group into the Event Grid System Topic."
  type        = bool
  default     = true
}

variable "inherited_resource_group_tags" {
  description = "Optional plan-known resource group tags. When null and inheritance is enabled, the module reads the resource group."
  type        = map(string)
  default     = null
}

variable "tags" {
  description = "Tags applied to the Event Grid System Topic. Caller tags override inherited resource-group tags."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for key, value in var.tags : trimspace(key) != "" && trimspace(value) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

variable "timeouts" {
  description = "Optional timeouts for Event Grid System Topic create, read, update, and delete operations."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}
