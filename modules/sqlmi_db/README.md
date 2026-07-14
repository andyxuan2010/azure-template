# SQL Managed Instance Database Module

Provision Azure SQL Managed Instance databases with RBAC and diagnostics.

## Overview

- Providers: `azuread` `3.8.0`, `azurerm` `4.65.0`
- Inputs: 11
- Outputs: 11
- Nested modules: 0
- Terraform tests: `tests/live.tftest.hcl`

## Features

- Creates managed resources including `azurerm_monitor_diagnostic_setting`, `azurerm_mssql_managed_database`, `azurerm_role_assignment`.
- Supports resource-level RBAC inputs for administrative and read-only access patterns.
- Supports optional diagnostic settings to Log Analytics.
- Uses deterministic mocked plan tests; no Azure credentials or live resources are required.
- Accepts Entra group object IDs or display names. Object IDs are preferred.

## Basic Usage

```hcl
module "sqlmi_db" {
  source = "./modules/sqlmi_db"

  app_sqlmi    = "sqlmi-data-prod"
  app_sqlmi_db = "orders"
  app_sqlmi_rg = "rg-data-prod"
}
```

## Key Inputs

- `app_sqlmi`: Name of the SQL Managed Instance to reference `string` (required)
- `app_sqlmi_db`: Name of the managed database `string` (required)
- `app_sqlmi_rg`: Resource group where the managed instance resides `string` (required)
- `app_admin_group`: List of Microsoft Entra group display names or object IDs that should receive Contributor access to the SQL Managed Database resource and Reader access to the SQL Managed Instance resource. `list(string)` (default: [])
- `app_user_group`: List of Microsoft Entra group display names or object IDs that should receive Reader access to both the SQL Managed Database and SQL Managed Instance resources. `list(string)` (default: [])
- `enable_diagnostics`: Enable diagnostic settings for the managed database `bool` (default: false)
- `log_analytics_workspace_id`: Log Analytics workspace ID for diagnostics (resource ID) `string` (default: "")

## Notable Outputs

- `administrator_login`: No description in outputs file.
- `app_admin_group_role_assignment_ids`: Map of Contributor role assignment IDs keyed by app_admin_group principal ID.
- `app_admin_group_managed_instance_role_assignment_ids`: Map of SQL Managed Instance Reader role assignment IDs keyed by app_admin_group principal ID.
- `app_user_group_role_assignment_ids`: Map of Reader role assignment IDs keyed by app_user_group principal ID.
- `app_user_group_managed_instance_role_assignment_ids`: Map of SQL Managed Instance Reader role assignment IDs keyed by app_user_group principal ID.
- `diagnostics_enabled`: Whether diagnostics are enabled.
- `diagnostic_setting_id`: Diagnostic setting ID when created.
- `fqdn`: No description in outputs file.
- `managed_database_id`: Resource ID of the managed database
- `managed_database_name`: The name of the managed database
- `managed_database_tags`: Effective database tags, merging SQL Managed Instance tags with caller tags.
- `managed_instance_id`: The managed instance resource ID referenced
- `name`: No description in outputs file.

## Testing

Run module tests from the module directory:

```powershell
terraform test
```

- `terraform test`
