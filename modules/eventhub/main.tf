data "azurerm_resource_group" "rg" {
  count = local.resource_group_lookup_required ? 1 : 0

  name = local.resource_group_name
}

data "azurerm_subnet" "private_endpoint" {
  count = var.enable_private_endpoint && trimspace(var.private_endpoint_subnet_id) == "" ? 1 : 0

  name                 = var.private_endpoint_subnet_name
  virtual_network_name = var.private_endpoint_vnet_name
  resource_group_name  = var.private_endpoint_network_resource_group_name
}

data "azurerm_private_dns_zone" "this" {
  for_each = local.private_dns_zone_names_effective

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

resource "random_string" "random" {
  count       = trimspace(var.name) == "" && var.use_random_suffix ? 1 : 0
  length      = 6
  special     = false
  upper       = false
  min_numeric = 2
}

resource "azurerm_eventhub_namespace" "this" {
  name                          = local.namespace_name
  location                      = local.location
  resource_group_name           = local.resource_group_name
  sku                           = var.sku
  capacity                      = var.capacity
  auto_inflate_enabled          = var.auto_inflate_enabled
  maximum_throughput_units      = var.auto_inflate_enabled ? var.maximum_throughput_units : null
  dedicated_cluster_id          = trimspace(var.dedicated_cluster_id) != "" ? var.dedicated_cluster_id : null
  local_authentication_enabled  = var.local_authentication_enabled
  public_network_access_enabled = var.public_network_access_enabled
  minimum_tls_version           = var.minimum_tls_version
  network_rulesets              = local.network_rulesets
  tags                          = local.merged_tags

  dynamic "identity" {
    for_each = local.identity_type != "" ? [1] : []

    content {
      type         = local.identity_type
      identity_ids = length(local.identity_ids) > 0 ? local.identity_ids : null
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    precondition {
      condition     = !var.auto_inflate_enabled || var.sku == "Standard"
      error_message = "auto_inflate_enabled is only supported for Standard Event Hub namespaces."
    }

    precondition {
      condition     = var.customer_managed_key == null || local.identity_type != ""
      error_message = "customer_managed_key requires identity, system_managed_identity_enabled, or identity_ids."
    }

    precondition {
      condition     = var.local_authentication_enabled || (length(var.authorization_rules) == 0 && length(local.eventhub_authorization_rules) == 0)
      error_message = "authorization_rules and Event Hub-level authorization_rules require local_authentication_enabled = true."
    }
  }
}

resource "azurerm_eventhub" "this" {
  for_each = var.eventhubs

  name              = try(trimspace(each.value.name), "") != "" ? trimspace(each.value.name) : each.key
  namespace_id      = azurerm_eventhub_namespace.this.id
  partition_count   = each.value.partition_count
  message_retention = try(each.value.retention_description, null) == null ? each.value.message_retention : null
  status            = each.value.status

  dynamic "retention_description" {
    for_each = try(each.value.retention_description, null) == null ? [] : [each.value.retention_description]

    content {
      cleanup_policy                    = retention_description.value.cleanup_policy
      retention_time_in_hours           = try(retention_description.value.retention_time_in_hours, null)
      tombstone_retention_time_in_hours = try(retention_description.value.tombstone_retention_time_in_hours, null)
    }
  }

  dynamic "capture_description" {
    for_each = try(each.value.capture_description, null) == null ? [] : [each.value.capture_description]

    content {
      enabled             = capture_description.value.enabled
      encoding            = try(capture_description.value.encoding, "Avro")
      interval_in_seconds = try(capture_description.value.interval_in_seconds, null)
      size_limit_in_bytes = try(capture_description.value.size_limit_in_bytes, null)
      skip_empty_archives = try(capture_description.value.skip_empty_archives, null)

      destination {
        name                        = try(capture_description.value.destination.name, "EventHubArchive.AzureBlockBlob")
        archive_name_format         = capture_description.value.destination.archive_name_format
        blob_container_name         = capture_description.value.destination.blob_container_name
        storage_account_id          = capture_description.value.destination.storage_account_id
        storage_authentication_type = try(capture_description.value.destination.storage_authentication_type, null)
        storage_authentication_id   = try(capture_description.value.destination.storage_authentication_id, null)
      }
    }
  }

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    precondition {
      condition     = var.sku != "Basic" || try(each.value.capture_description, null) == null
      error_message = "Event Hub Capture requires Standard, Premium, or Dedicated Event Hubs."
    }

    precondition {
      condition = (
        try(each.value.capture_description.destination.storage_authentication_type, "StorageSAS") == "StorageSAS" ||
        local.identity_type != ""
      )
      error_message = "Managed identity-based Event Hub Capture storage authentication requires a namespace managed identity."
    }
  }
}

resource "azurerm_eventhub_consumer_group" "this" {
  for_each = local.eventhub_consumer_groups

  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = azurerm_eventhub.this[each.value.eventhub_key].name
  resource_group_name = local.resource_group_name
  user_metadata       = each.value.user_metadata

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azurerm_eventhub_namespace_authorization_rule" "this" {
  for_each = var.authorization_rules

  name                = try(trimspace(each.value.name), "") != "" ? trimspace(each.value.name) : each.key
  namespace_name      = azurerm_eventhub_namespace.this.name
  resource_group_name = local.resource_group_name
  listen              = each.value.listen
  send                = each.value.send
  manage              = each.value.manage

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azurerm_eventhub_authorization_rule" "this" {
  for_each = local.eventhub_authorization_rules

  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = azurerm_eventhub.this[each.value.eventhub_key].name
  resource_group_name = local.resource_group_name
  listen              = each.value.listen
  send                = each.value.send
  manage              = each.value.manage

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azurerm_eventhub_namespace_schema_group" "this" {
  for_each = var.schema_groups

  name                 = try(trimspace(each.value.name), "") != "" ? trimspace(each.value.name) : each.key
  namespace_id         = azurerm_eventhub_namespace.this.id
  schema_compatibility = each.value.schema_compatibility
  schema_type          = each.value.schema_type

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      delete = timeouts.value.delete
    }
  }
}

