output "vm_ids" {
  description = "Windows VM resource IDs."
  value       = module.winvm.vm_ids
}

output "private_ip_addresses" {
  description = "Private IP addresses assigned to the VM NICs."
  value       = module.winvm.privateips
}

output "principal_ids" {
  description = "System-assigned managed identity principal IDs."
  value       = module.winvm.principal_ids
}
