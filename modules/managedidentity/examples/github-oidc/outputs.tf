output "identity_id" {
  description = "Resource ID of the GitHub workload identity."
  value       = module.github_identity.id
}

output "client_id" {
  description = "Client ID configured in the GitHub Actions login step."
  value       = module.github_identity.client_id
}

output "tenant_id" {
  description = "Tenant ID configured in the GitHub Actions login step."
  value       = module.github_identity.tenant_id
}
