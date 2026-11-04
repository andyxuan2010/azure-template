output "key_vault_id" {
  description = "Resource ID of the Key Vault."
  value       = module.key_vault.id
}

output "private_endpoint_ip_addresses" {
  description = "Private IP addresses assigned to the Key Vault private endpoint."
  value       = module.key_vault.private_endpoint_ip_addresses
}
