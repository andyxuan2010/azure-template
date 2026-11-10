output "default_url" {
  description = "Default HTTPS URL of the authenticated Web App."
  value       = module.web_app.default_url
}

output "auth_config" {
  description = "Resolved module authentication mode."
  value       = module.web_app.auth_config
}
