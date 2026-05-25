data "azurerm_client_config" "current" {}

#get existing resource group
data "azurerm_resource_group" "iac" {
  count = trimspace(var.iac_rg) == "" ? 1 : 0
  name  = var.iac_rg
}

data "azurerm_resource_group" "app" {
  count = trimspace(var.resource_group_name) == "" ? 1 : 0
  name  = var.resource_group_name
}

#skip domain join password for sandbox environment
data "azurerm_key_vault_secret" "domain-join-password" {
  #count       = var.app_env == "sbx" ? 0 : 1
  for_each     = var.enable_domain_join && contains(["prod", "dev", "qa", "poc", "test"], var.app_env) ? { "active" = "domain-join-password" } : {}
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
