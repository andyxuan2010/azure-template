output "network_security_group_id" {
  description = "Resource ID of the Network Security Group."
  value       = module.nsg.id
}

output "security_rule_names" {
  description = "Custom security rule names."
  value       = module.nsg.security_rule_names
}

output "subnet_association_ids" {
  description = "Subnet association IDs."
  value       = module.nsg.subnet_association_ids
}
