data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_subnet" "private_endpoint" {
  count = var.enable_private_endpoint && var.private_endpoint_subnet_id == "" ? 1 : 0

  name                 = var.private_endpoint_subnet_name
  virtual_network_name = var.private_endpoint_vnet_name
  resource_group_name  = var.private_endpoint_network_resource_group_name
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
  count       = var.name == "" ? 1 : 0
  length      = 8
  special     = false
  upper       = false
  min_numeric = 2
}

resource "azurerm_servicebus_namespace" "this" {
  name                          = local.namespace_name
  location                      = local.location
  resource_group_name           = data.azurerm_resource_group.rg.name
  sku                           = var.sku
  capacity                      = var.sku == "Premium" ? var.capacity : null
  premium_messaging_partitions  = var.sku == "Premium" ? var.premium_messaging_partitions : null
  local_auth_enabled            = var.local_auth_enabled
  public_network_access_enabled = var.public_network_access_enabled
  minimum_tls_version           = var.minimum_tls_version

  dynamic "identity" {
    for_each = var.system_managed_identity_enabled ? [1] : []

    content {
      type = "SystemAssigned"
    }
  }

  dynamic "network_rule_set" {
    for_each = var.enable_network_rule_set ? [1] : []

    content {
      default_action                = var.network_rule_default_action
      ip_rules                      = toset(var.network_rule_ip_rules)
      public_network_access_enabled = var.public_network_access_enabled
      trusted_services_allowed      = var.trusted_services_allowed

      dynamic "network_rules" {
        for_each = var.network_rules

        content {
          subnet_id                            = network_rules.value.subnet_id
          ignore_missing_vnet_service_endpoint = try(network_rules.value.ignore_missing_vnet_service_endpoint, false)
        }
      }
    }
  }

  tags = local.merged_tags
}

resource "azurerm_servicebus_queue" "this" {
  for_each = var.queues

  name                                    = each.key
  namespace_id                            = azurerm_servicebus_namespace.this.id
  max_size_in_megabytes                   = each.value.max_size_in_megabytes
  max_delivery_count                      = each.value.max_delivery_count
  lock_duration                           = each.value.lock_duration
  default_message_ttl                     = each.value.default_message_ttl
  auto_delete_on_idle                     = try(each.value.auto_delete_on_idle, null)
  dead_lettering_on_message_expiration    = each.value.dead_lettering_on_message_expiration
  duplicate_detection_history_time_window = try(each.value.duplicate_detection_history_time_window, null)
  requires_duplicate_detection            = each.value.requires_duplicate_detection
  requires_session                        = each.value.requires_session
  partitioning_enabled                    = each.value.partitioning_enabled
  express_enabled                         = each.value.express_enabled
  batched_operations_enabled              = each.value.batched_operations_enabled
  status                                  = each.value.status
  forward_to                              = try(each.value.forward_to, null)
  forward_dead_lettered_messages_to       = try(each.value.forward_dead_lettered_messages_to, null)
}

resource "azurerm_servicebus_topic" "this" {
  for_each = var.topics

  name                                    = each.key
  namespace_id                            = azurerm_servicebus_namespace.this.id
  max_size_in_megabytes                   = each.value.max_size_in_megabytes
  default_message_ttl                     = each.value.default_message_ttl
  auto_delete_on_idle                     = try(each.value.auto_delete_on_idle, null)
  duplicate_detection_history_time_window = try(each.value.duplicate_detection_history_time_window, null)
  requires_duplicate_detection            = each.value.requires_duplicate_detection
  partitioning_enabled                    = each.value.partitioning_enabled
  express_enabled                         = each.value.express_enabled
  batched_operations_enabled              = each.value.batched_operations_enabled
  support_ordering                        = each.value.support_ordering
  status                                  = each.value.status
}

resource "azurerm_servicebus_subscription" "this" {
  for_each = {
    for name, subscription in var.subscriptions :
    name => subscription
    if contains(keys(var.topics), subscription.topic_name)
  }

  name                                      = each.key
  topic_id                                  = azurerm_servicebus_topic.this[each.value.topic_name].id
  max_delivery_count                        = each.value.max_delivery_count
  lock_duration                             = each.value.lock_duration
  default_message_ttl                       = each.value.default_message_ttl
  auto_delete_on_idle                       = try(each.value.auto_delete_on_idle, null)
  dead_lettering_on_message_expiration      = each.value.dead_lettering_on_message_expiration
  dead_lettering_on_filter_evaluation_error = each.value.dead_lettering_on_filter_evaluation_error
  requires_session                          = each.value.requires_session
  batched_operations_enabled                = each.value.batched_operations_enabled
  status                                    = each.value.status
  forward_to                                = try(each.value.forward_to, null)
  forward_dead_lettered_messages_to         = try(each.value.forward_dead_lettered_messages_to, null)
  client_scoped_subscription_enabled        = each.value.client_scoped_subscription_enabled
}

resource "azurerm_servicebus_namespace_authorization_rule" "this" {
  for_each = var.authorization_rules

  name         = each.key
  namespace_id = azurerm_servicebus_namespace.this.id
  listen       = each.value.listen
  send         = each.value.send
  manage       = each.value.manage
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = merge(
    { for object_id in local.app_admin_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_admin : "name:${name}" => group.object_id }
  )

  scope                = azurerm_servicebus_namespace.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = merge(
    { for object_id in local.app_user_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_user : "name:${name}" => group.object_id }
  )

  scope                = azurerm_servicebus_namespace.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

resource "azurerm_private_endpoint" "this" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = "pep-${azurerm_servicebus_namespace.this.name}"
  location            = local.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = local.private_endpoint_subnet_id_resolved

  private_service_connection {
    name                           = "psc-${azurerm_servicebus_namespace.this.name}"
    private_connection_resource_id = azurerm_servicebus_namespace.this.id
    subresource_names              = ["namespace"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_id != "" ? [1] : []

    content {
      name                 = "default"
      private_dns_zone_ids = [var.private_dns_zone_id]
    }
  }

  tags = local.merged_tags
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostics ? 1 : 0

  name                       = "${azurerm_servicebus_namespace.this.name}-diagnostic-setting"
  target_resource_id         = azurerm_servicebus_namespace.this.id
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
