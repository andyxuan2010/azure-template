data "azurerm_resource_group" "rg" {
  count = var.inherit_resource_group_tags && var.inherited_resource_group_tags == null ? 1 : 0

  name = var.resource_group_name
}
