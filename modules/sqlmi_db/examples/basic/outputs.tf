output "managed_database_id" {
  description = "Managed database ID."
  value       = module.sqlmi_database.managed_database_id
}

output "managed_database_name" {
  description = "Managed database name."
  value       = module.sqlmi_database.managed_database_name
}

output "managed_instance_id" {
  description = "Referenced Managed Instance ID."
  value       = module.sqlmi_database.managed_instance_id
}
