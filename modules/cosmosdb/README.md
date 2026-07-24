# Cosmos DB Module

Provision an Azure Cosmos DB account with secure defaults, standardized naming and tags, managed identity, SQL API databases and containers, private endpoint, RBAC, diagnostics, backup, consistency, and geo-replication controls.

## Features

- Secure defaults: public network access disabled, local key authentication disabled, system-assigned managed identity enabled, TLS 1.2 minimum, and continuous backup.
- Standard generated naming using `name_prefix`, `workload_name`, `app_env`, `location_code`, and optional random suffixes.
- Caller-provided tags merged over optional resource-group tags, without module-generated governance tags.
- SQL API databases and containers with manual or autoscale throughput, partition keys, TTL, indexing policies, unique keys, conflict resolution, and analytical TTL.
- Geo-replication, automatic failover, optional multi-write, zone redundancy, account capabilities, and account-level throughput cap.
- Network controls for private endpoint, private DNS zone IDs or DNS zone lookup, static private endpoint IPs, service endpoint subnet rules, IP filters, and Azure service bypass.
- Managed identity and optional customer-managed key configuration.
- Account-scope Azure RBAC assignments, Entra group lookup by display name or object ID, custom SQL data-plane role definitions, and SQL role assignments.
- Diagnostics to Log Analytics, Storage Account archive, and Event Hub with category and category-group support.
- Cross-resource validation for container database references, serverless throughput, bounded staleness, private DNS lookup, and CMK identity requirements.
- Mock-provider Terraform tests for fast plan coverage without creating live Azure resources.

## Basic Usage

```hcl
module "cosmosdb" {
  source = "./modules/cosmosdb"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  workload_name       = "orders"
  app_env             = "prod"

  sql_databases = {
    app = {
      autoscale_max_ru = 4000
    }
  }

  sql_containers = {
    orders = {
      database_name       = "app"
      partition_key_paths = ["/tenantId"]
      autoscale_max_ru    = 4000
    }
  }

  tags = {
    Owner = "Platform"
  }
}
```

## Private Account

```hcl
module "cosmosdb" {
  source = "./modules/cosmosdb"

  resource_group_name           = "rg-platform-prod"
  location                      = "canadacentral"
  name                          = "cosmos-orders-prod-cc-001"
  public_network_access_enabled = false

  enable_private_endpoint    = true
  private_endpoint_subnet_id = module.vnet.subnet_ids["snet-private-endpoints"]
  private_dns_zone_ids       = [module.private_dns.zone_ids["privatelink.documents.azure.com"]]
}
```

## Diagnostics

```hcl
module "cosmosdb" {
  source = "./modules/cosmosdb"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  name                = "cosmos-orders-prod-cc-001"

  enable_diagnostics             = true
  log_analytics_workspace_id     = module.log_analytics.id
  log_analytics_destination_type = "Dedicated"
  diagnostic_log_categories      = ["AllLogs"]
}
```

## Testing

Run module checks from the module directory:

```powershell
terraform init -backend=false
terraform validate
terraform test
```

`tests/live.tftest.hcl` uses Terraform mock providers, so it validates module behavior without creating live Azure resources.

When a parent composition already knows resource-group tags, pass them with `inherited_resource_group_tags` to avoid a resource-group data lookup. Explicit `tags` take precedence.
