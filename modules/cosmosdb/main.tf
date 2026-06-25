data "azurerm_resource_group" "rg" {
  count = local.resource_group_lookup_required ? 1 : 0

  name = local.resource_group_name
}

data "azurerm_subnet" "private_endpoint" {
  count = local.private_endpoint_subnet_lookup_by_name ? 1 : 0

  name                 = var.private_endpoint_subnet_name
  virtual_network_name = var.private_endpoint_vnet_name
  resource_group_name  = var.private_endpoint_network_resource_group_name
}

data "azurerm_private_dns_zone" "cosmosdb" {
  for_each = var.enable_private_endpoint ? local.private_dns_zone_names_effective : toset([])

  name                = each.value
  resource_group_name = var.private_dns_zone_resource_group_name
}

data "azuread_group" "app_admin" {
  for_each = local.app_admin_group_names

  display_name = each.value
}

data "azuread_group" "app_user" {
  for_each = local.app_user_group_names

  display_name = each.value
}

resource "random_string" "suffix" {
  count = trimspace(var.name) == "" && var.use_random_suffix ? 1 : 0

  length  = 6
  upper   = false
  special = false
}

resource "azurerm_cosmosdb_account" "this" {
  name                                  = local.account_name
  resource_group_name                   = local.resource_group_name
  location                              = local.location
  offer_type                            = var.offer_type
  kind                                  = var.kind
  minimal_tls_version                   = var.minimal_tls_version
  public_network_access_enabled         = var.public_network_access_enabled
  local_authentication_disabled         = var.local_authentication_disabled
  automatic_failover_enabled            = var.automatic_failover_enabled
  multiple_write_locations_enabled      = var.multiple_write_locations_enabled
  free_tier_enabled                     = var.free_tier_enabled
  analytical_storage_enabled            = var.analytical_storage_enabled
  ip_range_filter                       = length(var.ip_range_filter) > 0 ? toset(var.ip_range_filter) : null
  is_virtual_network_filter_enabled     = length(var.virtual_network_rules) > 0
  network_acl_bypass_for_azure_services = var.network_acl_bypass_for_azure_services
  network_acl_bypass_ids                = length(var.network_acl_bypass_ids) > 0 ? var.network_acl_bypass_ids : null
  default_identity_type                 = trimspace(var.default_identity_type) != "" ? trimspace(var.default_identity_type) : null
  key_vault_key_id                      = trimspace(var.key_vault_key_id) != "" ? trimspace(var.key_vault_key_id) : null
  tags                                  = local.merged_tags

  consistency_policy {
    consistency_level       = var.consistency_policy.consistency_level
    max_interval_in_seconds = try(var.consistency_policy.max_interval_in_seconds, null)
    max_staleness_prefix    = try(var.consistency_policy.max_staleness_prefix, null)
  }

  dynamic "geo_location" {
    for_each = local.geo_locations_effective

    content {
      location          = geo_location.value.location
      failover_priority = geo_location.value.failover_priority
      zone_redundant    = try(geo_location.value.zone_redundant, false)
    }
  }

  backup {
    type                = var.backup.type
    tier                = try(var.backup.tier, null)
    interval_in_minutes = try(var.backup.interval_in_minutes, null)
    retention_in_hours  = try(var.backup.retention_in_hours, null)
    storage_redundancy  = try(var.backup.storage_redundancy, null)
  }

  dynamic "analytical_storage" {
    for_each = var.analytical_storage_enabled ? [1] : []

    content {
      schema_type = var.analytical_storage_schema_type
    }
  }

  dynamic "capabilities" {
    for_each = toset(var.capabilities)

    content {
      name = capabilities.value
    }
  }

  dynamic "capacity" {
    for_each = var.total_throughput_limit == null ? [] : [1]

    content {
      total_throughput_limit = var.total_throughput_limit
    }
  }

  dynamic "identity" {
    for_each = local.identity_enabled ? [1] : []

    content {
      type         = local.identity_type
      identity_ids = length(local.identity_ids) > 0 ? local.identity_ids : null
    }
  }

  dynamic "virtual_network_rule" {
    for_each = var.virtual_network_rules

    content {
      id                                   = virtual_network_rule.value.id
      ignore_missing_vnet_service_endpoint = try(virtual_network_rule.value.ignore_missing_vnet_service_endpoint, false)
    }
  }

  dynamic "timeouts" {
    for_each = var.account_timeouts == null ? [] : [var.account_timeouts]

    content {
      create = try(timeouts.value.create, null)
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
    }
  }
}

resource "azurerm_cosmosdb_sql_database" "this" {
  for_each = var.sql_databases

  name                = each.key
  resource_group_name = local.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  throughput          = try(each.value.throughput, null)

  dynamic "autoscale_settings" {
    for_each = try(each.value.autoscale_max_ru, null) == null ? [] : [1]

    content {
      max_throughput = each.value.autoscale_max_ru
    }
  }
}

