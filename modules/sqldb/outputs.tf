output "server_name" {
  value       = azurerm_mssql_server.sql_server.name
  description = "The name of the SQL Server"
}

output "server_fqdn" {
  value       = azurerm_mssql_server.sql_server.fully_qualified_domain_name
  description = "FQDN of the SQL Server"
}

output "database_name" {
  value       = azurerm_mssql_database.sql_db.name
  description = "The name of the SQL Database"
}

output "server_id" {
  value       = azurerm_mssql_server.sql_server.id
  description = "Resource ID of the SQL Server"
}

output "database_id" {
  value       = azurerm_mssql_database.sql_db.id
  description = "Resource ID of the SQL Database"
}

output "server_principal_id" {
  value       = try(azurerm_mssql_server.sql_server.identity[0].principal_id, null)
  description = "Principal ID of the SQL Server managed identity."
}

output "private_endpoint_id" {
  value       = try(azurerm_private_endpoint.sql[0].id, null)
  description = "Resource ID of the private endpoint (if enabled)"
}

output "private_endpoint_nic_id" {
  value       = try(azurerm_private_endpoint.sql[0].network_interface[0].id, null)
  description = "NIC ID of the private endpoint (if enabled)"
}

output "database_tags" {
  value       = azurerm_mssql_database.sql_db.tags
  description = "Tags applied to the SQL Database"
  sensitive   = false
}

output "diagnostic_setting_id" {
  value       = try(azurerm_monitor_diagnostic_setting.sql_diagnostics[0].id, null)
  description = "Resource ID of the diagnostic setting, if enabled."
}

output "backup_configuration" {
  value = {
    retention_days              = var.backup_retention_days
    long_term_retention_enabled = var.enable_long_term_retention
    threat_detection_enabled    = var.enable_threat_detection
    audit_enabled               = var.enable_audit
    diagnostics_enabled         = var.enable_diagnostics
    zone_redundant              = var.zone_redundant
  }
  description = "Database backup and security configuration summary"
}

output "app_admin_group_role_assignment_ids" {
  description = "Map of Contributor role assignment IDs keyed by app_admin_group principal ID."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Map of Reader role assignment IDs keyed by app_user_group principal ID."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}
