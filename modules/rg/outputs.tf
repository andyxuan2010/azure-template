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

output "location_code" {
  description = "The resolved location code used for generated naming."
  value       = local.location_code_resolved
}

output "app_env" {
  description = "The deployment environment used by the module."
  value       = var.app_env
}

output "managed_by" {
  description = "The managed_by value configured on the resource group, if any."
  value       = azurerm_resource_group.this.managed_by
}

output "lock_id" {
  description = "The ID of the management lock, if created."
  value       = try(azurerm_management_lock.this[0].id, null)
}

output "lock_config" {
  description = "Effective management lock configuration."
  value = {
    enabled = var.enable_lock
    name    = var.enable_lock ? local.lock_name_effective : null
    level   = var.enable_lock ? var.lock_level : null
    notes   = var.enable_lock ? local.lock_notes_effective : null
  }
}

output "app_admin_group_role_assignment_ids" {
  description = "Map of Contributor role assignment IDs keyed by app_admin_group input."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_admin_group_principal_ids" {
  description = "Map of resolved Contributor group principal IDs keyed by app_admin_group input."
  value       = local.app_admin_group_principal_ids
}

output "app_user_group_role_assignment_ids" {
  description = "Map of Reader role assignment IDs keyed by app_user_group input."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}

output "app_user_group_principal_ids" {
  description = "Map of resolved Reader group principal IDs keyed by app_user_group input."
  value       = local.app_user_group_principal_ids
}

output "role_assignment_ids" {
  description = "Map of additional role assignment IDs keyed by role_assignments input."
  value       = { for k, v in azurerm_role_assignment.this : k => v.id }
}

output "role_assignment_count" {
  description = "Total number of role assignments requested by this module."
  value       = length(local.app_admin_group_principal_ids) + length(local.app_user_group_principal_ids) + length(var.role_assignments)
}

output "tags" {
  description = "The effective tags assigned to the resource group."
  value       = azurerm_resource_group.this.tags
}
