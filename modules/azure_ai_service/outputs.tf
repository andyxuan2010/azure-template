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

output "location_code" {
  description = "The short location code used by generated names."
  value       = local.location_code_resolved
}

output "app_env" {
  description = "The deployment environment used for tags and generated names."
  value       = var.app_env
}

output "kind" {
  description = "The Cognitive Services account kind."
  value       = azurerm_cognitive_account.this.kind
}

output "sku_name" {
  description = "The Cognitive Services account SKU."
  value       = azurerm_cognitive_account.this.sku_name
}

output "endpoint" {
  description = "The Azure AI Services endpoint."
  value       = azurerm_cognitive_account.this.endpoint
}

output "custom_subdomain_name" {
  description = "The effective custom subdomain name configured on the Azure AI Services account."
  value       = local.custom_subdomain_name
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled."
  value       = azurerm_cognitive_account.this.public_network_access_enabled
}

output "local_auth_enabled" {
  description = "Whether local authentication keys are enabled."
  value       = azurerm_cognitive_account.this.local_auth_enabled
}

output "outbound_network_access_restricted" {
  description = "Whether outbound network access is restricted."
  value       = azurerm_cognitive_account.this.outbound_network_access_restricted
}

output "project_management_enabled" {
  description = "Whether project management is enabled."
  value       = azurerm_cognitive_account.this.project_management_enabled
}

output "primary_access_key" {
  description = "The primary access key when local authentication is enabled."
  value       = try(azurerm_cognitive_account.this.primary_access_key, null)
  sensitive   = true
}

output "secondary_access_key" {
  description = "The secondary access key when local authentication is enabled."
  value       = try(azurerm_cognitive_account.this.secondary_access_key, null)
  sensitive   = true
}

output "identity" {
  description = "Managed identity details for the Azure AI Services account."
  value       = try(azurerm_cognitive_account.this.identity[0], null)
}

output "identity_type" {
  description = "The managed identity type enabled on the Azure AI Services account."
  value       = local.identity_type
}

output "principal_id" {
  description = "The principal ID of the system-assigned managed identity, when enabled."
  value       = try(azurerm_cognitive_account.this.identity[0].principal_id, null)
}

output "tenant_id" {
  description = "The tenant ID of the system-assigned managed identity, when enabled."
  value       = try(azurerm_cognitive_account.this.identity[0].tenant_id, null)
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

output "rai_policy_ids" {
  description = "Map of Responsible AI policy IDs keyed by input key."
  value       = { for k, v in azurerm_cognitive_account_rai_policy.this : k => v.id }
}

output "deployment_ids" {
  description = "Map of Cognitive deployment IDs keyed by input key."
  value       = { for k, v in azurerm_cognitive_deployment.this : k => v.id }
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
  description = "Effective tags applied to the Azure AI Services account."
  value       = azurerm_cognitive_account.this.tags
}

output "merged_tags" {
  description = "Final merged tags applied to the Azure AI Services account."
  value       = local.merged_tags
}
