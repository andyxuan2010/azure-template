output "default_url" {
  description = "Default HTTPS URL of the container Web App."
  value       = module.container_web_app.default_url
}

output "identity_principal_id" {
  description = "Principal ID to grant AcrPull when using a private Azure Container Registry."
  value       = module.container_web_app.identity_principal_id
}
