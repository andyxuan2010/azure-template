# Azure SQL Database Examples

These examples show common ways to use the standardized `sqldb` module. Replace placeholder resource IDs with values from your subscription.

## Example 1: Secure Private Database

```hcl
module "sqldb" {
  source = "./modules/sqldb"

  resource_group_name = "rg-app-prod"
  location            = "canadacentral"
  server_name         = "sql-app-prod-001"
  database_name       = "sqldb-app-prod-001"
  app_env             = "prod"
  sku_name            = "GP_Gen5_2"
  max_size_gb         = 64

  admin_username      = "sqladminuser"
  admin_password      = var.sql_admin_password
  ad_admin_login_name = "sql-admin-group"
  ad_admin_object_id  = var.sql_admin_group_object_id

  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  private_dns_zone_ids       = [var.sql_private_dns_zone_id]
}
```

## Example 2: Generated Names

```hcl
module "sqldb" {
  source = "./modules/sqldb"

  resource_group_name = "rg-platform-dev"
  location            = "canadacentral"
  workload_name       = "platform"
  app_env             = "dev"
  location_code       = "cc"
  instance            = "001"
  use_random_suffix   = false

  admin_username      = "sqladminuser"
  admin_password      = var.sql_admin_password
  ad_admin_login_name = "sql-admin-group"
  ad_admin_object_id  = var.sql_admin_group_object_id

  private_endpoint_subnet_id = var.private_endpoint_subnet_id
}
```

## Example 3: Hardened Production

```hcl
module "sqldb" {
  source = "./modules/sqldb"

  resource_group_name = "rg-payments-prod"
  location            = "canadacentral"
  server_name         = "sql-payments-prod-001"
  database_name       = "sqldb-payments-prod-001"
  app_env             = "prod"
  sku_name            = "GP_Gen5_4"
  max_size_gb         = 256
  zone_redundant      = true

  admin_credentials_key_vault_id = azurerm_key_vault.platform.id
  admin_username_secret_name     = "sql-admin-username"
  admin_password_secret_name     = "sql-admin-password"
  ad_admin_login_name            = "sql-admin-group"
  ad_admin_object_id             = var.sql_admin_group_object_id

  public_network_access_enabled = false
  private_endpoint_subnet_id    = var.private_endpoint_subnet_id
  private_dns_zone_ids          = [var.sql_private_dns_zone_id]

  backup_retention_days      = 30
  backup_storage_redundancy  = "Geo"
  enable_long_term_retention = true
  long_term_retention_policy = {
    weekly_retention          = 12
    monthly_retention         = 12
    yearly_retention          = 5
    week_of_year              = 1
    immutable_backups_enabled = true
  }

  enable_audit                     = true
  enable_database_audit            = true
  enable_threat_detection          = true
  enable_database_threat_detection = true
  threat_detection_email_addresses = ["security@example.com"]

  enable_diagnostics         = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.platform.id
  diagnostic_log_categories  = ["AllLogs"]
}
```

## Example 4: Entra-Only Authentication And CMK

```hcl
module "sqldb" {
  source = "./modules/sqldb"

  resource_group_name = "rg-secure-prod"
  location            = "canadacentral"
  server_name         = "sql-secure-prod-001"
  database_name       = "sqldb-secure-prod-001"
  app_env             = "prod"

  azuread_authentication_only = true
  ad_admin_login_name         = "sql-admin-group"
  ad_admin_object_id          = var.sql_admin_group_object_id

  identity_ids                              = [azurerm_user_assigned_identity.sql.id]
  primary_user_assigned_identity_id         = azurerm_user_assigned_identity.sql.id
  transparent_data_encryption_key_vault_key_id = azurerm_key_vault_key.sql_tde.id

  database_identity_ids = [azurerm_user_assigned_identity.sqldb.id]
  database_transparent_data_encryption_key_vault_key_id = azurerm_key_vault_key.sqldb_tde.id
  database_transparent_data_encryption_key_automatic_rotation_enabled = true

  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  enable_diagnostics         = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.platform.id
}
```

## Example 5: Failover Group

```hcl
module "sqldb" {
  source = "./modules/sqldb"

  resource_group_name = "rg-app-prod"
  location            = "canadacentral"
  server_name         = "sql-app-prod-001"
  database_name       = "sqldb-app-prod-001"
  app_env             = "prod"

  admin_username      = "sqladminuser"
  admin_password      = var.sql_admin_password
  ad_admin_login_name = "sql-admin-group"
  ad_admin_object_id  = var.sql_admin_group_object_id

  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  enable_diagnostics         = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.platform.id
  enable_long_term_retention = true
  long_term_retention_policy = {
    weekly_retention = 4
  }

  failover_group = {
    partner_server_id = azurerm_mssql_server.secondary.id
    read_write_endpoint_failover_policy = {
      mode          = "Automatic"
      grace_minutes = 60
    }
  }
}
```

## Example 6: Azure SQL Free Offer

```hcl
module "sqldb" {
  source = "./modules/sqldb"

  resource_group_name = "rg-platform-dev"
  location            = "canadacentral"
  server_name         = "sql-platform-cc-dev"
  database_name       = "sqldb-platform-dev"
  app_env             = "dev"

  sku_name                    = "GP_S_Gen5_2"
  backup_storage_redundancy   = "Local"
  geo_backup_enabled          = false
  auto_pause_delay_in_minutes = 60
  min_capacity                = 0.5

  use_free_limit                 = true
  free_limit_exhaustion_behavior = "AutoPause"

  public_network_access_enabled = true
  enable_private_endpoint       = false

  admin_username      = "sqladminuser"
  admin_password      = var.sql_admin_password
  ad_admin_login_name = "sql-admin-group"
  ad_admin_object_id  = var.sql_admin_group_object_id
}
```

## Example 7: Low-Cost Public Demo

Use this only for short-lived demos or sandbox environments.

```hcl
module "sqldb" {
  source = "./modules/sqldb"

  resource_group_name = "rg-demo-dev"
  location            = "canadacentral"
  server_name         = "sql-demo-dev-001"
  database_name       = "sqldb-demo-dev-001"
  app_env             = "dev"
  sku_name            = "Basic"
  max_size_gb         = 2

  admin_username      = "sqladminuser"
  admin_password      = var.sql_admin_password
  ad_admin_login_name = "sql-admin-group"
  ad_admin_object_id  = var.sql_admin_group_object_id

  enable_private_endpoint       = false
  public_network_access_enabled = true
  firewall_rules = {
    office = {
      start_ip_address = "203.0.113.10"
      end_ip_address   = "203.0.113.10"
    }
  }
}
```

## Testing

```powershell
terraform -chdir=modules\sqldb init -backend=false
terraform -chdir=modules\sqldb validate
terraform -chdir=modules\sqldb test
```
