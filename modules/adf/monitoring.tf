data "azurerm_monitor_diagnostic_categories" "this" {
  for_each = local.diagnostics_enabled ? var.log_analytics_workspace : {}

  resource_id = azurerm_data_factory.this.id
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = local.diagnostics_enabled ? var.log_analytics_workspace : {}

  name                           = "${local.diagnostics_name}-${each.key}"
  target_resource_id             = azurerm_data_factory.this.id
  log_analytics_workspace_id     = each.value
  log_analytics_destination_type = var.analytics_destination_type

  dynamic "enabled_log" {
    for_each = length(var.diagnostic_log_categories) > 0 ? toset(var.diagnostic_log_categories) : toset(data.azurerm_monitor_diagnostic_categories.this[each.key].log_category_types)

    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = length(var.diagnostic_metric_categories) > 0 ? toset(var.diagnostic_metric_categories) : toset(data.azurerm_monitor_diagnostic_categories.this[each.key].metrics)

    content {
      category = enabled_metric.value
    }
  }
}
