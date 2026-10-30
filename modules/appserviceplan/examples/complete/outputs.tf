output "app_service_plan_id" {
  description = "Resource ID passed to hosted workload modules."
  value       = module.app_service_plan.id
}

output "zone_balancing_enabled" {
  description = "Whether zone balancing is configured."
  value       = module.app_service_plan.zone_balancing_enabled
}

output "diagnostic_setting_id" {
  description = "Resource ID of the diagnostic setting."
  value       = module.app_service_plan.diagnostic_setting_id
}
