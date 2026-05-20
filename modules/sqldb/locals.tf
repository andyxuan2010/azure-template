locals {
  resource_group_lookup_required = trimspace(var.location) == "" || var.inherit_resource_group_tags
  resource_group_name            = trimspace(var.resource_group_name)
  location                       = trimspace(var.location) != "" ? trimspace(var.location) : data.azurerm_resource_group.sql[0].location
  common_tags                    = var.inherit_resource_group_tags ? try(data.azurerm_resource_group.sql[0].tags, {}) : {}

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
  server_prefix          = lower(join("", regexall("[a-z0-9-]", var.name_prefix)))
  database_prefix        = lower(join("", regexall("[a-zA-Z0-9_-]", var.database_name_prefix)))
  location_code_resolved = trimspace(var.location_code) != "" ? trimspace(var.location_code) : lookup(local.location_code_map, lower(local.location), lower(join("", regexall("[a-z0-9]", replace(local.location, " ", "")))))
  generated_suffix       = var.use_random_suffix ? try(random_string.suffix[0].result, "000001") : lower(join("", regexall("[a-z0-9-]", var.instance)))

  generated_server_name_parts = compact([local.server_prefix, local.application_code, var.include_environment_in_name ? var.app_env : "", local.location_code_resolved, local.generated_suffix])
  generated_server_name_raw   = trim(join("-", local.generated_server_name_parts), "-")
  server_name                 = trimspace(var.server_name) != "" ? lower(trimspace(var.server_name)) : trim(substr(local.generated_server_name_raw != "" ? local.generated_server_name_raw : "sql-app-dev-eus-001", 0, 63), "-")

  generated_database_name_parts = compact([local.database_prefix, local.application_code, var.include_environment_in_name ? var.app_env : "", local.location_code_resolved, local.generated_suffix])
  generated_database_name_raw   = trim(join("-", local.generated_database_name_parts), "-")
  database_name                 = trimspace(var.database_name) != "" ? trimspace(var.database_name) : trim(substr(local.generated_database_name_raw != "" ? local.generated_database_name_raw : "sqldb-app-dev-eus-001", 0, 128), "-")

  server_identity_ids = distinct(compact(concat(
    [for identity_id in var.identity_ids : trimspace(identity_id)],
    trimspace(var.primary_user_assigned_identity_id) != "" ? [trimspace(var.primary_user_assigned_identity_id)] : []
  )))
  server_identity_type                     = join(", ", compact([var.system_assigned_identity_enabled ? "SystemAssigned" : "", length(local.server_identity_ids) > 0 ? "UserAssigned" : ""]))
  server_identity_enabled                  = local.server_identity_type != ""
  server_primary_user_assigned_identity_id = trimspace(var.primary_user_assigned_identity_id) != "" ? trimspace(var.primary_user_assigned_identity_id) : (length(local.server_identity_ids) > 0 ? local.server_identity_ids[0] : null)
  database_identity_ids                    = distinct(compact([for identity_id in var.database_identity_ids : trimspace(identity_id)]))
  database_identity_enabled                = length(local.database_identity_ids) > 0
  server_tde_key_vault_key_id              = trimspace(var.transparent_data_encryption_key_vault_key_id) != "" ? trimspace(var.transparent_data_encryption_key_vault_key_id) : null
  database_tde_key_vault_key_id            = trimspace(var.database_transparent_data_encryption_key_vault_key_id) != "" ? trimspace(var.database_transparent_data_encryption_key_vault_key_id) : null
  azuread_admin_enabled                    = var.azuread_administrator_enabled || trimspace(var.ad_admin_login_name) != "" || trimspace(var.ad_admin_object_id) != "" || var.azuread_authentication_only
  azuread_admin_tenant_id                  = trimspace(var.azuread_admin_tenant_id) != "" ? trimspace(var.azuread_admin_tenant_id) : null
  database_elastic_pool_id                 = trimspace(var.elastic_pool_id) != "" ? trimspace(var.elastic_pool_id) : null
  database_maintenance_configuration_name  = trimspace(var.maintenance_configuration_name) != "" ? trimspace(var.maintenance_configuration_name) : null
  database_sample_name                     = trimspace(var.sample_name) != "" ? trimspace(var.sample_name) : null
  database_secondary_type                  = trimspace(var.secondary_type) != "" ? trimspace(var.secondary_type) : null
  database_restore_point_in_time           = trimspace(var.restore_point_in_time) != "" ? trimspace(var.restore_point_in_time) : null
  database_creation_source_database_id     = trimspace(var.creation_source_database_id) != "" ? trimspace(var.creation_source_database_id) : null
  database_recover_database_id             = trimspace(var.recover_database_id) != "" ? trimspace(var.recover_database_id) : null
  database_restore_dropped_database_id     = trimspace(var.restore_dropped_database_id) != "" ? trimspace(var.restore_dropped_database_id) : null
  database_restore_ltr_backup_id           = trimspace(var.restore_long_term_retention_backup_id) != "" ? trimspace(var.restore_long_term_retention_backup_id) : null

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
    [for zone_id in var.private_dns_zone_ids : trimspace(zone_id)],
    [for _, zone in data.azurerm_private_dns_zone.sql : zone.id]
  )))
  private_endpoint_name                   = trimspace(var.private_endpoint_name) != "" ? trimspace(var.private_endpoint_name) : "pep-${local.server_name}"
  private_service_connection_name         = trimspace(var.private_service_connection_name) != "" ? trimspace(var.private_service_connection_name) : "psc-${local.server_name}"
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
  diagnostic_setting_name = trimspace(var.diagnostic_setting_name) != "" ? trimspace(var.diagnostic_setting_name) : "diag-${local.database_name}"

  diagnostic_log_categories_effective = toset([
    for category in var.diagnostic_log_categories :
    category
    if !contains(["AllLogs", "allLogs"], category)
  ])
  diagnostic_log_category_groups_effective = toset(distinct(concat(
    var.diagnostic_log_category_groups,
    [for category in var.diagnostic_log_categories : "allLogs" if contains(["AllLogs", "allLogs"], category)]
  )))

  threat_detection_retention_days = var.threat_detection_retention_days == null ? var.audit_retention_days : var.threat_detection_retention_days
  audit_storage_endpoint          = trimspace(var.audit_storage_endpoint) != "" ? trimspace(var.audit_storage_endpoint) : null
  database_audit_storage_endpoint = trimspace(var.database_audit_storage_endpoint) != "" ? trimspace(var.database_audit_storage_endpoint) : null
  failover_group_name_input       = var.failover_group == null ? "" : trimspace(join("", compact([try(var.failover_group.name, "")])))
  failover_group_name             = var.failover_group == null ? null : (local.failover_group_name_input != "" ? local.failover_group_name_input : "fog-${local.server_name}")

  admin_credentials_key_vault_id_effective = trimspace(var.admin_credentials_key_vault_id)
  admin_username_secret_name_effective     = trimspace(var.admin_username_secret_name)
  admin_password_secret_name_effective     = trimspace(var.admin_password_secret_name)

  admin_username_default = "sqladminuser"
  admin_password_default = "ChangeMeSql12345!"

  admin_username_input_effective = var.admin_username == null ? "" : trimspace(nonsensitive(var.admin_username))
  admin_password_input_effective = var.admin_password == null ? "" : trimspace(nonsensitive(var.admin_password))
  admin_username_input_provided  = nonsensitive(local.admin_username_input_effective != "")
  admin_password_input_provided  = nonsensitive(local.admin_password_input_effective != "")

  admin_credentials_key_vault_enabled  = local.admin_credentials_key_vault_id_effective != ""
  admin_username_secret_lookup_enabled = nonsensitive(local.admin_credentials_key_vault_enabled && !local.admin_username_input_provided && local.admin_username_secret_name_effective != "")
  admin_password_secret_lookup_enabled = nonsensitive(local.admin_credentials_key_vault_enabled && !local.admin_password_input_provided && local.admin_password_secret_name_effective != "")

  admin_username_secret_value = try(trimspace(data.azurerm_key_vault_secret.admin_username["active"].value), "")
  admin_password_secret_value = try(trimspace(data.azurerm_key_vault_secret.admin_password["active"].value), "")

  admin_username_effective = try(coalesce(
    local.admin_username_input_effective != "" ? local.admin_username_input_effective : null,
    local.admin_username_secret_value != "" ? local.admin_username_secret_value : null,
    local.admin_username_default
  ), local.admin_username_default)
  admin_password_effective = try(coalesce(
    local.admin_password_input_effective != "" ? local.admin_password_input_effective : null,
    local.admin_password_secret_value != "" ? local.admin_password_secret_value : null,
    local.admin_password_default
  ), local.admin_password_default)

  merged_tags = merge(
    local.common_tags,
    lookup(local.environment_tags, var.app_env, {}),
    {
      ManagedBy = "Terraform"
      module    = "sqldb"
      name      = local.database_name
      app_env   = var.app_env
    },
    var.tags
  )
}
