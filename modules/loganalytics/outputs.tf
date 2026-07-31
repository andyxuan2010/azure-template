output "id" {
  description = "Log Analytics workspace ID."
  value       = azurerm_log_analytics_workspace.this.id
}

output "name" {
  description = "Log Analytics workspace name."
  value       = azurerm_log_analytics_workspace.this.name
}

output "workspace_id" {
  description = "Log Analytics workspace ID value."
  value       = azurerm_log_analytics_workspace.this.workspace_id
}

output "primary_shared_key" {
  description = "Workspace primary shared key."
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}

output "secondary_shared_key" {
  description = "Workspace secondary shared key."
  value       = azurerm_log_analytics_workspace.this.secondary_shared_key
  sensitive   = true
}

output "identity" {
  description = "Managed identity details configured on the workspace."
  value       = try(azurerm_log_analytics_workspace.this.identity[0], null)
}

output "tags" {
  description = "Effective tags applied to the workspace."
  value       = azurerm_log_analytics_workspace.this.tags
}

output "merged_tags" {
  description = "Final merged tags applied to the workspace."
  value       = local.merged_tags
}
