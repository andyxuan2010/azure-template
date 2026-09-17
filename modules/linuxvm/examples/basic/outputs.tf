output "vm_ids" {
  description = "Resource IDs of the Linux VMs."
  value       = module.linux_vm.id
}

output "private_ip_by_vm_name" {
  description = "Private IP address keyed by VM name."
  value       = module.linux_vm.private_ip_by_vm_name
}

output "managed_identity_principal_ids" {
  description = "System-assigned identity principal IDs."
  value       = module.linux_vm.managed_identity_principal_ids
}
