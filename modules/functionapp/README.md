# Function App Module

Provision Azure Function App with runtime stack, storage integration, networking, RBAC, and diagnostics.

## Overview

- Providers: `azuread` `3.8.0`, `azurerm` `4.65.0`
- Inputs: 50
- Outputs: 13
- Nested modules: 0
- Terraform tests: `tests/live.tftest.hcl`

## Features

- Creates managed resources including `azurerm_linux_function_app`, `azurerm_monitor_diagnostic_setting`, `azurerm_private_endpoint`, `azurerm_role_assignment`, `azurerm_windows_function_app`.
- Supports resource-level RBAC inputs for administrative and read-only access patterns.
- Supports private endpoint configuration using either direct IDs or lookup inputs where exposed.
- Supports optional diagnostic settings to Log Analytics.
- Includes Terraform test coverage files: `tests/live.tftest.hcl`.

## Basic Usage

```hcl
module "functionapp" {
  source = "./modules/functionapp"

  name = "name-example-001"
  resource_group_name = "rg-example-prod"
  service_plan_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/<provider>/<type>/<name>"
  storage_account_name = "storage-account-example-001"

  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Key Inputs

- `name`: Function App name. `string` (required)
- `resource_group_name`: Existing resource group name where the Function App will be created. `string` (required)
- `service_plan_id`: App Service Plan ID used to host the Function App. `string` (required)
- `storage_account_name`: Existing storage account name used by the Function App. `string` (required)
- `app_admin_group`: List of Microsoft Entra group display names or object IDs that should receive Contributor access to the Function App. `list(string)` (default: [])
- `app_user_group`: List of Microsoft Entra group display names or object IDs that should receive Reader access to the Function App. `list(string)` (default: [])
- `enable_diagnostics`: Whether to create a diagnostic setting for the Function App. `bool` (default: false)
- `enable_private_endpoint`: Whether to create a private endpoint for the Function App sites endpoint. `bool` (default: false)
- `log_analytics_workspace_id`: Log Analytics workspace ID used when diagnostics are enabled. `string` (default: "")
- `tags`: Tags applied to resources created by this module. `map(string)` (default: {})

## Notable Outputs

- `app_admin_group_role_assignment_ids`: Map of Contributor role assignment IDs keyed by app_admin_group principal ID.
- `app_user_group_role_assignment_ids`: Map of Reader role assignment IDs keyed by app_user_group principal ID.
- `default_hostname`: Default hostname for the Function App.
- `diagnostic_setting_id`: Diagnostic setting resource ID when diagnostics are enabled.
- `id`: Function App resource ID.
- `identity_principal_id`: Principal ID of the system-assigned managed identity when enabled.
- `identity_tenant_id`: Tenant ID of the system-assigned managed identity when enabled.
- `kind`: Function App operating system.
- `name`: Function App name.
- `private_endpoint_id`: Private endpoint resource ID when enabled.

## Testing

Run module tests from the module directory:

```powershell
terraform test
```

- `terraform test -filter='tests\live.tftest.hcl'`
