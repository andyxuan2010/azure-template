output "id" {
  description = "The Cosmos DB account resource ID."
  value       = azurerm_cosmosdb_account.this.id
}

output "name" {
  description = "The Cosmos DB account name."
  value       = azurerm_cosmosdb_account.this.name
}

output "endpoint" {
  description = "The Cosmos DB account endpoint."
  value       = azurerm_cosmosdb_account.this.endpoint
}

output "read_endpoints" {
  description = "Read endpoints for the Cosmos DB account."
  value       = azurerm_cosmosdb_account.this.read_endpoints
}

output "write_endpoints" {
  description = "Write endpoints for the Cosmos DB account."
  value       = azurerm_cosmosdb_account.this.write_endpoints
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled."
  value       = azurerm_cosmosdb_account.this.public_network_access_enabled
}

output "local_authentication_disabled" {
  description = "Whether key-based local authentication is disabled."
  value       = var.local_authentication_disabled
}

output "identity_type" {
  description = "Configured managed identity type."
  value       = local.identity_type
}

output "primary_sql_connection_string" {
  description = "Primary SQL API connection string. Prefer Entra ID RBAC instead of using this output."
  value       = azurerm_cosmosdb_account.this.primary_sql_connection_string
  sensitive   = true
}

output "sql_database_ids" {
  description = "SQL database resource IDs keyed by database name."
  value       = { for k, v in azurerm_cosmosdb_sql_database.this : k => v.id }
}

output "sql_container_ids" {
  description = "SQL container resource IDs keyed by container name."
  value       = { for k, v in azurerm_cosmosdb_sql_container.this : k => v.id }
}

output "sql_role_definition_ids" {
  description = "SQL role definition IDs keyed by role name."
  value       = { for k, v in azurerm_cosmosdb_sql_role_definition.this : k => v.id }
}

output "sql_role_assignment_ids" {
  description = "SQL role assignment IDs keyed by assignment name."
  value       = { for k, v in azurerm_cosmosdb_sql_role_assignment.this : k => v.id }
}

output "app_admin_group_role_assignment_ids" {
  description = "Admin role assignment IDs keyed by principal key."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Reader role assignment IDs keyed by principal key."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}

output "role_assignment_ids" {
  description = "Additional Azure role assignment IDs keyed by assignment name."
  value       = { for k, v in azurerm_role_assignment.this : k => v.id }
}

output "role_assignment_count" {
  description = "Total account-scope Azure role assignment count created by this module."
  value       = length(azurerm_role_assignment.app_admin_group) + length(azurerm_role_assignment.app_user_group) + length(azurerm_role_assignment.this)
}

output "private_endpoint_id" {
  description = "Private endpoint ID when private endpoint is enabled."
  value       = try(azurerm_private_endpoint.this[0].id, null)
}

output "private_endpoint_name" {
  description = "Private endpoint name when private endpoint is enabled."
  value       = try(azurerm_private_endpoint.this[0].name, null)
}

output "private_dns_zone_ids" {
  description = "Private DNS zone IDs attached to the private endpoint."
  value       = local.private_dns_zone_ids
}

output "diagnostic_setting_id" {
  description = "Diagnostic setting ID when diagnostics are enabled."
  value       = try(azurerm_monitor_diagnostic_setting.this[0].id, null)
}

output "diagnostics_enabled" {
  description = "Whether diagnostic settings are enabled by this module."
  value       = local.diagnostics_enabled
}

output "tags" {
  description = "Effective tags applied to the Cosmos DB account."
  value       = azurerm_cosmosdb_account.this.tags
}

output "merged_tags" {
  description = "Final merged tags applied to module resources."
  value       = local.merged_tags
}
