output "id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "The name of the Key Vault."
  value       = azurerm_key_vault.this.name
}

output "resource_group_name" {
  description = "The resource group containing the Key Vault."
  value       = azurerm_key_vault.this.resource_group_name
}

output "location" {
  description = "The location of the Key Vault."
  value       = azurerm_key_vault.this.location
}

output "vault_uri" {
  description = "The URI of the Key Vault."
  value       = azurerm_key_vault.this.vault_uri
}

output "tenant_id" {
  description = "The tenant ID configured on the Key Vault."
  value       = azurerm_key_vault.this.tenant_id
}

output "private_endpoint_id" {
  description = "The ID of the private endpoint, if created."
  value       = try(azurerm_private_endpoint.this[0].id, null)
}

output "private_endpoint_name" {
  description = "The name of the private endpoint, if created."
  value       = try(azurerm_private_endpoint.this[0].name, null)
}

output "private_endpoint_fqdns" {
  description = "Private endpoint FQDNs, if created."
  value       = try([for config in azurerm_private_endpoint.this[0].custom_dns_configs : config.fqdn], null)
}

output "private_endpoint_ip_addresses" {
  description = "Private endpoint IP addresses, if created."
  value       = try(flatten([for config in azurerm_private_endpoint.this[0].custom_dns_configs : config.ip_addresses]), null)
}

output "app_admin_group_role_assignment_ids" {
  description = "Map of Key Vault Administrator role assignment IDs keyed by app_admin_group input."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Map of Key Vault Secrets User role assignment IDs keyed by app_user_group input."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}

output "current_caller_secrets_officer_role_assignment_id" {
  description = "The Key Vault Secrets Officer role assignment ID granted to the current Terraform caller, if enabled."
  value       = try(azurerm_role_assignment.current_caller_secrets_officer[0].id, null)
}

output "diagnostic_setting_id" {
  description = "The ID of the diagnostic setting, if created."
  value       = try(azurerm_monitor_diagnostic_setting.this[0].id, null)
}

output "tags" {
  description = "The effective tags assigned to the Key Vault."
  value       = azurerm_key_vault.this.tags
}
