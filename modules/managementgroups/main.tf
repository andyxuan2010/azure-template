resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

resource "azurerm_management_group" "this" {
  display_name               = var.display_name
  name                       = local.management_group_name
  parent_management_group_id = try(trimspace(var.parent_management_group_id), "") != "" ? var.parent_management_group_id : null

  lifecycle {
    ignore_changes = [
      subscription_ids
    ]
  }
}
