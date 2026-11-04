output "id" {
  description = "Private Endpoint ID."
  value       = module.private_endpoint.id
}

output "subnet_id" {
  description = "Subnet ID resolved through azurerm.prod."
  value       = module.private_endpoint.subnet_id
}

output "private_dns_zone_ids" {
  description = "Private DNS zone IDs resolved through azurerm.prod."
  value       = module.private_endpoint.private_dns_zone_ids
}
