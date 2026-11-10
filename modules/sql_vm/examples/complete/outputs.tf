output "vm_ids" {
  description = "SQL VM Azure VM resource IDs."
  value       = module.sqlvm.ids
}

output "private_ip_addresses" {
  description = "Private IP addresses assigned to the SQL VM NICs."
  value       = module.sqlvm.private_ip_addresses
}

output "managed_disk_ids" {
  description = "Managed SQL data disk resource IDs."
  value       = module.sqlvm.managed_disk_ids
}

output "sql_virtual_machine_ids" {
  description = "SQL IaaS Agent registration resource IDs."
  value       = module.sqlvm.sql_virtual_machine_ids
}
