output "cosmosdb" {
  description = "Key Cosmos DB deployment values."
  value = {
    id                    = module.cosmos.id
    name                  = module.cosmos.name
    endpoint              = module.cosmos.endpoint
    read_endpoints        = module.cosmos.read_endpoints
    write_endpoints       = module.cosmos.write_endpoints
    private_endpoint_id   = module.cosmos.private_endpoint_id
    diagnostic_setting_id = module.cosmos.diagnostic_setting_id
    sql_database_ids      = module.cosmos.sql_database_ids
    sql_container_ids     = module.cosmos.sql_container_ids
  }
}
