# Private Endpoint Module

Creates an Azure Private Endpoint with optional Private DNS zone association, static IP configuration, inherited tags, and subnet/DNS lookup helpers.

## Overview

- Providers: `azurerm`
- Use case: private access to Azure PaaS resources from a delegated private endpoint subnet
- Naming: `pep-<workload>-<region-code>-<environment>-<instance>` when `name` is empty
- Terraform tests: `tests/live.tftest.hcl`

## Basic Usage

```hcl
module "storage_blob_private_endpoint" {
  source = "./modules/private_endpoint"

  name                           = "pep-platform-cc-dev-001"
  resource_group_name            = "rg-platform-dev"
  location                       = "canadacentral"
  subnet_id                      = module.vnet.subnet_ids["snet-private-endpoints"]
  private_connection_resource_id = module.storageaccount.id
  subresource_names              = ["blob"]

  private_dns_zone_ids = [
    azurerm_private_dns_zone.blob.id
  ]
}
```

## Lookup By Name

```hcl
module "key_vault_private_endpoint" {
  source = "./modules/private_endpoint"

  resource_group_name            = "rg-platform-dev"
  location                       = "canadacentral"
  subnet_name                    = "snet-private-endpoints"
  virtual_network_name           = "vnet-spoke-platform-dev"
  private_connection_resource_id = module.keyvault.id
  subresource_names              = ["vault"]

  private_dns_zone_names               = ["privatelink.vaultcore.azure.net"]
  private_dns_zone_resource_group_name = "rg-platform-dns"
}
```

## Proper Usage

- Prefer `subnet_id` from the `vnet` module when the subnet is managed in the same composition.
- Use one module instance per Private Endpoint target/subresource group.
- Associate Private DNS zones when the target service requires private DNS resolution from the VNet.
- Keep static `ip_configurations` empty unless the platform requires deterministic private endpoint IPs.
- Use `is_manual_connection = true` only when the target resource owner approves the connection separately.

## Dependencies

- Required: existing resource group, existing subnet, target resource ID
- Common upstream: `rg`, `vnet`, `private_dns`, target service module such as `storageaccount`, `keyvault`, `appservice`, `sqldb`, or `openai`
- Common downstream: DNS validation, application workloads using the private service endpoint

## Testing

```powershell
terraform test -filter='tests\live.tftest.hcl'
```

Tests use a mocked AzureRM provider and cover direct ID usage, generated naming, DNS zone association, and invalid subnet inputs.
