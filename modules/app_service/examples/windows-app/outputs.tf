output "default_url" {
  description = "Default HTTPS URL of the Windows Web App."
  value       = module.windows_web_app.default_url
}

output "app_kind" {
  description = "Resolved Web App operating system."
  value       = module.windows_web_app.app_kind
}
