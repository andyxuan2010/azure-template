output "identity_id" {
  description = "Resource ID of the user-assigned managed identity."
  value       = module.identity.id
}

output "client_id" {
  description = "Client ID used by the Kubernetes workload."
  value       = module.identity.client_id
}

output "federated_identity_credential_ids" {
  description = "Federated identity credential IDs keyed by name."
  value       = module.identity.federated_identity_credential_ids
}

output "role_assignment_ids" {
  description = "Role assignment IDs keyed by name."
  value       = module.identity.role_assignment_ids
}
