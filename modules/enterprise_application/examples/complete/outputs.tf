output "application_id" {
  description = "Application/client ID created by the app registration module."
  value       = module.app_registration.application_id
}

output "enterprise_application_object_id" {
  description = "Enterprise Application service-principal object ID."
  value       = module.enterprise_application.object_id
}

output "display_name" {
  description = "Enterprise Application display name."
  value       = module.enterprise_application.display_name
}
