locals {
  location    = trimspace(var.location) != "" ? trimspace(var.location) : data.azurerm_resource_group.rg.location
  tenant_id   = trimspace(var.tenant_id) != "" ? trimspace(var.tenant_id) : data.azurerm_client_config.current.tenant_id
  common_tags = data.azurerm_resource_group.rg.tags

  tags = merge(
    local.common_tags,
    var.tags,
  )

  application_code_raw = try(data.azurerm_resource_group.rg.tags.application_id, "app")
  application_code     = lower(join("", regexall("[a-z0-9]", local.application_code_raw)))
  location_code        = lower(join("", regexall("[a-z0-9]", replace(local.location, " ", ""))))
  naming_seed          = substr("${local.application_code}${var.app_env}${local.location_code}", 0, 18)
  generated_name       = substr("kv${local.naming_seed != "" ? local.naming_seed : "app"}${try(random_string.random[0].result, "0000")}", 0, 24)
  key_vault_name       = trimspace(var.name) != "" ? trimspace(var.name) : local.generated_name

  create_private_endpoint = var.enable_private_endpoint && (
    trimspace(var.private_endpoint_subnet_id) != "" ||
    (
      try(trimspace(var.private_endpoint_subnet_name), "") != "" &&
      try(trimspace(var.private_endpoint_vnet_name), "") != "" &&
      try(trimspace(var.private_endpoint_network_resource_group_name), "") != ""
    )
  )
  private_endpoint_subnet_id_resolved = trimspace(var.private_endpoint_subnet_id) != "" ? trimspace(var.private_endpoint_subnet_id) : try(data.azurerm_subnet.pep[0].id, "")
  private_dns_zone_id_resolved        = trimspace(var.private_dns_zone_id) != "" ? trimspace(var.private_dns_zone_id) : try(data.azurerm_private_dns_zone.this[0].id, "")

  app_admin_group_values     = distinct(compact([for value in coalesce(var.app_admin_group, []) : trimspace(value)]))
  app_user_group_values      = distinct(compact([for value in coalesce(var.app_user_group, []) : trimspace(value)]))
  app_admin_group_object_ids = toset([for value in local.app_admin_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_admin_group_names      = toset([for value in local.app_admin_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_user_group_object_ids  = toset([for value in local.app_user_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_user_group_names       = toset([for value in local.app_user_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])

  current_terraform_service_principal_role_assignments = merge(
    var.grant_current_terraform_service_principal_key_vault_roles ? {
      contributor   = "Contributor"
      administrator = "Key Vault Administrator"
    } : {},
    !var.grant_current_terraform_service_principal_key_vault_roles && var.grant_current_caller_secrets_officer ? {
      secrets_officer = "Key Vault Secrets Officer"
    } : {}
  )
}
