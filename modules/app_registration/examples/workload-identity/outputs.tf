output "application_id" {
  description = "Client ID supplied to the GitHub Actions Azure login step."
  value       = module.github_workload_identity.application_id
}

output "federated_identity_credential_ids" {
  description = "Federated identity credential resource IDs keyed by scenario name."
  value       = module.github_workload_identity.federated_identity_credential_ids
}
