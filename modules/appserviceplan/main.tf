data "azurerm_resource_group" "this" {
  count = trimspace(var.location) == "" || var.inherit_resource_group_tags ? 1 : 0

  name = var.resource_group_name
}

resource "azurerm_service_plan" "this" {
  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = local.location
  os_type                         = var.os_type
  sku_name                        = var.sku_name
  worker_count                    = var.worker_count
  app_service_environment_id      = var.app_service_environment_id
  maximum_elastic_worker_count    = var.maximum_elastic_worker_count
  per_site_scaling_enabled        = var.per_site_scaling_enabled
  zone_balancing_enabled          = var.zone_balancing_enabled
  premium_plan_auto_scale_enabled = var.premium_plan_auto_scale_enabled
  tags                            = local.tags
}

data "azurerm_monitor_diagnostic_categories" "app_service_plan" {
  count       = var.enable_diagnostics ? 1 : 0
  resource_id = azurerm_service_plan.this.id
}

data "azuread_group" "app_admin" {
  for_each = local.app_admin_group_names

  display_name = each.value
}

data "azuread_group" "app_user" {
  for_each = local.app_user_group_names

  display_name = each.value
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = merge(
    { for value in local.app_admin_group_object_ids : "id:${value}" => value },
    { for name, group in data.azuread_group.app_admin : "name:${name}" => group.object_id }
  )

  scope                = azurerm_service_plan.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = merge(
    { for value in local.app_user_group_object_ids : "id:${value}" => value },
    { for name, group in data.azuread_group.app_user : "name:${name}" => group.object_id }
  )

  scope                = azurerm_service_plan.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

resource "azurerm_monitor_diagnostic_setting" "app_service_plan" {
  count                          = var.enable_diagnostics ? 1 : 0
  name                           = "${var.name}-diagnostic-setting"
  target_resource_id             = azurerm_service_plan.this.id
  log_analytics_workspace_id     = try(trimspace(var.log_analytics_workspace_id), "") != "" ? var.log_analytics_workspace_id : null
  log_analytics_destination_type = try(trimspace(var.log_analytics_workspace_id), "") != "" ? var.log_analytics_destination_type : null
  storage_account_id             = try(trimspace(var.diagnostic_storage_account_id), "") != "" ? var.diagnostic_storage_account_id : null
  eventhub_authorization_rule_id = try(trimspace(var.diagnostic_eventhub_authorization_rule_id), "") != "" ? var.diagnostic_eventhub_authorization_rule_id : null
  eventhub_name                  = try(trimspace(var.diagnostic_eventhub_name), "") != "" ? var.diagnostic_eventhub_name : null

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

resource "azurerm_monitor_autoscale_setting" "app_service_plan" {
  count               = var.enable_autoscale ? 1 : 0
  name                = "${var.name}-autoscale"
  resource_group_name = var.resource_group_name
  location            = local.location
  target_resource_id  = azurerm_service_plan.this.id
  enabled             = var.autoscale_enabled
  tags                = local.tags

  dynamic "predictive" {
    for_each = var.autoscale_predictive == null ? [] : [var.autoscale_predictive]

    content {
      scale_mode      = predictive.value.scale_mode
      look_ahead_time = try(predictive.value.look_ahead_time, null)
    }
  }

  profile {
    name = var.autoscale_profile_name

    capacity {
      default = var.autoscale_default_capacity
      minimum = var.autoscale_min_capacity
      maximum = var.autoscale_max_capacity
    }

    dynamic "fixed_date" {
      for_each = var.autoscale_fixed_date == null ? [] : [var.autoscale_fixed_date]

      content {
        start    = fixed_date.value.start
        end      = fixed_date.value.end
        timezone = try(fixed_date.value.timezone, null)
      }
    }

    dynamic "recurrence" {
      for_each = var.autoscale_recurrence == null ? [] : [var.autoscale_recurrence]

      content {
        timezone = try(recurrence.value.timezone, null)
        days     = recurrence.value.days
        hours    = recurrence.value.hours
        minutes  = recurrence.value.minutes
      }
    }

    dynamic "rule" {
      for_each = local.autoscale_rules_default

      content {
        metric_trigger {
          metric_name              = rule.value.metric_name
          metric_namespace         = try(rule.value.metric_namespace, null)
          metric_resource_id       = azurerm_service_plan.this.id
          time_grain               = rule.value.time_grain
          statistic                = rule.value.statistic
          time_window              = rule.value.time_window
          operator                 = rule.value.operator
          threshold                = rule.value.threshold
          time_aggregation         = rule.value.time_aggregation
          divide_by_instance_count = try(rule.value.divide_by_instance_count, false)

          dynamic "dimensions" {
            for_each = try(rule.value.dimensions, [])

            content {
              name     = dimensions.value.name
              operator = dimensions.value.operator
              values   = dimensions.value.values
            }
          }
        }

        scale_action {
          direction = rule.value.direction
          type      = rule.value.type
          value     = rule.value.value
          cooldown  = rule.value.cooldown
        }
      }
    }
  }

  dynamic "notification" {
    for_each = var.autoscale_notifications == null ? [] : [var.autoscale_notifications]

    content {
      dynamic "email" {
        for_each = try(notification.value.email, null) == null ? [] : [notification.value.email]

        content {
          send_to_subscription_administrator    = try(email.value.send_to_subscription_administrator, false)
          send_to_subscription_co_administrator = try(email.value.send_to_subscription_co_administrator, false)
          custom_emails                         = try(email.value.custom_emails, [])
        }
      }

      dynamic "webhook" {
        for_each = try(notification.value.webhooks, [])

        content {
          service_uri = webhook.value.service_uri
          properties  = try(webhook.value.properties, {})
        }
      }
    }
  }
}
