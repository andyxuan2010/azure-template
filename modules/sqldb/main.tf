resource "random_string" "suffix" {
  count = (trimspace(var.server_name) == "" || trimspace(var.database_name) == "") && var.use_random_suffix ? 1 : 0

  length  = 6
  upper   = false
  special = false
}

resource "azurerm_mssql_server" "sql_server" {
  name                                         = local.server_name
  resource_group_name                          = local.resource_group_name
  location                                     = local.location
  version                                      = var.server_version
  administrator_login                          = var.azuread_authentication_only ? null : local.admin_username_effective
  administrator_login_password                 = var.azuread_authentication_only ? null : local.admin_password_effective
  public_network_access_enabled                = var.public_network_access_enabled
  minimum_tls_version                          = var.minimum_tls_version
  connection_policy                            = var.connection_policy
  outbound_network_restriction_enabled         = var.outbound_network_restriction_enabled
  express_vulnerability_assessment_enabled     = var.express_vulnerability_assessment_enabled
  transparent_data_encryption_key_vault_key_id = local.server_tde_key_vault_key_id
  primary_user_assigned_identity_id            = local.server_primary_user_assigned_identity_id
  tags                                         = local.merged_tags

  dynamic "identity" {
    for_each = local.server_identity_enabled ? [1] : []

    content {
      type         = local.server_identity_type
      identity_ids = length(local.server_identity_ids) > 0 ? local.server_identity_ids : null
    }
  }

  dynamic "azuread_administrator" {
    for_each = local.azuread_admin_enabled ? [1] : []

    content {
      login_username              = trimspace(var.ad_admin_login_name)
      object_id                   = trimspace(var.ad_admin_object_id)
      tenant_id                   = local.azuread_admin_tenant_id
      azuread_authentication_only = var.azuread_authentication_only
    }
  }

  dynamic "timeouts" {
    for_each = var.server_timeouts == null ? [] : [var.server_timeouts]

    content {
      create = try(timeouts.value.create, null)
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
    }
  }

  lifecycle {
    precondition {
      condition     = var.azuread_authentication_only || (local.admin_username_effective != "" && can(regex("^[a-zA-Z][a-zA-Z0-9_@.-]{0,127}$", local.admin_username_effective)))
      error_message = "A valid SQL admin username is required unless azuread_authentication_only is true."
    }

    precondition {
      condition     = var.azuread_authentication_only || (local.admin_password_effective != "" && length(local.admin_password_effective) >= 8)
      error_message = "A SQL admin password of at least 8 characters is required unless azuread_authentication_only is true."
    }
  }
}

resource "azurerm_mssql_database" "sql_db" {
  name                                                       = local.database_name
  server_id                                                  = azurerm_mssql_server.sql_server.id
  sku_name                                                   = var.sku_name
  collation                                                  = var.collation
  max_size_gb                                                = var.max_size_gb
  zone_redundant                                             = var.zone_redundant
  storage_account_type                                       = var.backup_storage_redundancy
  transparent_data_encryption_enabled                        = var.transparent_data_encryption_enabled
  transparent_data_encryption_key_vault_key_id               = local.database_tde_key_vault_key_id
  transparent_data_encryption_key_automatic_rotation_enabled = var.database_transparent_data_encryption_key_automatic_rotation_enabled
  geo_backup_enabled                                         = var.geo_backup_enabled
  auto_pause_delay_in_minutes                                = var.auto_pause_delay_in_minutes
  min_capacity                                               = var.min_capacity
  elastic_pool_id                                            = local.database_elastic_pool_id
  enclave_type                                               = trimspace(var.enclave_type) != "" ? var.enclave_type : null
  license_type                                               = trimspace(var.license_type) != "" ? var.license_type : null
  maintenance_configuration_name                             = local.database_maintenance_configuration_name
  ledger_enabled                                             = var.ledger_enabled
  read_replica_count                                         = var.read_replica_count
  read_scale                                                 = var.read_scale
  create_mode                                                = var.database_import == null ? var.create_mode : null
  creation_source_database_id                                = local.database_creation_source_database_id
  recover_database_id                                        = local.database_recover_database_id
  restore_dropped_database_id                                = local.database_restore_dropped_database_id
  restore_long_term_retention_backup_id                      = local.database_restore_ltr_backup_id
  restore_point_in_time                                      = local.database_restore_point_in_time
  sample_name                                                = local.database_sample_name
  secondary_type                                             = local.database_secondary_type
  tags                                                       = local.merged_tags

  dynamic "identity" {
    for_each = local.database_identity_enabled ? [1] : []

    content {
      type         = "UserAssigned"
      identity_ids = local.database_identity_ids
    }
  }

  dynamic "import" {
    for_each = var.database_import == null ? [] : [var.database_import]

    content {
      administrator_login          = import.value.administrator_login
      administrator_login_password = import.value.administrator_login_password
      authentication_type          = import.value.authentication_type
      storage_account_id           = try(import.value.storage_account_id, null)
      storage_key                  = import.value.storage_key
      storage_key_type             = import.value.storage_key_type
      storage_uri                  = import.value.storage_uri
    }
  }

  short_term_retention_policy {
    retention_days           = var.backup_retention_days
    backup_interval_in_hours = var.backup_interval_in_hours
  }

  dynamic "long_term_retention_policy" {
    for_each = var.enable_long_term_retention ? [1] : []

    content {
      weekly_retention          = try(var.long_term_retention_policy.weekly_retention, 0) > 0 ? "P${var.long_term_retention_policy.weekly_retention}W" : null
      monthly_retention         = try(var.long_term_retention_policy.monthly_retention, 0) > 0 ? "P${var.long_term_retention_policy.monthly_retention}M" : null
      yearly_retention          = try(var.long_term_retention_policy.yearly_retention, 0) > 0 ? "P${var.long_term_retention_policy.yearly_retention}Y" : null
      week_of_year              = try(var.long_term_retention_policy.week_of_year, null)
      immutable_backups_enabled = try(var.long_term_retention_policy.immutable_backups_enabled, null)
    }
  }

  dynamic "threat_detection_policy" {
    for_each = var.enable_database_threat_detection ? [1] : []

    content {
      state                      = "Enabled"
      disabled_alerts            = var.threat_detection_disabled_alerts
      email_account_admins       = var.threat_detection_email_account_admins ? "Enabled" : "Disabled"
      email_addresses            = var.threat_detection_email_addresses
      retention_days             = local.threat_detection_retention_days
      storage_endpoint           = trimspace(var.threat_detection_storage_endpoint) != "" ? trimspace(var.threat_detection_storage_endpoint) : null
      storage_account_access_key = trimspace(var.threat_detection_storage_account_access_key) != "" ? var.threat_detection_storage_account_access_key : null
    }
  }

  dynamic "timeouts" {
    for_each = var.database_timeouts == null ? [] : [var.database_timeouts]

    content {
      create = try(timeouts.value.create, null)
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
    }
  }
}

