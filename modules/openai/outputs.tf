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

output "endpoint" {
  description = "The Azure OpenAI endpoint."
  value       = azurerm_cognitive_account.this.endpoint
}

output "custom_subdomain_name" {
  description = "The effective custom subdomain name configured on the Azure OpenAI account."
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

output "deployment_ids" {
  description = "Deployment resource IDs keyed by deployment name."
  value       = { for k, v in azurerm_cognitive_deployment.this : k => v.id }
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
  description = "Effective tags applied to the Azure OpenAI account."
  value       = azurerm_cognitive_account.this.tags
}

output "identity" {
  description = "Managed identity details for the Azure OpenAI account."
  value       = try(azurerm_cognitive_account.this.identity[0], null)
}

output "merged_tags" {
  description = "Final merged tags applied to the Azure OpenAI account."
  value       = local.merged_tags
}
