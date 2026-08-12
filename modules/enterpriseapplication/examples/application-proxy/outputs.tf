output "enterprise_application_object_id" {
  description = "Enterprise Application service-principal object ID."
  value       = module.enterprise_application.object_id
}

output "application_proxy_external_url" {
  description = "External URL reported by Microsoft Graph."
  value       = module.enterprise_application.application_proxy_external_url
}
