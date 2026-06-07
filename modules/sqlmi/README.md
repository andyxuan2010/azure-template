# SQL Managed Instance Module

Provision Azure SQL Managed Instance with identity, Entra administrator, RBAC, and diagnostics.

## Overview

- Providers: `azuread` `3.8.0`, `azurerm` `4.65.0`
- Inputs: 29
- Outputs: 12
- Nested modules: 0
- Terraform tests: `tests/live.tftest.hcl`

## Features

- Creates managed resources including `azurerm_monitor_diagnostic_setting`, `azurerm_mssql_managed_instance`, `azurerm_role_assignment`.
- Supports resource-level RBAC inputs for administrative and read-only access patterns.
- Supports optional diagnostic settings to Log Analytics.
- Includes Terraform test coverage files: `tests/live.tftest.hcl`.

## Basic Usage

```hcl
module "sqlmi" {
  source = "./modules/sqlmi"

  administrator_login = "<administrator_login>"
  administrator_login_password = "<administrator_login_password>"
  name = "name-example-001"
  resource_group_name = "rg-example-prod"
  sku_name = "sku-example-001"
  storage_size_in_gb = 1
  subnet_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/<provider>/<type>/<name>"
  vcores = 1

  tags = {
    Owner = "Platform"
  }
}
```

## Key Inputs

- `administrator_login`: SQL administrator login name. `string` (required)
- `administrator_login_password`: SQL administrator login password. `string` (required)
- `name`: SQL Managed Instance name. `string` (required)
- `resource_group_name`: Resource group where the SQL Managed Instance will be created. `string` (required)
- `sku_name`: SQL Managed Instance SKU name, for example GP_Gen5 or BC_Gen5. `string` (required)
- `storage_size_in_gb`: Storage size in GB for the SQL Managed Instance. `number` (required)
- `subnet_id`: Delegated subnet resource ID for the SQL Managed Instance. `string` (required)
- `vcores`: Number of vCores for the SQL Managed Instance. `number` (required)
- `app_admin_group`: List of Microsoft Entra group display names or object IDs that should receive Contributor access to the SQL Managed Instance resource. `list(string)` (default: [])
- `app_user_group`: List of Microsoft Entra group display names or object IDs that should receive Reader access to the SQL Managed Instance resource. `list(string)` (default: [])
- `enable_diagnostics`: Whether to create a diagnostic setting for the SQL Managed Instance. `bool` (default: false)
- `log_analytics_workspace_id`: Log Analytics workspace resource ID for diagnostics. `string` (default: "")
- `tags`: Custom tags to apply to the SQL Managed Instance. `map(string)` (default: {})

## Notable Outputs

- `administrator_login`: Administrator login name for the SQL Managed Instance.
- `app_admin_group_role_assignment_ids`: Map of Contributor role assignment IDs keyed by app_admin_group principal ID.
- `app_user_group_role_assignment_ids`: Map of Reader role assignment IDs keyed by app_user_group principal ID.
- `diagnostic_setting_id`: Diagnostic setting ID, if diagnostics are enabled.
- `fqdn`: Fully qualified domain name of the SQL Managed Instance.
- `id`: Resource ID of the SQL Managed Instance.
- `location`: Azure region of the SQL Managed Instance.
- `name`: Name of the SQL Managed Instance.
- `principal_id`: Managed identity principal ID, if enabled.
- `resource_group_name`: Resource group containing the SQL Managed Instance.

## Testing

Run module tests from the module directory:

```powershell
terraform test
```

- `terraform test -filter='tests\live.tftest.hcl'`
