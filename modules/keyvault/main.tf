data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_subnet" "pep" {
  count    = local.create_private_endpoint && var.private_endpoint_subnet_id == "" ? 1 : 0
  provider = azurerm.prod

  name                 = var.private_endpoint_subnet_name
  virtual_network_name = var.private_endpoint_vnet_name
  resource_group_name  = var.private_endpoint_network_resource_group_name
}

data "azurerm_private_dns_zone" "this" {
  count    = local.create_private_endpoint && trimspace(var.private_dns_zone_id) == "" && var.private_dns_zone_name != null && var.private_dns_zone_resource_group_name != null ? 1 : 0
  provider = azurerm.prod

  name                = var.private_dns_zone_name
  resource_group_name = var.private_dns_zone_resource_group_name
}

data "azuread_group" "app_admin" {
  for_each = local.app_admin_group_names

  display_name = each.value
}

data "azuread_group" "app_user" {
  for_each = local.app_user_group_names

  display_name = each.value
}

resource "random_string" "random" {
  count       = var.name == "" ? 1 : 0
  length      = 4
  special     = false
  upper       = false
  min_numeric = 1
}

resource "azurerm_key_vault" "this" {
  name                            = local.key_vault_name
  location                        = local.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  tenant_id                       = local.tenant_id
  sku_name                        = lower(var.sku_name)
  rbac_authorization_enabled      = var.enable_rbac_authorization
  public_network_access_enabled   = var.public_network_access_enabled
  purge_protection_enabled        = var.purge_protection_enabled
  soft_delete_retention_days      = var.soft_delete_retention_days
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment

  dynamic "network_acls" {
    for_each = var.enable_network_acls ? [1] : []

    content {
      default_action             = var.network_acls_default_action
      bypass                     = var.network_acls_bypass
      ip_rules                   = var.network_acls_ip_rules
      virtual_network_subnet_ids = var.network_acls_virtual_network_subnet_ids
    }
  }

  tags = local.tags
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = merge(
    { for object_id in local.app_admin_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_admin : "name:${name}" => group.object_id }
  )

  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = merge(
    { for object_id in local.app_user_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_user : "name:${name}" => group.object_id }
  )

  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "current_caller_secrets_officer" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_private_endpoint" "this" {
  count = local.create_private_endpoint ? 1 : 0

  name                = "pep-${azurerm_key_vault.this.name}"
  location            = azurerm_key_vault.this.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = local.private_endpoint_subnet_id_resolved

  private_service_connection {
    name                           = "psc-${azurerm_key_vault.this.name}"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = local.private_dns_zone_id_resolved != "" ? [1] : []

    content {
      name                 = "default"
      private_dns_zone_ids = [local.private_dns_zone_id_resolved]
    }
  }

  tags = local.tags
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostics ? 1 : 0

  name                       = "${azurerm_key_vault.this.name}-diagnostic-setting"
  target_resource_id         = azurerm_key_vault.this.id
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
