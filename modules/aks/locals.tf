locals {
  location = var.location != "" ? var.location : data.azurerm_resource_group.rg.location

  common_tags   = data.azurerm_resource_group.rg.tags
  explicit_tags = var.tags
  tags = merge(
    local.common_tags,
    local.explicit_tags,
    {
      module  = "aks"
      app_env = var.app_env
    }
  )
  # Azure copies AKS tags to the managed private DNS zone when using "System".
  # In that mode, do not merge RG tags or add synthetic tags; use only the caller-supplied tags.
  effective_tags = var.private_cluster_enabled && local.private_dns_zone_id_resolved == "System" ? var.tags : local.tags

  application_code_raw = try(data.azurerm_resource_group.rg.tags.application_id, "app")
  application_code     = lower(join("", regexall("[a-z0-9]", local.application_code_raw)))
  location_code        = lower(join("", regexall("[a-z0-9]", replace(local.location, " ", ""))))
  naming_seed          = substr("${local.application_code}${var.app_env}${local.location_code}", 0, 48)
  generated_name       = substr("aks-${local.naming_seed != "" ? local.naming_seed : "app"}-${try(random_string.name[0].result, "0000")}", 0, 63)
  aks_name             = var.name != "" ? var.name : local.generated_name

  generated_dns_prefix = substr(lower(join("", regexall("[a-z0-9-]", local.aks_name))), 0, 54)
  dns_prefix           = var.dns_prefix != "" ? var.dns_prefix : local.generated_dns_prefix

  private_dns_zone_lookup_required = var.private_cluster_enabled && var.private_dns_zone_id == "" && var.private_dns_zone_name != "" && var.private_dns_zone_resource_group_name != ""
  private_dns_zone_id_resolved = !var.private_cluster_enabled ? null : (
    var.private_dns_zone_id != "" ? var.private_dns_zone_id : (
      local.private_dns_zone_lookup_required ? data.azurerm_private_dns_zone.this[0].id : "System"
    )
  )

  app_admin_group_values     = compact(coalesce(var.app_admin_group, []))
  app_admin_group_object_ids = toset([for value in local.app_admin_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_admin_group_names      = toset([for value in local.app_admin_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])
  admin_group_object_ids     = sort(concat(tolist(local.app_admin_group_object_ids), [for _, group in data.azuread_group.app_admin : group.object_id]))
  app_user_group_values      = compact(coalesce(var.app_user_group, []))
  app_user_group_object_ids  = toset([for value in local.app_user_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_user_group_names       = toset([for value in local.app_user_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])
}
