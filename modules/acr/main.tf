data "azurerm_subnet" "pep" {
  count    = local.private_endpoint_lookup_by_name ? 1 : 0
  provider = azurerm.prod

  name                 = var.private_endpoint_subnet_name
  virtual_network_name = var.private_endpoint_vnet_name
  resource_group_name  = var.private_endpoint_network_resource_group_name
}

data "azurerm_private_dns_zone" "this" {
  count    = local.create_private_endpoint && trimspace(var.private_dns_zone_id) == "" && trimspace(var.private_dns_zone_name) != "" && trimspace(var.private_dns_zone_resource_group_name) != "" ? 1 : 0
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
  length      = 8
  special     = false
  upper       = false
  min_numeric = 1
}

resource "azurerm_container_registry" "this" {
  name                          = local.acr_name
  resource_group_name           = var.resource_group_name
  location                      = local.location
  sku                           = var.sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled
  anonymous_pull_enabled        = var.anonymous_pull_enabled
  data_endpoint_enabled         = var.data_endpoint_enabled
  network_rule_bypass_option    = var.sku == "Premium" && var.enable_network_rule_set ? var.network_rule_bypass_option : null

  dynamic "identity" {
    for_each = var.system_managed_identity_enabled ? [1] : []

    content {
      type = "SystemAssigned"
    }
  }

  dynamic "network_rule_set" {
    for_each = var.sku == "Premium" && var.enable_network_rule_set ? [{
      default_action = var.network_rule_default_action
      ip_rules       = local.network_rule_ip_rules
    }] : []

    content {
      default_action = network_rule_set.value.default_action

      dynamic "ip_rule" {
        for_each = toset(network_rule_set.value.ip_rules)

        content {
          action   = "Allow"
          ip_range = length(split("/", ip_rule.value)) > 1 ? ip_rule.value : "${ip_rule.value}/32"
        }
      }
    }
  }

  tags = local.tags
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = merge(
    { for object_id in local.app_admin_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_admin : "name:${name}" => group.object_id }
  )

  scope                = azurerm_container_registry.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = merge(
    { for object_id in local.app_user_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_user : "name:${name}" => group.object_id }
  )

  scope                = azurerm_container_registry.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

resource "azurerm_private_endpoint" "this" {
  count = local.create_private_endpoint ? 1 : 0

  name                = "pep-${azurerm_container_registry.this.name}"
  location            = azurerm_container_registry.this.location
  resource_group_name = var.resource_group_name
  subnet_id           = local.private_endpoint_subnet_id_final

  private_service_connection {
    name                           = "psc-${azurerm_container_registry.this.name}"
    private_connection_resource_id = azurerm_container_registry.this.id
    subresource_names              = ["registry"]
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

  name                       = "${azurerm_container_registry.this.name}-diagnostic-setting"
  target_resource_id         = azurerm_container_registry.this.id
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
