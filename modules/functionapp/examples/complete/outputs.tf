output "function_app_id" {
  description = "Resource ID of the Function App."
  value       = module.function_app.id
}

output "identity_principal_id" {
  description = "Principal ID of the Function App system-assigned identity."
  value       = module.function_app.identity_principal_id
}

output "private_endpoint_id" {
  description = "Resource ID of the Function App private endpoint."
  value       = module.function_app.private_endpoint_id
}
