output "enterprise_application_object_id" {
  description = "Object ID of the Enterprise Application service principal."
  value       = module.enterprise_application.object_id
}

output "display_name" {
  description = "Display name inherited from the app registration."
  value       = module.enterprise_application.display_name
}
