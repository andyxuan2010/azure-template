data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_subnet" "private_endpoint" {
  count = var.enable_private_endpoint && trimspace(var.private_endpoint_subnet_id) == "" ? 1 : 0

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
  count       = trimspace(var.name) == "" ? 1 : 0
  length      = 8
  special     = false
  upper       = false
  min_numeric = 2
}

resource "azurerm_search_service" "this" {
  name                                     = local.service_name
  resource_group_name                      = data.azurerm_resource_group.rg.name
  location                                 = local.location
  sku                                      = lower(trimspace(var.sku))
  replica_count                            = lower(trimspace(var.sku)) == "free" ? null : var.replica_count
  partition_count                          = lower(trimspace(var.sku)) == "free" ? null : var.partition_count
  hosting_mode                             = trimspace(var.hosting_mode)
  semantic_search_sku                      = trimspace(var.semantic_search_sku) != "" ? lower(trimspace(var.semantic_search_sku)) : null
  public_network_access_enabled            = var.public_network_access_enabled
  allowed_ips                              = length(var.allowed_ips) > 0 ? toset(var.allowed_ips) : null
  network_rule_bypass_option               = trimspace(var.network_rule_bypass_option)
  local_authentication_enabled             = var.local_authentication_enabled
  authentication_failure_mode              = trimspace(var.authentication_failure_mode) != "" ? trimspace(var.authentication_failure_mode) : null
  customer_managed_key_enforcement_enabled = var.customer_managed_key_enforcement_enabled
  tags                                     = local.merged_tags

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []

    content {
      type         = identity.value.type
      identity_ids = try(identity.value.identity_ids, null)
    }
  }

  lifecycle {
    precondition {
      condition     = lower(trimspace(var.sku)) != "free" || (!var.enable_private_endpoint && length(var.allowed_ips) == 0 && trimspace(var.semantic_search_sku) == "")
      error_message = "The free SKU does not support private endpoints, IP firewall rules, or semantic_search_sku."
    }

    precondition {
      condition     = trimspace(var.authentication_failure_mode) == "" || var.local_authentication_enabled
      error_message = "authentication_failure_mode can only be set when local_authentication_enabled is true."
    }

    precondition {
      condition     = trimspace(var.hosting_mode) != "highDensity" || lower(trimspace(var.sku)) == "standard3"
      error_message = "hosting_mode highDensity requires sku standard3."
    }
  }
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = merge(
    { for object_id in local.app_admin_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_admin : "name:${name}" => group.object_id }
  )

  scope                = azurerm_search_service.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = merge(
    { for object_id in local.app_user_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_user : "name:${name}" => group.object_id }
  )

  scope                = azurerm_search_service.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

resource "azurerm_private_endpoint" "this" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = "pep-${azurerm_search_service.this.name}"
  location            = local.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = local.private_endpoint_subnet_id_resolved

  private_service_connection {
    name                           = "psc-${azurerm_search_service.this.name}"
    private_connection_resource_id = azurerm_search_service.this.id
    subresource_names              = ["searchService"]
    is_manual_connection           = false
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
  count = var.enable_diagnostics ? 1 : 0

  name                       = "${azurerm_search_service.this.name}-diagnostic-setting"
  target_resource_id         = azurerm_search_service.this.id
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
