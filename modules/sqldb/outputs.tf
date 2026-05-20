output "server_name" {
  description = "The Azure SQL logical server name."
  value       = azurerm_mssql_server.sql_server.name
}

output "database_name" {
  description = "The Azure SQL database name."
  value       = azurerm_mssql_database.sql_db.name
}

output "server_id" {
  description = "Resource ID of the Azure SQL logical server."
  value       = azurerm_mssql_server.sql_server.id
}

output "database_id" {
  description = "Resource ID of the Azure SQL database."
  value       = azurerm_mssql_database.sql_db.id
}

output "resource_group_name" {
  description = "Resource group where SQL resources are deployed."
  value       = azurerm_mssql_server.sql_server.resource_group_name
}

output "location" {
  description = "Azure region where SQL resources are deployed."
  value       = azurerm_mssql_server.sql_server.location
}

output "location_code" {
  description = "Short location code used for generated naming."
  value       = local.location_code_resolved
}

output "server_fqdn" {
  description = "Fully qualified domain name of the Azure SQL logical server."
  value       = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled on the SQL server."
  value       = var.public_network_access_enabled
}

output "public_endpoint" {
  description = "Public SQL endpoint details when public access is enabled. Azure SQL exposes a public FQDN rather than a dedicated static IP."
  value = var.public_network_access_enabled ? {
    fqdn                  = azurerm_mssql_server.sql_server.fully_qualified_domain_name
    public_network_access = var.public_network_access_enabled
    public_ip             = null
    firewall_rules        = var.firewall_rules
    allow_azure_services  = var.allow_azure_services
  } : null
}

output "server_identity" {
  description = "Managed identity details for the SQL server."
  value       = try(azurerm_mssql_server.sql_server.identity[0], null)
}

output "server_identity_type" {
  description = "Managed identity type configured on the SQL server."
  value       = local.server_identity_type
}

output "server_identity_ids" {
  description = "User-assigned managed identity IDs configured on the SQL server."
  value       = local.server_identity_ids
}

output "server_principal_id" {
  description = "Principal ID of the SQL server system-assigned managed identity."
  value       = try(azurerm_mssql_server.sql_server.identity[0].principal_id, null)
}

output "database_identity_ids" {
  description = "User-assigned managed identity IDs configured on the SQL database."
  value       = local.database_identity_ids
}

output "azuread_administrator_enabled" {
  description = "Whether a Microsoft Entra administrator is configured."
  value       = local.azuread_admin_enabled
}

output "azuread_authentication_only" {
  description = "Whether Microsoft Entra-only authentication is enabled."
  value       = var.azuread_authentication_only
}

output "private_endpoint_id" {
  description = "Private endpoint resource ID when private endpoint is enabled."
  value       = try(azurerm_private_endpoint.sql[0].id, null)
}

output "private_endpoint_name" {
  description = "Private endpoint name when private endpoint is enabled."
  value       = try(azurerm_private_endpoint.sql[0].name, null)
}

output "private_endpoint_nic_id" {
  description = "Private endpoint network interface ID when private endpoint is enabled."
  value       = try(azurerm_private_endpoint.sql[0].network_interface[0].id, null)
}

output "private_endpoint_fqdns" {
  description = "Private endpoint FQDNs when private endpoint is enabled."
  value       = try([for config in azurerm_private_endpoint.sql[0].custom_dns_configs : config.fqdn], null)
}

output "private_endpoint_ip_addresses" {
  description = "Private endpoint IP addresses when private endpoint is enabled."
  value       = try(flatten([for config in azurerm_private_endpoint.sql[0].custom_dns_configs : config.ip_addresses]), null)
}

output "private_dns_zone_ids" {
  description = "Private DNS zone IDs associated with the private endpoint."
  value       = local.private_dns_zone_ids
}

output "diagnostic_setting_id" {
  description = "Diagnostic setting resource ID when diagnostics are enabled."
  value       = try(azurerm_monitor_diagnostic_setting.sql_diagnostics[0].id, null)
}

output "diagnostics_enabled" {
  description = "Whether diagnostic settings are enabled."
  value       = local.diagnostics_enabled
}

output "server_audit_policy_id" {
  description = "Server audit policy resource ID when enabled."
  value       = try(azurerm_mssql_server_extended_auditing_policy.audit[0].id, null)
}

output "database_audit_policy_id" {
  description = "Database audit policy resource ID when enabled."
  value       = try(azurerm_mssql_database_extended_auditing_policy.audit[0].id, null)
}

output "threat_detection_policy_id" {
  description = "Server threat detection policy resource ID when enabled."
  value       = try(azurerm_mssql_server_security_alert_policy.threat_detection[0].id, null)
}

output "failover_group_id" {
  description = "Failover group resource ID when configured."
  value       = try(azurerm_mssql_failover_group.this["this"].id, null)
}

output "failover_group_name" {
  description = "Failover group name when configured."
  value       = try(azurerm_mssql_failover_group.this["this"].name, null)
}

output "backup_configuration" {
  description = "Database backup and resiliency configuration summary."
  value = {
    short_term_retention_days   = var.backup_retention_days
    backup_interval_in_hours    = var.backup_interval_in_hours
    long_term_retention_enabled = var.enable_long_term_retention
    geo_backup_enabled          = var.geo_backup_enabled
    backup_storage_redundancy   = var.backup_storage_redundancy
    zone_redundant              = var.zone_redundant
    failover_group_enabled      = var.failover_group != null
  }
}

output "security_configuration" {
  description = "Database security and monitoring configuration summary."
  value = {
    minimum_tls_version           = var.minimum_tls_version
    public_network_access_enabled = var.public_network_access_enabled
    private_endpoint_enabled      = var.enable_private_endpoint
    azuread_admin_enabled         = local.azuread_admin_enabled
    azuread_authentication_only   = var.azuread_authentication_only
    server_audit_enabled          = var.enable_audit
    database_audit_enabled        = var.enable_database_audit
    threat_detection_enabled      = var.enable_threat_detection
    database_threat_detection     = var.enable_database_threat_detection
    diagnostics_enabled           = local.diagnostics_enabled
    tde_enabled                   = var.transparent_data_encryption_enabled
  }
}

output "app_admin_group_role_assignment_ids" {
  description = "Admin role assignment IDs keyed by principal ID."
  value       = { for key, assignment in azurerm_role_assignment.app_admin_group : key => assignment.id }
}

output "app_user_group_role_assignment_ids" {
  description = "User role assignment IDs keyed by principal ID."
  value       = { for key, assignment in azurerm_role_assignment.app_user_group : key => assignment.id }
}

output "role_assignment_ids" {
  description = "Additional role assignment IDs keyed by input key."
  value       = { for key, assignment in azurerm_role_assignment.this : key => assignment.id }
}

output "role_assignment_count" {
  description = "Total number of role assignments managed by this module."
  value       = length(azurerm_role_assignment.app_admin_group) + length(azurerm_role_assignment.app_user_group) + length(azurerm_role_assignment.this)
}

output "tags" {
  description = "Effective tags applied to SQL resources."
  value       = local.merged_tags
}

output "database_tags" {
  description = "Tags applied to the SQL database."
  value       = azurerm_mssql_database.sql_db.tags
}
