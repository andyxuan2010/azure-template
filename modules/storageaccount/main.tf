# Data sources
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_subnet" "pep" {
  count    = local.create_private_endpoints && trimspace(var.private_endpoint_subnet_id) == "" ? 1 : 0
  provider = azurerm.prod

  name                 = var.private_endpoint_subnet_name
  virtual_network_name = var.private_endpoint_vnet_name
  resource_group_name  = var.private_endpoint_network_resource_group_name
}

data "azurerm_private_dns_zone" "this" {
  for_each = local.private_dns_zone_names_effective
  provider = azurerm.prod

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
  count       = trimspace(var.name) == "" ? 1 : 0
  length      = 4
  special     = false
  upper       = false
  min_numeric = 1
}

resource "azurerm_storage_account" "this" {
  name                              = local.storage_account_name
  resource_group_name               = data.azurerm_resource_group.rg.name
  location                          = local.location
  account_tier                      = var.account_tier
  account_replication_type          = var.account_replication_type
  account_kind                      = var.account_kind
  access_tier                       = local.access_tier_effective
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

  dynamic "identity" {
    for_each = var.system_managed_identity_enabled ? [1] : []

    content {
      type = "SystemAssigned"
    }
  }

  dynamic "blob_properties" {
    for_each = var.blob_properties == null ? [] : [var.blob_properties]

    content {
      versioning_enabled       = try(blob_properties.value.versioning_enabled, null)
      change_feed_enabled      = try(blob_properties.value.change_feed_enabled, null)
      last_access_time_enabled = try(blob_properties.value.last_access_time_enabled, null)

      dynamic "delete_retention_policy" {
        for_each = try(blob_properties.value.delete_retention_policy_days, null) == null ? [] : [blob_properties.value.delete_retention_policy_days]

        content {
          days = delete_retention_policy.value
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
    }
  }

  tags = local.tags

  lifecycle {
    precondition {
      condition     = var.system_managed_identity_enabled || length(var.managed_identity_role_assignments) == 0
      error_message = "managed_identity_role_assignments requires system_managed_identity_enabled = true."
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
}

resource "azurerm_role_assignment" "managed_identity" {
  for_each = local.managed_identity_role_assignments_effective

  scope                = each.value.scope
  role_definition_name = try(each.value.role_definition_name, null)
  role_definition_id   = try(each.value.role_definition_id, null)
  principal_id         = azurerm_storage_account.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = merge(
    { for object_id in local.app_admin_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_admin : "name:${name}" => group.object_id }
  )

  scope                = azurerm_storage_account.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = merge(
    { for object_id in local.app_user_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_user : "name:${name}" => group.object_id }
  )

  scope                = azurerm_storage_account.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

resource "azurerm_private_endpoint" "this" {
  for_each = local.create_private_endpoints ? local.private_endpoint_subresources : toset([])

  name                = "pep-${azurerm_storage_account.this.name}-${each.key}"
  location            = azurerm_storage_account.this.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = local.private_endpoint_subnet_id_resolved

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.this.name}-${each.key}"
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
  count = var.enable_diagnostics ? 1 : 0

  name                       = "${azurerm_storage_account.this.name}-diagnostic-setting"
  target_resource_id         = azurerm_storage_account.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

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
