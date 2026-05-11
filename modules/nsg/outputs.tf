output "id" {
  description = "The resource ID of the NSG."
  value       = azurerm_network_security_group.this.id
}

output "name" {
  description = "The NSG name."
  value       = azurerm_network_security_group.this.name
}

output "security_rule_names" {
  description = "Security rule names configured in the NSG."
  value       = [for rule in azurerm_network_security_group.this.security_rule : rule.name]
}

output "subnet_association_ids" {
  description = "Subnet association resource IDs keyed by subnet ID."
  value       = { for k, v in azurerm_subnet_network_security_group_association.this : k => v.id }
}

output "network_interface_association_ids" {
  description = "NIC association resource IDs keyed by NIC ID."
  value       = { for k, v in azurerm_network_interface_security_group_association.this : k => v.id }
}

output "tags" {
  description = "Effective tags applied to the NSG."
  value       = azurerm_network_security_group.this.tags
}

output "merged_tags" {
  description = "Final merged tags applied to the NSG."
  value       = local.merged_tags
}
