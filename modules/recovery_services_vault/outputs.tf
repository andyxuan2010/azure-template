output "id" {
  description = "Recovery Services vault resource ID."
  value       = azurerm_recovery_services_vault.this.id
}

output "name" {
  description = "Recovery Services vault name."
  value       = azurerm_recovery_services_vault.this.name
}

output "sku" {
  description = "Recovery Services vault SKU."
  value       = azurerm_recovery_services_vault.this.sku
}

output "storage_mode_type" {
  description = "Backup storage redundancy mode."
  value       = azurerm_recovery_services_vault.this.storage_mode_type
}

output "identity" {
  description = "Managed identity properties returned by Azure, if configured outside this module."
  value       = azurerm_recovery_services_vault.this.identity
}

output "tags" {
  description = "Effective tags applied to the Recovery Services vault."
  value       = local.tags
}
