variable "name" {
  description = "Name of the App Service Plan"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,40}$", var.name))
    error_message = "name must be between 1 and 40 characters long and can only contain alphanumeric characters and hyphens."
  }
}

variable "app_env" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod", "sbx", "test", "qa", "poc"], var.app_env)
    error_message = "Environment must be one of: dev, staging, prod, sbx, test, qa, poc."
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
  description = "Azure region. If empty, the resource group's location is used."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.location) == "" || can(regex("^[a-z0-9-]+$", trimspace(var.location)))
    error_message = "location must be empty or a valid Azure region identifier."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into App Service Plan resources."
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

variable "os_type" {
  description = "OS type for the App Service Plan. Possible values: Windows, Linux, WindowsContainer"
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows", "WindowsContainer"], var.os_type)
    error_message = "os_type must be either Linux, Windows, or WindowsContainer."
  }
}

variable "sku_name" {
  description = "SKU name for the App Service Plan (e.g., B1, S1, P1v3, EP1)"
  type        = string

  validation {
    condition = can(regex(
      "^(F1|D1|B[1-3]|S[1-3]|P[1-3]v2|P[0-3]v3|P[1-3]v4|I[1-6]v2|I[1-6]v3|I[1-6]|EP[1-3]|WS[1-3]|Y1)$",
      trimspace(var.sku_name)
    ))
    error_message = "sku_name must be a supported App Service Plan SKU such as B1, S1, P1v3, P0v3, P1v4, I1v2, EP1, WS1, or Y1."
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

variable "premium_plan_auto_scale_enabled" {
  description = "Enable automatic scale for Premium plans that support platform-managed automatic scaling."
  type        = bool
  default     = false
}

variable "app_service_environment_id" {
  description = "The ID of the App Service Environment to create this Service Plan in."
  type        = string
  default     = null

  validation {
    condition     = var.app_service_environment_id == null || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Web/hostingEnvironments/.+$", var.app_service_environment_id))
    error_message = "app_service_environment_id must be null or a valid App Service Environment ID."
  }
}

variable "maximum_elastic_worker_count" {
  description = "The maximum number of workers to use in an Elastic SKU Plan."
  type        = number
  default     = null

  validation {
    condition     = try(var.maximum_elastic_worker_count > 0, true)
    error_message = "maximum_elastic_worker_count must be null or greater than 0."
  }
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

  validation {
    condition = alltrue([
      for value in var.app_admin_group : trimspace(value) != ""
    ])
    error_message = "app_admin_group must not contain empty values."
  }

  validation {
    condition     = length(var.app_admin_group) == length(distinct([for value in var.app_admin_group : trimspace(value)]))
    error_message = "app_admin_group must not contain duplicate values."
  }
}

variable "app_user_group" {
  description = "List of Microsoft Entra group display names or object IDs that should receive Reader access to the App Service Plan."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for value in var.app_user_group : trimspace(value) != ""
    ])
    error_message = "app_user_group must not contain empty values."
  }

  validation {
    condition     = length(var.app_user_group) == length(distinct([for value in var.app_user_group : trimspace(value)]))
    error_message = "app_user_group must not contain duplicate values."
  }
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
      try(trimspace(var.log_analytics_workspace_id), "") == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.OperationalInsights/workspaces/.+$", var.log_analytics_workspace_id))
    )
    error_message = "log_analytics_workspace_id must be null, empty, or a valid Log Analytics workspace resource ID."
  }
}

variable "log_analytics_destination_type" {
  description = "Log Analytics destination type for diagnostics."
  type        = string
  default     = "Dedicated"

  validation {
    condition     = contains(["Dedicated", "AzureDiagnostics"], var.log_analytics_destination_type)
    error_message = "log_analytics_destination_type must be Dedicated or AzureDiagnostics."
  }
}

variable "diagnostic_storage_account_id" {
  description = "Optional Storage Account resource ID for diagnostic settings."
  type        = string
  default     = null

  validation {
    condition = (
      var.diagnostic_storage_account_id == null ||
      try(trimspace(var.diagnostic_storage_account_id), "") == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Storage/storageAccounts/.+$", var.diagnostic_storage_account_id))
    )
    error_message = "diagnostic_storage_account_id must be null, empty, or a valid Storage Account resource ID."
  }
}

