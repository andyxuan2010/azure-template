output "application_id" {
  description = "Client ID of the Microsoft Entra application."
  value       = module.application.application_id
}

output "app_role_ids" {
  description = "Exposed application role IDs keyed by role value."
  value       = module.application.app_role_ids
}

output "oauth2_permission_scope_ids" {
  description = "Exposed delegated permission scope IDs keyed by scope value."
  value       = module.application.oauth2_permission_scope_ids
}

output "web_redirect_uris" {
  description = "Effective web redirect URIs."
  value       = module.application.web_redirect_uris
}
