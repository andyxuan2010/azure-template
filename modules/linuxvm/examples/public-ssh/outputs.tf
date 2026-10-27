output "vm_ids" {
  description = "Resource IDs of the Linux VMs."
  value       = module.linux_vm.id
}

output "public_ip_addresses" {
  description = "Public IP addresses assigned to the Linux VMs."
  value       = module.linux_vm.public_ip
}

output "network_security_group_ids" {
  description = "SSH Network Security Group IDs."
  value       = module.linux_vm.network_security_group_ids
}
