output "id" {
  description = "The ID of the resource group."
  value       = azurerm_resource_group.this.id
}

output "name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.this.name
}

output "location" {
  description = "The location of the resource group."
  value       = azurerm_resource_group.this.location
}

output "lock_id" {
  description = "The ID of the management lock, if created."
  value       = try(azurerm_management_lock.this[0].id, null)
}

output "app_admin_group_role_assignment_ids" {
  description = "Map of Contributor role assignment IDs keyed by app_admin_group input."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Map of Reader role assignment IDs keyed by app_user_group input."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}

output "tags" {
  description = "The effective tags assigned to the resource group."
  value       = azurerm_resource_group.this.tags
}
