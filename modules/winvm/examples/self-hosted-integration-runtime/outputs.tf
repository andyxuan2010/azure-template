output "vm_ids" {
  description = "SHIR Windows VM resource IDs."
  value       = module.winvm.vm_ids
}

output "principal_ids" {
  description = "VM managed identity principal IDs."
  value       = module.winvm.principal_ids
}

output "role_assignment_ids" {
  description = "Role assignment IDs, including Azure Data Factory access."
  value       = module.winvm.role_assignment_ids
}
