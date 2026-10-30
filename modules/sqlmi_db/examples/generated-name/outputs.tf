output "managed_database_name" {
  description = "Generated managed database name."
  value       = module.sqlmi_database.managed_database_name
}

output "managed_database_id" {
  description = "Managed database ID."
  value       = module.sqlmi_database.managed_database_id
}
