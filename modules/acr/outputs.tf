output "id" {
  description = "Azure Container Registry resource ID."
  value       = azurerm_container_registry.this.id
}

output "name" {
  description = "Azure Container Registry name."
  value       = azurerm_container_registry.this.name
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

output "role_assignment_ids" {
  description = "Role assignment IDs created for app_admin_group and app_user_group."
  value = {
    app_admin_group = [for role in azurerm_role_assignment.app_admin_group : role.id]
    app_user_group  = [for role in azurerm_role_assignment.app_user_group : role.id]
  }
}

output "tags" {
  description = "Effective tags applied to the registry."
  value       = local.tags
}

output "identity" {
  description = "Managed Identity of the Azure Container Registry."
  value       = try(azurerm_container_registry.this.identity[0], null)
}
