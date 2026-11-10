output "cosmosdb_id" {
  description = "Cosmos DB account ID."
  value       = module.cosmos.id
}

output "endpoint" {
  description = "Cosmos DB endpoint."
  value       = module.cosmos.endpoint
}

output "sql_container_ids" {
  description = "SQL container IDs keyed by name."
  value       = module.cosmos.sql_container_ids
}
