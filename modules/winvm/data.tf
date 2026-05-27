data "azurerm_client_config" "current" {}
#data.azurerm_client_config.current.tenant_id
#data.azurerm_client_config.current.client_id
#data.azurerm_client_config.current.subscription_id

data "azurerm_subscriptions" "available" {}
#data.azurerm_subscriptions.available.subscriptions




#get existing vnet
data "azurerm_virtual_network" "app" {
  name                = var.app_vnet
  resource_group_name = var.app_vnet_rg
}

# get existing subnet inside a vnet
data "azurerm_subnet" "app" {
  name                 = var.app_snet
  virtual_network_name = var.app_vnet
  resource_group_name  = var.app_vnet_rg
}

#get existing resource group
data "azurerm_resource_group" "iac" {
  name = var.iac_rg
}

data "azurerm_resource_group" "app" {
  name = var.app_rg
}
data "azurerm_key_vault_secret" "azure-user" {
  count        = local.admin_username_secret_lookup_enabled ? 1 : 0
  name         = local.admin_username_secret_name_effective
  key_vault_id = local.admin_credentials_key_vault_id_effective
}

data "azurerm_key_vault_secret" "azure-password" {
  count        = local.admin_password_secret_lookup_enabled ? 1 : 0
  name         = local.admin_password_secret_name_effective
  key_vault_id = local.admin_credentials_key_vault_id_effective
}

#skip domain join credentials for sandbox environment
data "azurerm_key_vault_secret" "domain_join_user" {
  count        = local.domain_join_username_secret_lookup_enabled ? 1 : 0
  name         = local.domain_join_username_secret_name_effective
  key_vault_id = local.admin_credentials_key_vault_id_effective
}

data "azurerm_key_vault_secret" "domain_join_password" {
  count        = local.domain_join_password_secret_lookup_enabled ? 1 : 0
  name         = local.domain_join_password_secret_name_effective
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

locals {
  vm_remote_group_value = try(trimspace(var.vm_remote_group), "")
  vm_admin_group_value  = try(trimspace(var.vm_admin_group), "")
}

data "azuread_group" "vm_remote_group_by_name" {
  count        = local.vm_remote_group_value != "" && !can(regex("^[0-9a-fA-F-]{36}$", local.vm_remote_group_value)) ? 1 : 0
  display_name = local.vm_remote_group_value
}

data "azuread_group" "vm_remote_group_by_id" {
  count     = local.vm_remote_group_value != "" && can(regex("^[0-9a-fA-F-]{36}$", local.vm_remote_group_value)) ? 1 : 0
  object_id = local.vm_remote_group_value
}

data "azuread_group" "vm_admin_group_by_name" {
  count        = local.vm_admin_group_value != "" && !can(regex("^[0-9a-fA-F-]{36}$", local.vm_admin_group_value)) ? 1 : 0
  display_name = local.vm_admin_group_value
}

data "azuread_group" "vm_admin_group_by_id" {
  count     = local.vm_admin_group_value != "" && can(regex("^[0-9a-fA-F-]{36}$", local.vm_admin_group_value)) ? 1 : 0
  object_id = local.vm_admin_group_value
}

data "azuread_group" "app_admin_group_by_name" {
  for_each = {
    for group in local.app_admin_group_values : group => group
    if !can(regex("^[0-9a-fA-F-]{36}$", group))
  }

  display_name = each.value
}

data "azuread_group" "app_user_group_by_name" {
  for_each = {
    for group in local.app_user_group_values : group => group
    if !can(regex("^[0-9a-fA-F-]{36}$", group))
  }

  display_name = each.value
}
