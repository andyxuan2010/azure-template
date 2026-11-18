# Reference the existing Azure SQL Managed Instance
data "azurerm_mssql_managed_instance" "this" {
  name                = var.app_sqlmi
  resource_group_name = var.app_sqlmi_rg
}

data "azurerm_resource_group" "rg" {
  count = var.inherit_resource_group_tags && var.inherited_resource_group_tags == null ? 1 : 0

  name = var.app_sqlmi_rg
}

data "azuread_group" "app_admin" {
  for_each = local.app_admin_group_names

  display_name = each.value
}

data "azuread_group" "app_user" {
  for_each = local.app_user_group_names

  display_name = each.value
}
