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

resource "azurerm_cognitive_account" "this" {
  name                                         = local.account_name
  resource_group_name                          = data.azurerm_resource_group.rg.name
  location                                     = local.location
  kind                                         = "OpenAI"
  sku_name                                     = var.sku_name
  custom_subdomain_name                        = trimspace(var.custom_subdomain_name) != "" ? var.custom_subdomain_name : null
  public_network_access_enabled                = var.public_network_access_enabled
  outbound_network_access_restricted           = var.outbound_network_access_restricted
  local_auth_enabled                           = var.local_auth_enabled
  dynamic_throttling_enabled                   = var.dynamic_throttling_enabled
  custom_question_answering_search_service_id  = trimspace(var.custom_question_answering_search_service_id) != "" ? var.custom_question_answering_search_service_id : null
  custom_question_answering_search_service_key = trimspace(var.custom_question_answering_search_service_key) != "" ? var.custom_question_answering_search_service_key : null
  tags                                         = local.merged_tags

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []

    content {
      type         = identity.value.type
      identity_ids = try(identity.value.identity_ids, null)
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
        for_each = try(network_acls.value.virtual_network_rules, [])

        content {
          subnet_id                            = virtual_network_rules.value.subnet_id
          ignore_missing_vnet_service_endpoint = try(virtual_network_rules.value.ignore_missing_vnet_service_endpoint, null)
        }
      }
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
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = merge(
    { for object_id in local.app_admin_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_admin : "name:${name}" => group.object_id }
  )

  scope                = azurerm_cognitive_account.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = merge(
    { for object_id in local.app_user_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_user : "name:${name}" => group.object_id }
  )

  scope                = azurerm_cognitive_account.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

resource "azurerm_private_endpoint" "this" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = "pep-${azurerm_cognitive_account.this.name}"
  location            = local.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = local.private_endpoint_subnet_id_resolved

  private_service_connection {
    name                           = "psc-${azurerm_cognitive_account.this.name}"
    private_connection_resource_id = azurerm_cognitive_account.this.id
    subresource_names              = ["account"]
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

  name                       = "${azurerm_cognitive_account.this.name}-diagnostic-setting"
  target_resource_id         = azurerm_cognitive_account.this.id
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
