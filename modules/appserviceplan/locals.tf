locals {
  environment_tag_map = {
    prod = "PROD"
    dev  = "DEV"
    qa   = "QA"
    test = "TEST"
    sbx  = "SBX"
    poc  = "POC"
  }

  location = trimspace(var.location) != "" ? trimspace(var.location) : data.azurerm_resource_group.this[0].location

  # Start from requested categories when provided, otherwise use what Azure reports
  diagnostic_log_categories_requested = length(var.diagnostic_log_categories) > 0 ? var.diagnostic_log_categories : try(data.azurerm_monitor_diagnostic_categories.app_service_plan[0].log_category_types, [])
  diagnostic_log_categories           = var.enable_diagnostics ? [for category in local.diagnostic_log_categories_requested : category if contains(try(data.azurerm_monitor_diagnostic_categories.app_service_plan[0].log_category_types, []), category)] : []

  autoscale_rules_default = var.enable_autoscale ? concat(
    [
      {
        metric_name              = "CpuPercentage"
        metric_namespace         = null
        operator                 = "GreaterThan"
        threshold                = var.autoscale_cpu_threshold_scale_up
        statistic                = "Average"
        time_aggregation         = "Average"
        time_grain               = var.autoscale_metric_time_grain
        time_window              = var.autoscale_metric_time_window
        divide_by_instance_count = false
        direction                = "Increase"
        type                     = "ChangeCount"
        value                    = var.autoscale_scale_up_increment
        cooldown                 = var.autoscale_scale_up_cooldown
        dimensions               = []
      },
      {
        metric_name              = "CpuPercentage"
        metric_namespace         = null
        operator                 = "LessThan"
        threshold                = var.autoscale_cpu_threshold_scale_down
        statistic                = "Average"
        time_aggregation         = "Average"
        time_grain               = var.autoscale_metric_time_grain
        time_window              = var.autoscale_metric_time_window
        divide_by_instance_count = false
        direction                = "Decrease"
        type                     = "ChangeCount"
        value                    = var.autoscale_scale_down_increment
        cooldown                 = var.autoscale_scale_down_cooldown
        dimensions               = []
      }
    ],
    var.enable_memory_autoscale ? [
      {
        metric_name              = "MemoryPercentage"
        metric_namespace         = null
        operator                 = "GreaterThan"
        threshold                = var.autoscale_memory_threshold_scale_up
        statistic                = "Average"
        time_aggregation         = "Average"
        time_grain               = var.autoscale_metric_time_grain
        time_window              = var.autoscale_metric_time_window
        divide_by_instance_count = false
        direction                = "Increase"
        type                     = "ChangeCount"
        value                    = var.autoscale_scale_up_increment
        cooldown                 = var.autoscale_scale_up_cooldown
        dimensions               = []
      },
      {
        metric_name              = "MemoryPercentage"
        metric_namespace         = null
        operator                 = "LessThan"
        threshold                = var.autoscale_memory_threshold_scale_down
        statistic                = "Average"
        time_aggregation         = "Average"
        time_grain               = var.autoscale_metric_time_grain
        time_window              = var.autoscale_metric_time_window
        divide_by_instance_count = false
        direction                = "Decrease"
        type                     = "ChangeCount"
        value                    = var.autoscale_scale_down_increment
        cooldown                 = var.autoscale_scale_down_cooldown
        dimensions               = []
      }
    ] : [],
    var.autoscale_custom_rules
  ) : []

  app_admin_group_object_ids = [
    for value in var.app_admin_group : value
    if length(regexall("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value)) > 0
  ]
  app_admin_group_names = {
    for value in var.app_admin_group : value => value
    if length(regexall("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value)) == 0
  }

  app_user_group_object_ids = [
    for value in var.app_user_group : value
    if length(regexall("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value)) > 0
  ]
  app_user_group_names = {
    for value in var.app_user_group : value => value
    if length(regexall("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value)) == 0
  }

  tags = merge(
    var.inherit_resource_group_tags ? try(data.azurerm_resource_group.this[0].tags, {}) : {},
    var.tags,
    {
      Environment = lookup(local.environment_tag_map, var.app_env, var.app_env)
      workload    = var.workload
    }
  )
}
