output "vault_id" {
  description = "Recovery Services vault resource ID."
  value       = module.recovery_services_vault.id
}

output "vault_name" {
  description = "Recovery Services vault name."
  value       = module.recovery_services_vault.name
}
