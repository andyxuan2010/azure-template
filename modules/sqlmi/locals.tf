locals {
  location_resolved            = trimspace(var.location) != "" ? var.location : data.azurerm_resource_group.this.location
  dns_zone_partner_id_resolved = try(trimspace(var.dns_zone_partner_id), "") != "" ? var.dns_zone_partner_id : null

  merged_tags = merge(
    var.inherit_resource_group_tags ? coalesce(var.inherited_resource_group_tags, data.azurerm_resource_group.this.tags) : {},
    var.tags
  )

  app_admin_group_values     = compact(coalesce(var.app_admin_group, []))
  entra_object_id_pattern    = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
  app_admin_group_object_ids = toset([for value in local.app_admin_group_values : value if can(regex(local.entra_object_id_pattern, value))])
  app_admin_group_names      = toset([for value in local.app_admin_group_values : value if !can(regex(local.entra_object_id_pattern, value))])
  app_user_group_values      = compact(coalesce(var.app_user_group, []))
  app_user_group_object_ids  = toset([for value in local.app_user_group_values : value if can(regex(local.entra_object_id_pattern, value))])
  app_user_group_names       = toset([for value in local.app_user_group_values : value if !can(regex(local.entra_object_id_pattern, value))])
}
