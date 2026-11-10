output "workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  value       = module.log_analytics.id
}

output "identity" {
  description = "Managed identity details for the workspace."
  value       = module.log_analytics.identity
}
