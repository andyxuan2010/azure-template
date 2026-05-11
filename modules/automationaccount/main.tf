# Data sources
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_subnet" "pep" {
  count = local.create_private_endpoint && var.private_endpoint_subnet_id == "" ? 1 : 0

  name                 = local.private_endpoint_subnet_name_resolved
  virtual_network_name = local.private_endpoint_vnet_name_resolved
  resource_group_name  = local.private_endpoint_network_resource_group_name_resolved
}

data "azuread_group" "app_admin" {
  for_each = local.app_admin_group_names

  display_name = each.value
}

data "azuread_group" "app_user" {
  for_each = local.app_user_group_names

  display_name = each.value
}

# Random string for unique naming
resource "random_string" "random" {
  count       = var.name == "" ? 1 : 0
  length      = 4
  special     = false
  upper       = false
  min_numeric = 1
}

# Automation Account resource
resource "azurerm_automation_account" "azure_automationaccount" {
  name                          = local.automation_account_name
  location                      = local.location
  resource_group_name           = data.azurerm_resource_group.rg.name
  sku_name                      = var.sku_name
  local_authentication_enabled  = var.local_auth_enabled
  public_network_access_enabled = var.public_access_enabled

  dynamic "identity" {
    for_each = var.system_managed_identity_enabled ? [1] : []

    content {
      type = "SystemAssigned"
    }
  }

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_role_assignment" "managed_identity" {
  for_each = local.managed_identity_role_assignments_effective

  scope                = each.value.scope
  role_definition_name = try(each.value.role_definition_name, null)
  role_definition_id   = try(each.value.role_definition_id, null)
  principal_id         = azurerm_automation_account.azure_automationaccount.identity[0].principal_id
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = merge(
    { for object_id in local.app_admin_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_admin : "name:${name}" => group.object_id }
  )

  scope                = azurerm_automation_account.azure_automationaccount.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = merge(
    { for object_id in local.app_user_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_user : "name:${name}" => group.object_id }
  )

  scope                = azurerm_automation_account.azure_automationaccount.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

# Private Endpoint
resource "azurerm_private_endpoint" "pep" {
  for_each = local.create_private_endpoint ? local.private_endpoint_subresources : {}

  name                = each.key == "legacy" ? "pep-${azurerm_automation_account.azure_automationaccount.name}" : "pep-${azurerm_automation_account.azure_automationaccount.name}-${each.key}"
  location            = azurerm_automation_account.azure_automationaccount.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = local.private_endpoint_subnet_id_resolved

  private_service_connection {
    name                           = "psc-${azurerm_automation_account.azure_automationaccount.name}"
    private_connection_resource_id = azurerm_automation_account.azure_automationaccount.id
    subresource_names              = [each.value]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_id != "" ? [1] : []

    content {
      name                 = "default_dns_zone"
      private_dns_zone_ids = [var.private_dns_zone_id]
    }
  }

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

# Optional Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "automation_account" {
  count = var.enable_diagnostics ? 1 : 0

  name                       = "${azurerm_automation_account.azure_automationaccount.name}-diagnostic-setting"
  target_resource_id         = azurerm_automation_account.azure_automationaccount.id
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
