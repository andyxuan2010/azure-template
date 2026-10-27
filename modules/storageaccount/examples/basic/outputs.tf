output "storage_account_id" {
  description = "Storage account resource ID."
  value       = module.storageaccount.id
}

output "storage_account_name" {
  description = "Storage account name."
  value       = module.storageaccount.name
}

output "network_rules" {
  description = "Effective storage network-rule configuration."
  value       = module.storageaccount.network_rules_config
}
