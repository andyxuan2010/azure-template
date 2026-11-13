output "server_id" {
  description = "Azure SQL logical server ID."
  value       = module.sqldb.server_id
}

output "database_id" {
  description = "Azure SQL database ID."
  value       = module.sqldb.database_id
}

output "server_fqdn" {
  description = "Azure SQL server FQDN."
  value       = module.sqldb.server_fqdn
}

output "backup_configuration" {
  description = "Configured database backup and resilience settings."
  value       = module.sqldb.backup_configuration
}

output "security_configuration" {
  description = "Configured database security and monitoring settings."
  value       = module.sqldb.security_configuration
}
