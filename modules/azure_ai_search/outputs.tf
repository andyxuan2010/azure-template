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

output "private_endpoint_id" {
  description = "Private endpoint ID when private endpoint is enabled."
  value       = try(azurerm_private_endpoint.this[0].id, null)
}

output "private_endpoint_fqdns" {
  description = "Private endpoint FQDNs when private endpoint is enabled."
  value       = try([for config in azurerm_private_endpoint.this[0].custom_dns_configs : config.fqdn], null)
}

output "private_endpoint_ip_addresses" {
  description = "Private endpoint IP addresses when private endpoint is enabled."
  value       = try(flatten([for config in azurerm_private_endpoint.this[0].custom_dns_configs : config.ip_addresses]), null)
}

output "diagnostic_setting_id" {
  description = "Diagnostic setting ID when diagnostics are enabled."
  value       = try(azurerm_monitor_diagnostic_setting.this[0].id, null)
}

output "diagnostics_enabled" {
  description = "Boolean flag indicating whether diagnostics are enabled."
  value       = var.enable_diagnostics
}

output "app_admin_group_role_assignment_ids" {
  description = "Contributor role assignment IDs keyed by principal ID."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Reader role assignment IDs keyed by principal ID."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}

output "tags" {
  description = "Effective tags applied to the Azure AI Search service."
  value       = azurerm_search_service.this.tags
}

output "identity" {
  description = "Managed identity details for the Azure AI Search service."
  value       = try(azurerm_search_service.this.identity[0], null)
}

output "merged_tags" {
  description = "Final merged tags applied to the Azure AI Search service."
  value       = local.merged_tags
}
