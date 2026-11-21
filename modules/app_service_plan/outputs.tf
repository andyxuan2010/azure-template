output "id" {
  description = "ID of the App Service Plan"
  value       = azurerm_service_plan.this.id
}

output "name" {
  description = "Name of the App Service Plan"
  value       = azurerm_service_plan.this.name
}

output "sku_name" {
  description = "SKU of the App Service Plan"
  value       = azurerm_service_plan.this.sku_name
}

output "location" {
  description = "Location of the App Service Plan"
  value       = azurerm_service_plan.this.location
}

output "resource_group_name" {
  description = "Resource group name of the App Service Plan"
  value       = azurerm_service_plan.this.resource_group_name
}

output "os_type" {
  description = "OS type of the App Service Plan"
  value       = azurerm_service_plan.this.os_type
}

output "worker_count" {
  description = "Worker count configured on the App Service Plan."
  value       = azurerm_service_plan.this.worker_count
}

output "maximum_elastic_worker_count" {
  description = "Maximum elastic worker count configured on the App Service Plan."
  value       = azurerm_service_plan.this.maximum_elastic_worker_count
}

output "per_site_scaling_enabled" {
  description = "Whether per-site scaling is enabled."
  value       = azurerm_service_plan.this.per_site_scaling_enabled
}

output "zone_balancing_enabled" {
  description = "Whether zone balancing is enabled."
  value       = azurerm_service_plan.this.zone_balancing_enabled
}

output "premium_plan_auto_scale_enabled" {
  description = "Whether Premium plan automatic scale is enabled."
  value       = azurerm_service_plan.this.premium_plan_auto_scale_enabled
}

output "diagnostic_setting_id" {
  description = "ID of the diagnostic setting"
  value       = var.enable_diagnostics ? azurerm_monitor_diagnostic_setting.app_service_plan[0].id : null
}

output "diagnostic_setting_name" {
  description = "Name of the diagnostic setting"
  value       = var.enable_diagnostics ? azurerm_monitor_diagnostic_setting.app_service_plan[0].name : null
}

output "autoscale_setting_id" {
  description = "ID of the autoscale setting"
  value       = var.enable_autoscale ? azurerm_monitor_autoscale_setting.app_service_plan[0].id : null
}

output "autoscale_setting_name" {
  description = "Name of the autoscale setting"
  value       = var.enable_autoscale ? azurerm_monitor_autoscale_setting.app_service_plan[0].name : null
}

output "autoscale_config" {
  description = "Autoscale configuration details"
  value = var.enable_autoscale ? {
    enabled                     = var.autoscale_enabled
    profile_name                = var.autoscale_profile_name
    min_capacity                = var.autoscale_min_capacity
    max_capacity                = var.autoscale_max_capacity
    default_capacity            = var.autoscale_default_capacity
    cpu_scale_up_threshold      = var.autoscale_cpu_threshold_scale_up
    cpu_scale_down_threshold    = var.autoscale_cpu_threshold_scale_down
    memory_autoscale_enabled    = var.enable_memory_autoscale
    memory_scale_up_threshold   = var.enable_memory_autoscale ? var.autoscale_memory_threshold_scale_up : null
    memory_scale_down_threshold = var.enable_memory_autoscale ? var.autoscale_memory_threshold_scale_down : null
    custom_rule_count           = length(var.autoscale_custom_rules)
  } : null
}

output "app_admin_group_role_assignment_ids" {
  description = "Map of Contributor role assignment IDs keyed by app_admin_group principal ID."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Map of Reader role assignment IDs keyed by app_user_group principal ID."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}

output "diagnostic_log_categories" {
  description = "Effective diagnostic log categories enabled for the App Service Plan."
  value       = local.diagnostic_log_categories
}

output "diagnostic_metric_categories" {
  description = "Diagnostic metric categories configured for the App Service Plan."
  value       = var.diagnostic_metrics
}

output "tags" {
  description = "Effective tags applied to resources."
  value       = local.tags
}
