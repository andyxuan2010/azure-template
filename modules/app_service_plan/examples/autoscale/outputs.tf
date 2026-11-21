output "app_service_plan_id" {
  description = "Resource ID of the autoscaled App Service Plan."
  value       = module.autoscaling_plan.id
}

output "autoscale_setting_id" {
  description = "Resource ID of the Azure Monitor autoscale setting."
  value       = module.autoscaling_plan.autoscale_setting_id
}

output "autoscale_config" {
  description = "Effective autoscale capacity and threshold summary."
  value       = module.autoscaling_plan.autoscale_config
}
