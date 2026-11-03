data "azurerm_resource_group" "rg" {
  count = local.read_resource_group ? 1 : 0

  name = var.resource_group_name
}
