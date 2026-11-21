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

output "location_code" {
  description = "The resolved location code used for generated naming."
  value       = local.location_code_resolved
}

output "app_env" {
  description = "The deployment environment used by the module."
  value       = var.app_env
}

output "account_kind" {
  description = "The storage account kind."
  value       = azurerm_storage_account.this.account_kind
}

output "account_tier" {
  description = "The storage account tier."
  value       = azurerm_storage_account.this.account_tier
}

output "account_replication_type" {
  description = "The storage account replication type."
  value       = azurerm_storage_account.this.account_replication_type
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

output "primary_web_endpoint" {
  description = "The primary static website endpoint."
  value       = azurerm_storage_account.this.primary_web_endpoint
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

output "identity_type" {
  description = "The resolved managed identity type assigned to the storage account."
  value       = local.identity_type
}

output "network_rules_id" {
  description = "The ID of the storage account network rules resource, if created."
  value       = try(azurerm_storage_account_network_rules.this[0].id, null)
}

output "network_rules_config" {
  description = "Effective storage account network rule configuration."
  value = {
    enabled                   = var.enable_network_rules
    default_action            = var.enable_network_rules ? var.network_rules_default_action : null
    bypass                    = var.enable_network_rules ? var.network_rules_bypass : []
    ip_rule_count             = var.enable_network_rules ? length(var.network_rules_ip_rules) : 0
    subnet_rule_count         = var.enable_network_rules ? length(var.network_rules_virtual_network_subnet_ids) : 0
    private_link_access_count = var.enable_network_rules ? length(var.network_rules_private_link_access) : 0
  }
}

output "container_ids" {
  description = "Map of storage container IDs keyed by container name."
  value       = { for k, v in azurerm_storage_container.this : k => v.id }
}

output "file_share_ids" {
  description = "Map of Azure Files share IDs keyed by share name."
  value       = { for k, v in azurerm_storage_share.this : k => v.id }
}

output "queue_ids" {
  description = "Map of storage queue IDs keyed by queue name."
  value       = { for k, v in azurerm_storage_queue.this : k => v.id }
}

output "table_ids" {
  description = "Map of storage table IDs keyed by table name."
  value       = { for k, v in azurerm_storage_table.this : k => v.id }
}

output "private_endpoint_ids" {
  description = "Map of private endpoint IDs keyed by storage subresource."
  value       = { for k, v in azurerm_private_endpoint.this : k => v.id }
}

output "private_endpoint_names" {
  description = "Map of private endpoint names keyed by storage subresource."
  value       = { for k, v in azurerm_private_endpoint.this : k => v.name }
}

output "private_endpoint_fqdns" {
  description = "Map of private endpoint FQDN lists keyed by storage subresource."
  value       = { for k, v in azurerm_private_endpoint.this : k => [for config in v.custom_dns_configs : config.fqdn] }
}

output "private_endpoint_ip_addresses" {
  description = "Map of private endpoint IP address lists keyed by storage subresource."
  value       = { for k, v in azurerm_private_endpoint.this : k => flatten([for config in v.custom_dns_configs : config.ip_addresses]) }
}

output "managed_identity_role_assignment_ids" {
  description = "Map of managed identity role assignment IDs keyed by assignment name."
  value       = { for k, v in azurerm_role_assignment.managed_identity : k => v.id }
}

output "app_admin_group_role_assignment_ids" {
  description = "Map of Contributor role assignment IDs keyed by app_admin_group input."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_admin_group_data_plane_role_assignment_ids" {
  description = "Map of storage data-plane role assignment IDs keyed by app_admin_group input and role."
  value       = { for k, v in azurerm_role_assignment.app_admin_group_data_plane : k => v.id }
}

output "app_admin_group_principal_ids" {
  description = "Map of resolved admin group principal IDs keyed by app_admin_group input."
  value       = local.app_admin_group_principal_ids
}

output "app_user_group_role_assignment_ids" {
  description = "Map of Reader role assignment IDs keyed by app_user_group display name."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}

output "app_user_group_principal_ids" {
  description = "Map of resolved Reader group principal IDs keyed by app_user_group input."
  value       = local.app_user_group_principal_ids
}

output "terraform_execution_identity_role_assignment_ids" {
  description = "Map of role assignment IDs created for the current Terraform execution identity."
  value       = { for k, v in azurerm_role_assignment.terraform_execution_identity : k => v.id }
}

output "role_assignment_ids" {
  description = "Map of additional role assignment IDs keyed by role_assignments input."
  value       = { for k, v in azurerm_role_assignment.this : k => v.id }
}

output "role_assignment_count" {
  description = "Total number of role assignments requested by this module."
  value       = length(local.app_admin_group_principal_ids) + length(local.app_admin_group_data_plane_role_assignments) + length(local.app_user_group_principal_ids) + length(local.terraform_execution_identity_role_assignments) + length(var.role_assignments) + length(local.managed_identity_role_assignments_effective)
}

output "diagnostic_setting_id" {
  description = "The ID of the diagnostic setting, if created."
  value       = try(azurerm_monitor_diagnostic_setting.this[0].id, null)
}

output "diagnostics_enabled" {
  description = "Whether diagnostics are enabled by this module."
  value       = local.diagnostics_enabled
}

output "diagnostic_setting_name" {
  description = "The effective diagnostic setting name."
  value       = local.diagnostic_setting_name
}

output "tags" {
  description = "The effective tags assigned to the storage account."
  value       = azurerm_storage_account.this.tags
}

output "default_to_oauth_authentication" {
  description = "Whether the storage account defaults requests to Microsoft Entra authorization where supported."
  value       = azurerm_storage_account.this.default_to_oauth_authentication
}
