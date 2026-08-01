data "azurerm_resource_group" "rg" {
  count = var.inherit_resource_group_tags && var.inherited_resource_group_tags == null ? 1 : 0

  name = var.resource_group_name
}

data "azurerm_key_vault_secret" "admin_password" {
  for_each = local.admin_password_secret_lookup_enabled ? { active = local.admin_password_secret_name_effective } : {}

  name         = each.value
  key_vault_id = local.admin_credentials_key_vault_id_effective
}

data "azurerm_key_vault_secret" "admin_ssh_key" {
  for_each = local.admin_ssh_key_secret_lookup_enabled ? { active = local.admin_ssh_key_secret_name_effective } : {}

  name         = each.value
  key_vault_id = local.admin_credentials_key_vault_id_effective
}
