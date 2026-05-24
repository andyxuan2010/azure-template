locals {
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

  environment_tags = {
    prod    = { Environment = "Production", CostCenter = "Operations" }
    staging = { Environment = "Staging", CostCenter = "Operations" }
    dev     = { Environment = "Development", CostCenter = "Development" }
    sbx     = { Environment = "Sandbox", CostCenter = "Development" }
    test    = { Environment = "Test", CostCenter = "QA" }
    qa      = { Environment = "QA", CostCenter = "QA" }
    poc     = { Environment = "POC", CostCenter = "Development" }
  }

  application_code_raw   = trimspace(var.workload_name) != "" ? trimspace(var.workload_name) : try(local.common_tags.application_id, "app")
  application_code       = lower(join("", regexall("[a-z0-9-]", local.application_code_raw)))
  name_prefix_normalized = lower(join("", regexall("[a-z0-9-]", var.name_prefix)))
  location_code_resolved = trimspace(var.location_code) != "" ? trimspace(var.location_code) : lookup(local.location_code_map, lower(local.location), lower(join("", regexall("[a-z0-9]", replace(local.location, " ", "")))))
  generated_suffix       = var.use_random_suffix ? try(random_string.suffix[0].result, "000001") : lower(join("", regexall("[a-z0-9-]", var.instance)))
  generated_name_parts   = compact([local.name_prefix_normalized, local.application_code, var.include_environment_in_name ? var.app_env : "", local.location_code_resolved, local.generated_suffix])
  generated_name_raw     = trim(join("-", local.generated_name_parts), "-")
  aks_name               = trimspace(var.name) != "" ? trimspace(var.name) : trim(substr(local.generated_name_raw != "" ? local.generated_name_raw : "aks-app-dev-eus-001", 0, 63), "-")

  generated_dns_prefix = trim(substr(lower(join("", regexall("[a-z0-9-]", local.aks_name))), 0, 54), "-")
  dns_prefix           = trimspace(var.dns_prefix) != "" ? trimspace(var.dns_prefix) : local.generated_dns_prefix

  private_dns_zone_lookup_required = var.private_cluster_enabled && trimspace(var.private_dns_zone_id) == "" && trimspace(var.private_dns_zone_name) != "" && trimspace(var.private_dns_zone_resource_group_name) != ""
  private_dns_zone_id_resolved = !var.private_cluster_enabled ? null : (
    trimspace(var.private_dns_zone_id) != "" ? trimspace(var.private_dns_zone_id) : (
      local.private_dns_zone_lookup_required ? data.azurerm_private_dns_zone.this[0].id : "System"
    )
  )

  identity_ids  = distinct(compact([for identity_id in var.identity_ids : trimspace(identity_id)]))
  identity_type = length(local.identity_ids) > 0 ? "UserAssigned" : "SystemAssigned"

  default_node_pool_auto_scaling_enabled = try(coalesce(var.default_node_pool.auto_scaling_enabled, var.default_node_pool.enable_auto_scaling), false)

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
  admin_group_object_ids = sort(distinct(concat(
    tolist(local.app_admin_group_object_ids),
    [for _, group in data.azuread_group.app_admin : group.object_id],
    [for object_id in var.admin_group_object_ids : trimspace(object_id)]
  )))

  diagnostic_destination_enabled = (
    trimspace(var.log_analytics_workspace_id) != "" ||
    trimspace(var.diagnostic_storage_account_id) != "" ||
    trimspace(var.diagnostic_eventhub_authorization_rule_id) != ""
  )
  diagnostics_enabled     = (var.enable_diagnostics || local.diagnostic_destination_enabled) && local.diagnostic_destination_enabled
  diagnostic_setting_name = trimspace(var.diagnostic_setting_name) != "" ? trimspace(var.diagnostic_setting_name) : "${local.aks_name}-diagnostic-setting"

  diagnostic_log_categories_effective = toset([
    for category in var.diagnostic_log_categories :
    category
    if !contains(["AllLogs", "allLogs"], category)
  ])
  diagnostic_log_category_groups_effective = toset(distinct(concat(
    var.diagnostic_log_category_groups,
    [for category in var.diagnostic_log_categories : "allLogs" if contains(["AllLogs", "allLogs"], category)]
  )))

  oms_agent_enabled         = var.oms_agent_enabled || trimspace(var.oms_agent_log_analytics_workspace_id) != ""
  oms_agent_workspace_id    = trimspace(var.oms_agent_log_analytics_workspace_id) != "" ? trimspace(var.oms_agent_log_analytics_workspace_id) : trimspace(var.log_analytics_workspace_id)
  defender_enabled          = var.microsoft_defender_enabled || trimspace(var.microsoft_defender_log_analytics_workspace_id) != ""
  defender_workspace_id     = trimspace(var.microsoft_defender_log_analytics_workspace_id) != "" ? trimspace(var.microsoft_defender_log_analytics_workspace_id) : trimspace(var.log_analytics_workspace_id)
  monitor_metrics_enabled   = var.monitor_metrics_enabled || var.monitor_metrics != null
  monitor_metrics_effective = var.monitor_metrics == null ? {} : var.monitor_metrics

  effective_tags = merge(
    local.common_tags,
    lookup(local.environment_tags, var.app_env, {}),
    var.tags
  )
}
