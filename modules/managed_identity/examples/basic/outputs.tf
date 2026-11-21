output "identity_id" {
  description = "Resource ID of the user-assigned managed identity."
  value       = module.identity.id
}

output "client_id" {
  description = "Client ID of the user-assigned managed identity."
  value       = module.identity.client_id
}

output "principal_id" {
  description = "Principal ID of the user-assigned managed identity."
  value       = module.identity.principal_id
}
