output "workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  value       = module.log_analytics.id
}

output "workspace_name" {
  description = "Name of the Log Analytics workspace."
  value       = module.log_analytics.name
}
