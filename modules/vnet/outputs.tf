output "id" {
  description = "The ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "name" {
  description = "The name of the virtual network."
  value       = azurerm_virtual_network.this.name
}

output "resource_group_name" {
  description = "The name of the resource group containing the virtual network."
  value       = azurerm_virtual_network.this.resource_group_name
}

output "location" {
  description = "The location of the virtual network."
  value       = azurerm_virtual_network.this.location
}

output "address_space" {
  description = "The address spaces configured on the virtual network."
  value       = azurerm_virtual_network.this.address_space
}

output "subnet_ids" {
  description = "Map of subnet IDs keyed by subnet name."
  value       = { for k, v in azurerm_subnet.this : k => v.id }
}

output "subnet_names" {
  description = "Map of subnet names keyed by subnet name."
  value       = { for k, v in azurerm_subnet.this : k => v.name }
}

output "app_admin_group_role_assignment_ids" {
  description = "Map of Contributor role assignment IDs keyed by app_admin_group input."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Map of Reader role assignment IDs keyed by app_user_group input."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}

output "diagnostic_setting_id" {
  description = "The ID of the diagnostic setting, if created."
  value       = try(azurerm_monitor_diagnostic_setting.this[0].id, null)
}

output "tags" {
  description = "The effective tags assigned to the virtual network."
  value       = azurerm_virtual_network.this.tags
}
