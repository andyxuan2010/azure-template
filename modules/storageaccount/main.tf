# Data sources
data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  count = local.resource_group_lookup_required ? 1 : 0

  name = local.resource_group_name
}

data "azurerm_subnet" "pep" {
  count = local.create_private_endpoints && trimspace(var.private_endpoint_subnet_id) == "" ? 1 : 0

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
  length      = 4
  special     = false
  upper       = false
  min_numeric = 1
}

resource "azurerm_storage_account" "this" {
  name                              = local.storage_account_name
  resource_group_name               = local.resource_group_name
  location                          = local.location
  account_tier                      = var.account_tier
  account_replication_type          = var.account_replication_type
  account_kind                      = var.account_kind
  access_tier                       = local.access_tier_effective
  edge_zone                         = var.edge_zone
  dns_endpoint_type                 = var.dns_endpoint_type
  allowed_copy_scope                = var.allowed_copy_scope
  min_tls_version                   = var.min_tls_version
  https_traffic_only_enabled        = var.https_traffic_only_enabled
  public_network_access_enabled     = var.public_network_access_enabled
  allow_nested_items_to_be_public   = var.allow_nested_items_to_be_public
  shared_access_key_enabled         = var.shared_access_key_enabled
  default_to_oauth_authentication   = var.default_to_oauth_authentication
  cross_tenant_replication_enabled  = var.cross_tenant_replication_enabled
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  is_hns_enabled                    = var.is_hns_enabled
  nfsv3_enabled                     = var.nfsv3_enabled
  sftp_enabled                      = var.sftp_enabled
  local_user_enabled                = var.local_user_enabled
  large_file_share_enabled          = var.large_file_share_enabled
  queue_encryption_key_type         = var.queue_encryption_key_type
  table_encryption_key_type         = var.table_encryption_key_type
  provisioned_billing_model_version = var.provisioned_billing_model_version

  dynamic "identity" {
    for_each = local.identity_type != "" ? [1] : []

    content {
      type         = local.identity_type
      identity_ids = local.identity_ids
    }
  }

  dynamic "custom_domain" {
    for_each = var.custom_domain == null ? [] : [var.custom_domain]

    content {
      name          = custom_domain.value.name
      use_subdomain = custom_domain.value.use_subdomain
    }
  }

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key == null ? [] : [var.customer_managed_key]

    content {
      key_vault_key_id          = try(customer_managed_key.value.key_vault_key_id, null)
      managed_hsm_key_id        = try(customer_managed_key.value.managed_hsm_key_id, null)
      user_assigned_identity_id = try(customer_managed_key.value.user_assigned_identity_id, null)
    }
  }

  dynamic "blob_properties" {
    for_each = var.blob_properties == null ? [] : [var.blob_properties]

    content {
      versioning_enabled            = try(blob_properties.value.versioning_enabled, null)
      change_feed_enabled           = try(blob_properties.value.change_feed_enabled, null)
      change_feed_retention_in_days = try(blob_properties.value.change_feed_retention_in_days, null)
      default_service_version       = try(blob_properties.value.default_service_version, null)
      last_access_time_enabled      = try(blob_properties.value.last_access_time_enabled, null)

      dynamic "delete_retention_policy" {
        for_each = try(blob_properties.value.delete_retention_policy_days, null) == null ? [] : [blob_properties.value.delete_retention_policy_days]

        content {
          days                     = delete_retention_policy.value
          permanent_delete_enabled = try(blob_properties.value.delete_retention_policy_permanent_delete_enabled, null)
        }
      }

      dynamic "container_delete_retention_policy" {
        for_each = try(blob_properties.value.container_delete_retention_policy_days, null) == null ? [] : [blob_properties.value.container_delete_retention_policy_days]

        content {
          days = container_delete_retention_policy.value
        }
      }

      dynamic "restore_policy" {
        for_each = try(blob_properties.value.restore_policy_days, null) == null ? [] : [blob_properties.value.restore_policy_days]

        content {
          days = restore_policy.value
        }
      }

      dynamic "cors_rule" {
        for_each = try(blob_properties.value.cors_rules, [])

        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }
    }
  }

  dynamic "azure_files_authentication" {
    for_each = var.azure_files_authentication == null ? [] : [var.azure_files_authentication]

    content {
      directory_type                 = azure_files_authentication.value.directory_type
      default_share_level_permission = try(azure_files_authentication.value.default_share_level_permission, null)

      dynamic "active_directory" {
        for_each = try(azure_files_authentication.value.active_directory, null) == null ? [] : [azure_files_authentication.value.active_directory]

        content {
          domain_guid         = active_directory.value.domain_guid
          domain_name         = active_directory.value.domain_name
          domain_sid          = active_directory.value.domain_sid
          forest_name         = active_directory.value.forest_name
          netbios_domain_name = active_directory.value.netbios_domain_name
          storage_sid         = active_directory.value.storage_sid
        }
      }
    }
  }

  dynamic "immutability_policy" {
    for_each = var.immutability_policy == null ? [] : [var.immutability_policy]

    content {
      allow_protected_append_writes = immutability_policy.value.allow_protected_append_writes
      period_since_creation_in_days = immutability_policy.value.period_since_creation_in_days
      state                         = immutability_policy.value.state
    }
  }

  dynamic "queue_properties" {
    for_each = var.queue_properties == null ? [] : [var.queue_properties]

    content {
      dynamic "cors_rule" {
        for_each = try(queue_properties.value.cors_rules, [])

        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }

      dynamic "logging" {
        for_each = try(queue_properties.value.logging, null) == null ? [] : [queue_properties.value.logging]

        content {
          delete                = logging.value.delete
          read                  = logging.value.read
          version               = logging.value.version
          write                 = logging.value.write
          retention_policy_days = try(logging.value.retention_policy_days, null)
        }
      }

      dynamic "hour_metrics" {
        for_each = try(queue_properties.value.hour_metrics, null) == null ? [] : [queue_properties.value.hour_metrics]

        content {
          enabled               = hour_metrics.value.enabled
          include_apis          = try(hour_metrics.value.include_apis, null)
          retention_policy_days = try(hour_metrics.value.retention_policy_days, null)
          version               = hour_metrics.value.version
        }
      }

      dynamic "minute_metrics" {
        for_each = try(queue_properties.value.minute_metrics, null) == null ? [] : [queue_properties.value.minute_metrics]

        content {
          enabled               = minute_metrics.value.enabled
          include_apis          = try(minute_metrics.value.include_apis, null)
          retention_policy_days = try(minute_metrics.value.retention_policy_days, null)
          version               = minute_metrics.value.version
        }
      }
    }
  }

  dynamic "routing" {
    for_each = var.routing == null ? [] : [var.routing]

    content {
      choice                      = routing.value.choice
      publish_internet_endpoints  = routing.value.publish_internet_endpoints
      publish_microsoft_endpoints = routing.value.publish_microsoft_endpoints
    }
  }

  dynamic "sas_policy" {
    for_each = var.sas_policy == null ? [] : [var.sas_policy]

    content {
      expiration_action = sas_policy.value.expiration_action
      expiration_period = sas_policy.value.expiration_period
    }
  }

  dynamic "share_properties" {
    for_each = var.share_properties == null ? [] : [var.share_properties]

    content {
      dynamic "cors_rule" {
        for_each = try(share_properties.value.cors_rules, [])

        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }

      dynamic "retention_policy" {
        for_each = try(share_properties.value.retention_policy_days, null) == null ? [] : [share_properties.value.retention_policy_days]

        content {
          days = retention_policy.value
        }
      }

      dynamic "smb" {
        for_each = try(share_properties.value.smb, null) == null ? [] : [share_properties.value.smb]

        content {
          authentication_types            = try(smb.value.authentication_types, null)
          channel_encryption_type         = try(smb.value.channel_encryption_type, null)
          kerberos_ticket_encryption_type = try(smb.value.kerberos_ticket_encryption_type, null)
          multichannel_enabled            = try(smb.value.multichannel_enabled, null)
          versions                        = try(smb.value.versions, null)
        }
      }
    }
  }

  dynamic "static_website" {
    for_each = var.static_website == null ? [] : [var.static_website]

    content {
      error_404_document = try(static_website.value.error_404_document, null)
      index_document     = try(static_website.value.index_document, null)
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

  tags = local.tags

  lifecycle {
    precondition {
      condition     = var.system_managed_identity_enabled || length(var.managed_identity_role_assignments) == 0
      error_message = "managed_identity_role_assignments requires system_managed_identity_enabled = true."
    }

    precondition {
      condition = var.customer_managed_key == null ? true : (
        local.identity_type != "" &&
        (
          try(trimspace(var.customer_managed_key.user_assigned_identity_id), "") == "" ||
          contains(local.identity_ids, var.customer_managed_key.user_assigned_identity_id)
        )
      )
      error_message = "customer_managed_key requires a managed identity. If user_assigned_identity_id is set, it must also be present in identity_ids."
    }
  }
}

resource "azurerm_storage_account_network_rules" "this" {
  count = var.enable_network_rules ? 1 : 0

  storage_account_id         = azurerm_storage_account.this.id
  default_action             = var.network_rules_default_action
  bypass                     = var.network_rules_bypass
  ip_rules                   = var.network_rules_ip_rules
  virtual_network_subnet_ids = var.network_rules_virtual_network_subnet_ids

  dynamic "private_link_access" {
    for_each = var.network_rules_private_link_access

    content {
      endpoint_resource_id = private_link_access.value.endpoint_resource_id
      endpoint_tenant_id   = try(private_link_access.value.endpoint_tenant_id, null)
    }
  }
}

resource "azurerm_storage_container" "this" {
  for_each = var.containers

  name                              = each.key
  storage_account_id                = azurerm_storage_account.this.id
  container_access_type             = each.value.container_access_type
  default_encryption_scope          = try(each.value.default_encryption_scope, null)
  encryption_scope_override_enabled = try(each.value.encryption_scope_override_enabled, null)
  metadata                          = try(each.value.metadata, {})
}

resource "azurerm_storage_share" "this" {
  for_each = var.file_shares

  name               = each.key
  storage_account_id = azurerm_storage_account.this.id
  quota              = each.value.quota
  access_tier        = try(each.value.access_tier, null)
  enabled_protocol   = each.value.enabled_protocol
  metadata           = try(each.value.metadata, {})
}

resource "azurerm_storage_queue" "this" {
  for_each = var.queues

  name                 = each.key
  storage_account_name = azurerm_storage_account.this.name
  metadata             = try(each.value.metadata, {})
}

resource "azurerm_storage_table" "this" {
  for_each = var.tables

  name                 = each.key
  storage_account_name = azurerm_storage_account.this.name
}

resource "azurerm_role_assignment" "managed_identity" {
  for_each = local.managed_identity_role_assignments_effective

  scope                = each.value.scope
  role_definition_name = try(each.value.role_definition_name, null)
  role_definition_id   = try(each.value.role_definition_id, null)
  principal_id         = azurerm_storage_account.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = local.app_admin_group_principal_ids

  scope                = azurerm_storage_account.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = local.app_user_group_principal_ids

  scope                = azurerm_storage_account.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "terraform_execution_identity" {
  for_each = local.terraform_execution_identity_role_assignments

  scope                = azurerm_storage_account.this.id
  role_definition_name = each.value
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                                  = azurerm_storage_account.this.id
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
  for_each = local.create_private_endpoints ? local.private_endpoint_subresources : toset([])

  name                = "${var.private_endpoint_name_prefix}-${azurerm_storage_account.this.name}-${each.key}"
  location            = azurerm_storage_account.this.location
  resource_group_name = local.resource_group_name
  subnet_id           = local.private_endpoint_subnet_id_resolved

  private_service_connection {
    name                           = "${var.private_service_connection_name_prefix}-${azurerm_storage_account.this.name}-${each.key}"
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = [each.key]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = lookup(local.private_dns_zone_ids_resolved, each.key, "") != "" ? [1] : []

    content {
      name                 = "default"
      private_dns_zone_ids = [local.private_dns_zone_ids_resolved[each.key]]
    }
  }

  tags = local.tags
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = local.diagnostics_enabled ? 1 : 0

  name                           = local.diagnostic_setting_name
  target_resource_id             = azurerm_storage_account.this.id
  log_analytics_workspace_id     = trimspace(var.log_analytics_workspace_id) != "" ? var.log_analytics_workspace_id : null
  log_analytics_destination_type = trimspace(var.log_analytics_workspace_id) != "" ? var.log_analytics_destination_type : null
  storage_account_id             = try(trimspace(var.diagnostic_storage_account_id), "") != "" ? var.diagnostic_storage_account_id : null
  eventhub_authorization_rule_id = try(trimspace(var.diagnostic_eventhub_authorization_rule_id), "") != "" ? var.diagnostic_eventhub_authorization_rule_id : null
  eventhub_name                  = try(trimspace(var.diagnostic_eventhub_name), "") != "" ? var.diagnostic_eventhub_name : null

  dynamic "enabled_log" {
    for_each = toset(var.diagnostic_log_categories)

    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = toset(var.diagnostic_metric_categories)

    content {
      category = enabled_metric.value
    }
  }
}
