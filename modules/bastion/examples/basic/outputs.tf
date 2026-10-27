output "bastion_id" {
  description = "Bastion host resource ID."
  value       = module.bastion.id
}

output "bastion_dns_name" {
  description = "Bastion host fully qualified domain name."
  value       = module.bastion.dns_name
}

output "public_ip_address_id" {
  description = "Public IP resource ID attached to the Bastion host."
  value       = module.bastion.public_ip_address_id
}
