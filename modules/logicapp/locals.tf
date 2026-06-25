locals {
  environment_tag_map = {
    prod    = "Production"
    dev     = "Development"
    qa      = "QA"
    test    = "Test"
    sbx     = "Sandbox"
    poc     = "POC"
    staging = "Staging"
  }

  resource_group_lookup_required      = try(trimspace(var.location), "") == "" || (var.inherit_resource_group_tags && var.inherited_resource_group_tags == null)
  location                            = try(trimspace(var.location), "") != "" ? var.location : data.azurerm_resource_group.rg[0].location
  storage_account_resource_group_name = try(trimspace(var.storage_account_resource_group_name), "") != "" ? var.storage_account_resource_group_name : var.resource_group_name

  identity_ids = distinct(compact([for identity_id in var.identity_ids : trimspace(identity_id)]))
  identity_type = join(", ", compact([
    var.system_assigned_identity_enabled ? "SystemAssigned" : "",
    length(local.identity_ids) > 0 ? "UserAssigned" : ""
  ]))

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
  private_dns_zone_id_resolved = try(trimspace(var.private_dns_zone_id), "") != "" ? var.private_dns_zone_id : try(data.azurerm_private_dns_zone.logicapp[0].id, "")

  public_network_access = var.public_network_access_enabled ? "Enabled" : "Disabled"

  merged_tags = merge(
    var.inherit_resource_group_tags ? coalesce(var.inherited_resource_group_tags, try(data.azurerm_resource_group.rg[0].tags, {})) : {},
    var.tags
  )

  app_admin_group_values     = distinct(compact([for value in coalesce(var.app_admin_group, []) : trimspace(value)]))
  app_admin_group_object_ids = toset([for value in local.app_admin_group_values : value if can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value))])
  app_admin_group_names      = toset([for value in local.app_admin_group_values : value if !can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value))])
  app_user_group_values      = distinct(compact([for value in coalesce(var.app_user_group, []) : trimspace(value)]))
  app_user_group_object_ids  = toset([for value in local.app_user_group_values : value if can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value))])
  app_user_group_names       = toset([for value in local.app_user_group_values : value if !can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value))])
}