resource "azurerm_eventhub_namespace_customer_managed_key" "this" {
  count = var.customer_managed_key == null ? 0 : 1

  eventhub_namespace_id             = azurerm_eventhub_namespace.this.id
  key_vault_key_ids                 = var.customer_managed_key.key_vault_key_ids
  infrastructure_encryption_enabled = try(var.customer_managed_key.infrastructure_encryption_enabled, false)
  user_assigned_identity_id         = try(trimspace(var.customer_managed_key.user_assigned_identity_id), "") != "" ? var.customer_managed_key.user_assigned_identity_id : null

  dynamic "timeouts" {
    for_each = try(var.customer_managed_key.timeouts, null) == null ? [] : [var.customer_managed_key.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azurerm_eventhub_namespace_disaster_recovery_config" "this" {
  count = var.disaster_recovery_config == null ? 0 : 1

  name                 = var.disaster_recovery_config.name
  namespace_name       = azurerm_eventhub_namespace.this.name
  resource_group_name  = local.resource_group_name
  partner_namespace_id = var.disaster_recovery_config.partner_namespace_id

  dynamic "timeouts" {
    for_each = try(var.disaster_recovery_config.timeouts, null) == null ? [] : [var.disaster_recovery_config.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = local.app_admin_group_principal_ids

  scope                = azurerm_eventhub_namespace.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = local.app_user_group_principal_ids

  scope                = azurerm_eventhub_namespace.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                                  = azurerm_eventhub_namespace.this.id
  principal_id                           = each.value.principal_id
  role_definition_id                     = try(each.value.role_definition_id, null)
  role_definition_name                   = try(each.value.role_definition_name, null)
  principal_type                         = try(each.value.principal_type, null)
  description                            = try(each.value.description, null)
  name                                   = try(each.value.name, null)
  condition                              = try(each.value.condition, null)
  condition_version                      = try(each.value.condition_version, null)
  delegated_managed_identity_resource_id = try(each.value.delegated_managed_identity_resource_id, null)
  skip_service_principal_aad_check       = try(each.value.skip_service_principal_aad_check, false)
}

resource "azurerm_private_endpoint" "this" {
  count = var.enable_private_endpoint ? 1 : 0

  name                          = "${var.private_endpoint_name_prefix}-${azurerm_eventhub_namespace.this.name}"
  location                      = local.location
  resource_group_name           = local.resource_group_name
  subnet_id                     = local.private_endpoint_subnet_id_resolved
  custom_network_interface_name = trimspace(var.private_endpoint_network_interface_name) != "" ? var.private_endpoint_network_interface_name : null

  private_service_connection {
    name                           = "${var.private_service_connection_name_prefix}-${azurerm_eventhub_namespace.this.name}"
    private_connection_resource_id = azurerm_eventhub_namespace.this.id
    subresource_names              = ["namespace"]
    is_manual_connection           = var.private_endpoint_manual_connection_enabled
    request_message                = var.private_endpoint_manual_connection_enabled && trimspace(var.private_endpoint_request_message) != "" ? var.private_endpoint_request_message : null
  }

  dynamic "ip_configuration" {
    for_each = var.private_endpoint_ip_configurations

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      subresource_name   = try(ip_configuration.value.subresource_name, "namespace")
      member_name        = try(ip_configuration.value.member_name, "namespace")
    }
  }

  dynamic "private_dns_zone_group" {
    for_each = length(local.private_dns_zone_ids) > 0 ? [1] : []

    content {
      name                 = "default"
      private_dns_zone_ids = local.private_dns_zone_ids
    }
  }

  dynamic "timeouts" {
    for_each = var.private_endpoint_timeouts == null ? [] : [var.private_endpoint_timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  tags = local.merged_tags
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = local.diagnostics_enabled ? 1 : 0

  name                           = local.diagnostic_setting_name
  target_resource_id             = azurerm_eventhub_namespace.this.id
  log_analytics_workspace_id     = trimspace(var.log_analytics_workspace_id) != "" ? var.log_analytics_workspace_id : null
  log_analytics_destination_type = trimspace(var.log_analytics_workspace_id) != "" ? var.log_analytics_destination_type : null
  storage_account_id             = try(trimspace(var.diagnostic_storage_account_id), "") != "" ? var.diagnostic_storage_account_id : null
  eventhub_authorization_rule_id = try(trimspace(var.diagnostic_eventhub_authorization_rule_id), "") != "" ? var.diagnostic_eventhub_authorization_rule_id : null
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

  dynamic "timeouts" {
    for_each = var.diagnostic_timeouts == null ? [] : [var.diagnostic_timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}
