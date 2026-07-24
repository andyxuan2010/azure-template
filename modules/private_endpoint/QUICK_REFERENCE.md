# Private Endpoint Quick Reference

Required inputs:

- `resource_group_name`
- `location`
- `subnet_id` or `subnet_name` plus `virtual_network_name`
- `private_connection_resource_id`
- `subresource_names`

Common subresources:

- Storage Account: `blob`, `file`, `queue`, `table`, `web`, `dfs`
- Key Vault: `vault`
- App Service / Function App: `sites`
- SQL Server: `sqlServer`
- Cosmos DB: `Sql`
- Service Bus / Event Hub: `namespace`
- Azure AI / OpenAI: `account`

Naming:

- Override: `name = "pep-app-cc-prod-001"`
- Generated: `pep-<workload>-<region-code>-<app_env>-<instance>`
