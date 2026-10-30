output "app_id" {
  description = "Resource ID of the Web App."
  value       = module.web_app.app_id
}

output "default_url" {
  description = "Default HTTPS URL of the Web App. It resolves privately in this scenario."
  value       = module.web_app.default_url
}

output "private_endpoint_id" {
  description = "Resource ID of the sites private endpoint."
  value       = module.web_app.private_endpoint_sites_id
}

output "identity_principal_id" {
  description = "Principal ID used for downstream least-privilege role assignments."
  value       = module.web_app.identity_principal_id
}
