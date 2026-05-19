data "azurerm_resource_group" "sql" {
  name = var.resource_group_name
}

data "azurerm_key_vault_secret" "admin_username" {
  for_each = local.admin_username_secret_lookup_enabled ? { "active" = local.admin_username_secret_name_effective } : {}

  name         = each.value
  key_vault_id = local.admin_credentials_key_vault_id_effective
}

data "azurerm_key_vault_secret" "admin_password" {
  for_each = local.admin_password_secret_lookup_enabled ? { "active" = local.admin_password_secret_name_effective } : {}

  name         = each.value
  key_vault_id = local.admin_credentials_key_vault_id_effective
}

data "azuread_group" "app_admin" {
  for_each = local.app_admin_group_names

  display_name = each.value
}

data "azuread_group" "app_user" {
  for_each = local.app_user_group_names

  display_name = each.value
}
