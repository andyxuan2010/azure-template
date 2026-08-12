output "container_app_id" {
  description = "Container App resource ID."
  value       = module.container_app.id
}

output "fqdn" {
  description = "FQDN of the latest Container App revision."
  value       = module.container_app.latest_revision_fqdn
}
