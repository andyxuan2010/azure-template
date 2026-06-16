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

  resource_group_lookup_required = trimspace(var.location) == "" || (var.inherit_resource_group_tags && var.inherited_resource_group_tags == null)
  resource_group_name            = trimspace(var.resource_group_name)
  location                       = trimspace(var.location) != "" ? trimspace(var.location) : data.azurerm_resource_group.rg[0].location
  common_tags                    = var.inherit_resource_group_tags ? coalesce(var.inherited_resource_group_tags, try(data.azurerm_resource_group.rg[0].tags, {})) : {}

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
  firewall_name          = trimspace(var.name) != "" ? trimspace(var.name) : substr(local.generated_name_raw != "" ? local.generated_name_raw : "afw-app-dev-eus-001", 0, 80)

  firewall_policy_name = trimspace(var.firewall_policy_name) != "" ? trimspace(var.firewall_policy_name) : "${local.firewall_name}-policy"
  firewall_policy_sku  = trimspace(var.firewall_policy_sku) != "" ? trimspace(var.firewall_policy_sku) : var.sku_tier

  create_vnet_public_ips = var.sku_name == "AZFW_VNet" && var.create_public_ip
  public_ip_names = local.create_vnet_public_ips ? [
    for index in range(var.public_ip_count) :
    index == 0 && trimspace(var.public_ip_name) != "" ? trimspace(var.public_ip_name) : (
      var.public_ip_count == 1 ? "${local.firewall_name}-pip" : "${local.firewall_name}-pip-${format("%02d", index + 1)}"
    )
  ] : []

  public_ip_map = {
    for index, name in local.public_ip_names :
    tostring(index) => name
  }

  created_public_ip_ids = [
    for key in sort(keys(azurerm_public_ip.this)) :
    azurerm_public_ip.this[key].id
  ]

  firewall_public_ip_ids = distinct(compact(concat(local.created_public_ip_ids, [
    for public_ip_id in var.public_ip_ids :
    trimspace(public_ip_id)
  ])))

  firewall_ip_configurations = {
    for index, public_ip_id in local.firewall_public_ip_ids :
    tostring(index) => {
      name                 = index == 0 ? var.ip_configuration_name : "${var.ip_configuration_name}-${format("%02d", index + 1)}"
      public_ip_address_id = public_ip_id
      subnet_id            = index == 0 ? trimspace(var.subnet_id) : null
    }
  }

  create_management_public_ip     = var.sku_name == "AZFW_VNet" && trimspace(var.management_subnet_id) != "" && trimspace(var.management_public_ip_id) == ""
  management_public_ip_name       = trimspace(var.management_public_ip_name) != "" ? trimspace(var.management_public_ip_name) : "${local.firewall_name}-mgmt-pip"
  management_public_ip_id         = local.create_management_public_ip ? azurerm_public_ip.management[0].id : trimspace(var.management_public_ip_id)
  management_ip_configuration_set = var.sku_name == "AZFW_VNet" && trimspace(var.management_subnet_id) != ""

  firewall_policy_id       = var.create_firewall_policy ? azurerm_firewall_policy.this[0].id : trimspace(var.firewall_policy_id)
  firewall_policy_attached = var.create_firewall_policy || trimspace(var.firewall_policy_id) != ""

  legacy_rule_collection_group_enabled = (
    length(var.application_rule_collections) +
    length(var.network_rule_collections) +
    length(var.nat_rule_collections)
  ) > 0

  legacy_rule_collection_group = local.legacy_rule_collection_group_enabled ? {
    legacy = {
      name                         = "${local.firewall_name}-rcg"
      priority                     = var.rule_collection_group_priority
      application_rule_collections = var.application_rule_collections
      network_rule_collections     = var.network_rule_collections
      nat_rule_collections         = var.nat_rule_collections
      timeouts                     = null
    }
  } : {}

  rule_collection_groups = merge(local.legacy_rule_collection_group, var.rule_collection_groups)

  merged_tags = merge(
    local.common_tags,
    var.tags
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

  diagnostic_destination_enabled = (
    trimspace(var.log_analytics_workspace_id) != "" ||
    try(trimspace(var.diagnostic_storage_account_id), "") != "" ||
    try(trimspace(var.diagnostic_eventhub_authorization_rule_id), "") != ""
  )
  diagnostics_enabled     = (var.enable_diagnostics || local.diagnostic_destination_enabled) && local.diagnostic_destination_enabled
  diagnostic_setting_name = trimspace(var.diagnostic_setting_name) != "" ? trimspace(var.diagnostic_setting_name) : "${local.firewall_name}-diagnostic-setting"

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
