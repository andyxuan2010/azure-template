locals {
  workload_code = lower(join("", regexall("[a-z0-9-]", trimspace(var.workload))))
  naming_suffix = "${local.workload_code}-${var.app_env}-${trimspace(var.instance)}"

  profile_name      = trimspace(var.name) != "" ? trimspace(var.name) : trim(substr("afd-${local.naming_suffix}", 0, 90), "-")
  endpoint_name     = trimspace(var.endpoint_name) != "" ? trimspace(var.endpoint_name) : trim(substr("afd-${local.naming_suffix}", 0, 50), "-")
  origin_group_name = trimspace(var.origin_group_name) != "" ? trimspace(var.origin_group_name) : trim(substr("og-${local.naming_suffix}", 0, 90), "-")
  origin_name       = trimspace(var.origin_name) != "" ? trimspace(var.origin_name) : trim(substr("origin-${local.naming_suffix}", 0, 90), "-")
  route_name        = trimspace(var.route_name) != "" ? trimspace(var.route_name) : trim(substr("route-${local.naming_suffix}", 0, 90), "-")

  tags = merge(
    var.inherit_resource_group_tags ? coalesce(var.inherited_resource_group_tags, try(data.azurerm_resource_group.rg[0].tags, {})) : {},
    var.tags
  )
}
