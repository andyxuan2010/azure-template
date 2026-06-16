output "id" {
  value       = azurerm_data_factory.this.id
  description = "Data Factory resource ID."
}

output "name" {
  value       = azurerm_data_factory.this.name
  description = "Data Factory name."
}

output "location" {
  value       = azurerm_data_factory.this.location
  description = "Data Factory Azure region."
}

output "identity" {
  value       = try(azurerm_data_factory.this.identity[0], null)
  description = "Data Factory managed identity block."
}

output "principal_id" {
  value       = try(azurerm_data_factory.this.identity[0].principal_id, null)
  description = "Principal ID for the Data Factory managed identity when present."
}

output "tenant_id" {
  value       = try(azurerm_data_factory.this.identity[0].tenant_id, null)
  description = "Tenant ID for the Data Factory managed identity when present."
}

output "default_integration_runtime_id" {
  value       = try(azurerm_data_factory_integration_runtime_azure.auto_resolve[0].id, null)
  description = "Data Factory Azure Integration Runtime ID when created."
}

output "default_integration_runtime_name" {
  value       = try(azurerm_data_factory_integration_runtime_azure.auto_resolve[0].name, null)
  description = "Data Factory Azure Integration Runtime name when created."
}

output "self_hosted_integration_runtime_id" {
  value       = try(azurerm_data_factory_integration_runtime_self_hosted.this[0].id, null)
  description = "Self-hosted integration runtime ID when created."
}

output "self_hosted_integration_runtime_name" {
  value       = try(azurerm_data_factory_integration_runtime_self_hosted.this[0].name, null)
  description = "Self-hosted integration runtime name when created."
}

output "self_hosted_integration_runtime_key" {
  value       = try(azurerm_data_factory_integration_runtime_self_hosted.this[0].primary_authorization_key, null)
  description = "Self-hosted integration runtime primary authorization key."
  sensitive   = true
}

output "shir_authorization_key_secret_ids" {
  value = {
    primary   = try(azurerm_key_vault_secret.shir_key1[0].id, null)
    secondary = try(azurerm_key_vault_secret.default_key[0].id, null)
  }
  description = "Key Vault secret IDs created for SHIR authorization keys."
}

output "private_endpoint_id" {
  value       = try(azurerm_private_endpoint.adf_datafactory[0].id, null)
  description = "ADF private endpoint ID when created."
}

output "private_endpoint_ip_address" {
  value       = try(azurerm_private_endpoint.adf_datafactory[0].private_service_connection[0].private_ip_address, null)
  description = "ADF private endpoint private IP address when created."
}

output "managed_private_endpoint_ids" {
  value       = { for name, endpoint in azurerm_data_factory_managed_private_endpoint.this : name => endpoint.id }
  description = "Managed private endpoint IDs keyed by input name."
}

output "managed_private_endpoint_fqdns" {
  value       = { for name, endpoint in azurerm_data_factory_managed_private_endpoint.this : name => endpoint.fqdns }
  description = "Managed private endpoint FQDNs keyed by input name."
}

output "diagnostic_setting_ids" {
  value       = { for name, setting in azurerm_monitor_diagnostic_setting.this : name => setting.id }
  description = "Diagnostic setting IDs keyed by log analytics workspace map key."
}

output "diagnostics_enabled" {
  description = "True when diagnostic settings are enabled."
  value       = local.diagnostics_enabled
}

output "app_admin_group_role_assignment_ids" {
  description = "Map of Contributor role assignment IDs keyed by app_admin_group principal ID or display name."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Map of Reader role assignment IDs keyed by app_user_group principal ID or display name."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}

output "additional_role_assignment_ids" {
  description = "Map of additional Data Factory role assignment IDs keyed by object ID and role."
  value       = { for k, v in azurerm_role_assignment.data_factory : k => v.id }
}

output "key_vault_secret_user_role_assignment_id" {
  description = "Key Vault Secrets User role assignment ID for the Data Factory managed identity when created."
  value       = try(azurerm_role_assignment.secret_user[0].id, null)
}

output "merged_tags" {
  description = "Final merged tags applied to resources."
  value       = local.merged_tags
}
