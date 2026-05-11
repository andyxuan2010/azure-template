# Resource Group Module

Provision Azure Resource Group with optional lock, RBAC, and tagging.

## Overview

- Providers: `azuread` `3.8.0`, `azurerm` `4.65.0`, `random` `3.8.1`
- Inputs: 8
- Outputs: 7
- Nested modules: 0
- Terraform tests: `tests/live.tftest.hcl`

## Features

- Creates managed resources including `azurerm_management_lock`, `azurerm_resource_group`, `azurerm_role_assignment`, `azurerm_string`.
- Supports resource-level RBAC inputs for administrative and read-only access patterns.
- Includes Terraform test coverage files: `tests/live.tftest.hcl`.

## Basic Usage

```hcl
module "rg" {
  source = "./modules/rg"

  location = "eastus"

  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Key Inputs

- `location`: The Azure region where the resource group will be deployed. `string` (required)
- `app_admin_group`: List of Entra group display names or object IDs that should receive Contributor access to the resource group. Prefer object IDs when display names are not unique. `list(string)` (default: null)
- `app_user_group`: List of Entra group display names or object IDs that should receive Reader access to the resource group. Prefer object IDs when display names are not unique. `list(string)` (default: null)
- `tags`: A mapping of tags to assign to the resource group. `map(string)` (default: {})

## Notable Outputs

- `app_admin_group_role_assignment_ids`: Map of Contributor role assignment IDs keyed by app_admin_group input.
- `app_user_group_role_assignment_ids`: Map of Reader role assignment IDs keyed by app_user_group input.
- `id`: The ID of the resource group.
- `location`: The location of the resource group.
- `lock_id`: The ID of the management lock, if created.
- `name`: The name of the resource group.
- `tags`: The effective tags assigned to the resource group.

## Testing

Run module tests from the module directory:

```powershell
terraform test
```

- `terraform test -filter='tests\live.tftest.hcl'`
