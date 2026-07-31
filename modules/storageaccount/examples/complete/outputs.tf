output "storage_account_id" {
  description = "Storage account resource ID."
  value       = module.storageaccount.id
}

output "container_ids" {
  description = "Blob container resource IDs."
  value       = module.storageaccount.container_ids
}

output "private_endpoint_ip_addresses" {
  description = "Private endpoint IP addresses keyed by Storage subresource."
  value       = module.storageaccount.private_endpoint_ip_addresses
}

output "diagnostic_setting_id" {
  description = "Diagnostic setting resource ID."
  value       = module.storageaccount.diagnostic_setting_id
}
