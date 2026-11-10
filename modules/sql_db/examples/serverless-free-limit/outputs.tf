output "database_id" {
  description = "Azure SQL database ID."
  value       = module.sqldb.database_id
}

output "public_endpoint" {
  description = "Public endpoint and firewall summary."
  value       = module.sqldb.public_endpoint
}

output "free_limit_configuration" {
  description = "Configured free-limit behavior."
  value       = module.sqldb.free_limit_configuration
}
