output "id" {
  description = "The ID of the storage account."
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "The name of the storage account."
  value       = azurerm_storage_account.this.name
}

output "resource_group_name" {
  description = "The name of the resource group containing the storage account."
  value       = azurerm_storage_account.this.resource_group_name
}

output "location" {
  description = "The location of the storage account."
  value       = azurerm_storage_account.this.location
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint."
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_dfs_endpoint" {
  description = "The primary Data Lake endpoint."
  value       = azurerm_storage_account.this.primary_dfs_endpoint
}

output "primary_file_endpoint" {
  description = "The primary file endpoint."
  value       = azurerm_storage_account.this.primary_file_endpoint
}

output "primary_queue_endpoint" {
  description = "The primary queue endpoint."
  value       = azurerm_storage_account.this.primary_queue_endpoint
}

output "primary_table_endpoint" {
  description = "The primary table endpoint."
  value       = azurerm_storage_account.this.primary_table_endpoint
}

output "identity" {
  description = "The identity block of the storage account."
  value       = azurerm_storage_account.this.identity
}

output "principal_id" {
  description = "The principal ID of the system-assigned managed identity, if enabled."
  value       = try(azurerm_storage_account.this.identity[0].principal_id, null)
}

output "tenant_id" {
  description = "The tenant ID of the system-assigned managed identity, if enabled."
  value       = try(azurerm_storage_account.this.identity[0].tenant_id, null)
}

output "network_rules_id" {
  description = "The ID of the storage account network rules resource, if created."
  value       = try(azurerm_storage_account_network_rules.this[0].id, null)
}

output "private_endpoint_ids" {
  description = "Map of private endpoint IDs keyed by storage subresource."
  value       = { for k, v in azurerm_private_endpoint.this : k => v.id }
}

output "private_endpoint_names" {
  description = "Map of private endpoint names keyed by storage subresource."
  value       = { for k, v in azurerm_private_endpoint.this : k => v.name }
}

output "managed_identity_role_assignment_ids" {
  description = "Map of managed identity role assignment IDs keyed by assignment name."
  value       = { for k, v in azurerm_role_assignment.managed_identity : k => v.id }
}

output "app_admin_group_role_assignment_ids" {
  description = "Map of Contributor role assignment IDs keyed by app_admin_group display name."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Map of Reader role assignment IDs keyed by app_user_group display name."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}

output "diagnostic_setting_id" {
  description = "The ID of the diagnostic setting, if created."
  value       = try(azurerm_monitor_diagnostic_setting.this[0].id, null)
}

output "tags" {
  description = "The effective tags assigned to the storage account."
  value       = azurerm_storage_account.this.tags
}
