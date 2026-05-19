# Azure AI Search Module

Provision an Azure AI Search service with optional managed identity, IP firewall rules, private endpoint, RBAC, and diagnostics.

## Overview

- Providers: `azurerm`, `azuread`, `random`
- Use case: search indexes, retrieval APIs, vector search backends, knowledge mining, and RAG support services
- Terraform tests: `tests/live.tftest.hcl`
- Private endpoint DNS zone: `privatelink.search.windows.net`

## Basic Usage

```hcl
module "azure_ai_search" {
  source = "./modules/azure_ai_search"

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  name                = "srch-example-prod-001"
  sku                 = "standard"
}
```

## Hardened Private Endpoint Usage

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

## Key Inputs

- `resource_group_name`: target resource group
- `name`: optional service name; generated if omitted
- `sku`: Search SKU, default `standard`
- `replica_count` and `partition_count`: search scale settings
- `hosting_mode`: optional hosting mode, including `highDensity` for supported SKUs
- `semantic_search_sku`: optional semantic ranker setting
- `identity`: optional system or user-assigned managed identity
- `allowed_ips`: optional IP allow list
- `enable_private_endpoint`: enables private endpoint creation
- `private_dns_zone_ids`: optional list of private DNS zones for the private endpoint
- `app_admin_group` and `app_user_group`: optional Entra groups for Contributor/Reader RBAC
- `enable_diagnostics` and `log_analytics_workspace_id`: optional diagnostic settings

## Key Outputs

- `id`, `name`, `endpoint`
- `sku`, `replica_count`, `partition_count`
- `primary_key`, `secondary_key`, `query_keys`
- `identity`
- `private_endpoint_id`
- `private_endpoint_fqdns`
- `private_endpoint_ip_addresses`
- `diagnostic_setting_id`

## Dependencies

- Required: existing resource group
- Common upstream: `rg`, `vnet`, `managedidentity`, `loganalytics`
- Common downstream: `openai`, application APIs, copilots, and RAG workloads

## Notes

- The free SKU does not support private endpoints, IP firewall rules, or semantic ranker configuration.
- This module exposes `customer_managed_key_enforcement_enabled` because the Terraform resource currently supports enforcement, not full customer-managed key wiring like `azure_ai_service` or `openai`.

## Testing

```powershell
terraform test -filter='tests\live.tftest.hcl'
```
