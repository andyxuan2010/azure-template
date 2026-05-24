data "azurerm_resource_group" "this" {
  count = trimspace(var.location) == "" ? 1 : 0

  name = var.resource_group_name
}

data "azurerm_monitor_diagnostic_categories" "web_app" {
  count = local.diagnostics_enabled && var.diagnostic_category_discovery_enabled ? 1 : 0

  resource_id = local.web_app.id
}

data "azurerm_subnet" "private_endpoint" {
  count = var.enable_private_endpoint && var.private_endpoint_subnet_id == "" && var.private_endpoint_subnet_name != null && var.private_endpoint_vnet_name != null && var.private_endpoint_network_resource_group_name != null ? 1 : 0

  name                 = var.private_endpoint_subnet_name
  virtual_network_name = var.private_endpoint_vnet_name
  resource_group_name  = var.private_endpoint_network_resource_group_name
}

data "azurerm_private_dns_zone" "webapp" {
  count = var.private_dns_zone_id == null && var.private_dns_zone_name != null && var.private_dns_zone_resource_group_name != null ? 1 : 0

  name                = var.private_dns_zone_name
  resource_group_name = var.private_dns_zone_resource_group_name
}

# VNet integration subnet: lookup by name when virtual_network_subnet_id is not set
data "azurerm_subnet" "vnet_integration" {
  count = (var.virtual_network_subnet_id == null || var.virtual_network_subnet_id == "") && var.vnet_integration_subnet_name != null && var.vnet_integration_vnet_name != null && var.vnet_integration_network_resource_group_name != null ? 1 : 0

  name                 = var.vnet_integration_subnet_name
  virtual_network_name = var.vnet_integration_vnet_name
  resource_group_name  = var.vnet_integration_network_resource_group_name
}

data "azuread_group" "app_admin" {
  for_each = local.app_admin_group_names

  display_name = each.value
}

data "azuread_group" "app_user" {
  for_each = local.app_user_group_names

  display_name = each.value
}
