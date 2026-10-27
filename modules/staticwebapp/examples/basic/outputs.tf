output "static_web_app_id" {
  description = "Static Web App resource ID."
  value       = module.staticwebapp.id
}

output "static_web_app_name" {
  description = "Static Web App name."
  value       = module.staticwebapp.name
}

output "default_host_name" {
  description = "Default Static Web App host name."
  value       = module.staticwebapp.default_host_name
}
