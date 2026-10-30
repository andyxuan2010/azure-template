variable "name" {
  description = "Optional Static Web App name override. Leave empty to generate one from the naming convention."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[A-Za-z0-9-]{1,60}$", trimspace(var.name)))
    error_message = "name must be empty or 1-60 characters using letters, numbers, or hyphens."
  }
}

variable "name_prefix" {
  description = "Prefix used when the Static Web App name is generated."
  type        = string
  default     = "swa"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,20}$", trimspace(var.name_prefix)))
    error_message = "name_prefix must be 1-20 lowercase letters, numbers, or hyphens."
  }
}

variable "resource_group_name" {
  description = "Name of the existing resource group where the Static Web App is deployed."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  description = "Azure region for the Static Web App. Leave empty to use the existing resource group's location."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.location) == "" || can(regex("^[a-z0-9-]+$", trimspace(var.location)))
    error_message = "location must be empty or a valid Azure region identifier."
  }
}

variable "location_code" {
  description = "Optional short location code used when the Static Web App name is generated."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.location_code) == "" || can(regex("^[a-z0-9-]{2,20}$", trimspace(var.location_code)))
    error_message = "location_code must be empty or 2-20 lowercase letters, numbers, or hyphens."
  }
}

variable "workload_name" {
  description = "Optional workload segment used when the Static Web App name is generated."
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
  description = "Deployment environment used when the Static Web App name is generated."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod", "sbx", "test", "qa", "poc"], var.app_env)
    error_message = "app_env must be one of: dev, staging, prod, sbx, test, qa, poc."
  }
}

variable "instance" {
  description = "Instance identifier used when the Static Web App name is generated."
  type        = string
  default     = "001"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,12}$", trimspace(var.instance)))
    error_message = "instance must be 1-12 lowercase letters, numbers, or hyphens."
  }
}

variable "sku_tier" {
  description = "Static Web App SKU tier. Free is the default plan and Standard is optional."
  type        = string
  default     = "Free"

  validation {
    condition     = contains(["Free", "Standard"], var.sku_tier)
    error_message = "sku_tier must be Free or Standard."
  }
}

variable "sku_size" {
  description = "Static Web App SKU size. Free is the default size and Standard is optional."
  type        = string
  default     = "Free"

  validation {
    condition     = contains(["Free", "Standard"], var.sku_size)
    error_message = "sku_size must be Free or Standard."
  }
}

variable "configuration_file_changes_enabled" {
  description = "Whether changes to the Static Web App configuration file are permitted."
  type        = bool
  default     = true
}

variable "preview_environments_enabled" {
  description = "Whether preview or staging environments are enabled."
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the Static Web App."
  type        = bool
  default     = true
}

variable "app_settings" {
  description = "Key-value application settings for the Static Web App."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "repository_url" {
  description = "Optional repository URL used for Static Web App deployment integration. Set with repository_branch and repository_token; partial configuration is rejected at plan time."
  type        = string
  default     = null
}

variable "repository_branch" {
  description = "Optional repository branch used for Static Web App deployment integration. Set with repository_url and repository_token; partial configuration is rejected at plan time."
  type        = string
  default     = null
}

variable "repository_token" {
  description = "Optional repository token with deployment administration privileges. Set with repository_url and repository_branch; partial configuration is rejected at plan time."
  type        = string
  default     = null
  sensitive   = true
}

variable "identity_type" {
  description = "Optional managed identity type for the Static Web App."
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

variable "basic_auth" {
  description = "Optional basic authentication configuration for all or staging environments."
  type = object({
    environments = string
    password     = string
  })
  default   = null
  sensitive = true

  validation {
    condition     = var.basic_auth == null || contains(["AllEnvironments", "StagingEnvironments"], var.basic_auth.environments)
    error_message = "basic_auth.environments must be AllEnvironments or StagingEnvironments."
  }
}

variable "inherit_resource_group_tags" {
  description = "Whether to merge tags from the target resource group into the Static Web App."
  type        = bool
  default     = true
}

variable "inherited_resource_group_tags" {
  description = "Optional plan-known resource group tags. When null and inheritance is enabled, the module reads the resource group."
  type        = map(string)
  default     = null
}

variable "tags" {
  description = "Tags applied to the Static Web App. Caller tags override inherited resource-group tags."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for key, value in var.tags : trimspace(key) != "" && trimspace(value) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

variable "timeouts" {
  description = "Optional timeouts for Static Web App create, read, update, and delete operations."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}
