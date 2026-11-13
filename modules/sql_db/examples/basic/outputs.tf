output "server_id" {
  description = "Azure SQL logical server ID."
  value       = module.sqldb.server_id
}

output "database_id" {
  description = "Azure SQL database ID."
  value       = module.sqldb.database_id
}

output "private_endpoint_id" {
  description = "SQL Private Endpoint ID."
  value       = module.sqldb.private_endpoint_id
}
