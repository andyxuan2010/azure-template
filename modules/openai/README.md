# OpenAI Module

Provision an Azure OpenAI account with optional deployments, identity, customer-managed keys, network ACLs, private endpoint, RBAC, and diagnostics.

## Overview

- Providers: `azurerm`, `azuread`, `random`
- Use case: generative AI platform foundation, model deployments, chat/completions, embeddings, and private AI endpoints
- Terraform tests: `tests/live.tftest.hcl`
- Private endpoint behavior: if `enable_private_endpoint = true` and `custom_subdomain_name` is omitted, the module automatically uses the account name as the custom subdomain because Azure OpenAI private endpoints require one. This value is immutable after creation.

## Basic Usage

```hcl
module "openai" {
  source = "./modules/openai"

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  name                = "oai-example-prod-001"
  sku_name            = "S0"
}
```

## Hardened Private Endpoint Usage

```hcl
module "openai" {
  source = "./modules/openai"

  resource_group_name           = "rg-example-prod"
  location                      = "eastus"
  name                          = "oai-example-prod-001"
  public_network_access_enabled = false
  enable_private_endpoint       = true
  private_endpoint_subnet_id    = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<pep-subnet>"
  private_dns_zone_ids = [
    "/subscriptions/<subscription-id>/resourceGroups/<dns-rg>/providers/Microsoft.Network/privateDnsZones/privatelink.openai.azure.com"
  ]

  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}
```

## Key Inputs

- `resource_group_name`: target resource group
- `name`: optional account name; generated if omitted
- `sku_name`: OpenAI account SKU, default `S0`
- `identity`: optional system or user-assigned managed identity
- `customer_managed_key`: optional Key Vault-backed encryption configuration
- `network_acls`: optional IP and virtual network restrictions
- `deployments`: optional model deployments keyed by deployment name
- `enable_private_endpoint`: enables private endpoint creation
- `private_dns_zone_ids`: optional list of private DNS zones for the private endpoint
- `enable_diagnostics` and `log_analytics_workspace_id`: optional diagnostic settings

## Key Outputs

- `id`, `name`, `endpoint`
- `custom_subdomain_name`
- `deployment_ids`
- `deployment_details`
- `identity`
- `private_endpoint_id`
- `private_endpoint_fqdns`
- `private_endpoint_ip_addresses`
- `diagnostic_setting_id`

## Dependencies

- Required: existing resource group
- Common upstream: `rg`, `vnet`, `keyvault`, `managedidentity`
- Common downstream: application APIs, copilots, AI gateways, integration services

## Testing

```powershell
terraform test -filter='tests\live.tftest.hcl'
```
