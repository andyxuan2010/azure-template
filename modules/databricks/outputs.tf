output "id" {
  description = "The Databricks workspace resource ID."
  value       = azurerm_databricks_workspace.this.id
}

output "name" {
  description = "The Databricks workspace name."
  value       = azurerm_databricks_workspace.this.name
}

output "workspace_id" {
  description = "The Databricks workspace ID."
  value       = azurerm_databricks_workspace.this.workspace_id
}

output "workspace_url" {
  description = "The Databricks workspace URL."
  value       = azurerm_databricks_workspace.this.workspace_url
}

output "managed_resource_group_id" {
  description = "The managed resource group resource ID."
  value       = azurerm_databricks_workspace.this.managed_resource_group_id
}

output "managed_resource_group_name" {
  description = "The managed resource group name."
  value       = azurerm_databricks_workspace.this.managed_resource_group_name
}

output "disk_encryption_set_id" {
  description = "The disk encryption set resource ID when CMK is enabled."
  value       = try(azurerm_databricks_workspace.this.disk_encryption_set_id, null)
}

output "app_admin_group_role_assignment_ids" {
  description = "Contributor role assignment IDs keyed by principal ID."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Reader role assignment IDs keyed by principal ID."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}

output "diagnostic_setting_id" {
  description = "Diagnostic setting ID when diagnostics are enabled."
  value       = try(azurerm_monitor_diagnostic_setting.this[0].id, null)
}

output "tags" {
  description = "Effective tags applied to the Databricks workspace."
  value       = azurerm_databricks_workspace.this.tags
}

output "merged_tags" {
  description = "Final merged tags applied to the Databricks workspace."
  value       = local.merged_tags
}
