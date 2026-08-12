output "vm_ids" {
  description = "Windows VM resource IDs."
  value       = module.winvm.vm_ids
}

output "private_ip_addresses" {
  description = "Private IP addresses assigned to the VM NICs."
  value       = module.winvm.privateips
}

output "diagnostic_setting_ids" {
  description = "Diagnostic setting IDs keyed by VM index."
  value       = module.winvm.diagnostic_setting_ids
}

output "role_assignment_ids" {
  description = "Role assignment IDs grouped by access purpose."
  value       = module.winvm.role_assignment_ids
}
