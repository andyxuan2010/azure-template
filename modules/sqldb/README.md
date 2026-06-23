# Azure SQL Database Module

This module provisions an Azure SQL logical server and a single Azure SQL Database with secure defaults, standardized naming, private networking, auditing, diagnostics, backup retention, optional customer-managed keys, RBAC, and optional failover group support.

## What This Module Creates

- `azurerm_mssql_server`
- `azurerm_mssql_database`
- Optional SQL firewall rules, including the Azure services rule
- Optional server and database auditing policies
- Optional server and database threat detection policies
- Optional database diagnostic settings
- Optional private endpoint with private DNS zone group
- Optional failover group
- Optional Azure SQL free monthly limits for eligible serverless databases
- Optional Azure RBAC role assignments

## Secure Defaults

- Public network access is disabled by default.
- A system-assigned managed identity is enabled by default.
- Microsoft Entra administrator configuration is enabled by default.
- Transparent Data Encryption is enabled by default.
- Short-term backup retention is configured by default.
- Private endpoint creation is enabled by default, so provide `private_endpoint_subnet_id` or subnet lookup inputs.

## Basic Private Database

```hcl
module "sqldb" {
  source = "./modules/sqldb"

  resource_group_name = "rg-workload-prod"
  location            = "canadacentral"
  server_name         = "sql-workload-prod-001"
  database_name       = "sqldb-workload-prod-001"
  app_env             = "prod"

  admin_username      = "sqladminuser"
  admin_password      = var.sql_admin_password
  ad_admin_login_name = "sql-admin-group"
  ad_admin_object_id  = "00000000-0000-0000-0000-000000000000"

  private_endpoint_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-workload/subnets/snet-private-endpoints"
  private_dns_zone_ids = [
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net"
  ]

  tags = {
    Owner = "CCOE"
  }
}
```

## Generated Naming

Leave `server_name` and `database_name` empty to generate names from `name_prefix`, `database_name_prefix`, `workload_name`, `app_env`, `location_code`, and either `instance` or a random suffix.

```hcl
module "sqldb" {
  source = "./modules/sqldb"

  resource_group_name = "rg-platform-dev"
  location            = "canadacentral"
  workload_name       = "platform"
  app_env             = "dev"
  use_random_suffix   = false
  instance            = "001"

  admin_username      = "sqladminuser"
  admin_password      = var.sql_admin_password
  ad_admin_login_name = "sql-admin-group"
  ad_admin_object_id  = var.sql_admin_group_object_id

  private_endpoint_subnet_id = var.private_endpoint_subnet_id
}
```

This generates `sql-platform-dev-cc-001` and `sqldb-platform-dev-cc-001`.

## Authentication And Credentials

Credential precedence:

- Direct inputs `admin_username` and `admin_password`
- Key Vault secrets from `admin_credentials_key_vault_id`
- Built-in compatibility defaults

For production, prefer Key Vault-backed credentials or `azuread_authentication_only = true` with a Microsoft Entra administrator.

```hcl
admin_credentials_key_vault_id = azurerm_key_vault.platform.id
admin_username_secret_name     = "sql-admin-username"
admin_password_secret_name     = "sql-admin-password"
```

## Security And Monitoring

Use these options for hardened environments:

```hcl
public_network_access_enabled = false
minimum_tls_version           = "1.2"
enable_audit                  = true
enable_database_audit         = true
enable_threat_detection       = true
enable_database_threat_detection = true

enable_diagnostics         = true
log_analytics_workspace_id = azurerm_log_analytics_workspace.platform.id
diagnostic_log_categories  = ["AllLogs"]
diagnostic_metric_categories = ["AllMetrics"]
```

Diagnostic settings support Log Analytics, Storage Account, and Event Hub destinations.

## Backup And Resilience

```hcl
backup_retention_days      = 30
backup_interval_in_hours   = 12
backup_storage_redundancy  = "Geo"
geo_backup_enabled         = true
zone_redundant             = true
enable_long_term_retention = true

long_term_retention_policy = {
  weekly_retention          = 12
  monthly_retention         = 12
  yearly_retention          = 5
  week_of_year              = 1
  immutable_backups_enabled = true
}
```

For cross-region failover, configure `failover_group` with a partner server ID.

## Azure SQL Free Offer

For eligible subscriptions, Azure SQL free monthly limits can be enabled on a General Purpose serverless database.

```hcl
sku_name                    = "GP_S_Gen5_2"
backup_storage_redundancy   = "Local"
geo_backup_enabled          = false
auto_pause_delay_in_minutes = 60
min_capacity                = 0.5

use_free_limit                 = true
free_limit_exhaustion_behavior = "AutoPause"
```

When `use_free_limit = true` and `free_limit_exhaustion_behavior = "AutoPause"`, the module omits `max_size_gb` because Azure SQL only accepts the platform default size for that free-limit behavior.

Set `free_limit_exhaustion_behavior = "BillOverUsage"` only when you want the database to stay online and bill overage after the monthly free limits are exhausted.

## Customer-Managed Keys

Server-level and database-level TDE keys are supported. User-assigned identities can be attached to the server and database when needed.

```hcl
identity_ids = [azurerm_user_assigned_identity.sql.id]
primary_user_assigned_identity_id = azurerm_user_assigned_identity.sql.id
transparent_data_encryption_key_vault_key_id = azurerm_key_vault_key.sql_tde.id

database_identity_ids = [azurerm_user_assigned_identity.sqldb.id]
database_transparent_data_encryption_key_vault_key_id = azurerm_key_vault_key.sqldb_tde.id
database_transparent_data_encryption_key_automatic_rotation_enabled = true
```

## RBAC

Use `app_admin_group` and `app_user_group` for the common SQL server management roles, or `role_assignments` for custom assignments at server, database, or explicit scope.

```hcl
app_admin_group = ["00000000-0000-0000-0000-000000000000"]
app_user_group  = ["sql-readers"]

role_assignments = {
  database_reader = {
    principal_id         = "11111111-1111-1111-1111-111111111111"
    principal_type       = "Group"
    role_definition_name = "Reader"
    scope                = "database"
  }
}
```

## Important Inputs

- `resource_group_name`: Target resource group.
- `location`: Azure region. Leave empty to read the resource group location.
- `server_name`, `database_name`: Explicit names, or leave empty for generated names.
- `app_env`: One of `prod`, `staging`, `dev`, `qa`, `sbx`, `test`, or `poc`.
- `private_endpoint_subnet_id`: Required when `enable_private_endpoint = true` unless subnet lookup inputs are used.
- `ad_admin_login_name`, `ad_admin_object_id`: Required when Microsoft Entra administrator is enabled.
- `enable_diagnostics`: Requires at least one diagnostic destination.
- `enable_long_term_retention`: Requires at least one non-zero LTR retention value.
- `use_free_limit`: Enables Azure SQL free monthly limits for an eligible serverless database.

## Outputs

Common outputs include:

- `server_name`, `server_id`, `server_fqdn`
- `database_name`, `database_id`
- `private_endpoint_id`, `private_endpoint_name`
- `diagnostic_setting_id`, `diagnostics_enabled`
- `backup_configuration`, `security_configuration`
- `free_limit_configuration`
- `role_assignment_ids`, `role_assignment_count`
- `tags`

## Validation

From the module directory:

```powershell
terraform init -backend=false
terraform validate
terraform test
```

The test suite uses Terraform mock providers and runs plan-only coverage for secure defaults, generated names, private endpoint and diagnostics, RBAC, CMK, Entra-only authentication, and failover group configuration.
