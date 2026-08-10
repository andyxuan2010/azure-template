output "managed_database_id" {
  description = "Managed database ID."
  value       = module.sqlmi_database.managed_database_id
}

output "diagnostic_setting_id" {
  description = "Diagnostic setting ID."
  value       = module.sqlmi_database.diagnostic_setting_id
}

output "app_admin_group_role_assignment_ids" {
  description = "Database Contributor assignment IDs."
  value       = module.sqlmi_database.app_admin_group_role_assignment_ids
}

output "app_user_group_role_assignment_ids" {
  description = "Database Reader assignment IDs."
  value       = module.sqlmi_database.app_user_group_role_assignment_ids
}
