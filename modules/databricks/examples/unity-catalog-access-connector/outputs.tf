output "workspace_id" {
  description = "Azure Databricks workspace ID."
  value       = module.databricks.id
}

output "access_connector_id" {
  description = "Databricks access connector resource ID."
  value       = module.databricks.access_connector_id
}

output "access_connector_identity" {
  description = "Managed identity details used for external storage access."
  value       = module.databricks.access_connector_identity
}
