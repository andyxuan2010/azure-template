output "id" {
  description = "The Azure OpenAI account resource ID."
  value       = azurerm_cognitive_account.this.id
}

output "name" {
  description = "The Azure OpenAI account name."
  value       = azurerm_cognitive_account.this.name
}

output "resource_group_name" {
  description = "The resource group name where the Azure OpenAI account is deployed."
  value       = azurerm_cognitive_account.this.resource_group_name
}

output "location" {
  description = "The Azure region where the Azure OpenAI account is deployed."
  value       = azurerm_cognitive_account.this.location
}

output "location_code" {
  description = "Short location code used for generated naming."
  value       = local.location_code_resolved
}

output "endpoint" {
  description = "The Azure OpenAI endpoint."
  value       = azurerm_cognitive_account.this.endpoint
}

output "custom_subdomain_name" {
  description = "The effective custom subdomain name configured on the Azure OpenAI account."
  value       = local.custom_subdomain_name
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled."
  value       = var.public_network_access_enabled
}

output "local_auth_enabled" {
  description = "Whether local key-based authentication is enabled."
  value       = var.local_auth_enabled
}

output "primary_access_key" {
  description = "The primary access key when local authentication is enabled."
  value       = var.local_auth_enabled ? azurerm_cognitive_account.this.primary_access_key : null
  sensitive   = true
}

output "secondary_access_key" {
  description = "The secondary access key when local authentication is enabled."
  value       = var.local_auth_enabled ? azurerm_cognitive_account.this.secondary_access_key : null
  sensitive   = true
}

output "deployment_ids" {
  description = "Deployment resource IDs keyed by deployment name."
  value       = { for k, v in azurerm_cognitive_deployment.this : k => v.id }
}

output "deployment_names" {
  description = "Deployment names keyed by deployment key."
  value       = { for k, v in azurerm_cognitive_deployment.this : k => v.name }
}

output "deployment_details" {
  description = "Deployment details keyed by deployment name."
  value = {
    for k, v in azurerm_cognitive_deployment.this : k => {
      id                     = v.id
      name                   = v.name
      version_upgrade_option = v.version_upgrade_option
      rai_policy_name        = v.rai_policy_name
    }
  }
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

output "private_dns_zone_ids" {
  description = "Private DNS zone IDs associated with the private endpoint."
  value       = local.private_dns_zone_ids
}

output "diagnostic_setting_id" {
  description = "Diagnostic setting ID when diagnostics are enabled."
  value       = try(azurerm_monitor_diagnostic_setting.this[0].id, null)
}

output "diagnostics_enabled" {
  description = "Whether diagnostic settings are enabled."
  value       = local.diagnostics_enabled
}

output "app_admin_group_role_assignment_ids" {
  description = "Admin role assignment IDs keyed by principal ID."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "User role assignment IDs keyed by principal ID."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}

output "role_assignment_ids" {
  description = "Additional role assignment IDs keyed by input key."
  value       = { for k, v in azurerm_role_assignment.this : k => v.id }
}

output "role_assignment_count" {
  description = "Total number of role assignments managed by this module."
  value       = length(azurerm_role_assignment.app_admin_group) + length(azurerm_role_assignment.app_user_group) + length(azurerm_role_assignment.this)
}

output "tags" {
  description = "Effective tags applied to the Azure OpenAI account."
  value       = azurerm_cognitive_account.this.tags
}

output "merged_tags" {
  description = "Final merged tags applied to the Azure OpenAI account."
  value       = local.merged_tags
}

output "identity" {
  description = "Managed identity details for the Azure OpenAI account."
  value       = try(azurerm_cognitive_account.this.identity[0], null)
}

output "identity_type" {
  description = "Managed identity type configured on the Azure OpenAI account."
  value       = local.identity_type
}

output "identity_ids" {
  description = "User-assigned managed identity IDs configured on the Azure OpenAI account."
  value       = local.identity_ids
}
