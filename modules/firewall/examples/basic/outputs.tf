output "firewall_id" {
  description = "Azure Firewall resource ID."
  value       = module.firewall.id
}

output "private_ip_address" {
  description = "Firewall private IP used as a UDR next hop."
  value       = module.firewall.private_ip_address
}

output "public_ip_addresses" {
  description = "Created public IP addresses."
  value       = module.firewall.public_ip_addresses
}