variable "diagnostic_eventhub_authorization_rule_id" {
  description = "Optional Event Hub authorization rule resource ID for diagnostic settings."
  type        = string
  default     = null

  validation {
    condition = (
      var.diagnostic_eventhub_authorization_rule_id == null ||
      try(trimspace(var.diagnostic_eventhub_authorization_rule_id), "") == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.EventHub/namespaces/.+/authorizationRules/.+$", var.diagnostic_eventhub_authorization_rule_id)) ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.EventHub/namespaces/.+/eventhubs/.+/authorizationRules/.+$", var.diagnostic_eventhub_authorization_rule_id))
    )
    error_message = "diagnostic_eventhub_authorization_rule_id must be null, empty, or a valid Event Hub authorization rule resource ID."
  }
}

variable "diagnostic_eventhub_name" {
  description = "Optional Event Hub name for diagnostic settings when using an Event Hub destination."
  type        = string
  default     = null
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

variable "autoscale_enabled" {
  description = "Whether the autoscale setting is enabled after creation."
  type        = bool
  default     = true
}

variable "autoscale_profile_name" {
  description = "Name of the default autoscale profile."
  type        = string
  default     = "default"

  validation {
    condition     = trimspace(var.autoscale_profile_name) != ""
    error_message = "autoscale_profile_name cannot be empty."
  }
}

variable "autoscale_metric_time_grain" {
  description = "Time grain used by default autoscale metric triggers."
  type        = string
  default     = "PT1M"
}

variable "autoscale_metric_time_window" {
  description = "Time window used by default autoscale metric triggers."
  type        = string
  default     = "PT5M"
}

variable "autoscale_scale_up_cooldown" {
  description = "Cooldown used by scale-up actions."
  type        = string
  default     = "PT5M"
}

variable "autoscale_scale_down_cooldown" {
  description = "Cooldown used by scale-down actions."
  type        = string
  default     = "PT5M"
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

variable "autoscale_memory_threshold_scale_down" {
  description = "Memory percentage threshold to scale down (0-100)"
  type        = number
  default     = 40

  validation {
    condition     = var.autoscale_memory_threshold_scale_down > 0 && var.autoscale_memory_threshold_scale_down <= 100
    error_message = "autoscale_memory_threshold_scale_down must be between 0 and 100."
  }
}

variable "autoscale_recurrence" {
  description = "Optional recurrence schedule for the autoscale profile."
  type = object({
    timezone = optional(string)
    days     = list(string)
    hours    = list(number)
    minutes  = list(number)
  })
  default = null

  validation {
    condition = var.autoscale_recurrence == null ? true : (
      length(var.autoscale_recurrence.days) > 0 &&
      length(var.autoscale_recurrence.hours) > 0 &&
      length(var.autoscale_recurrence.minutes) > 0 &&
      alltrue([for day in var.autoscale_recurrence.days : contains(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], day)]) &&
      alltrue([for hour in var.autoscale_recurrence.hours : hour >= 0 && hour <= 23]) &&
      alltrue([for minute in var.autoscale_recurrence.minutes : minute >= 0 && minute <= 59])
    )
    error_message = "autoscale_recurrence must include valid days, hours, and minutes."
  }
}

variable "autoscale_fixed_date" {
  description = "Optional fixed date schedule for the autoscale profile."
  type = object({
    timezone = optional(string)
    start    = string
    end      = string
  })
  default = null
}

variable "autoscale_predictive" {
  description = "Optional predictive autoscale configuration."
  type = object({
    scale_mode      = string
    look_ahead_time = optional(string)
  })
  default = null

  validation {
    condition     = var.autoscale_predictive == null ? true : contains(["Enabled", "ForecastOnly", "Disabled"], var.autoscale_predictive.scale_mode)
    error_message = "autoscale_predictive.scale_mode must be Enabled, ForecastOnly, or Disabled."
  }
}

variable "autoscale_notifications" {
  description = "Optional autoscale email and webhook notifications."
  type = object({
    email = optional(object({
      send_to_subscription_administrator    = optional(bool, false)
      send_to_subscription_co_administrator = optional(bool, false)
      custom_emails                         = optional(list(string), [])
    }))
    webhooks = optional(list(object({
      service_uri = string
      properties  = optional(map(string), {})
    })), [])
  })
  default = null

  validation {
    condition = var.autoscale_notifications == null ? true : alltrue(concat(
      [for email in try(var.autoscale_notifications.email.custom_emails, []) : can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", email))],
      [for webhook in try(var.autoscale_notifications.webhooks, []) : can(regex("^https://", webhook.service_uri))]
    ))
    error_message = "autoscale_notifications custom emails must be valid email addresses and webhooks must use https URLs."
  }
}

variable "autoscale_custom_rules" {
  description = "Additional autoscale rules to add to the default profile."
  type = list(object({
    metric_name              = string
    metric_namespace         = optional(string)
    operator                 = string
    threshold                = number
    statistic                = optional(string, "Average")
    time_aggregation         = optional(string, "Average")
    time_grain               = optional(string, "PT1M")
    time_window              = optional(string, "PT5M")
    divide_by_instance_count = optional(bool, false)
    direction                = string
    type                     = optional(string, "ChangeCount")
    value                    = number
    cooldown                 = optional(string, "PT5M")
    dimensions = optional(list(object({
      name     = string
      operator = string
      values   = list(string)
    })), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.autoscale_custom_rules :
      trimspace(rule.metric_name) != "" &&
      contains(["Equals", "NotEquals", "GreaterThan", "GreaterThanOrEqual", "LessThan", "LessThanOrEqual"], rule.operator) &&
      contains(["Increase", "Decrease", "None"], rule.direction) &&
      contains(["ChangeCount", "ExactCount", "PercentChangeCount"], rule.type) &&
      rule.value >= 0
    ])
    error_message = "autoscale_custom_rules entries must include a metric name, supported operator/action values, and non-negative action value."
  }
}

check "appserviceplan_input_consistency" {
  assert {
    condition = !var.enable_diagnostics || anytrue([
      try(trimspace(var.log_analytics_workspace_id), "") != "",
      try(trimspace(var.diagnostic_storage_account_id), "") != "",
      try(trimspace(var.diagnostic_eventhub_authorization_rule_id), "") != ""
    ])
    error_message = "At least one diagnostic destination must be set when enable_diagnostics is true."
  }

  assert {
    condition     = !var.enable_autoscale || !can(regex("^(F1|D1|Y1)$", var.sku_name))
    error_message = "Autoscale is not supported for Free, Shared, or Consumption SKUs."
  }

  assert {
    condition     = !var.zone_balancing_enabled || var.worker_count >= 3
    error_message = "zone_balancing_enabled requires worker_count of at least 3."
  }

  assert {
    condition     = !var.premium_plan_auto_scale_enabled || can(regex("^P", var.sku_name))
    error_message = "premium_plan_auto_scale_enabled requires a Premium SKU."
  }

  assert {
    condition     = var.maximum_elastic_worker_count == null || can(regex("^EP", var.sku_name))
    error_message = "maximum_elastic_worker_count is supported only with Elastic Premium SKUs such as EP1, EP2, or EP3."
  }

  assert {
    condition     = !(var.enable_autoscale && var.premium_plan_auto_scale_enabled)
    error_message = "Use either Azure Monitor autoscale or premium_plan_auto_scale_enabled, not both."
  }

  assert {
    condition     = !(var.autoscale_fixed_date != null && var.autoscale_recurrence != null)
    error_message = "Configure either autoscale_fixed_date or autoscale_recurrence, not both."
  }

  assert {
    condition     = var.autoscale_predictive == null || var.enable_autoscale
    error_message = "autoscale_predictive requires enable_autoscale = true."
  }

  assert {
    condition     = var.autoscale_notifications == null || var.enable_autoscale
    error_message = "autoscale_notifications requires enable_autoscale = true."
  }

  assert {
    condition     = length(var.autoscale_custom_rules) == 0 || var.enable_autoscale
    error_message = "autoscale_custom_rules requires enable_autoscale = true."
  }

  assert {
    condition     = !var.enable_autoscale || length(local.autoscale_rules_default) <= 10
    error_message = "Azure Monitor autoscale supports at most 10 rules per profile."
  }

  assert {
    condition     = !var.enable_memory_autoscale || var.enable_autoscale
    error_message = "enable_memory_autoscale requires enable_autoscale = true."
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

  assert {
    condition     = !var.enable_memory_autoscale || var.autoscale_memory_threshold_scale_down < var.autoscale_memory_threshold_scale_up
    error_message = "autoscale_memory_threshold_scale_down must be less than autoscale_memory_threshold_scale_up."
  }
}
