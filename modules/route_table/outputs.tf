output "id" {
  description = "Route table ID."
  value       = azurerm_route_table.this.id
}

output "name" {
  description = "Route table name."
  value       = azurerm_route_table.this.name
}

output "subnet_association_ids" {
  description = "Subnet association IDs keyed by subnet ID."
  value       = { for k, v in azurerm_subnet_route_table_association.this : k => v.id }
}

output "tags" {
  description = "Effective tags applied to the route table."
  value       = azurerm_route_table.this.tags
}

output "merged_tags" {
  description = "Final merged tags applied to the route table."
  value       = local.merged_tags
}
