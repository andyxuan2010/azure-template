# App Service Plan Module

Provision Azure App Service Plan with optional autoscale, RBAC, and diagnostics.

## Overview

- Providers: `azuread` `3.8.0`, `azurerm` `4.65.0`
- Inputs: 25
- Outputs: 13
- Nested modules: 0
- Terraform tests: `tests/live.tftest.hcl`

## Features

- Creates managed resources including `azurerm_monitor_autoscale_setting`, `azurerm_monitor_diagnostic_setting`, `azurerm_role_assignment`, `azurerm_service_plan`.
- Supports resource-level RBAC inputs for administrative and read-only access patterns.
- Supports optional diagnostic settings to Log Analytics.
- Includes Terraform test coverage files: `tests/live.tftest.hcl`.

## Basic Usage

```hcl
module "appserviceplan" {
  source = "git::https://dev.azure.com/CCOE-Azure/CCoE-Infra-IaC/_git/template//modules/appserviceplan?ref=main"

  location = "canadacentral"
  name = "name-example-001"
  resource_group_name = "rg-example-prod"
  sku_name = "sku-example-001"

  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Key Inputs

- `location`: Azure region `string` (required)
- `name`: Name of the App Service Plan `string` (required)
- `resource_group_name`: Resource group where the App Service Plan will be created `string` (required)
- `sku_name`: SKU name for the App Service Plan (e.g., B1, S1, P1v3, EP1) `string` (required)
- `app_admin_group`: List of Microsoft Entra group display names or object IDs that should receive Contributor access to the App Service Plan. `list(string)` (default: [])
- `app_user_group`: List of Microsoft Entra group display names or object IDs that should receive Reader access to the App Service Plan. `list(string)` (default: [])
- `enable_diagnostics`: Enable diagnostics for the App Service Plan `bool` (default: false)
- `log_analytics_workspace_id`: Log Analytics Workspace ID for diagnostics `string` (default: null)
- `diagnostic_log_categories`: Optional diagnostic log categories to request. When left empty, the module enables whatever log categories Azure reports as supported for that specific App Service Plan resource. If you provide values, unsupported categories are filtered out automatically before the diagnostic setting is created. `list(string)` (default: `[]`)
- `tags`: Tags applied to the App Service Plan and autoscale setting `map(string)` (default: {})

## Notable Outputs

- `app_admin_group_role_assignment_ids`: Map of Contributor role assignment IDs keyed by app_admin_group principal ID.
- `app_user_group_role_assignment_ids`: Map of Reader role assignment IDs keyed by app_user_group principal ID.
- `autoscale_config`: Autoscale configuration details
- `autoscale_setting_id`: ID of the autoscale setting
- `autoscale_setting_name`: Name of the autoscale setting
- `diagnostic_setting_id`: ID of the diagnostic setting
- `diagnostic_setting_name`: Name of the diagnostic setting
- `id`: ID of the App Service Plan
- `location`: Location of the App Service Plan
- `name`: Name of the App Service Plan

## Testing

Run module tests from the module directory:

```powershell
terraform test
```

- `terraform test -filter='tests\live.tftest.hcl'`
