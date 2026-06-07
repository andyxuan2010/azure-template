# Virtual Network Module

Provision Azure Virtual Network and subnets with RBAC and diagnostics.

## Overview

- Providers: `azuread` `3.8.0`, `azurerm` `4.65.0`, `random` `3.8.1`
- Inputs: 17
- Outputs: 11
- Nested modules: 0
- Terraform tests: `tests/live.tftest.hcl`

## Features

- Creates managed resources including `azurerm_monitor_diagnostic_setting`, `azurerm_role_assignment`, `azurerm_string`, `azurerm_subnet`, `azurerm_virtual_network`.
- Supports resource-level RBAC inputs for administrative and read-only access patterns.
- Supports optional diagnostic settings to Log Analytics.
- Includes Terraform test coverage files: `tests/live.tftest.hcl`.

## Basic Usage

```hcl
module "vnet" {
  source = "./modules/vnet"

  address_space = []
  resource_group_name = "rg-example-prod"

  tags = {
    Owner = "Platform"
  }
}
```

## Key Inputs

- `address_space`: The address spaces applied to the virtual network. `list(string)` (required)
- `resource_group_name`: The name of the resource group where the virtual network will be deployed. `string` (required)
- `app_admin_group`: List of Entra group display names or object IDs that should receive Contributor access to the virtual network. Prefer object IDs when display names are not unique. `list(string)` (default: null)
- `app_user_group`: List of Entra group display names or object IDs that should receive Reader access to the virtual network. Prefer object IDs when display names are not unique. `list(string)` (default: null)
- `enable_diagnostics`: Enable diagnostic settings for the virtual network. `bool` (default: false)
- `log_analytics_workspace_id`: Log Analytics workspace resource ID for diagnostics. Required when enable_diagnostics is true. `string` (default: "")
- `tags`: A mapping of tags to assign to the resources. `map(string)` (default: {})

## Notable Outputs

- `address_space`: The address spaces configured on the virtual network.
- `app_admin_group_role_assignment_ids`: Map of Contributor role assignment IDs keyed by app_admin_group input.
- `app_user_group_role_assignment_ids`: Map of Reader role assignment IDs keyed by app_user_group input.
- `diagnostic_setting_id`: The ID of the diagnostic setting, if created.
- `id`: The ID of the virtual network.
- `location`: The location of the virtual network.
- `name`: The name of the virtual network.
- `resource_group_name`: The name of the resource group containing the virtual network.
- `subnet_ids`: Map of subnet IDs keyed by subnet name.
- `subnet_names`: Map of subnet names keyed by subnet name.

## Testing

Run module tests from the module directory:

```powershell
terraform test
```

- `terraform test -filter='tests\live.tftest.hcl'`
