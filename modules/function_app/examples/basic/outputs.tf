output "function_app_id" {
  description = "Resource ID of the Function App."
  value       = module.function_app.id
}

output "default_hostname" {
  description = "Default hostname of the Function App."
  value       = module.function_app.default_hostname
}

output "storage_auth_mode" {
  description = "Storage authentication mode selected by the module."
  value       = module.function_app.storage_auth_mode
}
