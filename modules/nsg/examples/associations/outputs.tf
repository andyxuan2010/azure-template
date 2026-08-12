output "network_security_group_id" {
  description = "Resource ID of the Network Security Group."
  value       = module.nsg.id
}

output "subnet_association_ids" {
  description = "Subnet association IDs."
  value       = module.nsg.subnet_association_ids
}

output "network_interface_association_ids" {
  description = "Network interface association IDs."
  value       = module.nsg.network_interface_association_ids
}
