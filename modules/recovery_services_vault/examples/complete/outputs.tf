output "vault_id" {
  description = "Recovery Services vault resource ID."
  value       = module.recovery_services_vault.id
}

output "vault_name" {
  description = "Recovery Services vault name."
  value       = module.recovery_services_vault.name
}

output "vault_storage_mode" {
  description = "Vault storage redundancy mode."
  value       = module.recovery_services_vault.storage_mode_type
}
