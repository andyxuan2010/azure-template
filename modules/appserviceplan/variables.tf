variable "name" {
  description = "Name of the App Service Plan"
  type        = string

  validation {
    condition     = trimspace(var.name) != ""
    error_message = "name cannot be empty."
  }
}

variable "resource_group_name" {
  description = "Resource group where the App Service Plan will be created"
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  description = "Azure region"
  type        = string

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location cannot be empty."
  }
}

variable "os_type" {
  description = "OS type for the App Service Plan. Possible values: Windows, Linux"
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "os_type must be either Linux or Windows."
  }
}

variable "sku_name" {
  description = "SKU name for the App Service Plan (e.g., B1, S1, P1v3, EP1)"
  type        = string

  validation {
    condition     = trimspace(var.sku_name) != ""
    error_message = "sku_name cannot be empty."
  }
}

variable "worker_count" {
  description = "Number of workers. Should be set to 1 when autoscaling is enabled to avoid conflicts."
  type        = number
  default     = 1

  validation {
    condition     = var.worker_count >= 1
    error_message = "worker_count must be at least 1."
  }
}

variable "per_site_scaling_enabled" {
  description = "Enable per site scaling"
  type        = bool
  default     = false
}

variable "zone_balancing_enabled" {
  description = "Enable zone balancing"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for the App Service Plan"
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

variable "app_admin_group" {
  description = "List of Microsoft Entra group display names or object IDs that should receive Contributor access to the App Service Plan."
  type        = list(string)
  default     = []
}

variable "app_user_group" {
  description = "List of Microsoft Entra group display names or object IDs that should receive Reader access to the App Service Plan."
  type        = list(string)
  default     = []
}

# Diagnostics Variables
variable "enable_diagnostics" {
  description = "Enable diagnostics for the App Service Plan"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostics"
  type        = string
  default     = null

  validation {
    condition = (
      var.log_analytics_workspace_id == null ||
      trimspace(var.log_analytics_workspace_id) == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.OperationalInsights/workspaces/.+$", var.log_analytics_workspace_id))
    )
    error_message = "log_analytics_workspace_id must be null, empty, or a valid Log Analytics workspace resource ID."
  }
}

variable "diagnostic_log_categories" {
  description = "List of log categories to enable for diagnostics"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for value in var.diagnostic_log_categories :
      trimspace(value) != ""
    ])
    error_message = "diagnostic_log_categories must contain only non-empty category names."
  }
}

variable "diagnostic_metrics" {
  description = "List of metrics to enable for diagnostics"
  type        = list(string)
  default     = ["AllMetrics"]

  validation {
    condition = alltrue([
      for value in var.diagnostic_metrics :
      contains(["AllMetrics"], value)
    ])
    error_message = "diagnostic_metrics must contain only supported metric categories."
  }
}

# Autoscale Variables
variable "enable_autoscale" {
  description = "Enable autoscale settings for the App Service Plan"
  type        = bool
  default     = false

  validation {
    condition = (
      var.enable_autoscale == false ||
      var.worker_count == 1
    )
    error_message = "When enable_autoscale is true, worker_count should be set to 1 to avoid conflicts with autoscaling rules."
  }
}

variable "autoscale_default_capacity" {
  description = "Default number of instances for autoscale"
  type        = number
  default     = 1

  validation {
    condition     = var.autoscale_default_capacity >= 1
    error_message = "autoscale_default_capacity must be at least 1."
  }
}

variable "autoscale_min_capacity" {
  description = "Minimum number of instances for autoscale"
  type        = number
  default     = 1

  validation {
    condition     = var.autoscale_min_capacity >= 1
    error_message = "autoscale_min_capacity must be at least 1."
  }
}

variable "autoscale_max_capacity" {
  description = "Maximum number of instances for autoscale"
  type        = number
  default     = 3

  validation {
    condition     = var.autoscale_max_capacity >= 2
    error_message = "autoscale_max_capacity must be at least 2."
  }
}

variable "autoscale_cpu_threshold_scale_up" {
  description = "CPU percentage threshold to scale up (0-100)"
  type        = number
  default     = 75

  validation {
    condition     = var.autoscale_cpu_threshold_scale_up > 0 && var.autoscale_cpu_threshold_scale_up <= 100
    error_message = "autoscale_cpu_threshold_scale_up must be between 0 and 100."
  }
}

variable "autoscale_cpu_threshold_scale_down" {
  description = "CPU percentage threshold to scale down (0-100)"
  type        = number
  default     = 25

  validation {
    condition     = var.autoscale_cpu_threshold_scale_down > 0 && var.autoscale_cpu_threshold_scale_down <= 100
    error_message = "autoscale_cpu_threshold_scale_down must be between 0 and 100."
  }
}

variable "autoscale_scale_up_increment" {
  description = "Number of instances to add when scaling up"
  type        = number
  default     = 1

  validation {
    condition     = var.autoscale_scale_up_increment >= 1
    error_message = "autoscale_scale_up_increment must be at least 1."
  }
}

variable "autoscale_scale_down_increment" {
  description = "Number of instances to remove when scaling down"
  type        = number
  default     = 1

  validation {
    condition     = var.autoscale_scale_down_increment >= 1
    error_message = "autoscale_scale_down_increment must be at least 1."
  }
}

variable "enable_memory_autoscale" {
  description = "Enable autoscale based on memory percentage"
  type        = bool
  default     = false
}

variable "autoscale_memory_threshold_scale_up" {
  description = "Memory percentage threshold to scale up (0-100)"
  type        = number
  default     = 80

  validation {
    condition     = var.autoscale_memory_threshold_scale_up > 0 && var.autoscale_memory_threshold_scale_up <= 100
    error_message = "autoscale_memory_threshold_scale_up must be between 0 and 100."
  }
}

check "appserviceplan_input_consistency" {
  assert {
    condition = !var.enable_diagnostics || (
      var.log_analytics_workspace_id != null &&
      trimspace(var.log_analytics_workspace_id) != ""
    )
    error_message = "log_analytics_workspace_id must be set when enable_diagnostics is true."
  }

  assert {
    condition = !var.enable_autoscale || (
      var.autoscale_min_capacity <= var.autoscale_default_capacity &&
      var.autoscale_default_capacity <= var.autoscale_max_capacity
    )
    error_message = "Autoscale capacity must satisfy autoscale_min_capacity <= autoscale_default_capacity <= autoscale_max_capacity."
  }

  assert {
    condition     = !var.enable_autoscale || var.autoscale_cpu_threshold_scale_down < var.autoscale_cpu_threshold_scale_up
    error_message = "autoscale_cpu_threshold_scale_down must be less than autoscale_cpu_threshold_scale_up."
  }
}
