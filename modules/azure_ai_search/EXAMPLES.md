# Azure AI Search Examples

## Basic Azure AI Search Service

```hcl
module "azure_ai_search" {
  source = "./modules/azure_ai_search"

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  name                = "srch-example-prod-001"
  sku                 = "standard"
}
```

## Private Azure AI Search Service

```hcl
module "azure_ai_search" {
  source = "./modules/azure_ai_search"

  resource_group_name           = "rg-example-prod"
  location                      = "eastus"
  name                          = "srch-example-prod-001"
  sku                           = "standard"
  public_network_access_enabled = false
  enable_private_endpoint       = true
  private_endpoint_subnet_id    = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<pep-subnet>"
  private_dns_zone_ids = [
    "/subscriptions/<subscription-id>/resourceGroups/<dns-rg>/providers/Microsoft.Network/privateDnsZones/privatelink.search.windows.net"
  ]
}
```

## Search Service With Identity And Firewall Rules

```hcl
module "azure_ai_search" {
  source = "./modules/azure_ai_search"

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  name                = "srch-example-prod-001"
  sku                 = "standard"
  replica_count       = 2
  partition_count     = 1

  identity = {
    type = "SystemAssigned"
  }

  allowed_ips = [
    "203.0.113.10",
    "203.0.113.11"
  ]
}
```

## Standard3 High Density Search Service

```hcl
module "azure_ai_search" {
  source = "./modules/azure_ai_search"

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  name                = "srch-example-prod-001"
  sku                 = "standard3"
  hosting_mode        = "highDensity"
  replica_count       = 3
  partition_count     = 3
  semantic_search_sku = "standard"
}
```
