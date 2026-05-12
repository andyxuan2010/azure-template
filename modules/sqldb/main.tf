resource "azurerm_mssql_server" "sql_server" {
  name                          = var.server_name
  resource_group_name           = data.azurerm_resource_group.sql.name
  location                      = local.location
  version                       = var.server_version
  administrator_login           = var.admin_username
  administrator_login_password  = var.admin_password
  public_network_access_enabled = var.public_network_access_enabled
  minimum_tls_version           = var.minimum_tls_version

  identity {
    type = "SystemAssigned"
  }

  azuread_administrator {
    login_username = var.ad_admin_login_name
    object_id      = var.ad_admin_object_id
  }

  tags = local.merged_tags
}

resource "azurerm_mssql_database" "sql_db" {
  name           = var.database_name
  server_id      = azurerm_mssql_server.sql_server.id
  sku_name       = var.sku_name
  collation      = var.collation
  max_size_gb    = var.max_size_gb
  zone_redundant = var.zone_redundant

  transparent_data_encryption_enabled = true

  # Backup retention settings
  short_term_retention_policy {
    retention_days = var.backup_retention_days
  }

  dynamic "long_term_retention_policy" {
    for_each = var.enable_long_term_retention ? [1] : []

    content {
      weekly_retention  = try(var.long_term_retention_policy.weekly_retention, 0) > 0 ? "P${var.long_term_retention_policy.weekly_retention}W" : null
      monthly_retention = try(var.long_term_retention_policy.monthly_retention, 0) > 0 ? "P${var.long_term_retention_policy.monthly_retention}M" : null
      yearly_retention  = try(var.long_term_retention_policy.yearly_retention, 0) > 0 ? "P${var.long_term_retention_policy.yearly_retention}Y" : null
      week_of_year      = try(var.long_term_retention_policy.yearly_retention, 0) > 0 ? 1 : null
    }
  }

  tags = local.merged_tags
}

# Server threat detection policy
resource "azurerm_mssql_server_security_alert_policy" "threat_detection" {
  count               = var.enable_threat_detection ? 1 : 0
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mssql_server.sql_server.name
  state               = "Enabled"

  disabled_alerts = []
  retention_days  = var.audit_retention_days > 0 ? var.audit_retention_days : 0

  email_addresses = []
}

# Auditing policy
resource "azurerm_mssql_server_extended_auditing_policy" "audit" {
  count                  = var.enable_audit ? 1 : 0
  server_id              = azurerm_mssql_server.sql_server.id
  log_monitoring_enabled = true
  retention_in_days      = var.audit_retention_days
}

# Diagnostic settings for database
resource "azurerm_monitor_diagnostic_setting" "sql_diagnostics" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "diag-${var.database_name}"
  target_resource_id         = azurerm_mssql_database.sql_db.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = toset(var.diagnostic_log_categories)

    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = toset(var.diagnostic_metric_categories)

    content {
      category = enabled_metric.value
    }
  }
}

# Private endpoint for SQL Server
resource "azurerm_private_endpoint" "sql" {
  count               = var.enable_private_endpoint && var.private_endpoint_subnet_id != "" ? 1 : 0
  name                = "pep-${var.server_name}"
  location            = local.location
  resource_group_name = data.azurerm_resource_group.sql.name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "plsc-${var.server_name}"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }

  tags = local.merged_tags
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = merge(
    { for object_id in local.app_admin_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_admin : "name:${name}" => group.object_id }
  )

  scope                = azurerm_mssql_server.sql_server.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = merge(
    { for object_id in local.app_user_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_user : "name:${name}" => group.object_id }
  )

  scope                = azurerm_mssql_server.sql_server.id
  role_definition_name = "Reader"
  principal_id         = each.value
}
