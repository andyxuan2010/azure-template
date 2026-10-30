output "id" {
  description = "Resource ID of the Enterprise Application service principal."
  value       = azuread_service_principal.this.id
}

output "object_id" {
  description = "Object ID of the Enterprise Application service principal."
  value       = azuread_service_principal.this.object_id
}

output "application_id" {
  description = "Application (client) ID connected to this Enterprise Application."
  value       = azuread_service_principal.this.client_id
}

output "display_name" {
  description = "Display name of the Enterprise Application."
  value       = azuread_service_principal.this.display_name
}

output "app_role_assignment_ids" {
  description = "App role assignment IDs keyed by input name."
  value       = { for key, assignment in azuread_app_role_assignment.this : key => assignment.id }
}

output "application_proxy_enabled" {
  description = "Whether this module configured Application Proxy."
  value       = var.create_application_proxy
}

output "application_proxy_external_url" {
  description = "Application Proxy external URL configured on the connected app registration."
  value       = var.create_application_proxy ? msgraph_update_resource.application_proxy[0].output.external_url : null
}

output "application_proxy_internal_url" {
  description = "Application Proxy internal URL configured on the connected app registration."
  value       = var.create_application_proxy ? msgraph_update_resource.application_proxy[0].output.internal_url : null
}

output "owners" {
  description = "Effective owner object IDs applied to the Enterprise Application."
  value       = local.owners
}
