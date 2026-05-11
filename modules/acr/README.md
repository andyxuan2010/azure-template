# Azure Container Registry Module

Provision Azure Container Registry with optional RBAC, network rules, private endpoints, and diagnostics.

## Overview

- Providers: `azuread` `3.8.0`, `azurerm` `4.65.0`, `random` `3.8.1`
- Inputs: 28
- Outputs: 8
- Nested modules: 0
- Terraform tests: `tests/live.tftest.hcl`

## Features

- Creates managed resources including `azurerm_container_registry`, `azurerm_monitor_diagnostic_setting`, `azurerm_private_endpoint`, `azurerm_role_assignment`, `azurerm_string`.
- Supports resource-level RBAC inputs for administrative and read-only access patterns.
- Supports private endpoint configuration using direct IDs or lookup inputs for the subnet and private DNS zone.
- Supports optional diagnostic settings to Log Analytics.
- Requires callers to pass `azurerm.prod` when private endpoint subnet or private DNS zone lookup is used.
- Includes Terraform test coverage files: `tests/live.tftest.hcl`.

## Basic Usage

```hcl
module "acr" {
  source = "./modules/acr"
  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name = "rg-example-prod"
  location            = "eastus"

  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Key Inputs

- `resource_group_name`: Existing resource group name where the Azure Container Registry will be created. `string` (required)
- `location`: Azure region for the Azure Container Registry. `string` (required)
- `app_admin_group`: Entra groups that receive Contributor on the registry resource. Values may be display names or object IDs. `list(string)` (default: null)
- `app_user_group`: Entra groups that receive Reader on the registry resource. Values may be display names or object IDs. `list(string)` (default: null)
- `enable_diagnostics`: Whether to create a diagnostic setting for the registry. `bool` (default: false)
- `enable_private_endpoint`: Whether to create a private endpoint for the registry. `bool` (default: false)
- `log_analytics_workspace_id`: Log Analytics workspace ID used when diagnostics are enabled. `string` (default: "")
- `private_dns_zone_id`: Optional private DNS zone ID for the registry private endpoint. `string` (default: "")
- `private_dns_zone_name`: Optional existing Private DNS zone name resolved through `azurerm.prod` when `private_dns_zone_id` is not set. `string` (default: `""`)
- `private_dns_zone_resource_group_name`: Resource group containing the private DNS zone used for lookup. `string` (default: `""`)
- `tags`: Tags applied to resources created by this module. `map(string)` (default: {})

## Private DNS Options

Use one of these patterns for private endpoint DNS:

- Direct ID via `private_dns_zone_id`
- Lookup by name via `private_dns_zone_name` plus `private_dns_zone_resource_group_name`

## Notable Outputs

- `admin_password`: Admin password when admin access is enabled.
- `admin_username`: Admin username when admin access is enabled.
- `id`: Azure Container Registry resource ID.
- `login_server`: Azure Container Registry login server.
- `name`: Azure Container Registry name.
- `private_endpoint_id`: Private endpoint ID when enabled.
- `role_assignment_ids`: Role assignment IDs created for app_admin_group and app_user_group.
- `tags`: Effective tags applied to the registry.

## Testing

Run module tests from the module directory:

```powershell
terraform test
```

- `terraform test -filter='tests\live.tftest.hcl'`
