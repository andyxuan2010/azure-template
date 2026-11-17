output "id" {
  description = "The Databricks workspace resource ID."
  value       = azurerm_databricks_workspace.this.id
}

output "name" {
  description = "The Databricks workspace name."
  value       = azurerm_databricks_workspace.this.name
}

output "resource_group_name" {
  description = "The resource group name where the Databricks workspace is deployed."
  value       = azurerm_databricks_workspace.this.resource_group_name
}

output "location" {
  description = "The Azure region where the Databricks workspace is deployed."
  value       = azurerm_databricks_workspace.this.location
}

output "location_code" {
  description = "The short location code used by generated names."
  value       = local.location_code_resolved
}

output "app_env" {
  description = "The deployment environment used for tags and generated names."
  value       = var.app_env
}

output "workspace_id" {
  description = "The Databricks workspace ID."
  value       = azurerm_databricks_workspace.this.workspace_id
}

output "workspace_url" {
  description = "The Databricks workspace URL."
  value       = azurerm_databricks_workspace.this.workspace_url
}

output "sku" {
  description = "The Databricks workspace SKU."
  value       = azurerm_databricks_workspace.this.sku
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled."
  value       = azurerm_databricks_workspace.this.public_network_access_enabled
}

output "managed_resource_group_id" {
  description = "The managed resource group resource ID."
  value       = azurerm_databricks_workspace.this.managed_resource_group_id
}

output "managed_resource_group_name" {
  description = "The managed resource group name."
  value       = azurerm_databricks_workspace.this.managed_resource_group_name
}

output "managed_disk_identity" {
  description = "Managed disk identity exposed by Azure Databricks for managed disk CMK scenarios."
  value       = try(azurerm_databricks_workspace.this.managed_disk_identity[0], null)
}

output "storage_account_identity" {
  description = "Storage account identity exposed by Azure Databricks for root DBFS CMK scenarios."
  value       = try(azurerm_databricks_workspace.this.storage_account_identity[0], null)
}

output "disk_encryption_set_id" {
  description = "The disk encryption set resource ID when CMK is enabled."
  value       = try(azurerm_databricks_workspace.this.disk_encryption_set_id, null)
}

output "access_connector_id" {
  description = "The Databricks access connector ID used by the workspace, if configured."
  value       = local.access_connector_id_effective != "" ? local.access_connector_id_effective : null
}

output "access_connector_name" {
  description = "The created Databricks access connector name, if created."
  value       = try(azurerm_databricks_access_connector.this[0].name, null)
}

output "access_connector_identity" {
  description = "The created Databricks access connector identity, if created."
  value       = try(azurerm_databricks_access_connector.this[0].identity[0], null)
}

output "root_dbfs_customer_managed_key_id" {
  description = "The root DBFS customer-managed key resource ID, if configured."
  value       = try(azurerm_databricks_workspace_root_dbfs_customer_managed_key.this[0].id, null)
}

output "private_endpoint_ids" {
  description = "Map of private endpoint IDs keyed by Databricks subresource name."
  value       = { for k, v in azurerm_private_endpoint.this : k => v.id }
}

output "private_endpoint_names" {
  description = "Map of private endpoint names keyed by Databricks subresource name."
  value       = { for k, v in azurerm_private_endpoint.this : k => v.name }
}

output "diagnostics_enabled" {
  description = "Boolean flag indicating whether diagnostics are enabled."
  value       = local.diagnostics_enabled
}

output "diagnostic_setting_name" {
  description = "Diagnostic setting name when diagnostics are enabled."
  value       = local.diagnostics_enabled ? local.diagnostic_setting_name : null
}

output "diagnostic_setting_id" {
  description = "Diagnostic setting ID when diagnostics are enabled."
  value       = try(azurerm_monitor_diagnostic_setting.this[0].id, null)
}

output "app_admin_group_principal_ids" {
  description = "Map of resolved app admin group principal IDs."
  value       = local.app_admin_group_principal_ids
}

output "app_user_group_principal_ids" {
  description = "Map of resolved app user group principal IDs."
  value       = local.app_user_group_principal_ids
}

output "app_admin_group_role_assignment_ids" {
  description = "Contributor role assignment IDs keyed by principal ID."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_admin_group_storage_account_contributor_role_assignment_ids" {
  description = "Storage account Contributor role assignment IDs keyed by principal ID."
  value       = { for k, v in azurerm_role_assignment.app_admin_group_storage_account_contributor : k => v.id }
}

output "app_admin_group_storage_account_blob_data_contributor_role_assignment_ids" {
  description = "Storage Blob Data Contributor role assignment IDs keyed by principal ID."
  value       = { for k, v in azurerm_role_assignment.app_admin_group_storage_account_blob_data_contributor : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Reader role assignment IDs keyed by principal ID."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}

output "app_user_group_storage_account_reader_role_assignment_ids" {
  description = "Storage account Reader role assignment IDs keyed by principal ID."
  value       = { for k, v in azurerm_role_assignment.app_user_group_storage_account_reader : k => v.id }
}

output "app_user_group_storage_account_blob_data_reader_role_assignment_ids" {
  description = "Storage Blob Data Reader role assignment IDs keyed by principal ID."
  value       = { for k, v in azurerm_role_assignment.app_user_group_storage_account_blob_data_reader : k => v.id }
}

output "role_assignment_ids" {
  description = "Map of additional workspace role assignment IDs keyed by assignment name."
  value       = { for k, v in azurerm_role_assignment.this : k => v.id }
}

output "access_connector_role_assignment_ids" {
  description = "Map of access connector role assignment IDs keyed by assignment name."
  value       = { for k, v in azurerm_role_assignment.access_connector : k => v.id }
}

output "role_assignment_count" {
  description = "Total number of role assignments created by this module."
  value = (
    length(azurerm_role_assignment.app_admin_group) +
    length(azurerm_role_assignment.app_admin_group_storage_account_contributor) +
    length(azurerm_role_assignment.app_admin_group_storage_account_blob_data_contributor) +
    length(azurerm_role_assignment.app_user_group) +
    length(azurerm_role_assignment.app_user_group_storage_account_reader) +
    length(azurerm_role_assignment.app_user_group_storage_account_blob_data_reader) +
    length(azurerm_role_assignment.this) +
    length(azurerm_role_assignment.access_connector)
  )
}

output "tags" {
  description = "Effective tags applied to the Databricks workspace."
  value       = azurerm_databricks_workspace.this.tags
}

output "merged_tags" {
  description = "Final merged tags applied to the Databricks workspace."
  value       = local.merged_tags
}
