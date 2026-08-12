output "subnet_ids" {
  description = "Created subnet resource IDs keyed by subnet name."
  value       = module.subnet.ids
}

output "network_security_group_association_ids" {
  description = "NSG association resource IDs."
  value       = module.subnet.network_security_group_association_ids
}

output "route_table_association_ids" {
  description = "Route table association resource IDs."
  value       = module.subnet.route_table_association_ids
}
