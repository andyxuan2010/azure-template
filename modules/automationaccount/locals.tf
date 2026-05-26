locals {
  environment_tag_map = {
    prod    = "Production"
    dev     = "Development"
    qa      = "QA"
    test    = "Test"
    sbx     = "Sandbox"
    poc     = "POC"
    staging = "Staging"
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
  generated_suffix       = var.use_random_suffix ? try(random_string.random[0].result, "0000") : lower(join("", regexall("[a-z0-9-]", var.instance)))
  generated_name_parts   = compact([local.name_prefix_normalized, local.application_code, var.include_environment_in_name ? var.app_env : "", local.location_code_resolved, local.generated_suffix])
  generated_name_raw     = join("-", local.generated_name_parts)
  generated_name         = substr(local.generated_name_raw != "" ? local.generated_name_raw : "aa-app-dev-001", 0, 50)
  automation_account_name = trimspace(var.name) != "" ? trimspace(var.name) : trim(
    local.generated_name,
    "-"
  )

  identity_ids  = distinct(compact([for identity_id in var.identity_ids : trimspace(identity_id)]))
  identity_type = join(", ", compact([var.system_managed_identity_enabled ? "SystemAssigned" : "", length(local.identity_ids) > 0 ? "UserAssigned" : ""]))

  tags = merge(
    local.common_tags,
    var.tags,
    {
      Environment = lookup(local.environment_tag_map, var.app_env, var.app_env)
      workload    = var.workload
    }
  )

  private_endpoint_vnet_name_resolved                   = var.private_endpoint_vnet_name != null ? var.private_endpoint_vnet_name : (var.pep_vnet_name != "" ? var.pep_vnet_name : null)
  private_endpoint_network_resource_group_name_resolved = var.private_endpoint_network_resource_group_name != null ? var.private_endpoint_network_resource_group_name : (var.pep_vnet_resource_group_name != "" ? var.pep_vnet_resource_group_name : null)
  private_endpoint_subnet_name_resolved = var.private_endpoint_subnet_name != null ? var.private_endpoint_subnet_name : (
    local.private_endpoint_vnet_name_resolved != null ? (contains(var.private_endpoint_vnet_exceptions, local.private_endpoint_vnet_name_resolved) ? "PrivateEndpoint2" : "PrivateEndpoint") : null
  )
  private_endpoint_subnet_id_resolved = trimspace(var.private_endpoint_subnet_id) != "" ? trimspace(var.private_endpoint_subnet_id) : try(data.azurerm_subnet.pep[0].id, "")
  private_endpoint_subresources = (
    var.enable_webhook_private_endpoint == null && var.enable_hrw_private_endpoint == null ? {
      legacy = var.private_endpoint_subresource_name == "DscAndHybridWorker" ? "DSCAndHybridWorker" : var.private_endpoint_subresource_name
      } : merge(
      var.enable_webhook_private_endpoint ? { webhook = "Webhook" } : {},
      var.enable_hrw_private_endpoint ? { hrw = "DSCAndHybridWorker" } : {}
    )
  )
  create_private_endpoint = length(local.private_endpoint_subresources) > 0 && (
    trimspace(var.private_endpoint_subnet_id) != "" ||
    (
      local.private_endpoint_subnet_name_resolved != null &&
      local.private_endpoint_vnet_name_resolved != null &&
      local.private_endpoint_network_resource_group_name_resolved != null
    )
  )

  private_dns_zone_id_resolved = trimspace(var.private_dns_zone_id) != "" ? var.private_dns_zone_id : try(data.azurerm_private_dns_zone.pep[0].id, "")

  managed_identity_role_assignments_effective = var.system_managed_identity_enabled ? var.managed_identity_role_assignments : {}

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
    try(trimspace(var.diagnostic_storage_account_id), "") != "" ||
    try(trimspace(var.diagnostic_eventhub_authorization_rule_id), "") != ""
  )
  diagnostics_enabled     = (var.enable_diagnostics || local.diagnostic_destination_enabled) && local.diagnostic_destination_enabled
  diagnostic_setting_name = trimspace(var.diagnostic_setting_name) != "" ? trimspace(var.diagnostic_setting_name) : "${local.automation_account_name}-diagnostic-setting"
  diagnostic_log_categories_effective = toset([
    for category in var.diagnostic_log_categories :
    category
    if !contains(["AllLogs", "allLogs"], category)
  ])
  diagnostic_log_category_groups_effective = toset(distinct(concat(
    var.diagnostic_log_category_groups,
    [for category in var.diagnostic_log_categories : "allLogs" if contains(["AllLogs", "allLogs"], category)]
  )))
}
