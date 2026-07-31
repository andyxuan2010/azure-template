output "id" {
  description = "SQL Managed Instance ID."
  value       = module.sqlmi.id
}

output "fqdn" {
  description = "SQL Managed Instance FQDN."
  value       = module.sqlmi.fqdn
}
