data "azurerm_resource_group" "rg" {
  count = var.inherit_resource_group_tags && var.inherited_resource_group_tags == null ? 1 : 0

  name = var.resource_group_name
}

data "azurerm_subnet" "this" {
  count = local.subnet_lookup_by_name ? 1 : 0

  provider = azurerm.prod

  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = local.virtual_network_resource_group_name
}

data "azurerm_private_dns_zone" "this" {
  for_each = toset(local.private_dns_zone_lookup_names)

  provider = azurerm.prod

  name                = each.value
  resource_group_name = var.private_dns_zone_resource_group_name
}
