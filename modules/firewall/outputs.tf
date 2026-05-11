output "id" {
  description = "Azure Firewall ID."
  value       = azurerm_firewall.this.id
}

output "name" {
  description = "Azure Firewall name."
  value       = azurerm_firewall.this.name
}

output "private_ip_address" {
  description = "Azure Firewall private IP address."
  value       = azurerm_firewall.this.ip_configuration[0].private_ip_address
}

output "public_ip_id" {
  description = "Public IP ID used by the firewall."
  value       = azurerm_public_ip.this.id
}

output "firewall_policy_id" {
  description = "Firewall policy ID."
  value       = azurerm_firewall_policy.this.id
}

output "rule_collection_group_id" {
  description = "Firewall rule collection group ID when created."
  value       = try(azurerm_firewall_policy_rule_collection_group.this[0].id, null)
}

output "tags" {
  description = "Effective tags applied to the Azure Firewall."
  value       = azurerm_firewall.this.tags
}

output "merged_tags" {
  description = "Final merged tags applied to firewall resources."
  value       = local.merged_tags
}
