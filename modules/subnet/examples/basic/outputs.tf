output "subnet_ids" {
  description = "Created subnet resource IDs keyed by subnet name."
  value       = module.subnet.ids
}

output "address_prefixes" {
  description = "Created subnet address prefixes keyed by subnet name."
  value       = module.subnet.address_prefixes
}
