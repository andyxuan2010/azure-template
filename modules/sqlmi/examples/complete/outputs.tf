output "id" {
  description = "SQL Managed Instance ID."
  value       = module.sqlmi.id
}

output "fqdn" {
  description = "SQL Managed Instance FQDN."
  value       = module.sqlmi.fqdn
}

output "principal_id" {
  description = "System-assigned identity principal ID."
  value       = module.sqlmi.principal_id
}

output "diagnostic_setting_id" {
  description = "Diagnostic setting ID."
  value       = module.sqlmi.diagnostic_setting_id
}
