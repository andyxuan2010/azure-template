# -----------------------------------------------------------------------------
# Data sources for existing private endpoint subnet and private DNS zone
# Use these when leveraging existing infrastructure instead of passing resource IDs.
# Private DNS zone used by the app service private endpoint.
# -----------------------------------------------------------------------------

data "azurerm_subnet" "private_endpoint" {
  count = var.enable_private_endpoint && var.private_endpoint_subnet_id == "" && var.private_endpoint_subnet_name != null && var.private_endpoint_vnet_name != null && var.private_endpoint_network_resource_group_name != null ? 1 : 0

  name                 = var.private_endpoint_subnet_name
  virtual_network_name = var.private_endpoint_vnet_name
  resource_group_name  = var.private_endpoint_network_resource_group_name
}

# provider "azurerm" {
#   subscription_id = "ef8ff35a-8548-485c-be32-204db0340dd1"
#   features {}
#   alias = "prod"
# }
data "azurerm_private_dns_zone" "webapp" {
  count    = var.private_dns_zone_id == null && var.private_dns_zone_name != null && var.private_dns_zone_resource_group_name != null ? 1 : 0
  provider = azurerm.prod

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

