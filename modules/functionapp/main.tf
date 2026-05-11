data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_storage_account" "function" {
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

data "azurerm_private_dns_zone" "functionapp" {
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

resource "azurerm_linux_function_app" "key" {
  count = local.is_windows || var.storage_uses_managed_identity ? 0 : 1

  name                            = var.name
  location                        = local.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  service_plan_id                 = var.service_plan_id
  storage_account_name            = data.azurerm_storage_account.function.name
  storage_account_access_key      = data.azurerm_storage_account.function.primary_access_key
  functions_extension_version     = var.functions_extension_version
  builtin_logging_enabled         = var.builtin_logging_enabled
  https_only                      = var.https_only
  public_network_access_enabled   = var.public_network_access_enabled
  virtual_network_subnet_id       = local.vnet_integration_subnet_id_resolved != "" ? local.vnet_integration_subnet_id_resolved : null
  key_vault_reference_identity_id = local.key_vault_reference_identity_id_resolved
  app_settings                    = var.app_settings
  daily_memory_time_quota         = var.daily_memory_time_quota
  zip_deploy_file                 = var.zip_deploy_file
  tags                            = local.merged_tags

  dynamic "connection_string" {
    for_each = var.connection_strings

    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  site_config {
    always_on                         = var.always_on
    ftps_state                        = var.ftps_state
    http2_enabled                     = var.http2_enabled
    minimum_tls_version               = var.minimum_tls_version
    use_32_bit_worker                 = var.use_32_bit_worker
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = var.health_check_eviction_time_in_min
    runtime_scale_monitoring_enabled  = var.runtime_scale_monitoring_enabled
    vnet_route_all_enabled            = var.vnet_route_all_enabled

    dynamic "application_stack" {
      for_each = var.application_stack == null ? [] : [var.application_stack]

      content {
        dotnet_version              = try(application_stack.value.dotnet_version, null)
        java_version                = try(application_stack.value.java_version, null)
        node_version                = try(application_stack.value.node_version, null)
        powershell_core_version     = try(application_stack.value.powershell_core_version, null)
        python_version              = try(application_stack.value.python_version, null)
        use_custom_runtime          = try(application_stack.value.use_custom_runtime, null)
        use_dotnet_isolated_runtime = try(application_stack.value.use_dotnet_isolated_runtime, null)
      }
    }
  }

  dynamic "identity" {
    for_each = local.identity_type != "" ? [1] : []

    content {
      type         = local.identity_type
      identity_ids = local.identity_ids
    }
  }

  dynamic "sticky_settings" {
    for_each = length(var.sticky_settings_app_setting_names) > 0 || length(var.sticky_settings_connection_string_names) > 0 ? [1] : []

    content {
      app_setting_names       = length(var.sticky_settings_app_setting_names) > 0 ? var.sticky_settings_app_setting_names : null
      connection_string_names = length(var.sticky_settings_connection_string_names) > 0 ? var.sticky_settings_connection_string_names : null
    }
  }
}

resource "azurerm_linux_function_app" "managed_identity" {
  count = local.is_windows || !var.storage_uses_managed_identity ? 0 : 1

  name                            = var.name
  location                        = local.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  service_plan_id                 = var.service_plan_id
  storage_account_name            = data.azurerm_storage_account.function.name
  storage_uses_managed_identity   = true
  functions_extension_version     = var.functions_extension_version
  builtin_logging_enabled         = var.builtin_logging_enabled
  https_only                      = var.https_only
  public_network_access_enabled   = var.public_network_access_enabled
  virtual_network_subnet_id       = local.vnet_integration_subnet_id_resolved != "" ? local.vnet_integration_subnet_id_resolved : null
  key_vault_reference_identity_id = local.key_vault_reference_identity_id_resolved
  app_settings                    = var.app_settings
  daily_memory_time_quota         = var.daily_memory_time_quota
  zip_deploy_file                 = var.zip_deploy_file
  tags                            = local.merged_tags

  dynamic "connection_string" {
    for_each = var.connection_strings

    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  site_config {
    always_on                         = var.always_on
    ftps_state                        = var.ftps_state
    http2_enabled                     = var.http2_enabled
    minimum_tls_version               = var.minimum_tls_version
    use_32_bit_worker                 = var.use_32_bit_worker
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = var.health_check_eviction_time_in_min
    runtime_scale_monitoring_enabled  = var.runtime_scale_monitoring_enabled
    vnet_route_all_enabled            = var.vnet_route_all_enabled

    dynamic "application_stack" {
      for_each = var.application_stack == null ? [] : [var.application_stack]

      content {
        dotnet_version              = try(application_stack.value.dotnet_version, null)
        java_version                = try(application_stack.value.java_version, null)
        node_version                = try(application_stack.value.node_version, null)
        powershell_core_version     = try(application_stack.value.powershell_core_version, null)
        python_version              = try(application_stack.value.python_version, null)
        use_custom_runtime          = try(application_stack.value.use_custom_runtime, null)
        use_dotnet_isolated_runtime = try(application_stack.value.use_dotnet_isolated_runtime, null)
      }
    }
  }

  dynamic "identity" {
    for_each = local.identity_type != "" ? [1] : []

    content {
      type         = local.identity_type
      identity_ids = local.identity_ids
    }
  }

  dynamic "sticky_settings" {
    for_each = length(var.sticky_settings_app_setting_names) > 0 || length(var.sticky_settings_connection_string_names) > 0 ? [1] : []

    content {
      app_setting_names       = length(var.sticky_settings_app_setting_names) > 0 ? var.sticky_settings_app_setting_names : null
      connection_string_names = length(var.sticky_settings_connection_string_names) > 0 ? var.sticky_settings_connection_string_names : null
    }
  }
}

resource "azurerm_windows_function_app" "key" {
  count = local.is_windows && !var.storage_uses_managed_identity ? 1 : 0

  name                            = var.name
  location                        = local.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  service_plan_id                 = var.service_plan_id
  storage_account_name            = data.azurerm_storage_account.function.name
  storage_account_access_key      = data.azurerm_storage_account.function.primary_access_key
  functions_extension_version     = var.functions_extension_version
  builtin_logging_enabled         = var.builtin_logging_enabled
  https_only                      = var.https_only
  public_network_access_enabled   = var.public_network_access_enabled
  virtual_network_subnet_id       = local.vnet_integration_subnet_id_resolved != "" ? local.vnet_integration_subnet_id_resolved : null
  key_vault_reference_identity_id = local.key_vault_reference_identity_id_resolved
  app_settings                    = var.app_settings
  daily_memory_time_quota         = var.daily_memory_time_quota
  zip_deploy_file                 = var.zip_deploy_file
  tags                            = local.merged_tags

  dynamic "connection_string" {
    for_each = var.connection_strings

    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  site_config {
    always_on                         = var.always_on
    ftps_state                        = var.ftps_state
    http2_enabled                     = var.http2_enabled
    minimum_tls_version               = var.minimum_tls_version
    use_32_bit_worker                 = var.use_32_bit_worker
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = var.health_check_eviction_time_in_min
    runtime_scale_monitoring_enabled  = var.runtime_scale_monitoring_enabled
    vnet_route_all_enabled            = var.vnet_route_all_enabled

    dynamic "application_stack" {
      for_each = var.application_stack == null ? [] : [var.application_stack]

      content {
        dotnet_version              = try(application_stack.value.dotnet_version, null)
        java_version                = try(application_stack.value.java_version, null)
        node_version                = try(application_stack.value.node_version, null)
        powershell_core_version     = try(application_stack.value.powershell_core_version, null)
        use_custom_runtime          = try(application_stack.value.use_custom_runtime, null)
        use_dotnet_isolated_runtime = try(application_stack.value.use_dotnet_isolated_runtime, null)
      }
    }
  }

  dynamic "identity" {
    for_each = local.identity_type != "" ? [1] : []

    content {
      type         = local.identity_type
      identity_ids = local.identity_ids
    }
  }

  dynamic "sticky_settings" {
    for_each = length(var.sticky_settings_app_setting_names) > 0 || length(var.sticky_settings_connection_string_names) > 0 ? [1] : []

    content {
      app_setting_names       = length(var.sticky_settings_app_setting_names) > 0 ? var.sticky_settings_app_setting_names : null
      connection_string_names = length(var.sticky_settings_connection_string_names) > 0 ? var.sticky_settings_connection_string_names : null
    }
  }
}

resource "azurerm_windows_function_app" "managed_identity" {
  count = local.is_windows && var.storage_uses_managed_identity ? 1 : 0

  name                            = var.name
  location                        = local.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  service_plan_id                 = var.service_plan_id
  storage_account_name            = data.azurerm_storage_account.function.name
  storage_uses_managed_identity   = true
  functions_extension_version     = var.functions_extension_version
  builtin_logging_enabled         = var.builtin_logging_enabled
  https_only                      = var.https_only
  public_network_access_enabled   = var.public_network_access_enabled
  virtual_network_subnet_id       = local.vnet_integration_subnet_id_resolved != "" ? local.vnet_integration_subnet_id_resolved : null
  key_vault_reference_identity_id = local.key_vault_reference_identity_id_resolved
  app_settings                    = var.app_settings
  daily_memory_time_quota         = var.daily_memory_time_quota
  zip_deploy_file                 = var.zip_deploy_file
  tags                            = local.merged_tags

  dynamic "connection_string" {
    for_each = var.connection_strings

    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  site_config {
    always_on                         = var.always_on
    ftps_state                        = var.ftps_state
    http2_enabled                     = var.http2_enabled
    minimum_tls_version               = var.minimum_tls_version
    use_32_bit_worker                 = var.use_32_bit_worker
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = var.health_check_eviction_time_in_min
    vnet_route_all_enabled            = var.vnet_route_all_enabled

    dynamic "application_stack" {
      for_each = var.application_stack == null ? [] : [var.application_stack]

      content {
        dotnet_version              = try(application_stack.value.dotnet_version, null)
        java_version                = try(application_stack.value.java_version, null)
        node_version                = try(application_stack.value.node_version, null)
        powershell_core_version     = try(application_stack.value.powershell_core_version, null)
        use_custom_runtime          = try(application_stack.value.use_custom_runtime, null)
        use_dotnet_isolated_runtime = try(application_stack.value.use_dotnet_isolated_runtime, null)
      }
    }
  }

  dynamic "identity" {
    for_each = local.identity_type != "" ? [1] : []

    content {
      type         = local.identity_type
      identity_ids = local.identity_ids
    }
  }

  dynamic "sticky_settings" {
    for_each = length(var.sticky_settings_app_setting_names) > 0 || length(var.sticky_settings_connection_string_names) > 0 ? [1] : []

    content {
      app_setting_names       = length(var.sticky_settings_app_setting_names) > 0 ? var.sticky_settings_app_setting_names : null
      connection_string_names = length(var.sticky_settings_connection_string_names) > 0 ? var.sticky_settings_connection_string_names : null
    }
  }
}

resource "azurerm_private_endpoint" "this" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = "pep-${var.name}-sites"
  location            = local.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = local.private_endpoint_subnet_id_resolved

  private_service_connection {
    name                           = "psc-${var.name}-sites"
    private_connection_resource_id = local.function_app.id
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
  target_resource_id         = local.function_app.id
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

  scope                = local.function_app.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = merge(
    { for object_id in local.app_user_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_user : "name:${name}" => group.object_id }
  )

  scope                = local.function_app.id
  role_definition_name = "Reader"
  principal_id         = each.value
}
