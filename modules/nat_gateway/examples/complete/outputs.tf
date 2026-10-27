output "nat_gateway_id" {
  description = "NAT Gateway resource ID."
  value       = module.nat_gateway.id
}

output "public_ip_address_ids" {
  description = "Public IP resource IDs associated with the NAT Gateway."
  value       = module.nat_gateway.public_ip_address_ids
}

output "subnet_association_ids" {
  description = "NAT Gateway subnet association IDs."
  value       = module.nat_gateway.subnet_association_ids
}
