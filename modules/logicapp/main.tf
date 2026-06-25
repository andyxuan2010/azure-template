data "azurerm_resource_group" "rg" {
  count = local.resource_group_lookup_required ? 1 : 0

  name = var.resource_group_name
}

data "azurerm_storage_account" "logicapp" {
  name                = var.storage_account_name
  resource_group_name = local.storage_account_resource_group_name
}

data "azurerm_subnet" "vnet_integration" {
  count = local.vnet_integration_lookup_by_name ? 1 : 0

  name                 = var.vnet_integration_subnet_name
  virtual_network_name = var.vnet_integration_vnet_name
  resource_group_name  = var.vnet_integration_network_resource_group_name
}

data "azurerm_subnet" "private_endpoint" {
  count = local.private_endpoint_subnet_lookup_by_name ? 1 : 0

  name                 = var.private_endpoint_subnet_name
  virtual_network_name = var.private_endpoint_vnet_name
  resource_group_name  = var.private_endpoint_network_resource_group_name
}

data "azurerm_private_dns_zone" "logicapp" {
  count = local.private_dns_zone_lookup_by_name ? 1 : 0

  name                = var.private_dns_zone_name
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

resource "azurerm_logic_app_standard" "this" {
  name                                     = var.name
  location                                 = local.location
  resource_group_name                      = var.resource_group_name
  app_service_plan_id                      = var.service_plan_id
  storage_account_name                     = data.azurerm_storage_account.logicapp.name
  storage_account_access_key               = data.azurerm_storage_account.logicapp.primary_access_key
  storage_account_share_name               = try(trimspace(var.storage_account_share_name), "") != "" ? trimspace(var.storage_account_share_name) : null
  app_settings                             = var.app_settings
  enabled                                  = var.enabled
  https_only                               = var.https_only
  public_network_access                    = local.public_network_access
  client_affinity_enabled                  = var.client_affinity_enabled
  client_certificate_mode                  = var.client_certificate_mode
  ftp_publish_basic_authentication_enabled = var.ftp_publish_basic_authentication_enabled
  scm_publish_basic_authentication_enabled = var.scm_basic_auth_publishing_credentials_enabled
  use_extension_bundle                     = var.use_extension_bundle
  bundle_version                           = var.bundle_version
  version                                  = var.logic_app_version
  virtual_network_subnet_id                = local.vnet_integration_subnet_id_resolved != "" ? local.vnet_integration_subnet_id_resolved : null
  vnet_content_share_enabled               = local.vnet_integration_subnet_id_resolved != ""
  tags                                     = local.merged_tags

  dynamic "connection_string" {
    for_each = var.connection_strings

    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  site_config {
    always_on                        = var.always_on
    ftps_state                       = var.ftps_state
    health_check_path                = var.health_check_path
    http2_enabled                    = var.http2_enabled
    min_tls_version                  = var.minimum_tls_version
    runtime_scale_monitoring_enabled = var.runtime_scale_monitoring_enabled
    use_32_bit_worker_process        = var.use_32_bit_worker_process
    vnet_route_all_enabled           = var.vnet_route_all_enabled
    websockets_enabled               = var.websockets_enabled
  }

  dynamic "identity" {
    for_each = local.identity_type != "" ? [1] : []

    content {
      type         = local.identity_type
      identity_ids = length(local.identity_ids) > 0 ? local.identity_ids : null
    }
  }

  lifecycle {
    ignore_changes = [
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"]
    ]
  }
}

check "logicapp_input_consistency" {
  assert {
    condition     = !var.vnet_route_all_enabled || local.vnet_integration_subnet_id_resolved != ""
    error_message = "vnet_route_all_enabled requires VNet integration."
  }

  assert {
    condition     = var.use_extension_bundle != false || try(trimspace(var.bundle_version), "") == ""
    error_message = "bundle_version cannot be set when use_extension_bundle is false."
  }

  assert {
    condition     = !var.enable_private_endpoint || local.private_endpoint_subnet_id_resolved != ""
    error_message = "enable_private_endpoint requires a resolvable private endpoint subnet."
  }
}

resource "azurerm_private_endpoint" "this" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = "pep-${var.name}-sites"
  location            = local.location
  resource_group_name = var.resource_group_name
  subnet_id           = local.private_endpoint_subnet_id_resolved

  private_service_connection {
    name                           = "psc-${var.name}-sites"
    private_connection_resource_id = azurerm_logic_app_standard.this.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = local.private_dns_zone_id_resolved != "" ? [1] : []

    content {
      name                 = "default"
      private_dns_zone_ids = [local.private_dns_zone_id_resolved]
    }
  }

  tags = local.merged_tags
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostics ? 1 : 0

  name                       = "${var.name}-diagnostic-setting"
  target_resource_id         = azurerm_logic_app_standard.this.id
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

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = merge(
    { for object_id in local.app_admin_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_admin : "name:${name}" => group.object_id }
  )

  scope                = azurerm_logic_app_standard.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = merge(
    { for object_id in local.app_user_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_user : "name:${name}" => group.object_id }
  )

  scope                = azurerm_logic_app_standard.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}
