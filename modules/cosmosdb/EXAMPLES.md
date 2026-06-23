# Cosmos DB Examples

## Secure SQL API Account With Generated Name

```hcl
module "cosmosdb" {
  source = "../cosmosdb"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  workload_name       = "orders"
  app_env             = "prod"
  use_random_suffix   = false
  instance            = "001"

  tags = {
    Owner = "Platform"
  }
}
```

## SQL Database And Containers

```hcl
module "cosmosdb" {
  source = "../cosmosdb"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  name                = "cosmos-orders-prod-cc-001"

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
      default_ttl         = 2592000

      indexing_policy = {
        included_paths = [{ path = "/*" }]
        excluded_paths = [{ path = "/largePayload/?" }]
      }

      unique_keys = [
        { paths = ["/tenantId", "/orderNumber"] }
      ]
    }
  }
}
```

## Multi-Region Account

```hcl
module "cosmosdb" {
  source = "../cosmosdb"

  resource_group_name              = "rg-platform-prod"
  location                         = "canadacentral"
  name                             = "cosmos-orders-prod-001"
  automatic_failover_enabled       = true
  multiple_write_locations_enabled = false

  geo_locations = [
    {
      location          = "canadacentral"
      failover_priority = 0
      zone_redundant    = true
    },
    {
      location          = "westus2"
      failover_priority = 1
      zone_redundant    = true
    }
  ]
}
```

## Private Endpoint With DNS Lookup

```hcl
module "cosmosdb" {
  source = "../cosmosdb"

  resource_group_name           = "rg-platform-prod"
  location                      = "canadacentral"
  name                          = "cosmos-orders-prod-cc-001"
  public_network_access_enabled = false

  enable_private_endpoint                  = true
  private_endpoint_subnet_id               = module.vnet.subnet_ids["snet-private-endpoints"]
  private_dns_zone_names                   = ["privatelink.documents.azure.com"]
  private_dns_zone_resource_group_name     = "rg-platform-dns"
  private_endpoint_network_interface_name  = "nic-pep-cosmos-orders-prod-cc-001"
}
```

## RBAC And Diagnostics

```hcl
module "cosmosdb" {
  source = "../cosmosdb"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  name                = "cosmos-orders-prod-cc-001"

  enable_diagnostics             = true
  log_analytics_workspace_id     = module.log_analytics.id
  log_analytics_destination_type = "Dedicated"
  diagnostic_log_categories      = ["AllLogs"]

  app_admin_group = ["11111111-1111-1111-1111-111111111111"]
  app_user_group  = ["22222222-2222-2222-2222-222222222222"]

  role_assignments = {
    auditor = {
      principal_id         = "33333333-3333-3333-3333-333333333333"
      principal_type       = "Group"
      role_definition_name = "Reader"
    }
  }
}
```

## Notes

- Prefer Microsoft Entra ID RBAC and keep `local_authentication_disabled = true` unless legacy clients require keys.
- Prefer private endpoint plus `public_network_access_enabled = false` for production workloads.
- Use `autoscale_max_ru` for unpredictable workloads and set throughput at either the database or container level, not both for the same workload boundary.
