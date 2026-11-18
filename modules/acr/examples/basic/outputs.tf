output "registry_id" {
  description = "Resource ID of the registry."
  value       = module.acr.id
}

output "login_server" {
  description = "Registry login server."
  value       = module.acr.login_server
}
