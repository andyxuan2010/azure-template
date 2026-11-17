output "app_service_plan_id" {
  description = "Resource ID passed to Web App or Function App modules."
  value       = module.app_service_plan.id
}

output "sku_name" {
  description = "Configured App Service Plan SKU."
  value       = module.app_service_plan.sku_name
}
