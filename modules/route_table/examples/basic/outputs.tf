output "id" {
  description = "Route table resource ID."
  value       = module.route_table.id
}

output "subnet_association_ids" {
  description = "Subnet association IDs keyed by subnet ID."
  value       = module.route_table.subnet_association_ids
}