resource "azapi_update_resource" "free_limit" {
  count       = var.use_free_limit ? 1 : 0
  type        = "Microsoft.Sql/servers/databases@2025-01-01"
  resource_id = azurerm_mssql_database.sql_db.id

  body = {
    properties = {
      useFreeLimit                = true
      freeLimitExhaustionBehavior = var.free_limit_exhaustion_behavior
    }
  }
}

resource "azurerm_mssql_firewall_rule" "azure_services" {
  count = var.allow_azure_services ? 1 : 0

  name             = "AllowAllWindowsAzureIps"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_firewall_rule" "sql" {
  for_each = var.firewall_rules

  name             = each.key
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]

    content {
      create = try(timeouts.value.create, null)
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
    }
  }
}

resource "azurerm_mssql_server_security_alert_policy" "threat_detection" {
  count = var.enable_threat_detection ? 1 : 0

  resource_group_name        = local.resource_group_name
  server_name                = azurerm_mssql_server.sql_server.name
  state                      = "Enabled"
  disabled_alerts            = var.threat_detection_disabled_alerts
  email_account_admins       = var.threat_detection_email_account_admins
  email_addresses            = var.threat_detection_email_addresses
  retention_days             = local.threat_detection_retention_days
  storage_endpoint           = trimspace(var.threat_detection_storage_endpoint) != "" ? trimspace(var.threat_detection_storage_endpoint) : null
  storage_account_access_key = trimspace(var.threat_detection_storage_account_access_key) != "" ? var.threat_detection_storage_account_access_key : null
}

resource "azurerm_mssql_server_extended_auditing_policy" "audit" {
  count = var.enable_audit ? 1 : 0

  server_id                               = azurerm_mssql_server.sql_server.id
  enabled                                 = true
  log_monitoring_enabled                  = var.audit_log_monitoring_enabled
  retention_in_days                       = var.audit_retention_days
  audit_actions_and_groups                = length(var.audit_actions_and_groups) > 0 ? var.audit_actions_and_groups : null
  predicate_expression                    = trimspace(var.audit_predicate_expression) != "" ? trimspace(var.audit_predicate_expression) : null
  storage_endpoint                        = local.audit_storage_endpoint
  storage_account_access_key              = trimspace(var.audit_storage_account_access_key) != "" ? var.audit_storage_account_access_key : null
  storage_account_access_key_is_secondary = var.audit_storage_account_access_key_is_secondary
  storage_account_subscription_id         = trimspace(var.audit_storage_account_subscription_id) != "" ? trimspace(var.audit_storage_account_subscription_id) : null
}

resource "azurerm_mssql_database_extended_auditing_policy" "audit" {
  count = var.enable_database_audit ? 1 : 0

  database_id                             = azurerm_mssql_database.sql_db.id
  enabled                                 = true
  log_monitoring_enabled                  = var.database_audit_log_monitoring_enabled
  retention_in_days                       = var.database_audit_retention_days == null ? var.audit_retention_days : var.database_audit_retention_days
  storage_endpoint                        = local.database_audit_storage_endpoint
  storage_account_access_key              = trimspace(var.database_audit_storage_account_access_key) != "" ? var.database_audit_storage_account_access_key : null
  storage_account_access_key_is_secondary = var.database_audit_storage_account_access_key_is_secondary
}

