locals {
  location    = var.location != "" ? var.location : data.azurerm_resource_group.rg.location
  tenant_id   = var.tenant_id != "" ? var.tenant_id : data.azurerm_client_config.current.tenant_id
  common_tags = data.azurerm_resource_group.rg.tags

  tags = merge(
    local.common_tags,
    var.tags,
    {
      module  = "keyvault"
      app_env = var.app_env
    }
  )

  application_code_raw = try(data.azurerm_resource_group.rg.tags.application_id, "app")
  application_code     = lower(join("", regexall("[a-z0-9]", local.application_code_raw)))
  location_code        = lower(join("", regexall("[a-z0-9]", replace(local.location, " ", ""))))
  naming_seed          = substr("${local.application_code}${var.app_env}${local.location_code}", 0, 18)
  generated_name       = substr("kv${local.naming_seed != "" ? local.naming_seed : "app"}${try(random_string.random[0].result, "0000")}", 0, 24)
  key_vault_name       = var.name != "" ? var.name : local.generated_name

  create_private_endpoint = var.enable_private_endpoint && (
    var.private_endpoint_subnet_id != "" ||
    (
      var.private_endpoint_subnet_name != null &&
      var.private_endpoint_vnet_name != null &&
      var.private_endpoint_network_resource_group_name != null
    )
  )
  private_endpoint_subnet_id_resolved = var.private_endpoint_subnet_id != "" ? var.private_endpoint_subnet_id : try(data.azurerm_subnet.pep[0].id, "")
  private_dns_zone_id_resolved        = trimspace(var.private_dns_zone_id) != "" ? trimspace(var.private_dns_zone_id) : try(data.azurerm_private_dns_zone.this[0].id, "")

  app_admin_group_values     = compact(coalesce(var.app_admin_group, []))
  app_user_group_values      = compact(coalesce(var.app_user_group, []))
  app_admin_group_object_ids = toset([for value in local.app_admin_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_admin_group_names      = toset([for value in local.app_admin_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_user_group_object_ids  = toset([for value in local.app_user_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_user_group_names       = toset([for value in local.app_user_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])
}
