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

data "azurerm_private_dns_zone" "openai" {
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

resource "azurerm_cognitive_account" "this" {
  name                                         = local.account_name
  resource_group_name                          = local.resource_group_name
  location                                     = local.location
  kind                                         = "OpenAI"
  sku_name                                     = var.sku_name
  custom_subdomain_name                        = local.custom_subdomain_name
  public_network_access_enabled                = var.public_network_access_enabled
  outbound_network_access_restricted           = var.outbound_network_access_restricted
  local_auth_enabled                           = var.local_auth_enabled
  dynamic_throttling_enabled                   = var.dynamic_throttling_enabled ? true : null
  fqdns                                        = length(var.fqdns) > 0 ? var.fqdns : null
  custom_question_answering_search_service_id  = trimspace(var.custom_question_answering_search_service_id) != "" ? trimspace(var.custom_question_answering_search_service_id) : null
  custom_question_answering_search_service_key = trimspace(var.custom_question_answering_search_service_key) != "" ? trimspace(var.custom_question_answering_search_service_key) : null
  tags                                         = local.merged_tags

  dynamic "identity" {
    for_each = local.identity_enabled ? [1] : []

    content {
      type         = local.identity_type
      identity_ids = length(local.identity_ids) > 0 ? local.identity_ids : null
    }
  }

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key != null ? [var.customer_managed_key] : []

    content {
      key_vault_key_id   = customer_managed_key.value.key_vault_key_id
      identity_client_id = try(customer_managed_key.value.identity_client_id, null)
    }
  }

  dynamic "network_acls" {
    for_each = var.network_acls != null ? [var.network_acls] : []

    content {
      default_action = network_acls.value.default_action
      bypass         = try(network_acls.value.bypass, null)
      ip_rules       = try(network_acls.value.ip_rules, null)

      dynamic "virtual_network_rules" {
        for_each = coalesce(try(network_acls.value.virtual_network_rules, null), [])

        content {
          subnet_id                            = virtual_network_rules.value.subnet_id
          ignore_missing_vnet_service_endpoint = try(virtual_network_rules.value.ignore_missing_vnet_service_endpoint, null)
        }
      }
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

resource "azurerm_cognitive_deployment" "this" {
  for_each = var.deployments

  name                       = each.key
  cognitive_account_id       = azurerm_cognitive_account.this.id
  dynamic_throttling_enabled = try(each.value.dynamic_throttling_enabled, null)
  rai_policy_name            = try(each.value.rai_policy_name, null)
  version_upgrade_option     = try(each.value.version_upgrade_option, null)

  model {
    format  = each.value.model_format
    name    = each.value.model_name
    version = try(each.value.model_version, null)
  }

  sku {
    name     = each.value.sku_name
    capacity = try(each.value.sku_capacity, null)
    family   = try(each.value.sku_family, null)
    size     = try(each.value.sku_size, null)
    tier     = try(each.value.sku_tier, null)
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

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = local.app_admin_group_principal_ids

  scope                = azurerm_cognitive_account.this.id
  role_definition_name = var.app_admin_role_definition_name
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = local.app_user_group_principal_ids

  scope                = azurerm_cognitive_account.this.id
  role_definition_name = var.app_user_role_definition_name
  principal_id         = each.value
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                                  = azurerm_cognitive_account.this.id
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
    private_connection_resource_id = azurerm_cognitive_account.this.id
    subresource_names              = ["account"]
    is_manual_connection           = var.private_endpoint_manual_connection
    request_message                = local.private_endpoint_manual_request_message
  }

  dynamic "ip_configuration" {
    for_each = var.private_endpoint_ip_configurations

    content {
      member_name        = try(ip_configuration.value.member_name, "account")
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      subresource_name   = try(ip_configuration.value.subresource_name, "account")
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

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = local.diagnostics_enabled ? 1 : 0

  name                           = local.diagnostic_setting_name
  target_resource_id             = azurerm_cognitive_account.this.id
  log_analytics_workspace_id     = trimspace(var.log_analytics_workspace_id) != "" ? var.log_analytics_workspace_id : null
  log_analytics_destination_type = var.log_analytics_destination_type
  storage_account_id             = trimspace(var.diagnostic_storage_account_id) != "" ? var.diagnostic_storage_account_id : null
  eventhub_authorization_rule_id = trimspace(var.diagnostic_eventhub_authorization_rule_id) != "" ? var.diagnostic_eventhub_authorization_rule_id : null
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
