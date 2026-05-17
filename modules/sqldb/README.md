# SQL Database Module

Provision Azure SQL Server and SQL Database with RBAC, auditing, private endpoint, and diagnostics.

## Overview

- Providers: `azuread` `>= 2.0.0`, `azurerm` `>= 3.0.0`
- Nested modules: 0
- Terraform tests: `tests/live.tftest.hcl`

## Best Practices Implemented

- Standardized variable naming (e.g., `server_name` instead of `server_name`).
- Explicit configuration for Managed Identity (`SystemAssigned`) on the SQL Server.
- Configured Private DNS Zone Group integration for Private Endpoints natively.
- Explicit definition of Transparent Data Encryption (TDE) on the Database.

## Features

- Creates managed resources including `azurerm_monitor_diagnostic_setting`, `azurerm_mssql_database`, `azurerm_mssql_server`, `azurerm_mssql_server_extended_auditing_policy`, `azurerm_mssql_server_security_alert_policy`.
- Supports resource-level RBAC inputs for administrative and read-only access patterns via Microsoft Entra groups.
- Supports private endpoint configuration using either direct IDs or lookup inputs, optionally connecting to Private DNS Zones.
- Supports optional diagnostic settings to Log Analytics.
- Includes Terraform test coverage files: `tests/live.tftest.hcl`.

## Basic Usage

```hcl
module "sqldb" {
  source = "./modules/sqldb"

  app_env             = "prod"
  server_name         = "sql-workload-prod-001"
  database_name       = "sqldb-workload-prod-001"
  max_size_gb         = 2
  sku_name            = "Basic"
  backup_storage_redundancy = "Local"
  public_network_access_enabled = true
  firewall_rules = {
    office = {
      start_ip_address = "203.0.113.10"
      end_ip_address   = "203.0.113.10"
    }
  }
  
  admin_username      = "sqladmin"
  admin_password      = "ChangeMe123!"
  ad_admin_login_name = "sql-admin-group"
  ad_admin_object_id  = "00000000-0000-0000-0000-000000000000"

  resource_group_name = "rg-workload-prod"
  location            = "eastus"

  tags = {
    ManagedBy = "Terraform"
  }
}
```

Credential precedence:

- direct module inputs `admin_username` and `admin_password` win when set
- otherwise the module reads `admin_username_secret_name` and `admin_password_secret_name` from `admin_credentials_key_vault_id`
- if neither direct input nor Key Vault value is available, the module uses its built-in defaults

## Low-Cost Test And Demo Usage

- Use `sku_name = "Basic"` for the lowest-cost supported single database profile in this module.
- When `sku_name = "Basic"`, set `max_size_gb` to `2` or less.
- Use `backup_storage_redundancy = "Local"` when you want locally redundant backups at the lowest cost.
- Use `S0` or higher only when you need more Standard-tier capacity or features.

## Key Inputs

- `app_env`: Deployment environment (dev, staging, prod, sbx, test, qa) `string` (required)
- `server_name`: Name of the SQL Server `string` (required)
- `database_name`: Name of the SQL Database `string` (required)
- `resource_group_name`: Resource Group for SQL resources `string` (required)
- `admin_username`: Optional admin username override. When omitted, the module falls back to Key Vault and then to the built-in default `sqladminuser`. `string` (default: `null`)
- `admin_password`: Optional admin password override. When omitted, the module falls back to Key Vault and then to the built-in default `ChangeMeSql12345!`. `string` (default: `null`, sensitive)
- `admin_credentials_key_vault_id`: Optional Key Vault resource ID for SQL admin credentials. `string` (default: `""`)
- `admin_username_secret_name`: Key Vault secret name for the admin username fallback. `string` (default: `"azure-user"`)
- `admin_password_secret_name`: Key Vault secret name for the admin password fallback. `string` (default: `"azure-password"`)
- `ad_admin_login_name`: AD Admin username for SQL Server `string` (required)
- `ad_admin_object_id`: AD Admin Object ID for SQL Server `string` (required)
- `app_admin_group`: List of Microsoft Entra group display names or object IDs that should receive Contributor access. `list(string)` (default: [])
- `app_user_group`: List of Microsoft Entra group display names or object IDs that should receive Reader access. `list(string)` (default: [])
- `enable_private_endpoint`: Whether to enable private endpoint for SQL Server `bool` (default: true)
- `public_network_access_enabled`: Whether to enable public network access for SQL Server `bool` (default: false)
- `firewall_rules`: Optional map of SQL firewall rules with `start_ip_address` and `end_ip_address`. `map(object)` (default: `{}`)
- `private_dns_zone_ids`: List of Private DNS Zone IDs to associate with the Private Endpoint `list(string)` (default: [])
- `enable_diagnostics`: Enable diagnostic settings for the database `bool` (default: false)
- `log_analytics_workspace_id`: Log Analytics workspace ID for diagnostics (required if enable_diagnostics=true) `string` (default: "")

## Testing

Run module tests from the module directory:

```powershell
terraform test
```
