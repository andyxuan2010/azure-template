output "id" {
  description = "The Azure AI Search service resource ID."
  value       = azurerm_search_service.this.id
}

output "name" {
  description = "The Azure AI Search service name."
  value       = azurerm_search_service.this.name
}

output "resource_group_name" {
  description = "The resource group name where the Azure AI Search service is deployed."
  value       = azurerm_search_service.this.resource_group_name
}

output "location" {
  description = "The Azure region where the Azure AI Search service is deployed."
  value       = azurerm_search_service.this.location
}

output "location_code" {
  description = "The short location code used by generated names."
  value       = local.location_code_resolved
}

output "app_env" {
  description = "The deployment environment used for tags and generated names."
  value       = var.app_env
}

output "endpoint" {
  description = "The Azure AI Search endpoint."
  value       = local.endpoint
}

output "sku" {
  description = "The Azure AI Search service SKU."
  value       = azurerm_search_service.this.sku
}

output "replica_count" {
  description = "The replica count configured on the Azure AI Search service."
  value       = azurerm_search_service.this.replica_count
}

output "partition_count" {
  description = "The partition count configured on the Azure AI Search service."
  value       = azurerm_search_service.this.partition_count
}

output "hosting_mode" {
  description = "The hosting mode configured on the Azure AI Search service."
  value       = azurerm_search_service.this.hosting_mode
}

output "semantic_search_sku" {
  description = "The semantic search SKU configured on the Azure AI Search service."
  value       = azurerm_search_service.this.semantic_search_sku
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled."
  value       = azurerm_search_service.this.public_network_access_enabled
}

output "local_authentication_enabled" {
  description = "Whether API-key local authentication is enabled."
  value       = azurerm_search_service.this.local_authentication_enabled
}

output "customer_managed_key_enforcement_enabled" {
  description = "Whether customer-managed key enforcement is enabled."
  value       = azurerm_search_service.this.customer_managed_key_enforcement_enabled
}

output "customer_managed_key_encryption_compliance_status" {
  description = "Customer-managed key encryption compliance status reported by Azure AI Search."
  value       = azurerm_search_service.this.customer_managed_key_encryption_compliance_status
}

output "primary_key" {
  description = "The primary admin key."
  value       = azurerm_search_service.this.primary_key
  sensitive   = true
}

output "secondary_key" {
  description = "The secondary admin key."
  value       = azurerm_search_service.this.secondary_key
  sensitive   = true
}

output "query_keys" {
  description = "The query keys exposed by the Azure AI Search service."
  value       = azurerm_search_service.this.query_keys
  sensitive   = true
}

output "identity" {
  description = "Managed identity details for the Azure AI Search service."
  value       = try(azurerm_search_service.this.identity[0], null)
}

output "identity_type" {
  description = "The managed identity type enabled on the Azure AI Search service."
  value       = local.identity_type
}

output "principal_id" {
  description = "The principal ID of the system-assigned managed identity, when enabled."
  value       = try(azurerm_search_service.this.identity[0].principal_id, null)
}

output "tenant_id" {
  description = "The tenant ID of the system-assigned managed identity, when enabled."
  value       = try(azurerm_search_service.this.identity[0].tenant_id, null)
}

output "private_endpoint_id" {
  description = "Private endpoint ID when private endpoint is enabled."
  value       = try(azurerm_private_endpoint.this[0].id, null)
}

output "private_endpoint_name" {
  description = "Private endpoint name when private endpoint is enabled."
  value       = try(azurerm_private_endpoint.this[0].name, null)
}

output "private_endpoint_fqdns" {
  description = "Private endpoint FQDNs when private endpoint is enabled."
  value       = try([for config in azurerm_private_endpoint.this[0].custom_dns_configs : config.fqdn], null)
}

output "private_endpoint_ip_addresses" {
  description = "Private endpoint IP addresses when private endpoint is enabled."
  value       = try(flatten([for config in azurerm_private_endpoint.this[0].custom_dns_configs : config.ip_addresses]), null)
}

output "shared_private_link_service_ids" {
  description = "Map of shared private link resource IDs keyed by input key."
  value       = { for k, v in azurerm_search_shared_private_link_service.this : k => v.id }
}

output "shared_private_link_service_statuses" {
  description = "Map of shared private link resource approval statuses keyed by input key."
  value       = { for k, v in azurerm_search_shared_private_link_service.this : k => v.status }
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

output "app_user_group_role_assignment_ids" {
  description = "Reader role assignment IDs keyed by principal ID."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}

output "role_assignment_ids" {
  description = "Map of additional role assignment IDs keyed by assignment name."
  value       = { for k, v in azurerm_role_assignment.this : k => v.id }
}

output "role_assignment_count" {
  description = "Total number of role assignments created by this module."
  value = (
    length(azurerm_role_assignment.app_admin_group) +
    length(azurerm_role_assignment.app_user_group) +
    length(azurerm_role_assignment.this)
  )
}

output "tags" {
  description = "Effective tags applied to the Azure AI Search service."
  value       = azurerm_search_service.this.tags
}

output "merged_tags" {
  description = "Final merged tags applied to the Azure AI Search service."
  value       = local.merged_tags
}
