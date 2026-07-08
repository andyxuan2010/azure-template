resource "azurerm_mssql_managed_instance" "this" {
  name                           = local.sqlmi_name
  resource_group_name            = var.resource_group_name
  location                       = local.location_resolved
  subnet_id                      = var.subnet_id
  administrator_login            = var.administrator_login
  administrator_login_password   = var.administrator_login_password
  sku_name                       = var.sku_name
  license_type                   = var.license_type
  vcores                         = var.vcores
  storage_size_in_gb             = var.storage_size_in_gb
  collation                      = var.collation
  minimum_tls_version            = var.minimum_tls_version
  timezone_id                    = var.timezone_id
  public_data_endpoint_enabled   = var.public_data_endpoint_enabled
  proxy_override                 = var.proxy_override
  storage_account_type           = var.storage_account_type
  maintenance_configuration_name = var.maintenance_configuration_name
  zone_redundant_enabled         = var.zone_redundant_enabled
  dns_zone_partner_id            = local.dns_zone_partner_id_resolved
  tags                           = local.merged_tags

  dynamic "identity" {
    for_each = var.identity_type == "" ? [] : [1]

    content {
      type         = var.identity_type
      identity_ids = contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type) ? var.identity_ids : null
    }
  }

  dynamic "azure_active_directory_administrator" {
    for_each = var.azure_active_directory_administrator == null ? [] : [var.azure_active_directory_administrator]

    content {
      login_username                      = azure_active_directory_administrator.value.login_username
      object_id                           = azure_active_directory_administrator.value.object_id
      principal_type                      = azure_active_directory_administrator.value.principal_type
      tenant_id                           = try(azure_active_directory_administrator.value.tenant_id, null)
      azuread_authentication_only_enabled = try(azure_active_directory_administrator.value.azuread_authentication_only_enabled, false)
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "${azurerm_mssql_managed_instance.this.name}-diagnostic"
  target_resource_id         = azurerm_mssql_managed_instance.this.id
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

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = merge(
    { for object_id in local.app_admin_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_admin : "name:${name}" => group.object_id }
  )

  scope                = azurerm_mssql_managed_instance.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = merge(
    { for object_id in local.app_user_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_user : "name:${name}" => group.object_id }
  )

  scope                = azurerm_mssql_managed_instance.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}
