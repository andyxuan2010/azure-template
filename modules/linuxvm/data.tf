data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "app" {
  count = (
    (var.inherit_resource_group_tags && var.inherited_resource_group_tags == null) ||
    length(local.all_access_group_principal_ids) > 0
  ) ? 1 : 0

  name = var.resource_group_name
}

#skip domain join credentials for sandbox environment
data "azurerm_key_vault_secret" "domain_join_user" {
  for_each     = local.domain_join_username_secret_lookup_enabled ? { "active" = local.domain_join_username_secret_name_effective } : {}
  name         = each.value
  key_vault_id = local.iac_kv_id_effective
}

data "azurerm_key_vault_secret" "domain-join-password" {
  #count       = var.app_env == "sbx" ? 0 : 1
  for_each     = local.domain_join_secret_lookup_allowed ? { "active" = "domain-join-password" } : {}
  name         = each.value
  key_vault_id = local.iac_kv_id_effective
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

data "azurerm_key_vault_secret" "admin_ssh_key" {
  for_each = local.admin_ssh_key_secret_lookup_enabled ? { "active" = local.admin_ssh_key_secret_name_effective } : {}

  name         = each.value
  key_vault_id = local.admin_credentials_key_vault_id_effective
}
# get an existing managed identity
# data "azurerm_user_assigned_identity" "identity" {
#   name                = "my-identity"
#   resource_group_name = "my-resource-group"
# }

# get an existing app service
# data "azurerm_app_service" "app" {
#   name                = "my-app-service"
#   resource_group_name = "my-resource-group"
# }

# this is the windows init script before init.ps1 run.
# first run init.cmd, then init.ps1 and then scheduled.ps1
# data "template_file" "cloud-init" {
#   template = file("${path.module}/scripts/cloud-init.ps1")
# }
