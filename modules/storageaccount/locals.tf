locals {
  location    = trimspace(var.location) != "" ? trimspace(var.location) : data.azurerm_resource_group.rg.location
  common_tags = data.azurerm_resource_group.rg.tags

  tags = merge(
    local.common_tags,
    var.tags,
    {
      module = "storageaccount"
    }
  )

  application_code_raw = try(data.azurerm_resource_group.rg.tags.application_id, "app")
  application_code     = lower(join("", regexall("[a-z0-9]", local.application_code_raw)))
  location_code        = lower(join("", regexall("[a-z0-9]", replace(local.location, " ", ""))))
  naming_seed          = substr("${local.application_code}${local.location_code}", 0, 18)
  generated_name       = substr("st${local.naming_seed != "" ? local.naming_seed : "app"}${try(random_string.random[0].result, "0000")}", 0, 24)
  storage_account_name = trimspace(var.name) != "" ? trimspace(var.name) : local.generated_name

  access_tier_effective = var.account_tier == "Standard" && contains(["StorageV2", "BlobStorage"], var.account_kind) ? var.access_tier : null

  private_endpoint_subnet_id_resolved = trimspace(var.private_endpoint_subnet_id) != "" ? trimspace(var.private_endpoint_subnet_id) : try(data.azurerm_subnet.pep[0].id, "")
  private_endpoint_subresources       = toset([for name in var.private_endpoint_subresource_names : lower(name)])
  private_dns_zone_names_effective = {
    for key, value in var.private_dns_zone_names :
    lower(key) => trimspace(value)
    if trimspace(value) != "" && trimspace(lookup(var.private_dns_zone_ids, lower(key), "")) == ""
  }
  private_dns_zone_ids_resolved = merge(
    { for key, value in var.private_dns_zone_ids : lower(key) => trimspace(value) },
    { for key, zone in data.azurerm_private_dns_zone.this : key => zone.id }
  )
  create_private_endpoints = length(local.private_endpoint_subresources) > 0 && (
    trimspace(var.private_endpoint_subnet_id) != "" ||
    (
      try(trimspace(var.private_endpoint_subnet_name), "") != "" &&
      try(trimspace(var.private_endpoint_vnet_name), "") != "" &&
      try(trimspace(var.private_endpoint_network_resource_group_name), "") != ""
    )
  )

  managed_identity_role_assignments_effective = var.system_managed_identity_enabled ? var.managed_identity_role_assignments : {}

  app_admin_group_values     = distinct(compact([for value in coalesce(var.app_admin_group, []) : trimspace(value)]))
  app_user_group_values      = distinct(compact([for value in coalesce(var.app_user_group, []) : trimspace(value)]))
  app_admin_group_object_ids = toset([for value in local.app_admin_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_admin_group_names      = toset([for value in local.app_admin_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_user_group_object_ids  = toset([for value in local.app_user_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_user_group_names       = toset([for value in local.app_user_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])
}
