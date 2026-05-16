data "azurerm_virtual_network" "app" {
  count               = var.self_hosted_integration_runtime_enabled ? 1 : 0
  name                = var.app_vnet
  resource_group_name = var.app_vnet_rg
}

data "azurerm_subnet" "app" {
  count                = local.network_inputs_required ? 1 : 0
  name                 = local.private_endpoint_by_name ? local.private_endpoint_subnet_name_final : var.app_snet
  virtual_network_name = local.private_endpoint_by_name ? local.private_endpoint_vnet_name_final : var.app_vnet
  resource_group_name  = local.private_endpoint_by_name ? local.private_endpoint_rg_name_final : var.app_vnet_rg
}

data "azurerm_resource_group" "iac" {
  count = var.self_hosted_integration_runtime_enabled ? 1 : 0

  name = var.iac_rg
}

data "azurerm_storage_account" "iac" {
  count = local.storage_lookup_required ? 1 : 0

  name                = var.iac_st
  resource_group_name = var.iac_rg
}

data "azurerm_key_vault" "iac" {
  count = local.iac_lookup_required ? 1 : 0

  name                = var.iac_kv
  resource_group_name = var.iac_rg
}

data "azurerm_resource_group" "adf" {
  count = trimspace(var.location) == "" ? 1 : 0

  name = var.resource_group
}

data "azurerm_private_dns_zone" "adf_datafactory" {
  count               = var.enable_private_endpoint && trimspace(var.private_dns_zone_id) == "" ? 1 : 0
  name                = var.private_dns_zone_name
  resource_group_name = var.private_dns_zone_resource_group_name
}

data "azuread_group" "app_admin" {
  for_each = local.app_admin_group_names

  display_name = each.value
}

data "azuread_group" "app_user" {
  for_each = local.app_user_group_names

  display_name = each.value
}
