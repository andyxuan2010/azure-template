locals {
  environment_tag_map = {
    prod = "PROD"
    dev  = "DEV"
    qa   = "QA"
    test = "TEST"
    sbx  = "SBX"
    poc  = "POC"
  }

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
  tags = merge(
    local.common_tags,
    var.tags
  )

  application_code_raw   = trimspace(var.workload_name) != "" ? var.workload_name : try(local.common_tags.application_id, "app")
  application_code       = lower(join("", regexall("[a-z0-9]", local.application_code_raw)))
  name_prefix_normalized = lower(join("", regexall("[a-z0-9]", var.name_prefix)))
  location_code_resolved = trimspace(var.location_code) != "" ? trimspace(var.location_code) : lookup(local.location_code_map, lower(local.location), lower(join("", regexall("[a-z0-9]", replace(local.location, " ", "")))))
  generated_suffix       = var.use_random_suffix ? try(random_string.random[0].result, "0000") : lower(join("", regexall("[a-z0-9]", var.instance)))
  generated_name_parts   = compact([local.name_prefix_normalized, local.application_code, var.include_environment_in_name ? var.app_env : "", local.location_code_resolved, local.generated_suffix])
  generated_name_compact = join("", local.generated_name_parts)
  generated_name         = substr(local.generated_name_compact != "" ? local.generated_name_compact : "stapp0000", 0, 24)
  storage_account_name   = trimspace(var.name) != "" ? trimspace(var.name) : local.generated_name

  access_tier_effective = var.account_tier == "Standard" && contains(["StorageV2", "BlobStorage"], var.account_kind) ? var.access_tier : null
  identity_ids          = distinct(compact(var.identity_ids))
  identity_type         = join(", ", compact([var.system_managed_identity_enabled ? "SystemAssigned" : "", length(local.identity_ids) > 0 ? "UserAssigned" : ""]))

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
  entra_object_id_pattern    = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
  app_admin_group_object_ids = toset([for value in local.app_admin_group_values : value if can(regex(local.entra_object_id_pattern, value))])
  app_admin_group_names      = toset([for value in local.app_admin_group_values : value if !can(regex(local.entra_object_id_pattern, value))])
  app_user_group_object_ids  = toset([for value in local.app_user_group_values : value if can(regex(local.entra_object_id_pattern, value))])
  app_user_group_names       = toset([for value in local.app_user_group_values : value if !can(regex(local.entra_object_id_pattern, value))])

  # Keep role-assignment instance keys derived only from module inputs. Azure
  # AD object IDs may be unknown until the data sources are resolved, so they
  # must remain values rather than determining the for_each keys.
  app_admin_group_keys = {
    for value in local.app_admin_group_values :
    value => can(regex(local.entra_object_id_pattern, value)) ? "id:${value}" : "name:${value}"
  }
  app_user_group_keys = {
    for value in local.app_user_group_values :
    value => can(regex(local.entra_object_id_pattern, value)) ? "id:${value}" : "name:${value}"
  }
  app_admin_group_principal_ids = {
    for value in local.app_admin_group_values :
    local.app_admin_group_keys[value] => can(regex(local.entra_object_id_pattern, value)) ? value : data.azuread_group.app_admin[value].object_id
  }
  app_user_group_principal_ids = {
    for value in local.app_user_group_values :
    local.app_user_group_keys[value] => can(regex(local.entra_object_id_pattern, value)) ? value : data.azuread_group.app_user[value].object_id
  }

  storage_data_plane_admin_roles = {
    storage_blob_data_owner        = "Storage Blob Data Owner"
    storage_file_data_elevated     = "Storage File Data SMB Share Elevated Contributor"
    storage_queue_data_contributor = "Storage Queue Data Contributor"
    storage_table_data_contributor = "Storage Table Data Contributor"
  }
  app_admin_group_data_plane_role_assignments = {
    for pair in setproduct(local.app_admin_group_values, keys(local.storage_data_plane_admin_roles)) :
    "${local.app_admin_group_keys[pair[0]]}|${pair[1]}" => {
      principal_id         = local.app_admin_group_principal_ids[local.app_admin_group_keys[pair[0]]]
      role_definition_name = local.storage_data_plane_admin_roles[pair[1]]
    }
  }

  terraform_execution_identity_role_assignments = var.grant_current_terraform_service_principal_storage_roles ? {
    contributor                    = "Contributor"
    storage_blob_data_owner        = "Storage Blob Data Owner"
    storage_file_data_elevated     = "Storage File Data SMB Share Elevated Contributor"
    storage_queue_data_contributor = "Storage Queue Data Contributor"
    storage_table_data_contributor = "Storage Table Data Contributor"
  } : {}

  diagnostic_destination_enabled = (
    trimspace(var.log_analytics_workspace_id) != "" ||
    try(trimspace(var.diagnostic_storage_account_id), "") != "" ||
    try(trimspace(var.diagnostic_eventhub_authorization_rule_id), "") != ""
  )
  diagnostics_enabled     = (var.enable_diagnostics || local.diagnostic_destination_enabled) && local.diagnostic_destination_enabled
  diagnostic_setting_name = trimspace(var.diagnostic_setting_name) != "" ? trimspace(var.diagnostic_setting_name) : "${local.storage_account_name}-diagnostic-setting"
}
