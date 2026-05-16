locals {
  location    = trimspace(var.location) != "" ? trimspace(var.location) : data.azurerm_resource_group.rg.location
  common_tags = data.azurerm_resource_group.rg.tags

  service_name = trimspace(var.name) != "" ? trimspace(var.name) : "srch${random_string.random[0].result}"
  private_dns_zone_ids = distinct(compact(concat(
    trimspace(var.private_dns_zone_id) != "" ? [trimspace(var.private_dns_zone_id)] : [],
    [for zone_id in var.private_dns_zone_ids : trimspace(zone_id)]
  )))

  merged_tags = merge(
    local.common_tags,
    var.tags,
    {
      module = "azure_ai_search"
    }
  )

  app_admin_group_values     = distinct(compact([for value in coalesce(var.app_admin_group, []) : trimspace(value)]))
  app_user_group_values      = distinct(compact([for value in coalesce(var.app_user_group, []) : trimspace(value)]))
  app_admin_group_object_ids = toset([for value in local.app_admin_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_admin_group_names      = toset([for value in local.app_admin_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_user_group_object_ids  = toset([for value in local.app_user_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_user_group_names       = toset([for value in local.app_user_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])

  private_endpoint_subnet_id_resolved = trimspace(var.private_endpoint_subnet_id) != "" ? trimspace(var.private_endpoint_subnet_id) : try(data.azurerm_subnet.private_endpoint[0].id, null)
  endpoint                            = "https://${local.service_name}.search.windows.net"
}
