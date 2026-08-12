data "azurerm_virtual_network" "this" {
  count = local.virtual_network_lookup_required ? 1 : 0

  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

data "azuread_group" "app_admin" {
  for_each = local.app_admin_group_names

  display_name = each.value
}

data "azuread_group" "app_user" {
  for_each = local.app_user_group_names

  display_name = each.value
}
