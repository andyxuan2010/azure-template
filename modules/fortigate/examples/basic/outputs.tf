output "virtual_machine_ids" {
  description = "FortiGate virtual machine IDs."
  value       = module.fortigate.virtual_machine_ids
}

output "private_ip_addresses" {
  description = "FortiGate private IP addresses keyed by instance and interface."
  value       = module.fortigate.private_ip_addresses
}

output "public_frontend_enabled" {
  description = "Confirms that no public load-balancer frontend is enabled."
  value       = module.fortigate.public_frontend_enabled
}
