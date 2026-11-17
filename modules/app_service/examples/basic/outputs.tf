output "app_id" {
  description = "Resource ID of the Web App."
  value       = module.web_app.app_id
}

output "default_url" {
  description = "Default HTTPS URL of the Web App."
  value       = module.web_app.default_url
}

output "identity_principal_id" {
  description = "Principal ID of the system-assigned managed identity."
  value       = module.web_app.identity_principal_id
}
