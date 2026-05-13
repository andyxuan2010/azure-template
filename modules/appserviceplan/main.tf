resource "azurerm_service_plan" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.os_type
  sku_name            = var.sku_name

  worker_count                 = var.worker_count
  app_service_environment_id   = var.app_service_environment_id
  maximum_elastic_worker_count = var.maximum_elastic_worker_count

  per_site_scaling_enabled = var.per_site_scaling_enabled
  zone_balancing_enabled   = var.zone_balancing_enabled

  tags = local.tags
}

data "azurerm_monitor_diagnostic_categories" "app_service_plan" {
  count       = var.enable_diagnostics ? 1 : 0
  resource_id = azurerm_service_plan.this.id
}

data "azuread_group" "app_admin" {
  for_each = {
    for value in var.app_admin_group : value => value
    if !can(regex("^[0-9a-fA-F-]{36}$", value))
  }

  display_name = each.value
}

data "azuread_group" "app_user" {
  for_each = {
    for value in var.app_user_group : value => value
    if !can(regex("^[0-9a-fA-F-]{36}$", value))
  }

  display_name = each.value
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = merge(
    { for value in var.app_admin_group : "id:${value}" => value if can(regex("^[0-9a-fA-F-]{36}$", value)) },
    { for name, group in data.azuread_group.app_admin : "name:${name}" => group.object_id }
  )

  scope                = azurerm_service_plan.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = merge(
    { for value in var.app_user_group : "id:${value}" => value if can(regex("^[0-9a-fA-F-]{36}$", value)) },
    { for name, group in data.azuread_group.app_user : "name:${name}" => group.object_id }
  )

  scope                = azurerm_service_plan.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

# Monitor Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "app_service_plan" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "${var.name}-diagnostic-setting"
  target_resource_id         = azurerm_service_plan.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = toset(local.diagnostic_log_categories)

    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = toset(var.diagnostic_metrics)

    content {
      category = enabled_metric.value
    }
  }
}

# Autoscale Settings
resource "azurerm_monitor_autoscale_setting" "app_service_plan" {
  count               = var.enable_autoscale ? 1 : 0
  name                = "${var.name}-autoscale"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_service_plan.this.id
  tags                = var.tags

  profile {
    name = "default"

    capacity {
      default = var.autoscale_default_capacity
      minimum = var.autoscale_min_capacity
      maximum = var.autoscale_max_capacity
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.this.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        operator           = "GreaterThan"
        threshold          = var.autoscale_cpu_threshold_scale_up
        time_aggregation   = "Average"
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = var.autoscale_scale_up_increment
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.this.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        operator           = "LessThan"
        threshold          = var.autoscale_cpu_threshold_scale_down
        time_aggregation   = "Average"
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = var.autoscale_scale_down_increment
        cooldown  = "PT5M"
      }
    }

    dynamic "rule" {
      for_each = var.enable_memory_autoscale ? [1] : []
      content {
        metric_trigger {
          metric_name        = "MemoryPercentage"
          metric_resource_id = azurerm_service_plan.this.id
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT5M"
          operator           = "GreaterThan"
          threshold          = var.autoscale_memory_threshold_scale_up
          time_aggregation   = "Average"
        }

        scale_action {
          direction = "Increase"
          type      = "ChangeCount"
          value     = var.autoscale_scale_up_increment
          cooldown  = "PT5M"
        }
      }
    }
  }
}