resource "azurerm_cosmosdb_sql_container" "this" {
  for_each = var.sql_containers

  name                   = each.key
  resource_group_name    = local.resource_group_name
  account_name           = azurerm_cosmosdb_account.this.name
  database_name          = each.value.database_name
  partition_key_paths    = each.value.partition_key_paths
  partition_key_kind     = try(each.value.partition_key_kind, "Hash")
  partition_key_version  = try(each.value.partition_key_version, 2)
  throughput             = try(each.value.throughput, null)
  default_ttl            = try(each.value.default_ttl, null)
  analytical_storage_ttl = try(each.value.analytical_storage_ttl, null)

  dynamic "autoscale_settings" {
    for_each = try(each.value.autoscale_max_ru, null) == null ? [] : [1]

    content {
      max_throughput = each.value.autoscale_max_ru
    }
  }

  dynamic "conflict_resolution_policy" {
    for_each = try(each.value.conflict_resolution_policy, null) == null ? [] : [each.value.conflict_resolution_policy]

    content {
      mode                          = conflict_resolution_policy.value.mode
      conflict_resolution_path      = try(conflict_resolution_policy.value.conflict_resolution_path, null)
      conflict_resolution_procedure = try(conflict_resolution_policy.value.conflict_resolution_procedure, null)
    }
  }

  dynamic "indexing_policy" {
    for_each = try(each.value.indexing_policy, null) == null ? [] : [each.value.indexing_policy]

    content {
      indexing_mode = try(indexing_policy.value.indexing_mode, "consistent")

      dynamic "included_path" {
        for_each = try(indexing_policy.value.included_paths, [])

        content {
          path = included_path.value.path
        }
      }

      dynamic "excluded_path" {
        for_each = try(indexing_policy.value.excluded_paths, [])

        content {
          path = excluded_path.value.path
        }
      }

      dynamic "composite_index" {
        for_each = try(indexing_policy.value.composite_indexes, [])

        content {
          dynamic "index" {
            for_each = composite_index.value

            content {
              path  = index.value.path
              order = index.value.order
            }
          }
        }
      }

      dynamic "spatial_index" {
        for_each = try(indexing_policy.value.spatial_indexes, [])

        content {
          path  = spatial_index.value.path
          types = try(spatial_index.value.types, null)
        }
      }
    }
  }

  dynamic "unique_key" {
    for_each = try(each.value.unique_keys, [])

    content {
      paths = unique_key.value.paths
    }
  }

  depends_on = [azurerm_cosmosdb_sql_database.this]
}

resource "azurerm_cosmosdb_sql_role_definition" "this" {
  for_each = var.sql_role_definitions

  name                = each.key
  resource_group_name = local.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  type                = "CustomRole"
  assignable_scopes   = each.value.assignable_scopes

  permissions {
    data_actions = each.value.data_actions
  }
}

resource "azurerm_cosmosdb_sql_role_assignment" "this" {
  for_each = var.sql_role_assignments

  name                = each.key
  resource_group_name = local.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  principal_id        = each.value.principal_id
  role_definition_id  = each.value.role_definition_id
  scope               = try(each.value.scope, azurerm_cosmosdb_account.this.id)
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = local.app_admin_group_principal_ids

  scope                = azurerm_cosmosdb_account.this.id
  role_definition_name = var.app_admin_role_definition_name
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = local.app_user_group_principal_ids

  scope                = azurerm_cosmosdb_account.this.id
  role_definition_name = var.app_user_role_definition_name
  principal_id         = each.value
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                                  = azurerm_cosmosdb_account.this.id
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

resource "azurerm_private_endpoint" "this" {
  count = var.enable_private_endpoint ? 1 : 0

  name                          = local.private_endpoint_name
  location                      = local.location
  resource_group_name           = local.resource_group_name
  subnet_id                     = local.private_endpoint_subnet_id_resolved
  custom_network_interface_name = local.private_endpoint_network_interface_name
  tags                          = local.merged_tags

  private_service_connection {
    name                           = local.private_service_connection_name
    private_connection_resource_id = azurerm_cosmosdb_account.this.id
    subresource_names              = ["Sql"]
    is_manual_connection           = var.private_endpoint_manual_connection
    request_message                = local.private_endpoint_manual_request_message
  }

  dynamic "ip_configuration" {
    for_each = var.private_endpoint_ip_configurations

    content {
      member_name        = try(ip_configuration.value.member_name, "Sql")
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      subresource_name   = try(ip_configuration.value.subresource_name, "Sql")
    }
  }

  dynamic "private_dns_zone_group" {
    for_each = length(local.private_dns_zone_ids) > 0 ? [1] : []

    content {
      name                 = local.private_dns_zone_group_name
      private_dns_zone_ids = local.private_dns_zone_ids
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = local.diagnostics_enabled ? 1 : 0

  name                           = local.diagnostic_setting_name
  target_resource_id             = azurerm_cosmosdb_account.this.id
  log_analytics_workspace_id     = trimspace(var.log_analytics_workspace_id) != "" ? var.log_analytics_workspace_id : null
  log_analytics_destination_type = trimspace(var.log_analytics_workspace_id) != "" ? var.log_analytics_destination_type : null
  storage_account_id             = trimspace(var.diagnostic_storage_account_id) != "" ? var.diagnostic_storage_account_id : null
  eventhub_authorization_rule_id = trimspace(var.diagnostic_eventhub_authorization_rule_id) != "" ? var.diagnostic_eventhub_authorization_rule_id : null
  eventhub_name                  = try(trimspace(var.diagnostic_eventhub_name), "") != "" ? var.diagnostic_eventhub_name : null

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
