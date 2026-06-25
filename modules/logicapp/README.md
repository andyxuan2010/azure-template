# Logic App Module

Provision Azure Logic App Standard with secure defaults, storage integration, managed identity, private networking, RBAC, and diagnostics.

## Overview

- Providers: `azuread` `3.8.0`, `azurerm` `4.65.0`
- Inputs: 49
- Outputs: 17
- Nested modules: 0
- Terraform tests: mock-provider plans in `tests/live.tftest.hcl`

## Features

- Creates managed resources including `azurerm_logic_app_standard`, `azurerm_monitor_diagnostic_setting`, `azurerm_private_endpoint`, and `azurerm_role_assignment`.
- Supports resource-level RBAC inputs for administrative and read-only access patterns.
- Supports private endpoint configuration using either direct IDs or lookup inputs where exposed.
- Supports optional diagnostic settings to Log Analytics.
- Uses deterministic plan-only tests and never creates Azure resources.

## Basic Usage

```hcl
module "logicapp" {
  source = "./modules/logicapp"

  name                  = "logic-example-001"
  resource_group_name   = "rg-example-prod"
  service_plan_id       = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Web/serverFarms/<plan-name>"
  storage_account_name  = "storageexample001"

  tags = {
    Owner = "Platform"
  }
}
```

## Key Inputs

- `name`: Logic App Standard name. `string` (required)
- `resource_group_name`: Existing resource group name where the Logic App Standard will be created. `string` (required)
- `service_plan_id`: App Service Plan ID used to host the Logic App Standard. `string` (required)
- `storage_account_name`: Existing storage account name used by the Logic App Standard. `string` (required)
- `app_admin_group`: List of Microsoft Entra group display names or object IDs that should receive Contributor access to the Logic App Standard. `list(string)` (default: [])
- `app_user_group`: List of Microsoft Entra group display names or object IDs that should receive Reader access to the Logic App Standard. `list(string)` (default: [])
- `enable_diagnostics`: Whether to create a diagnostic setting for the Logic App Standard. `bool` (default: false)
- `enable_private_endpoint`: Whether to create a private endpoint for the Logic App Standard sites endpoint. `bool` (default: false)
- `log_analytics_workspace_id`: Log Analytics workspace ID used when diagnostics are enabled. `string` (default: "")
- `tags`: Tags applied to resources created by this module. `map(string)` (default: {})

## Notable Outputs

- `app_admin_group_role_assignment_ids`: Map of Contributor role assignment IDs keyed by app_admin_group principal ID.
- `app_user_group_role_assignment_ids`: Map of Reader role assignment IDs keyed by app_user_group principal ID.
- `default_hostname`: Default hostname for the Logic App Standard.
- `diagnostic_setting_id`: Diagnostic setting resource ID when diagnostics are enabled.
- `id`: Logic App Standard resource ID.
- `identity_principal_id`: Principal ID of the system-assigned managed identity when enabled.
- `identity_tenant_id`: Tenant ID of the system-assigned managed identity when enabled.
- `kind`: Logic App Standard kind reported by Azure.
- `name`: Logic App Standard name.
- `private_endpoint_id`: Private endpoint resource ID when enabled.

## Testing

Run module tests from the module directory:

```powershell
terraform test
```

- `terraform test -filter='tests\live.tftest.hcl'`

The suite covers the secure baseline, identity, private endpoints, diagnostics,
VNet route-all validation, and duplicate connection-string rejection.
