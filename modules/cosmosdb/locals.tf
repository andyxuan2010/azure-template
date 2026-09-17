locals {
  resource_group_lookup_required = trimspace(var.location) == "" || (var.inherit_resource_group_tags && var.inherited_resource_group_tags == null)
  resource_group_name            = trimspace(var.resource_group_name)
  location                       = trimspace(var.location) != "" ? trimspace(var.location) : data.azurerm_resource_group.rg[0].location
  common_tags                    = var.inherit_resource_group_tags ? coalesce(var.inherited_resource_group_tags, try(data.azurerm_resource_group.rg[0].tags, {})) : {}

  location_code_map = {
    australiaeast      = "aue"
    brazilsouth        = "brs"
    canadacentral      = "cc"
    canadaeast         = "cae"
    centralindia       = "cin"
    centralus          = "cus"
    eastasia           = "ea"
    eastus             = "eus"
    eastus2            = "eus2"
    francecentral      = "frc"
    germanywestcentral = "gwc"
    japaneast          = "jpe"
    koreacentral       = "krc"
    northeurope        = "neu"
    southcentralus     = "scus"
    southeastasia      = "sea"
    uksouth            = "uks"
    ukwest             = "ukw"
    westcentralus      = "wcus"
    westeurope         = "weu"
    westus             = "wus"
    westus2            = "wus2"
    westus3            = "wus3"
  }
  workload_name_raw      = trimspace(var.workload_name) != "" ? trimspace(var.workload_name) : try(local.common_tags.application_id, "app")
  workload_name          = lower(join("", regexall("[a-z0-9-]", local.workload_name_raw)))
  account_prefix         = lower(join("", regexall("[a-z0-9-]", var.name_prefix)))
  location_code_resolved = trimspace(var.location_code) != "" ? trimspace(var.location_code) : lookup(local.location_code_map, lower(local.location), lower(join("", regexall("[a-z0-9]", replace(local.location, " ", "")))))
  generated_suffix       = var.use_random_suffix ? try(random_string.suffix[0].result, "000001") : lower(join("", regexall("[a-z0-9-]", var.instance)))

  generated_account_name_parts = compact([local.account_prefix, local.workload_name, var.include_environment_in_name ? var.app_env : "", local.location_code_resolved, local.generated_suffix])
  generated_account_name_raw   = trim(join("-", local.generated_account_name_parts), "-")
  account_name                 = trimspace(var.name) != "" ? lower(trimspace(var.name)) : trim(substr(local.generated_account_name_raw != "" ? local.generated_account_name_raw : "cosmos-app-dev-eus-001", 0, 44), "-")

  identity_ids     = distinct(compact([for identity_id in var.identity_ids : trimspace(identity_id)]))
  identity_type    = join(", ", compact([var.system_assigned_identity_enabled ? "SystemAssigned" : "", length(local.identity_ids) > 0 ? "UserAssigned" : ""]))
  identity_enabled = local.identity_type != ""

  geo_locations_effective = length(var.geo_locations) > 0 ? var.geo_locations : [
    {
      location          = local.location
      failover_priority = 0
      zone_redundant    = var.zone_redundant
    }
  ]

  private_endpoint_subnet_lookup_by_name = (
    var.enable_private_endpoint &&
    trimspace(var.private_endpoint_subnet_id) == "" &&
    trimspace(var.private_endpoint_subnet_name) != "" &&
    trimspace(var.private_endpoint_vnet_name) != "" &&
    trimspace(var.private_endpoint_network_resource_group_name) != ""
  )
  private_endpoint_subnet_id_resolved = trimspace(var.private_endpoint_subnet_id) != "" ? trimspace(var.private_endpoint_subnet_id) : try(data.azurerm_subnet.private_endpoint[0].id, null)

  private_dns_zone_names_effective = toset(distinct(compact(concat(
    trimspace(var.private_dns_zone_name) != "" ? [trimspace(var.private_dns_zone_name)] : [],
    [for name in var.private_dns_zone_names : trimspace(name)]
  ))))
  private_dns_zone_ids = distinct(compact(concat(
    trimspace(var.private_dns_zone_id) != "" ? [trimspace(var.private_dns_zone_id)] : [],
    [for zone_id in var.private_dns_zone_ids : trimspace(zone_id)],
    [for _, zone in data.azurerm_private_dns_zone.cosmosdb : zone.id]
  )))
  private_endpoint_name                   = trimspace(var.private_endpoint_name) != "" ? trimspace(var.private_endpoint_name) : "pep-${local.account_name}"
  private_service_connection_name         = trimspace(var.private_service_connection_name) != "" ? trimspace(var.private_service_connection_name) : "psc-${local.account_name}"
  private_endpoint_network_interface_name = trimspace(var.private_endpoint_network_interface_name) != "" ? trimspace(var.private_endpoint_network_interface_name) : null
  private_endpoint_manual_request_message = trimspace(var.private_endpoint_manual_request_message) != "" ? trimspace(var.private_endpoint_manual_request_message) : null
  private_dns_zone_group_name             = trimspace(var.private_dns_zone_group_name) != "" ? trimspace(var.private_dns_zone_group_name) : "default"

  app_admin_group_values     = distinct(compact([for value in coalesce(var.app_admin_group, []) : trimspace(value)]))
  app_user_group_values      = distinct(compact([for value in coalesce(var.app_user_group, []) : trimspace(value)]))
  entra_object_id_pattern    = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
  app_admin_group_object_ids = toset([for value in local.app_admin_group_values : value if can(regex(local.entra_object_id_pattern, value))])
  app_admin_group_names      = toset([for value in local.app_admin_group_values : value if !can(regex(local.entra_object_id_pattern, value))])
  app_user_group_object_ids  = toset([for value in local.app_user_group_values : value if can(regex(local.entra_object_id_pattern, value))])
  app_user_group_names       = toset([for value in local.app_user_group_values : value if !can(regex(local.entra_object_id_pattern, value))])

  app_admin_group_principal_ids = merge(
    { for object_id in local.app_admin_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_admin : "name:${name}" => group.object_id }
  )
  app_user_group_principal_ids = merge(
    { for object_id in local.app_user_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_user : "name:${name}" => group.object_id }
  )

  diagnostic_destination_enabled = (
    trimspace(var.log_analytics_workspace_id) != "" ||
    trimspace(var.diagnostic_storage_account_id) != "" ||
    trimspace(var.diagnostic_eventhub_authorization_rule_id) != ""
  )
  diagnostics_enabled     = (var.enable_diagnostics || local.diagnostic_destination_enabled) && local.diagnostic_destination_enabled
  diagnostic_setting_name = trimspace(var.diagnostic_setting_name) != "" ? trimspace(var.diagnostic_setting_name) : "diag-${local.account_name}"

  diagnostic_log_categories_effective = toset([
    for category in var.diagnostic_log_categories :
    category
    if !contains(["AllLogs", "allLogs"], category)
  ])
  diagnostic_log_category_groups_effective = toset(distinct(concat(
    var.diagnostic_log_category_groups,
    [for category in var.diagnostic_log_categories : "allLogs" if contains(["AllLogs", "allLogs"], category)]
  )))

  merged_tags = merge(
    local.common_tags,
    var.tags
  )
}
