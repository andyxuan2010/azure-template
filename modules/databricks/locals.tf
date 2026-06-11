locals {
  environment_tag_map = {
    prod = "PROD"
    dev  = "DEV"
    qa   = "QA"
    test = "TEST"
    sbx  = "SBX"
    poc  = "POC"
  }

  resource_group_lookup_required = trimspace(var.location) == "" || var.inherit_resource_group_tags
  resource_group_name            = trimspace(var.resource_group_name)
  location                       = trimspace(var.location) != "" ? trimspace(var.location) : data.azurerm_resource_group.rg[0].location
  common_tags                    = var.inherit_resource_group_tags ? try(data.azurerm_resource_group.rg[0].tags, {}) : {}

  location_code_map = {
    australiaeast      = "aue"
    brazilsouth        = "brs"
    canadacentral      = "cac"
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
  application_code_raw   = trimspace(var.workload_name) != "" ? var.workload_name : try(local.common_tags.application_id, "app")
  application_code       = lower(join("", regexall("[a-z0-9-]", local.application_code_raw)))
  name_prefix_normalized = lower(join("", regexall("[a-z0-9-]", var.name_prefix)))
  location_code_resolved = trimspace(var.location_code) != "" ? trimspace(var.location_code) : lookup(local.location_code_map, lower(local.location), lower(join("", regexall("[a-z0-9]", replace(local.location, " ", "")))))
  generated_suffix       = var.use_random_suffix ? try(random_string.random[0].result, "000000") : lower(join("", regexall("[a-z0-9-]", var.instance)))
  generated_name_parts   = compact([local.name_prefix_normalized, local.application_code, var.include_environment_in_name ? var.app_env : "", local.location_code_resolved, local.generated_suffix])
  generated_name_raw     = trim(join("-", local.generated_name_parts), "-")
  workspace_name         = trimspace(var.name) != "" ? trimspace(var.name) : substr(local.generated_name_raw != "" ? local.generated_name_raw : "dbw-app-dev-001", 0, 64)

  access_connector_name                  = trimspace(var.access_connector_name) != "" ? trimspace(var.access_connector_name) : "dac-${local.workspace_name}"
  access_connector_identity_ids          = distinct(compact([for identity_id in var.access_connector_identity_ids : trimspace(identity_id)]))
  access_connector_identity_type         = join(", ", compact([var.access_connector_system_assigned_identity_enabled ? "SystemAssigned" : "", length(local.access_connector_identity_ids) > 0 ? "UserAssigned" : ""]))
  access_connector_id_effective          = var.create_access_connector ? azurerm_databricks_access_connector.this[0].id : trimspace(var.access_connector_id)
  default_storage_firewall_enabled_value = (var.default_storage_firewall_enabled || var.create_access_connector) && local.access_connector_id_effective != "" ? var.default_storage_firewall_enabled : null

  private_dns_zone_ids = distinct(compact(concat(
    [for zone_id in var.private_dns_zone_ids : trimspace(zone_id)],
    [for _, zone in data.azurerm_private_dns_zone.this : zone.id]
  )))

  private_dns_zone_names_effective = {
    for name in var.private_dns_zone_names :
    name => name
    if trimspace(name) != ""
  }

  private_endpoint_subnet_id_resolved = trimspace(var.private_endpoint_subnet_id) != "" ? trimspace(var.private_endpoint_subnet_id) : try(data.azurerm_subnet.private_endpoint[0].id, null)
  private_endpoint_subresources       = toset([for name in var.private_endpoint_subresource_names : name])
  create_private_endpoints = length(local.private_endpoint_subresources) > 0 && (
    trimspace(var.private_endpoint_subnet_id) != "" ||
    (
      trimspace(var.private_endpoint_subnet_name) != "" &&
      trimspace(var.private_endpoint_vnet_name) != "" &&
      trimspace(var.private_endpoint_network_resource_group_name) != ""
    )
  )

  merged_tags = merge(
    local.common_tags,
    var.tags,
    {
      Environment = lookup(local.environment_tag_map, lower(trimspace(var.app_env)), upper(trimspace(var.app_env)))
      Workload    = trimspace(var.workload)
    }
  )

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

  custom_storage_account_name = try(trimspace(var.custom_parameters.storage_account_name), "")
  custom_storage_account_id   = local.custom_storage_account_name != "" ? "${azurerm_databricks_workspace.this.managed_resource_group_id}/providers/Microsoft.Storage/storageAccounts/${local.custom_storage_account_name}" : null

  diagnostic_destination_enabled = (
    trimspace(var.log_analytics_workspace_id) != "" ||
    try(trimspace(var.diagnostic_storage_account_id), "") != "" ||
    try(trimspace(var.diagnostic_eventhub_authorization_rule_id), "") != ""
  )
  diagnostics_enabled     = (var.enable_diagnostics || local.diagnostic_destination_enabled) && local.diagnostic_destination_enabled
  diagnostic_setting_name = trimspace(var.diagnostic_setting_name) != "" ? trimspace(var.diagnostic_setting_name) : "${local.workspace_name}-diagnostic-setting"

  diagnostic_log_categories_effective = toset([
    for category in var.diagnostic_log_categories :
    category
    if !contains(["AllLogs", "allLogs"], category)
  ])
  diagnostic_log_category_groups_effective = toset(distinct(concat(
    var.diagnostic_log_category_groups,
    [for category in var.diagnostic_log_categories : "allLogs" if contains(["AllLogs", "allLogs"], category)]
  )))

  enable_custom_parameters = var.custom_parameters != null
  enable_enhanced_security = var.enhanced_security_compliance != null
}
