output "vm_ids" {
  description = "SQL VM Azure VM resource IDs."
  value       = module.sqlvm.ids
}

output "sql_virtual_machine_ids" {
  description = "SQL IaaS Agent registration resource IDs."
  value       = module.sqlvm.sql_virtual_machine_ids
}
