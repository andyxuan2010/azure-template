output "cosmosdb_id" {
  description = "Serverless Cosmos DB account ID."
  value       = module.cosmos.id
}

output "endpoint" {
  description = "Serverless Cosmos DB endpoint."
  value       = module.cosmos.endpoint
}
