data "azurerm_client_config" "current" {}

resource "azurerm_application_insights" "this" {
  count = var.enable_application_insights ? 1 : 0

  name                = local.application_insights_name_resolved
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = local.application_insights_workspace_id_resolved
  application_type    = "web"
  retention_in_days   = var.application_insights_retention_in_days
  tags                = local.merged_tags
}

resource "azurerm_linux_web_app" "this" {
  count = local.is_windows ? 0 : 1

  name                            = var.app_name
  client_certificate_enabled      = var.client_certificate_enabled
  client_certificate_mode         = var.client_certificate_mode
  location                        = var.location
  resource_group_name             = var.resource_group_name
  service_plan_id                 = var.app_service_plan_id
  app_settings                    = local.app_settings_merged
  https_only                      = local.https_only
  client_affinity_enabled         = var.client_affinity_enabled
  key_vault_reference_identity_id = var.key_vault_reference_identity_id
  public_network_access_enabled   = var.public_network_access_enabled
  virtual_network_subnet_id       = local.vnet_integration_subnet_id_resolved != "" ? local.vnet_integration_subnet_id_resolved : null
  zip_deploy_file                 = var.zip_deploy_file

  ftp_publish_basic_authentication_enabled       = var.ftp_publish_basic_authentication_enabled
  webdeploy_publish_basic_authentication_enabled = local.webdeploy_publish_basic_authentication_enabled

  tags = local.merged_tags

  dynamic "connection_string" {
    for_each = var.connection_strings

    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  dynamic "auth_settings_v2" {
    for_each = local.easy_auth_enabled ? [1] : []

    content {
      auth_enabled           = local.auth_settings_enabled
      require_authentication = local.auth_settings_require_authentication
      unauthenticated_action = local.auth_settings_unauthenticated_action
      default_provider       = local.auth_settings_default_provider
      excluded_paths         = local.auth_settings_excluded_paths

      login {
        token_store_enabled            = local.auth_settings_token_store_enabled
        allowed_external_redirect_urls = local.auth_settings_allowed_external_redirect_urls
      }

      active_directory_v2 {
        client_id                       = var.active_directory_client_id
        client_secret_setting_name      = var.active_directory_client_secret_setting_name
        tenant_auth_endpoint            = local.active_directory_tenant_auth_endpoint
        allowed_audiences               = local.active_directory_allowed_audiences
        allowed_groups                  = local.active_directory_allowed_groups
        allowed_applications            = local.active_directory_allowed_applications
        allowed_identities              = local.active_directory_allowed_identities
        jwt_allowed_client_applications = local.active_directory_jwt_allowed_client_applications
        jwt_allowed_groups              = local.active_directory_jwt_allowed_groups
        login_parameters                = var.active_directory_login_parameters
      }
    }
  }

  site_config {
    app_command_line                              = var.app_command_line
    vnet_route_all_enabled                        = var.vnet_route_all_enabled
    websockets_enabled                            = var.websockets_enabled
    container_registry_use_managed_identity       = local.container_registry_use_managed_identity
    container_registry_managed_identity_client_id = var.container_registry_managed_identity_client_id
    always_on                                     = var.always_on
    ftps_state                                    = var.ftps_state
    http2_enabled                                 = var.http2_enabled
    health_check_path                             = var.health_check_path
    health_check_eviction_time_in_min             = var.health_check_eviction_time_in_min
    use_32_bit_worker                             = var.use_32_bit_worker
    ip_restriction_default_action                 = var.ip_restriction_default_action
    //scm_type =  "ExternalGit"

    dynamic "cors" {
      for_each = var.cors != null ? [var.cors] : []

      content {
        allowed_origins     = cors.value.allowed_origins
        support_credentials = cors.value.support_credentials
      }
    }

    dynamic "ip_restriction" {
      for_each = var.ip_restrictions

      content {
        action      = ip_restriction.value.action
        headers     = ip_restriction.value.headers != null ? [ip_restriction.value.headers] : []
        ip_address  = ip_restriction.value.ip_address
        name        = ip_restriction.value.name
        priority    = ip_restriction.value.priority
        service_tag = ip_restriction.value.service_tag
      }
    }

    dynamic "application_stack" {
      for_each = var.application_stack == null ? toset([]) : toset([var.application_stack])

      content {
        docker_image_name        = application_stack.value.docker_image_name
        docker_registry_url      = application_stack.value.docker_registry_url
        docker_registry_username = application_stack.value.docker_registry_username
        docker_registry_password = application_stack.value.docker_registry_password
        dotnet_version           = application_stack.value.dotnet_version
        node_version             = application_stack.value.node_version
        python_version           = application_stack.value.python_version
        php_version              = application_stack.value.php_version
        java_version             = application_stack.value.java_version
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

  dynamic "storage_account" {
    for_each = var.storage_accounts

    content {
      access_key   = "@AppSettingRef(${storage_account.value.access_key_setting_name})"
      account_name = storage_account.value.account_name
      mount_path   = storage_account.value.mount_path
      name         = storage_account.value.name
      share_name   = storage_account.value.share_name
      type         = storage_account.value.type
    }
  }

  logs {
    application_logs {
      file_system_level = var.application_logs_file_system_level
    }

    detailed_error_messages = var.logs_detailed_error_messages
    failed_request_tracing  = var.logs_failed_request_tracing

    http_logs {
      file_system {
        retention_in_mb   = var.http_logs_file_system_retention_in_mb
        retention_in_days = var.http_logs_file_system_retention_in_days
      }
    }
  }

  lifecycle {
    ignore_changes = [
      # This setting turns itself off after 12 hours.
      # Ignore changes to prevent cycle of turning on/off...
      logs[0].application_logs,

      # Ignore changes to common build settings.
      # These are usually configured in CI/CD pipelines.
      app_settings["BUILD"],
      app_settings["BUILD_NUMBER"],
      app_settings["BUILD_ID"],
      app_settings["APPLICATIONINSIGHTS_CONNECTION_STRING"],
      app_settings["APPINSIGHTS_INSTRUMENTATIONKEY"],

      # Ignore changes to hidden tags that are managed by Azure.
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"]
    ]
  }

  dynamic "sticky_settings" {
    for_each = length(var.sticky_settings_app_setting_names) > 0 || length(var.sticky_settings_connection_string_names) > 0 ? [0] : []

    content {
      app_setting_names       = length(var.sticky_settings_app_setting_names) > 0 ? var.sticky_settings_app_setting_names : null
      connection_string_names = length(var.sticky_settings_connection_string_names) > 0 ? var.sticky_settings_connection_string_names : null
    }
  }
}

resource "azurerm_windows_web_app" "this" {
  count = local.is_windows ? 1 : 0

  name                            = var.app_name
  client_certificate_enabled      = var.client_certificate_enabled
  client_certificate_mode         = var.client_certificate_mode
  location                        = var.location
  resource_group_name             = var.resource_group_name
  service_plan_id                 = var.app_service_plan_id
  app_settings                    = local.app_settings_merged
  https_only                      = local.https_only
  client_affinity_enabled         = var.client_affinity_enabled
  key_vault_reference_identity_id = var.key_vault_reference_identity_id
  public_network_access_enabled   = var.public_network_access_enabled
  virtual_network_subnet_id       = local.vnet_integration_subnet_id_resolved != "" ? local.vnet_integration_subnet_id_resolved : null
  zip_deploy_file                 = var.zip_deploy_file

  ftp_publish_basic_authentication_enabled       = var.ftp_publish_basic_authentication_enabled
  webdeploy_publish_basic_authentication_enabled = local.webdeploy_publish_basic_authentication_enabled

  tags = local.merged_tags

  dynamic "connection_string" {
    for_each = var.connection_strings

    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  dynamic "auth_settings_v2" {
    for_each = local.easy_auth_enabled ? [1] : []

    content {
      auth_enabled           = local.auth_settings_enabled
      require_authentication = local.auth_settings_require_authentication
      unauthenticated_action = local.auth_settings_unauthenticated_action
      default_provider       = local.auth_settings_default_provider
      excluded_paths         = local.auth_settings_excluded_paths

      login {
        token_store_enabled            = local.auth_settings_token_store_enabled
        allowed_external_redirect_urls = local.auth_settings_allowed_external_redirect_urls
      }

      active_directory_v2 {
        client_id                       = var.active_directory_client_id
        client_secret_setting_name      = var.active_directory_client_secret_setting_name
        tenant_auth_endpoint            = local.active_directory_tenant_auth_endpoint
        allowed_audiences               = local.active_directory_allowed_audiences
        allowed_groups                  = local.active_directory_allowed_groups
        allowed_applications            = local.active_directory_allowed_applications
        allowed_identities              = local.active_directory_allowed_identities
        jwt_allowed_client_applications = local.active_directory_jwt_allowed_client_applications
        jwt_allowed_groups              = local.active_directory_jwt_allowed_groups
        login_parameters                = var.active_directory_login_parameters
      }
    }
  }

  site_config {
    vnet_route_all_enabled                        = var.vnet_route_all_enabled
    websockets_enabled                            = var.websockets_enabled
    container_registry_use_managed_identity       = local.container_registry_use_managed_identity
    container_registry_managed_identity_client_id = var.container_registry_managed_identity_client_id
    always_on                                     = var.always_on
    ftps_state                                    = var.ftps_state
    http2_enabled                                 = var.http2_enabled
    health_check_path                             = var.health_check_path
    health_check_eviction_time_in_min             = var.health_check_eviction_time_in_min
    use_32_bit_worker                             = var.use_32_bit_worker
    ip_restriction_default_action                 = var.ip_restriction_default_action
    //scm_type =  "ExternalGit"

    dynamic "cors" {
      for_each = var.cors != null ? [var.cors] : []

      content {
        allowed_origins     = cors.value.allowed_origins
        support_credentials = cors.value.support_credentials
      }
    }

    dynamic "ip_restriction" {
      for_each = var.ip_restrictions

      content {
        action      = ip_restriction.value.action
        headers     = ip_restriction.value.headers != null ? [ip_restriction.value.headers] : []
        ip_address  = ip_restriction.value.ip_address
        name        = ip_restriction.value.name
        priority    = ip_restriction.value.priority
        service_tag = ip_restriction.value.service_tag
      }
    }

    dynamic "application_stack" {
      for_each = var.application_stack == null ? toset([]) : toset([var.application_stack])

      content {
        docker_image_name        = application_stack.value.docker_image_name
        docker_registry_url      = application_stack.value.docker_registry_url
        docker_registry_username = application_stack.value.docker_registry_username
        docker_registry_password = application_stack.value.docker_registry_password
        current_stack            = application_stack.value.current_stack
        dotnet_version           = application_stack.value.dotnet_version
        node_version             = application_stack.value.node_version

        php_version  = application_stack.value.php_version
        java_version = application_stack.value.java_version
      }
    }

    dynamic "virtual_application" {
      for_each = var.virtual_applications

      content {
        virtual_path  = virtual_application.value.virtual_path
        physical_path = virtual_application.value.physical_path
        preload       = virtual_application.value.preload

        dynamic "virtual_directory" {
          for_each = virtual_application.value.virtual_directories

          content {
            physical_path = virtual_directory.value.physical_path
            virtual_path  = virtual_directory.value.virtual_path
          }
        }
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

  dynamic "storage_account" {
    for_each = var.storage_accounts

    content {
      access_key   = "@AppSettingRef(${storage_account.value.access_key_setting_name})"
      account_name = storage_account.value.account_name
      mount_path   = storage_account.value.mount_path
      name         = storage_account.value.name
      share_name   = storage_account.value.share_name
      type         = storage_account.value.type
    }
  }

  logs {
    application_logs {
      file_system_level = var.application_logs_file_system_level
    }

    detailed_error_messages = var.logs_detailed_error_messages
    failed_request_tracing  = var.logs_failed_request_tracing

    http_logs {
      file_system {
        retention_in_mb   = var.http_logs_file_system_retention_in_mb
        retention_in_days = var.http_logs_file_system_retention_in_days
      }
    }
  }

  lifecycle {
    ignore_changes = [
      # This setting turns itself off after 12 hours.
      # Ignore changes to prevent cycle of turning on/off...
      logs[0].application_logs,

      # Ignore changes to common build settings.
      # These are usually configured in CI/CD pipelines.
      app_settings["BUILD"],
      app_settings["BUILD_NUMBER"],
      app_settings["BUILD_ID"],
      app_settings["APPLICATIONINSIGHTS_CONNECTION_STRING"],
      app_settings["APPINSIGHTS_INSTRUMENTATIONKEY"],

      # Ignore changes to hidden tags that are managed by Azure.
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"]
    ]
  }

  dynamic "sticky_settings" {
    for_each = length(var.sticky_settings_app_setting_names) > 0 || length(var.sticky_settings_connection_string_names) > 0 ? [0] : []

    content {
      app_setting_names       = length(var.sticky_settings_app_setting_names) > 0 ? var.sticky_settings_app_setting_names : null
      connection_string_names = length(var.sticky_settings_connection_string_names) > 0 ? var.sticky_settings_connection_string_names : null
    }
  }
}

check "build_settings_check" {
  assert {
    condition     = length(setintersection(["BUILD", "BUILD_NUMBER", "BUILD_ID"], keys(var.app_settings))) == 0
    error_message = "App settings \"BUILD\", \"BUILD_NUMBER\" and \"BUILD_ID\" should be configured outside of Terraform, commonly in a CI/CD pipeline. Any changes made to these app settings will be ignored."
  }
}

resource "azurerm_app_service_custom_hostname_binding" "this" {
  for_each = var.custom_hostname_bindings

  hostname            = each.value["hostname"]
  app_service_name    = local.web_app.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_app_service_managed_certificate" "this" {
  for_each = var.custom_hostname_bindings

  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.this[each.key].id
}

resource "azurerm_app_service_certificate_binding" "this" {
  for_each = var.custom_hostname_bindings

  hostname_binding_id = azurerm_app_service_custom_hostname_binding.this[each.key].id
  certificate_id      = azurerm_app_service_managed_certificate.this[each.key].id
  ssl_state           = each.value["ssl_state"]
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = local.diagnostics_enabled ? 1 : 0

  name                       = var.diagnostic_setting_name
  target_resource_id         = local.web_app.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = toset(var.diagnostic_setting_enabled_log_categories)

    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = toset(var.diagnostic_setting_enabled_metric_categories)

    content {
      category = enabled_metric.value
    }
  }
}

# -----------------------------------------------------------------------------
# Deployment Center (Azure Repos)
# -----------------------------------------------------------------------------

resource "azurerm_app_service_source_control" "deployment_center" {
  count = var.deployment_center_enabled && local.deployment_center_azure_repos_repo_url != null ? 1 : 0

  app_id   = local.web_app.id
  repo_url = local.deployment_center_azure_repos_repo_url
  branch   = var.deployment_center_azure_repos_branch

  use_manual_integration = var.deployment_center_use_manual_integration
  use_mercurial          = false
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = merge(
    { for object_id in local.app_admin_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_admin : "name:${name}" => group.object_id }
  )

  scope                = local.web_app.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = merge(
    { for object_id in local.app_user_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_user : "name:${name}" => group.object_id }
  )

  scope                = local.web_app.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

# -----------------------------------------------------------------------------
# Private endpoint (sites)
# -----------------------------------------------------------------------------

resource "azurerm_private_endpoint" "sites" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "pep-${var.app_name}-sites"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = local.private_endpoint_subnet_id_resolved

  private_service_connection {
    name                           = "plsc-${var.app_name}-sites"
    private_connection_resource_id = local.web_app.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [local.private_dns_zone_id_resolved]
  }
  tags = local.merged_tags
}
