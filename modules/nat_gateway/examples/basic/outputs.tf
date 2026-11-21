output "nat_gateway_id" {
  description = "NAT Gateway resource ID."
  value       = module.nat_gateway.id
}

output "managed_public_ip_addresses" {
  description = "Static public IP addresses created for the NAT Gateway."
  value       = module.nat_gateway.managed_public_ip_addresses
}

output "subnet_association_ids" {
  description = "NAT Gateway subnet association IDs."
  value       = module.nat_gateway.subnet_association_ids
}
