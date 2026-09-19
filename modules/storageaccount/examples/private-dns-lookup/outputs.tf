output "storage_account_id" {
  description = "Storage account resource ID."
  value       = module.storageaccount.id
}

output "private_endpoint_fqdns" {
  description = "Private endpoint FQDNs keyed by Storage subresource."
  value       = module.storageaccount.private_endpoint_fqdns
}
