locals {
  location       = trimspace(var.location) != "" ? var.location : data.azurerm_resource_group.rg.location
  common_tags    = var.inherit_resource_group_tags ? coalesce(var.inherited_resource_group_tags, data.azurerm_resource_group.rg.tags) : {}
  namespace_name = trimspace(var.name) != "" ? var.name : "sb${random_string.random[0].result}"

  merged_tags = merge(
    local.common_tags,
    var.tags
  )

  app_admin_group_values     = compact(coalesce(var.app_admin_group, []))
  app_user_group_values      = compact(coalesce(var.app_user_group, []))
  entra_object_id_pattern    = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
  app_admin_group_object_ids = toset([for value in local.app_admin_group_values : value if can(regex(local.entra_object_id_pattern, value))])
  app_admin_group_names      = toset([for value in local.app_admin_group_values : value if !can(regex(local.entra_object_id_pattern, value))])
  app_user_group_object_ids  = toset([for value in local.app_user_group_values : value if can(regex(local.entra_object_id_pattern, value))])
  app_user_group_names       = toset([for value in local.app_user_group_values : value if !can(regex(local.entra_object_id_pattern, value))])

  private_endpoint_subnet_id_resolved = var.private_endpoint_subnet_id != "" ? var.private_endpoint_subnet_id : try(data.azurerm_subnet.private_endpoint[0].id, null)
}
