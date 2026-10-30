output "virtual_network_id" {
  description = "VNet resource ID."
  value       = module.vnet.id
}

output "address_space" {
  description = "Configured VNet address spaces."
  value       = module.vnet.address_space
}
