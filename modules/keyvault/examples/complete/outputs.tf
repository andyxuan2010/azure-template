output "key_vault_id" {
  description = "Resource ID of the Key Vault."
  value       = module.key_vault.id
}

output "private_endpoint_id" {
  description = "Resource ID of the Key Vault private endpoint."
  value       = module.key_vault.private_endpoint_id
}

output "diagnostic_setting_id" {
  description = "Resource ID of the Key Vault diagnostic setting."
  value       = module.key_vault.diagnostic_setting_id
}
