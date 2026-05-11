locals {
  # Start from requested categories when provided, otherwise use what Azure reports
  diagnostic_log_categories_requested = length(var.diagnostic_log_categories) > 0 ? var.diagnostic_log_categories : try(data.azurerm_monitor_diagnostic_categories.app_service_plan[0].log_category_types, [])
  diagnostic_log_categories           = var.enable_diagnostics ? [for category in local.diagnostic_log_categories_requested : category if contains(try(data.azurerm_monitor_diagnostic_categories.app_service_plan[0].log_category_types, []), category)] : []
}
