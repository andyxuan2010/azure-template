locals {
  location = var.location != "" ? var.location : data.azurerm_resource_group.sql.location

  merged_tags = merge(
    data.azurerm_resource_group.sql.tags,
    var.tags,
    {
      module = "sqldb"
    }
  )

  app_admin_group_values     = compact(coalesce(var.app_admin_group, []))
  app_admin_group_object_ids = toset([for value in local.app_admin_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_admin_group_names      = toset([for value in local.app_admin_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_user_group_values      = compact(coalesce(var.app_user_group, []))
  app_user_group_object_ids  = toset([for value in local.app_user_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_user_group_names       = toset([for value in local.app_user_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])

  admin_credentials_key_vault_id_effective = trimspace(var.admin_credentials_key_vault_id)
  admin_username_secret_name_effective     = trimspace(var.admin_username_secret_name)
  admin_password_secret_name_effective     = trimspace(var.admin_password_secret_name)

  admin_username_default = "sqladminuser"
  admin_password_default = "ChangeMeSql12345!"

  admin_username_input_effective = var.admin_username == null ? "" : trimspace(nonsensitive(var.admin_username))
  admin_password_input_effective = var.admin_password == null ? "" : trimspace(nonsensitive(var.admin_password))
  admin_username_input_provided  = nonsensitive(local.admin_username_input_effective != "")
  admin_password_input_provided  = nonsensitive(local.admin_password_input_effective != "")

  admin_credentials_key_vault_enabled  = local.admin_credentials_key_vault_id_effective != ""
  admin_username_secret_lookup_enabled = nonsensitive(local.admin_credentials_key_vault_enabled && !local.admin_username_input_provided && local.admin_username_secret_name_effective != "")
  admin_password_secret_lookup_enabled = nonsensitive(local.admin_credentials_key_vault_enabled && !local.admin_password_input_provided && local.admin_password_secret_name_effective != "")

  admin_username_secret_value = try(trimspace(data.azurerm_key_vault_secret.admin_username["active"].value), "")
  admin_password_secret_value = try(trimspace(data.azurerm_key_vault_secret.admin_password["active"].value), "")

  admin_username_effective = try(coalesce(
    local.admin_username_input_effective != "" ? local.admin_username_input_effective : null,
    local.admin_username_secret_value != "" ? local.admin_username_secret_value : null,
    local.admin_username_default
  ), local.admin_username_default)
  admin_password_effective = try(coalesce(
    local.admin_password_input_effective != "" ? local.admin_password_input_effective : null,
    local.admin_password_secret_value != "" ? local.admin_password_secret_value : null,
    local.admin_password_default
  ), local.admin_password_default)
}
