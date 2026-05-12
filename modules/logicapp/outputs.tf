output "id" {
  description = "Logic App Standard resource ID."
  value       = azurerm_logic_app_standard.this.id
}

output "name" {
  description = "Logic App Standard name."
  value       = azurerm_logic_app_standard.this.name
}

output "kind" {
  description = "Logic App Standard kind reported by Azure."
  value       = azurerm_logic_app_standard.this.kind
}

output "location" {
  description = "Resolved Azure region for the Logic App Standard."
  value       = azurerm_logic_app_standard.this.location
}

output "default_hostname" {
  description = "Default hostname for the Logic App Standard."
  value       = azurerm_logic_app_standard.this.default_hostname
}

output "custom_domain_verification_id" {
  description = "Identifier used for custom domain ownership verification."
  value       = azurerm_logic_app_standard.this.custom_domain_verification_id
  sensitive   = true
}

output "identity_principal_id" {
  description = "Principal ID of the system-assigned managed identity when enabled."
  value       = try(azurerm_logic_app_standard.this.identity[0].principal_id, null)
}

output "identity_tenant_id" {
  description = "Tenant ID of the system-assigned managed identity when enabled."
  value       = try(azurerm_logic_app_standard.this.identity[0].tenant_id, null)
}

output "private_endpoint_id" {
  description = "Private endpoint resource ID when enabled."
  value       = try(azurerm_private_endpoint.this[0].id, null)
}

output "diagnostic_setting_id" {
  description = "Diagnostic setting resource ID when diagnostics are enabled."
  value       = try(azurerm_monitor_diagnostic_setting.this[0].id, null)
}

output "service_plan_id" {
  description = "Resolved App Service Plan ID used by the Logic App Standard."
  value       = var.service_plan_id
}

output "storage_account_id" {
  description = "Resolved storage account ID used by the Logic App Standard."
  value       = data.azurerm_storage_account.logicapp.id
}

output "site_credential_name" {
  description = "The site credentials username used for publishing."
  value       = azurerm_logic_app_standard.this.site_credential[0].username
  sensitive   = true
}

output "site_credential_password" {
  description = "The site credentials password used for publishing."
  value       = azurerm_logic_app_standard.this.site_credential[0].password
  sensitive   = true
}

output "tags" {
  description = "Effective tags applied to resources created by this module."
  value       = local.merged_tags
}

output "app_admin_group_role_assignment_ids" {
  description = "Map of Contributor role assignment IDs keyed by app_admin_group principal ID."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Map of Reader role assignment IDs keyed by app_user_group principal ID."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}
