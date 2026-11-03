output "key_vault_id" {
  description = "Resource ID of the Key Vault."
  value       = module.key_vault.id
}

output "vault_uri" {
  description = "Data-plane URI of the Key Vault."
  value       = module.key_vault.vault_uri
}
