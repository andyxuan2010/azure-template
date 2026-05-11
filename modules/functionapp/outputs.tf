output "id" {
  description = "Function App resource ID."
  value       = local.function_app.id
}

output "name" {
  description = "Function App name."
  value       = local.function_app.name
}

output "default_hostname" {
  description = "Default hostname for the Function App."
  value       = local.function_app.default_hostname
}

output "kind" {
  description = "Function App operating system."
  value       = var.os_type
}

output "identity_principal_id" {
  description = "Principal ID of the system-assigned managed identity when enabled."
  value       = try(local.function_app.identity[0].principal_id, null)
}

output "identity_tenant_id" {
  description = "Tenant ID of the system-assigned managed identity when enabled."
  value       = try(local.function_app.identity[0].tenant_id, null)
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
  description = "Resolved App Service Plan ID used by the Function App."
  value       = var.service_plan_id
}

output "storage_account_id" {
  description = "Resolved storage account ID used by the Function App."
  value       = data.azurerm_storage_account.function.id
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
