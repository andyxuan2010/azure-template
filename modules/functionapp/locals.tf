locals {
  location                                 = try(trimspace(var.location), "") != "" ? var.location : data.azurerm_resource_group.rg.location
  is_windows                               = var.os_type == "Windows"
  storage_account_resource_group_name      = try(trimspace(var.storage_account_resource_group_name), "") != "" ? var.storage_account_resource_group_name : var.resource_group_name
  key_vault_reference_identity_id_resolved = try(trimspace(var.key_vault_reference_identity_id), "") != "" ? var.key_vault_reference_identity_id : null

  identity_ids  = concat(compact([var.key_vault_reference_identity_id]), var.identity_ids)
  identity_type = join(", ", compact([var.system_assigned_identity_enabled ? "SystemAssigned" : "", length(local.identity_ids) > 0 ? "UserAssigned" : ""]))

  vnet_integration_lookup_by_name = (
    try(trimspace(var.virtual_network_subnet_id), "") == "" &&
    try(trimspace(var.vnet_integration_subnet_name), "") != "" &&
    try(trimspace(var.vnet_integration_vnet_name), "") != "" &&
    try(trimspace(var.vnet_integration_network_resource_group_name), "") != ""
  )
  vnet_integration_subnet_id_resolved = try(trimspace(var.virtual_network_subnet_id), "") != "" ? var.virtual_network_subnet_id : try(data.azurerm_subnet.vnet_integration[0].id, "")

  private_endpoint_subnet_lookup_by_name = (
    var.enable_private_endpoint &&
    try(trimspace(var.private_endpoint_subnet_id), "") == "" &&
    try(trimspace(var.private_endpoint_subnet_name), "") != "" &&
    try(trimspace(var.private_endpoint_vnet_name), "") != "" &&
    try(trimspace(var.private_endpoint_network_resource_group_name), "") != ""
  )
  private_endpoint_subnet_id_resolved = try(trimspace(var.private_endpoint_subnet_id), "") != "" ? var.private_endpoint_subnet_id : try(data.azurerm_subnet.private_endpoint[0].id, "")

  private_dns_zone_lookup_by_name = (
    var.enable_private_endpoint &&
    try(trimspace(var.private_dns_zone_id), "") == "" &&
    try(trimspace(var.private_dns_zone_name), "") != "" &&
    try(trimspace(var.private_dns_zone_resource_group_name), "") != ""
  )
  private_dns_zone_id_resolved = try(trimspace(var.private_dns_zone_id), "") != "" ? var.private_dns_zone_id : try(data.azurerm_private_dns_zone.functionapp[0].id, "")

  function_app = local.is_windows ? (
    var.storage_uses_managed_identity ? azurerm_windows_function_app.managed_identity[0] : azurerm_windows_function_app.key[0]
    ) : (
    var.storage_uses_managed_identity ? azurerm_linux_function_app.managed_identity[0] : azurerm_linux_function_app.key[0]
  )

  merged_tags = merge(
    {
      module = "functionapp"
      name   = var.name
    },
    var.tags
  )

  app_admin_group_values     = compact(coalesce(var.app_admin_group, []))
  app_admin_group_object_ids = toset([for value in local.app_admin_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_admin_group_names      = toset([for value in local.app_admin_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_user_group_values      = compact(coalesce(var.app_user_group, []))
  app_user_group_object_ids  = toset([for value in local.app_user_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_user_group_names       = toset([for value in local.app_user_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])
}
