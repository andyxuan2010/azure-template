output "route_table_id" {
  description = "Firewall egress route table ID."
  value       = module.firewall_egress.id
}

output "subnet_association_ids" {
  description = "Subnet association IDs keyed by subnet ID."
  value       = module.firewall_egress.subnet_association_ids
}
