# Azure AI Search Examples

## Minimal Secure Search Service

```hcl
module "azure_ai_search" {
  source = "./modules/azure_ai_search"

  resource_group_name = "rg-example-prod"
  location            = "canadacentral"
  workload_name       = "rag"
  app_env             = "prod"
  sku                 = "standard"
}
```

## Deterministic Naming

```hcl
module "azure_ai_search" {
  source = "./modules/azure_ai_search"

  resource_group_name         = "rg-example-prod"
  location                    = "canadacentral"
  name                        = ""
  name_prefix                 = "srch"
  workload_name               = "shared"
  app_env                     = "poc"
  include_environment_in_name = true
  location_code               = "cc"
  instance                    = "001"
  use_random_suffix           = false
}
```

## Private Search Service

```hcl
module "azure_ai_search" {
  source = "./modules/azure_ai_search"

  resource_group_name = "rg-example-prod"
  location            = "canadacentral"
  name                = "srch-rag-prod-cc-001"
  sku                 = "standard"

  public_network_access_enabled = false
  enable_private_endpoint       = true
  private_endpoint_subnet_id    = "/subscriptions/<sub>/resourceGroups/<network-rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>"
  private_dns_zone_ids = [
    "/subscriptions/<sub>/resourceGroups/<dns-rg>/providers/Microsoft.Network/privateDnsZones/privatelink.search.windows.net"
  ]
}
```

## Identity, RBAC, And Diagnostics

```hcl
module "azure_ai_search" {
  source = "./modules/azure_ai_search"

  resource_group_name             = "rg-example-prod"
  location                        = "canadacentral"
  name                            = "srch-rag-prod-cc-001"
  app_env                         = "prod"
  system_managed_identity_enabled = true

  app_admin_group = ["11111111-1111-1111-1111-111111111111"]
  app_user_group  = ["22222222-2222-2222-2222-222222222222"]

  role_assignments = {
    search_index_reader = {
      principal_id         = "33333333-3333-3333-3333-333333333333"
      principal_type       = "Group"
      role_definition_name = "Search Index Data Reader"
    }
  }

  enable_diagnostics             = true
  log_analytics_workspace_id     = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.OperationalInsights/workspaces/<workspace>"
  log_analytics_destination_type = "Dedicated"
  diagnostic_storage_account_id  = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/<account>"
}
```

## Private Outbound Dependencies

```hcl
module "azure_ai_search" {
  source = "./modules/azure_ai_search"

  resource_group_name             = "rg-example-prod"
  location                        = "canadacentral"
  name                            = "srch-rag-prod-cc-001"
  system_managed_identity_enabled = true

  shared_private_link_services = {
    blob_ingest = {
      name               = "spl-blob-ingest"
      subresource_name   = "blob"
      target_resource_id = "/subscriptions/<sub>/resourceGroups/<data-rg>/providers/Microsoft.Storage/storageAccounts/<account>"
      request_message    = "Allow Azure AI Search indexers to read private blob content."
    }
  }
}
```

## High Density Search

```hcl
module "azure_ai_search" {
  source = "./modules/azure_ai_search"

  resource_group_name = "rg-example-prod"
  location            = "canadacentral"
  name                = "srch-rag-prod-cc-001"
  sku                 = "standard3"
  hosting_mode        = "highDensity"
  replica_count       = 3
  partition_count     = 3
  semantic_search_sku = "standard"
}
```

## Test Coverage

- `tests/live.tftest.hcl` validates named resources, deterministic generated names, standardized tags, secure defaults, identity, RBAC, diagnostics, private endpoint naming, shared private link resources, and high-density scale settings.
