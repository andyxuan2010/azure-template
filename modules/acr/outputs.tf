output "id" {
  description = "Azure Container Registry resource ID."
  value       = azurerm_container_registry.this.id
}

output "name" {
  description = "Azure Container Registry name."
  value       = azurerm_container_registry.this.name
}

output "location" {
  description = "Azure region where the registry is deployed."
  value       = azurerm_container_registry.this.location
}

output "login_server" {
  description = "Azure Container Registry login server."
  value       = azurerm_container_registry.this.login_server
}

output "admin_username" {
  description = "Admin username when admin access is enabled."
  value       = try(azurerm_container_registry.this.admin_username, null)
}

output "admin_password" {
  description = "Admin password when admin access is enabled."
  value       = try(azurerm_container_registry.this.admin_password, null)
  sensitive   = true
}

output "private_endpoint_id" {
  description = "Private endpoint ID when enabled."
  value       = try(azurerm_private_endpoint.this[0].id, null)
}

output "private_endpoint_ip_address" {
  description = "Private endpoint IP address when enabled."
  value       = try(azurerm_private_endpoint.this[0].private_service_connection[0].private_ip_address, null)
}

output "diagnostic_setting_id" {
  description = "Diagnostic setting ID when diagnostics are enabled."
  value       = try(azurerm_monitor_diagnostic_setting.this[0].id, null)
}

output "tags" {
  description = "Effective tags applied to the registry."
  value       = local.tags
}

output "identity" {
  description = "Managed Identity of the Azure Container Registry."
  value       = try(azurerm_container_registry.this.identity[0], null)
}

output "principal_id" {
  description = "Principal ID of the registry managed identity when present."
  value       = try(azurerm_container_registry.this.identity[0].principal_id, null)
}

output "tenant_id" {
  description = "Tenant ID of the registry managed identity when present."
  value       = try(azurerm_container_registry.this.identity[0].tenant_id, null)
}

output "managed_identity_role_assignment_ids" {
  description = "Map of role assignment IDs created for the registry's system-assigned managed identity."
  value       = { for name, role in azurerm_role_assignment.managed_identity : name => role.id }
}

output "app_admin_group_role_assignment_ids" {
  description = "Map of Contributor role assignment IDs keyed by app_admin_group input key."
  value       = { for name, role in azurerm_role_assignment.app_admin_group : name => role.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Map of Reader role assignment IDs keyed by app_user_group input key."
  value       = { for name, role in azurerm_role_assignment.app_user_group : name => role.id }
}

output "role_assignment_ids" {
  description = "Role assignment IDs created for app_admin_group, app_user_group, and managed_identity_role_assignments."
  value = {
    managed_identity = values({ for name, role in azurerm_role_assignment.managed_identity : name => role.id })
    app_admin_group  = values({ for name, role in azurerm_role_assignment.app_admin_group : name => role.id })
    app_user_group   = values({ for name, role in azurerm_role_assignment.app_user_group : name => role.id })
  }
}
