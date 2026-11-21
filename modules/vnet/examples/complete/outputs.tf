output "virtual_network_id" {
  description = "VNet resource ID."
  value       = module.vnet.id
}

output "subnet_ids" {
  description = "Subnet resource IDs keyed by name."
  value       = module.vnet.subnet_ids
}

output "diagnostic_setting_id" {
  description = "VNet diagnostic setting resource ID."
  value       = module.vnet.diagnostic_setting_id
}
