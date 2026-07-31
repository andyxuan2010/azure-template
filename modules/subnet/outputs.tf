output "ids" {
  description = "Map of subnet IDs keyed by subnet name."
  value       = { for name, subnet in azurerm_subnet.this : name => subnet.id }
}

output "names" {
  description = "Map of subnet names keyed by subnet name."
  value       = { for name, subnet in azurerm_subnet.this : name => subnet.name }
}

output "address_prefixes" {
  description = "Map of configured address prefixes keyed by subnet name."
  value       = { for name, subnet in azurerm_subnet.this : name => subnet.address_prefixes }
}

output "network_security_group_association_ids" {
  description = "Map of NSG association IDs keyed by subnet name."
  value       = { for name, association in azurerm_subnet_network_security_group_association.this : name => association.id }
}

output "route_table_association_ids" {
  description = "Map of route table association IDs keyed by subnet name."
  value       = { for name, association in azurerm_subnet_route_table_association.this : name => association.id }
}

output "app_admin_group_role_assignment_ids" {
  description = "Map of Contributor role assignment IDs keyed by app_admin_group input."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Map of Reader role assignment IDs keyed by app_user_group input."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}
