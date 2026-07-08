resource "random_string" "suffix" {
  count = trimspace(var.name) == "" ? 1 : 0

  length  = 4
  upper   = false
  special = false
}

resource "azurerm_management_group" "this" {
  display_name               = local.display_name
  name                       = local.management_group_name
  parent_management_group_id = try(trimspace(var.parent_management_group_id), "") != "" ? var.parent_management_group_id : null
  subscription_ids           = local.subscription_ids
}
