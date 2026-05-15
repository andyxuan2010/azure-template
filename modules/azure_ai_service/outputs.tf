output "id" {
  description = "The Azure AI Services account resource ID."
  value       = azurerm_cognitive_account.this.id
}

output "name" {
  description = "The Azure AI Services account name."
  value       = azurerm_cognitive_account.this.name
}

output "resource_group_name" {
  description = "The resource group name where the Azure AI Services account is deployed."
  value       = azurerm_cognitive_account.this.resource_group_name
}

output "location" {
  description = "The Azure region where the Azure AI Services account is deployed."
  value       = azurerm_cognitive_account.this.location
}

output "endpoint" {
  description = "The Azure AI Services endpoint."
  value       = azurerm_cognitive_account.this.endpoint
}

output "custom_subdomain_name" {
  description = "The effective custom subdomain name configured on the Azure AI Services account."
  value       = local.custom_subdomain_name
}

output "primary_access_key" {
  description = "The primary access key."
  value       = azurerm_cognitive_account.this.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "The secondary access key."
  value       = azurerm_cognitive_account.this.secondary_access_key
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

output "app_admin_group_role_assignment_ids" {
  description = "Contributor role assignment IDs keyed by principal ID."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Reader role assignment IDs keyed by principal ID."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}

output "tags" {
  description = "Effective tags applied to the Azure AI Services account."
  value       = azurerm_cognitive_account.this.tags
}

output "identity" {
  description = "Managed identity details for the Azure AI Services account."
  value       = try(azurerm_cognitive_account.this.identity[0], null)
}

output "merged_tags" {
  description = "Final merged tags applied to the Azure AI Services account."
  value       = local.merged_tags
}
