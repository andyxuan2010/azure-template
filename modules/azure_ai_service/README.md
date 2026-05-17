# Azure AI Service Module

Provision an Azure AI Services account with optional identity, customer-managed keys, network ACLs, storage attachments, private endpoint, RBAC, and diagnostics.

## Overview

- Providers: `azurerm`, `azuread`, `random`
- Use case: AI services foundation, shared AI endpoint, document intelligence, vision, speech, and multi-service AI workloads
- Terraform tests: `tests/live.tftest.hcl`
- Private endpoint behavior: if `enable_private_endpoint = true` and `custom_subdomain_name` is omitted, the module automatically uses the account name as the custom subdomain because Cognitive Services private endpoints require one. This value is immutable after creation.

## Basic Usage

```hcl
module "azure_ai_service" {
  source = "./modules/azure_ai_service"

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  name                = "ais-example-prod-001"
  sku_name            = "S0"
}
```

## Hardened Private Endpoint Usage

```hcl
module "azure_ai_service" {
  source = "./modules/azure_ai_service"

  resource_group_name           = "rg-example-prod"
  location                      = "eastus"
  name                          = "ais-example-prod-001"
  public_network_access_enabled = false
  enable_private_endpoint       = true
  private_endpoint_subnet_id    = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<pep-subnet>"
  private_dns_zone_ids = [
    "/subscriptions/<subscription-id>/resourceGroups/<dns-rg>/providers/Microsoft.Network/privateDnsZones/privatelink.cognitiveservices.azure.com"
  ]

  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}
```

## Dependencies

- Required: existing resource group
- Common upstream: `rg`, `vnet`, `keyvault`, `managedidentity`
- Common downstream: application platforms, AI apps, document processing workloads

## Key Inputs

- `resource_group_name`: target resource group
- `name`: optional account name; generated if omitted
- `sku_name`: AI Services SKU, default `S0`
- `identity`: optional system or user-assigned managed identity
- `customer_managed_key`: optional Key Vault-backed encryption configuration
- `network_acls`: optional IP and virtual network restrictions
- `enable_private_endpoint`: enables private endpoint creation
- `private_dns_zone_ids`: optional list of private DNS zones for the private endpoint
- `app_admin_group` and `app_user_group`: optional Entra groups for Contributor/Reader RBAC
- `enable_diagnostics` and `log_analytics_workspace_id`: optional diagnostic settings

## Key Outputs

- `id`, `name`, `endpoint`
- `custom_subdomain_name`
- `identity`
- `private_endpoint_id`
- `private_endpoint_fqdns`
- `private_endpoint_ip_addresses`
- `diagnostic_setting_id`

## Testing

```powershell
terraform test -filter='tests\live.tftest.hcl'
```
