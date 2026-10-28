output "id" {
  value       = azurerm_mssql_managed_instance.this.id
  description = "Resource ID of the SQL Managed Instance."
}

output "name" {
  value       = azurerm_mssql_managed_instance.this.name
  description = "Name of the SQL Managed Instance."
}

output "fqdn" {
  value       = azurerm_mssql_managed_instance.this.fqdn
  description = "Fully qualified domain name of the SQL Managed Instance."
}

output "resource_group_name" {
  value       = azurerm_mssql_managed_instance.this.resource_group_name
  description = "Resource group containing the SQL Managed Instance."
}

output "location" {
  value       = azurerm_mssql_managed_instance.this.location
  description = "Azure region of the SQL Managed Instance."
}

output "subnet_id" {
  value       = azurerm_mssql_managed_instance.this.subnet_id
  description = "Delegated subnet resource ID used by the SQL Managed Instance."
}

output "administrator_login" {
  value       = azurerm_mssql_managed_instance.this.administrator_login
  description = "Administrator login name for the SQL Managed Instance."
}

output "principal_id" {
  value       = try(azurerm_mssql_managed_instance.this.identity[0].principal_id, null)
  description = "Managed identity principal ID, if enabled."
}

output "diagnostic_setting_id" {
  value       = try(azurerm_monitor_diagnostic_setting.this[0].id, null)
  description = "Diagnostic setting ID, if diagnostics are enabled."
}

output "tags" {
  value       = azurerm_mssql_managed_instance.this.tags
  description = "Tags applied to the SQL Managed Instance."
}

output "app_admin_group_role_assignment_ids" {
  description = "Map of Contributor role assignment IDs keyed by app_admin_group principal ID."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Map of Reader role assignment IDs keyed by app_user_group principal ID."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}
