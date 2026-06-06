output "application_id" {
  description = "Application/client ID created by the appregistration module."
  value       = module.appregistration.application_id
}

output "enterprise_application_object_id" {
  description = "Object ID of the Enterprise Application service principal."
  value       = module.enterpriseapplication.object_id
}

output "enterprise_application_display_name" {
  description = "Display name of the Enterprise Application."
  value       = module.enterpriseapplication.display_name
}

output "application_proxy_external_url" {
  description = "Application Proxy external URL when proxy publishing is enabled."
  value       = module.enterpriseapplication.application_proxy_external_url
}
