output "workspace_id" {
  description = "Azure Databricks workspace resource ID."
  value       = module.databricks.id
}

output "workspace_url" {
  description = "Azure Databricks workspace URL."
  value       = module.databricks.workspace_url
}

output "managed_resource_group_id" {
  description = "Azure-managed workspace resource group ID."
  value       = module.databricks.managed_resource_group_id
}