resource "azurerm_monitor_diagnostic_setting" "sql_diagnostics" {
  count = local.diagnostics_enabled ? 1 : 0

  name                           = local.diagnostic_setting_name
  target_resource_id             = azurerm_mssql_database.sql_db.id
  log_analytics_workspace_id     = trimspace(var.log_analytics_workspace_id) != "" ? trimspace(var.log_analytics_workspace_id) : null
  log_analytics_destination_type = trimspace(var.log_analytics_workspace_id) != "" ? var.log_analytics_destination_type : null
  storage_account_id             = trimspace(var.diagnostic_storage_account_id) != "" ? trimspace(var.diagnostic_storage_account_id) : null
  eventhub_authorization_rule_id = trimspace(var.diagnostic_eventhub_authorization_rule_id) != "" ? trimspace(var.diagnostic_eventhub_authorization_rule_id) : null
  eventhub_name                  = var.diagnostic_eventhub_name

  dynamic "enabled_log" {
    for_each = local.diagnostic_log_categories_effective

    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_log" {
    for_each = local.diagnostic_log_category_groups_effective

    content {
      category_group = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = toset(var.diagnostic_metric_categories)

    content {
      category = enabled_metric.value
    }
  }
}

resource "azurerm_private_endpoint" "sql" {
  count = var.enable_private_endpoint ? 1 : 0

  name                          = local.private_endpoint_name
  location                      = local.location
  resource_group_name           = local.resource_group_name
  subnet_id                     = local.private_endpoint_subnet_id_resolved
  custom_network_interface_name = local.private_endpoint_network_interface_name
  tags                          = local.merged_tags

  private_service_connection {
    name                           = local.private_service_connection_name
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = var.private_endpoint_manual_connection
    request_message                = local.private_endpoint_manual_request_message
  }

  dynamic "ip_configuration" {
    for_each = var.private_endpoint_ip_configurations

    content {
      member_name        = try(ip_configuration.value.member_name, "sqlServer")
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      subresource_name   = try(ip_configuration.value.subresource_name, "sqlServer")
    }
  }

  dynamic "private_dns_zone_group" {
    for_each = length(local.private_dns_zone_ids) > 0 ? [1] : []

    content {
      name                 = local.private_dns_zone_group_name
      private_dns_zone_ids = local.private_dns_zone_ids
    }
  }

  dynamic "timeouts" {
    for_each = var.private_endpoint_timeouts == null ? [] : [var.private_endpoint_timeouts]

    content {
      create = try(timeouts.value.create, null)
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
    }
  }
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = local.app_admin_group_principal_ids

  scope                = azurerm_mssql_server.sql_server.id
  role_definition_name = var.app_admin_role_definition_name
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = local.app_user_group_principal_ids

  scope                = azurerm_mssql_server.sql_server.id
  role_definition_name = var.app_user_role_definition_name
  principal_id         = each.value
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope = (
    lower(trimspace(try(each.value.scope, "server"))) == "server" ? azurerm_mssql_server.sql_server.id :
    lower(trimspace(try(each.value.scope, "server"))) == "database" ? azurerm_mssql_database.sql_db.id :
    trimspace(each.value.scope)
  )
  principal_id                           = each.value.principal_id
  principal_type                         = try(each.value.principal_type, null)
  role_definition_id                     = try(each.value.role_definition_id, null)
  role_definition_name                   = try(each.value.role_definition_name, null)
  name                                   = try(each.value.name, null)
  description                            = try(each.value.description, null)
  condition                              = try(each.value.condition, null)
  condition_version                      = try(each.value.condition_version, null)
  delegated_managed_identity_resource_id = try(each.value.delegated_managed_identity_resource_id, null)
  skip_service_principal_aad_check       = try(each.value.skip_service_principal_aad_check, false)
}

resource "azurerm_mssql_failover_group" "this" {
  for_each = var.failover_group == null ? {} : { "this" = var.failover_group }

  name                                      = local.failover_group_name
  server_id                                 = azurerm_mssql_server.sql_server.id
  databases                                 = length(try(each.value.database_ids, [])) > 0 ? each.value.database_ids : [azurerm_mssql_database.sql_db.id]
  readonly_endpoint_failover_policy_enabled = try(each.value.readonly_endpoint_failover_policy_enabled, null)
  tags = merge(local.merged_tags, try(each.value.tags, {}), {
    Environment = lookup(local.environment_tag_map, lower(trimspace(var.app_env)), upper(trimspace(var.app_env)))
    Workload    = trimspace(var.workload)
  })

  partner_server {
    id       = each.value.partner_server_id
    location = try(each.value.partner_server_location, null)
    role     = try(each.value.partner_server_role, null)
  }

  read_write_endpoint_failover_policy {
    mode          = try(each.value.read_write_endpoint_failover_policy.mode, "Automatic")
    grace_minutes = try(each.value.read_write_endpoint_failover_policy.grace_minutes, 60)
  }

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]

    content {
      create = try(timeouts.value.create, null)
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
    }
  }
}
