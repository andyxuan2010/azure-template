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

resource "azurerm_cognitive_account" "this" {
  name                                         = local.account_name
  resource_group_name                          = local.resource_group_name
  location                                     = local.location
  kind                                         = var.kind
  sku_name                                     = var.sku_name
  custom_subdomain_name                        = local.custom_subdomain_name
  public_network_access_enabled                = var.public_network_access_enabled
  outbound_network_access_restricted           = var.outbound_network_access_restricted
  local_auth_enabled                           = var.local_auth_enabled
  dynamic_throttling_enabled                   = contains(["OpenAI", "AIServices"], var.kind) ? null : var.dynamic_throttling_enabled
  fqdns                                        = length(var.fqdns) > 0 ? var.fqdns : null
  project_management_enabled                   = var.project_management_enabled
  qna_runtime_endpoint                         = trimspace(var.qna_runtime_endpoint) != "" ? var.qna_runtime_endpoint : null
  custom_question_answering_search_service_id  = var.custom_question_answering == null ? null : var.custom_question_answering.search_service_id
  custom_question_answering_search_service_key = var.custom_question_answering == null ? null : var.custom_question_answering.search_service_key
  metrics_advisor_aad_client_id                = var.metrics_advisor == null ? null : var.metrics_advisor.aad_client_id
  metrics_advisor_aad_tenant_id                = var.metrics_advisor == null ? null : var.metrics_advisor.aad_tenant_id
  metrics_advisor_super_user_name              = var.metrics_advisor == null ? null : var.metrics_advisor.super_user_name
  metrics_advisor_website_name                 = var.metrics_advisor == null ? null : var.metrics_advisor.website_name
  tags                                         = local.merged_tags

  dynamic "identity" {
    for_each = local.identity_type != "" ? [1] : []

    content {
      type         = local.identity_type
      identity_ids = local.identity_ids
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

  dynamic "network_injection" {
    for_each = var.network_injection == null ? [] : [var.network_injection]

    content {
      scenario  = network_injection.value.scenario
      subnet_id = network_injection.value.subnet_id
    }
  }

  dynamic "storage" {
    for_each = var.storage

    content {
      storage_account_id = storage.value.storage_account_id
      identity_client_id = try(storage.value.identity_client_id, null)
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
      condition     = var.customer_managed_key == null || local.identity_type != ""
      error_message = "customer_managed_key requires identity, system_managed_identity_enabled, or identity_ids to be configured."
    }

    precondition {
      condition     = var.network_acls == null || local.custom_subdomain_name != null
      error_message = "network_acls requires custom_subdomain_name. The module auto-generates it when not explicitly set."
    }

    precondition {
      condition     = var.network_injection == null || var.kind == "AIServices"
      error_message = "network_injection is only supported when kind = AIServices."
    }
  }
}

resource "azurerm_cognitive_account_rai_policy" "this" {
  for_each = var.rai_policies

  name                 = each.value.name
  cognitive_account_id = azurerm_cognitive_account.this.id
  base_policy_name     = each.value.base_policy_name
  mode                 = try(each.value.mode, null)
  tags                 = merge(local.merged_tags, try(each.value.tags, {}))

  dynamic "content_filter" {
    for_each = each.value.content_filters

    content {
      name               = content_filter.value.name
      filter_enabled     = content_filter.value.filter_enabled
      block_enabled      = content_filter.value.block_enabled
      severity_threshold = content_filter.value.severity_threshold
      source             = content_filter.value.source
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
}

resource "azurerm_cognitive_deployment" "this" {
  for_each = var.deployments

  name                       = each.value.name
  cognitive_account_id       = azurerm_cognitive_account.this.id
  dynamic_throttling_enabled = try(each.value.dynamic_throttling_enabled, null)
  rai_policy_name            = try(each.value.rai_policy_name, null)
  version_upgrade_option     = try(each.value.version_upgrade_option, null)

  model {
    format  = each.value.model.format
    name    = each.value.model.name
    version = try(each.value.model.version, null)
  }

  sku {
    name     = each.value.sku.name
    tier     = try(each.value.sku.tier, null)
    size     = try(each.value.sku.size, null)
    family   = try(each.value.sku.family, null)
    capacity = try(each.value.sku.capacity, null)
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

  depends_on = [azurerm_cognitive_account_rai_policy.this]
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = local.app_admin_group_principal_ids

  scope                = azurerm_cognitive_account.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = local.app_user_group_principal_ids

  scope                = azurerm_cognitive_account.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                                  = azurerm_cognitive_account.this.id
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

  name                          = "${var.private_endpoint_name_prefix}-${azurerm_cognitive_account.this.name}"
  location                      = local.location
  resource_group_name           = local.resource_group_name
  subnet_id                     = local.private_endpoint_subnet_id_resolved
  custom_network_interface_name = trimspace(var.private_endpoint_network_interface_name) != "" ? var.private_endpoint_network_interface_name : null

  private_service_connection {
    name                           = "${var.private_service_connection_name_prefix}-${azurerm_cognitive_account.this.name}"
    private_connection_resource_id = azurerm_cognitive_account.this.id
    subresource_names              = ["account"]
    is_manual_connection           = var.private_endpoint_manual_connection_enabled
    request_message                = var.private_endpoint_manual_connection_enabled && trimspace(var.private_endpoint_request_message) != "" ? var.private_endpoint_request_message : null
  }

  dynamic "ip_configuration" {
    for_each = var.private_endpoint_ip_configurations

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      subresource_name   = try(ip_configuration.value.subresource_name, "account")
      member_name        = try(ip_configuration.value.member_name, "account")
    }
  }

  dynamic "private_dns_zone_group" {
    for_each = length(local.private_dns_zone_ids) > 0 ? [1] : []

    content {
      name                 = "default"
      private_dns_zone_ids = local.private_dns_zone_ids
    }
  }

  tags = local.merged_tags
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = local.diagnostics_enabled ? 1 : 0

  name                           = local.diagnostic_setting_name
  target_resource_id             = azurerm_cognitive_account.this.id
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
}
