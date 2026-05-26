output "managed_database_name" {
  value       = azurerm_mssql_managed_database.this.name
  description = "The name of the managed database"
}

output "managed_database_id" {
  value       = azurerm_mssql_managed_database.this.id
  description = "Resource ID of the managed database"
}

output "managed_instance_id" {
  value       = data.azurerm_mssql_managed_instance.this.id
  description = "The managed instance resource ID referenced"
}

output "managed_database_tags" {
  value       = azurerm_mssql_managed_database.this.tags
  description = "Tags applied to the managed database"
}

output "diagnostics_enabled" {
  value       = try(azurerm_monitor_diagnostic_setting.this[0].id, null)
  description = "Diagnostic setting ID (if created)"
}

output "app_admin_group_role_assignment_ids" {
  description = "Map of Contributor role assignment IDs keyed by app_admin_group principal ID."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_admin_group_managed_instance_role_assignment_ids" {
  description = "Map of SQL Managed Instance Reader role assignment IDs keyed by app_admin_group principal ID."
  value       = { for k, v in azurerm_role_assignment.app_admin_group_managed_instance : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Map of Reader role assignment IDs keyed by app_user_group principal ID."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}

output "app_user_group_managed_instance_role_assignment_ids" {
  description = "Map of SQL Managed Instance Reader role assignment IDs keyed by app_user_group principal ID."
  value       = { for k, v in azurerm_role_assignment.app_user_group_managed_instance : k => v.id }
}
