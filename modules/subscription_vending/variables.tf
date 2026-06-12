variable "subscription_alias_enabled" {
  description = "Whether to create a subscription alias and new subscription."
  type        = bool
  default     = false
}

variable "subscription_alias_name" {
  description = "Subscription alias name when subscription_alias_enabled is true."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.subscription_alias_name) == "" || can(regex("^[a-zA-Z0-9._()-]{1,90}$", var.subscription_alias_name))
    error_message = "subscription_alias_name must be empty or 1-90 characters using supported alias characters."
  }
}

variable "subscription_name" {
  description = "Display name for the subscription."
  type        = string

  validation {
    condition     = trimspace(var.subscription_name) != ""
    error_message = "subscription_name cannot be empty."
  }
}

variable "billing_scope_id" {
  description = "Billing scope ID used when creating a new subscription alias."
  type        = string
  default     = ""
}

variable "existing_subscription_id" {
  description = "Existing subscription ID used when only associating or bootstrapping an existing subscription."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.existing_subscription_id) == "" || can(regex("^/subscriptions/[0-9a-fA-F-]+$", var.existing_subscription_id))
    error_message = "existing_subscription_id must be empty or a valid subscription resource ID."
  }
}

variable "management_group_id" {
  description = "Optional management group ID used to associate the subscription."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.management_group_id) == "" || can(regex("^/providers/Microsoft\\.Management/managementGroups/.+$", var.management_group_id))
    error_message = "management_group_id must be empty or a valid management group resource ID."
  }
}

variable "enable_management_group_association" {
  description = "Whether to associate the subscription with management_group_id. Use this when management_group_id is produced by another resource and is unknown during plan."
  type        = bool
  default     = true
}

variable "resource_provider_registrations" {
  description = "Resource providers to register in the subscription."
  type        = list(string)
  default     = []
}

variable "bootstrap_resource_groups" {
  description = "Bootstrap resource groups to create in the subscription."
  type = map(object({
    name     = string
    location = string
    tags     = optional(map(string), {})
  }))
  default = {}
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
  description = "Default tags applied to bootstrap resource groups."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

check "subscription_vending_consistency" {
  assert {
    condition     = var.subscription_alias_enabled ? trimspace(var.subscription_alias_name) != "" && trimspace(var.billing_scope_id) != "" : true
    error_message = "subscription_alias_name and billing_scope_id must be set when subscription_alias_enabled is true."
  }

  assert {
    condition     = var.subscription_alias_enabled || trimspace(var.existing_subscription_id) != ""
    error_message = "existing_subscription_id must be set when subscription_alias_enabled is false."
  }
}
