# Key Vault Module

Provision Azure Key Vault with RBAC, network ACLs, private endpoints, and diagnostics.

## Overview

- Providers: `azuread` `3.8.0`, `azurerm` `4.65.0`, `random` `3.8.1`
- Inputs: 34
- Outputs: 12
- Nested modules: 0
- Terraform tests: `tests/live.tftest.hcl`

## Features

- Creates managed resources including `azurerm_key_vault`, `azurerm_monitor_diagnostic_setting`, `azurerm_private_endpoint`, `azurerm_role_assignment`, `azurerm_string`.
- Supports resource-level RBAC inputs for administrative and read-only access patterns.
- Grants the current Terraform caller the `Key Vault Secrets Officer` role on the vault.
- Supports private endpoint configuration using direct IDs or lookup inputs for the subnet and private DNS zone.
- Supports optional diagnostic settings to Log Analytics.
- Requires callers to pass `azurerm.prod` when private endpoint subnet or private DNS zone lookup is used.
- Enforces purge protection by default according to Azure best practices.
- Includes Terraform test coverage files: `tests/live.tftest.hcl`.

## Basic Usage

```hcl
module "keyvault" {
  source = "./modules/keyvault"
  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name = "rg-example-prod"
  app_env             = "prod"

  tags = {
    ManagedBy = "Terraform"
  }
}
```

The module also grants the current Terraform caller `Key Vault Secrets Officer` access on the created vault.

## Key Inputs

- `resource_group_name`: The name of the resource group where the Key Vault will be deployed. `string` (required)
- `app_env`: Deployment environment used for standardisation and naming (dev, staging, prod, sbx, test, qa). `string` (default: "dev")
- `app_admin_group`: List of Entra group display names or object IDs that should receive Key Vault Administrator access. Prefer object IDs when display names are not unique. `list(string)` (default: null)
- `app_user_group`: List of Entra group display names or object IDs that should receive Key Vault Secrets User access. Prefer object IDs when display names are not unique. `list(string)` (default: null)
- `contacts`: A list of contacts for Key Vault certificates notifications. `list(object)` (default: [])
- `enable_diagnostics`: Enable diagnostic settings for the Key Vault. `bool` (default: false)
- `enable_private_endpoint`: Whether to create a private endpoint for the Key Vault. `bool` (default: false)
- `log_analytics_workspace_id`: Log Analytics workspace resource ID for diagnostics. `string` (default: "")
- `private_dns_zone_id`: Optional Private DNS zone ID attached to the Key Vault private endpoint. `string` (default: "")
- `private_dns_zone_name`: Optional existing Private DNS zone name resolved through `azurerm.prod` when `private_dns_zone_id` is not set. `string` (default: `null`)
- `private_dns_zone_resource_group_name`: Resource group containing the private DNS zone used for lookup. `string` (default: `null`)
- `tags`: A mapping of tags to assign to the resources. `map(string)` (default: {})

## Private DNS Options

Use one of these patterns for private endpoint DNS:

- Direct ID via `private_dns_zone_id`
- Lookup by name via `private_dns_zone_name` plus `private_dns_zone_resource_group_name`

## Notable Outputs

- `app_admin_group_role_assignment_ids`: Map of Key Vault Administrator role assignment IDs keyed by app_admin_group input.
- `app_user_group_role_assignment_ids`: Map of Key Vault Secrets User role assignment IDs keyed by app_user_group input.
- `diagnostic_setting_id`: The ID of the diagnostic setting, if created.
- `id`: The ID of the Key Vault.
- `location`: The location of the Key Vault.
- `name`: The name of the Key Vault.
- `private_endpoint_id`: The ID of the private endpoint, if created.
- `private_endpoint_name`: The name of the private endpoint, if created.
- `resource_group_name`: The resource group containing the Key Vault.
- `tags`: The effective tags assigned to the Key Vault.

## Testing

Run module tests from the module directory:

```powershell
terraform test
```

- `terraform test -filter='tests\live.tftest.hcl'`
