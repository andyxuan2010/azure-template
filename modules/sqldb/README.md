# SQL Database Module

Provision Azure SQL Server and SQL Database with RBAC, auditing, private endpoint, and diagnostics.

## Overview

- Providers: `azuread` `3.8.0`, `azurerm` `4.65.0`
- Inputs: 31
- Outputs: 13
- Nested modules: 0
- Terraform tests: `tests/live.tftest.hcl`

## Features

- Creates managed resources including `azurerm_monitor_diagnostic_setting`, `azurerm_mssql_database`, `azurerm_mssql_server`, `azurerm_mssql_server_extended_auditing_policy`, `azurerm_mssql_server_security_alert_policy`.
- Supports resource-level RBAC inputs for administrative and read-only access patterns.
- Supports private endpoint configuration using either direct IDs or lookup inputs where exposed.
- Supports optional diagnostic settings to Log Analytics.
- Includes Terraform test coverage files: `tests/live.tftest.hcl`.

## Basic Usage

```hcl
module "sqldb" {
  source = "./modules/sqldb"

  app_env = "<app_env>"
  sql_ad_admin = "<sql_ad_admin>"
  sql_ad_admin_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/<provider>/<type>/<name>"
  sql_admin_password = "<sql_admin_password>"
  sql_admin_username = "<sql_admin_username>"
  sql_database_name = "sql-database-example-001"
  sql_max_size_gb = 1

  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Key Inputs

- `app_env`: Deployment environment (dev, staging, prod, sbx, test, qa) `string` (required)
- `sql_ad_admin`: AD Admin username for SQL Server `string` (required)
- `sql_ad_admin_id`: AD Admin id (Object ID) for SQL Server `string` (required)
- `sql_admin_password`: Admin password for SQL Server `string` (required)
- `sql_admin_username`: Admin username for SQL Server `string` (required)
- `app_admin_group`: List of Microsoft Entra group display names or object IDs that should receive Contributor access to the SQL Server resource. `list(string)` (default: [])
- `app_user_group`: List of Microsoft Entra group display names or object IDs that should receive Reader access to the SQL Server resource. `list(string)` (default: [])
- `enable_diagnostics`: Enable diagnostic settings for the database `bool` (default: false)
- `enable_private_endpoint`: Whether to enable private endpoint for SQL Server `bool` (default: true)
- `log_analytics_workspace_id`: Log Analytics workspace ID for diagnostics (required if enable_diagnostics=true) `string` (default: "")
- `tags`: Customized tags for resources `map(string)` (default: {})

## Notable Outputs

- `app_admin_group_role_assignment_ids`: Map of Contributor role assignment IDs keyed by app_admin_group principal ID.
- `app_user_group_role_assignment_ids`: Map of Reader role assignment IDs keyed by app_user_group principal ID.
- `backup_configuration`: Database backup and security configuration summary
- `database_tags`: Tags applied to the SQL Database
- `diagnostic_setting_id`: Resource ID of the diagnostic setting, if enabled.
- `private_endpoint_id`: Resource ID of the private endpoint (if enabled)
- `private_endpoint_nic_id`: NIC ID of the private endpoint (if enabled)
- `sql_database_id`: Resource ID of the SQL Database
- `sql_database_name`: The name of the SQL Database
- `sql_server_fqdn`: FQDN of the SQL Server

## Testing

Run module tests from the module directory:

```powershell
terraform test
```

- `terraform test -filter='tests\live.tftest.hcl'`
