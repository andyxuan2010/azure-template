output "vm_ids" {
  description = "Resource IDs of the Linux VMs."
  value       = module.linux_vm.id
}

output "private_ip_by_vm_name" {
  description = "Private IP address keyed by VM name."
  value       = module.linux_vm.private_ip_by_vm_name
}

output "role_assignment_ids" {
  description = "RBAC assignment IDs created by the module."
  value       = module.linux_vm.role_assignment_ids
}
