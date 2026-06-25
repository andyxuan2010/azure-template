# Reference the existing Azure SQL Managed Instance
data "azurerm_mssql_managed_instance" "this" {
  name                = var.app_sqlmi
  resource_group_name = var.app_sqlmi_rg
}

data "azuread_group" "app_admin" {
  for_each = local.app_admin_group_names

  display_name = each.value
}

data "azuread_group" "app_user" {
  for_each = local.app_user_group_names

  display_name = each.value
}
