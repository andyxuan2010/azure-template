resource "azurerm_log_analytics_workspace" "this" {
  name                                    = var.name
  resource_group_name                     = var.resource_group_name
  location                                = var.location
  sku                                     = var.sku
  retention_in_days                       = var.retention_in_days
  daily_quota_gb                          = var.daily_quota_gb
  internet_ingestion_enabled              = var.internet_ingestion_enabled
  internet_query_enabled                  = var.internet_query_enabled
  local_authentication_enabled            = !var.local_authentication_disabled
  reservation_capacity_in_gb_per_day      = var.reservation_capacity_in_gb_per_day
  allow_resource_only_permissions         = var.allow_resource_only_permissions
  cmk_for_query_forced                    = var.cmk_for_query_forced
  data_collection_rule_id                 = var.data_collection_rule_id
  immediate_data_purge_on_30_days_enabled = var.immediate_data_purge_on_30_days_enabled
  tags                                    = local.merged_tags

  dynamic "identity" {
    for_each = var.identity == null ? [] : [var.identity]

    content {
      type         = identity.value.type
      identity_ids = try(identity.value.identity_ids, null)
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
