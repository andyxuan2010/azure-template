# Automation Account Module

Provision Azure Automation Account with RBAC, optional private endpoints, and diagnostics.

## Overview

- Providers: `azuread` `3.8.0`, `azurerm` `4.63.0`, `random` `3.8.1`
- Inputs: 26
- Outputs: 19
- Nested modules: 0
- Terraform tests: `tests/live.tftest.hcl`

## Features

- Creates managed resources including `azurerm_automation_account`, `azurerm_monitor_diagnostic_setting`, `azurerm_private_endpoint`, `azurerm_role_assignment`, `azurerm_string`.
- Supports resource-level RBAC inputs for administrative and read-only access patterns.
- Supports private endpoint configuration using either direct IDs or lookup inputs where exposed.
- Supports optional diagnostic settings to Log Analytics.
- Includes Terraform test coverage files: `tests/live.tftest.hcl`.

## Basic Usage

```hcl
module "automationaccount" {
  source = "./modules/automationaccount"

  resource_group_name = "rg-example-prod"

  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Key Inputs

- `resource_group_name`: The name of the resource group where the Automation Account will be deployed. `string` (required)
- `app_admin_group`: Microsoft Entra group display names or object IDs granted Contributor on the Automation Account. `list(string)` (default: [])
- `app_user_group`: Microsoft Entra group display names or object IDs granted Reader on the Automation Account. `list(string)` (default: [])
- `enable_diagnostics`: Enable diagnostic settings for the Automation Account. `bool` (default: false)
- `log_analytics_workspace_id`: Log Analytics workspace resource ID for diagnostics. Required when enable_diagnostics is true. `string` (default: "")
- `tags`: A mapping of tags to assign to the resources. `map(string)` (default: {})

## Notable Outputs

- `app_admin_group_role_assignment_ids`: Map of Contributor role assignment IDs keyed by app_admin_group principal ID.
- `app_user_group_role_assignment_ids`: Map of Reader role assignment IDs keyed by app_user_group principal ID.
- `diagnostic_setting_id`: The ID of the diagnostic setting (if created).
- `id`: The ID of the Automation Account.
- `identity`: The identity block of the Automation Account.
- `local_authentication_enabled`: Whether local authentication is enabled for the Automation Account.
- `location`: The location of the Automation Account.
- `managed_identity_role_assignment_ids`: Map of managed identity role assignment IDs keyed by assignment name.
- `name`: The name of the Automation Account.
- `principal_id`: The Principal ID of the System Assigned Managed Identity (null when identity is disabled).

## Testing

Run module tests from the module directory:

```powershell
terraform test
```

- `terraform test -filter='tests\live.tftest.hcl'`
