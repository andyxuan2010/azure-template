output "application_id" {
  description = "Client ID of the Microsoft Entra application."
  value       = module.application.application_id
}

output "service_principal_object_id" {
  description = "Object ID of the service principal."
  value       = module.application.service_principal_object_id
}
