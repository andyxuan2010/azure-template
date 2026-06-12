data "azurerm_client_config" "current" {}

resource "azurerm_application_insights" "this" {
  count = var.enable_application_insights ? 1 : 0

  name                = local.application_insights_name_resolved
  location            = local.location
  resource_group_name = var.resource_group_name
  workspace_id        = local.application_insights_workspace_id_resolved
  application_type    = "web"
  retention_in_days   = var.application_insights_retention_in_days
  tags                = local.merged_tags
}

resource "azurerm_linux_web_app" "this" {
  count = local.is_windows ? 0 : 1

  name                                   = var.app_name
  enabled                                = var.app_enabled
  client_certificate_enabled             = var.client_certificate_enabled
  client_certificate_exclusion_paths     = var.client_certificate_exclusion_paths
  client_certificate_mode                = var.client_certificate_mode
  location                               = local.location
  resource_group_name                    = var.resource_group_name
  service_plan_id                        = var.app_service_plan_id
  app_settings                           = local.app_settings_merged
  https_only                             = local.https_only
  client_affinity_enabled                = var.client_affinity_enabled
  key_vault_reference_identity_id        = var.key_vault_reference_identity_id
  public_network_access_enabled          = var.public_network_access_enabled
  virtual_network_backup_restore_enabled = var.virtual_network_backup_restore_enabled
  virtual_network_subnet_id              = local.vnet_integration_subnet_id_resolved != "" ? local.vnet_integration_subnet_id_resolved : null
  vnet_image_pull_enabled                = var.vnet_image_pull_enabled
  zip_deploy_file                        = var.zip_deploy_file

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
      require_https          = var.auth_require_https
      runtime_version        = var.auth_runtime_version
      http_route_api_prefix  = var.auth_http_route_api_prefix
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
    api_definition_url                            = var.api_definition_url
    api_management_api_id                         = var.api_management_api_id
    app_command_line                              = var.app_command_line
    default_documents                             = var.default_documents
    vnet_route_all_enabled                        = var.vnet_route_all_enabled
    websockets_enabled                            = var.websockets_enabled
    container_registry_use_managed_identity       = local.container_registry_use_managed_identity
    container_registry_managed_identity_client_id = var.container_registry_managed_identity_client_id
    always_on                                     = var.always_on
    ftps_state                                    = var.ftps_state
    http2_enabled                                 = var.http2_enabled
    health_check_path                             = var.health_check_path
    health_check_eviction_time_in_min             = var.health_check_eviction_time_in_min
    linux_fx_version                              = var.linux_fx_version
    load_balancing_mode                           = var.load_balancing_mode
    local_mysql_enabled                           = var.local_mysql_enabled
    managed_pipeline_mode                         = var.managed_pipeline_mode
    minimum_tls_version                           = var.minimum_tls_version
    remote_debugging_enabled                      = var.remote_debugging_enabled
    remote_debugging_version                      = var.remote_debugging_version
    scm_ip_restriction_default_action             = var.scm_ip_restriction_default_action
    scm_minimum_tls_version                       = var.scm_minimum_tls_version
    scm_type                                      = var.scm_type
    scm_use_main_ip_restriction                   = local.scm_ip_security_restrictions_use_main
    use_32_bit_worker                             = var.use_32_bit_worker
    worker_count                                  = var.worker_count
    ip_restriction_default_action                 = var.ip_restriction_default_action

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
        action                    = ip_restriction.value.action
        description               = ip_restriction.value.description
        headers                   = ip_restriction.value.headers != null ? [ip_restriction.value.headers] : []
        ip_address                = ip_restriction.value.ip_address
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        service_tag               = ip_restriction.value.service_tag
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = var.scm_ip_restrictions

      content {
        action                    = scm_ip_restriction.value.action
        description               = scm_ip_restriction.value.description
        headers                   = scm_ip_restriction.value.headers != null ? [scm_ip_restriction.value.headers] : []
        ip_address                = scm_ip_restriction.value.ip_address
        name                      = scm_ip_restriction.value.name
        priority                  = scm_ip_restriction.value.priority
        service_tag               = scm_ip_restriction.value.service_tag
        virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id
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
        go_version               = application_stack.value.go_version
        java_server              = application_stack.value.java_server
        java_server_version      = application_stack.value.java_server_version
        node_version             = application_stack.value.node_version
        python_version           = application_stack.value.python_version
        php_version              = application_stack.value.php_version
        java_version             = application_stack.value.java_version
        ruby_version             = application_stack.value.ruby_version
      }
    }

    dynamic "auto_heal_setting" {
      for_each = var.auto_heal_setting == null ? [] : [var.auto_heal_setting]

      content {
        action {
          action_type                    = auto_heal_setting.value.action.action_type
          minimum_process_execution_time = auto_heal_setting.value.action.minimum_process_execution_time
        }

        trigger {
          dynamic "requests" {
            for_each = auto_heal_setting.value.trigger.requests == null ? [] : [auto_heal_setting.value.trigger.requests]

            content {
              count    = requests.value.count
              interval = requests.value.interval
            }
          }

          dynamic "slow_request" {
            for_each = auto_heal_setting.value.trigger.slow_request == null ? [] : [auto_heal_setting.value.trigger.slow_request]

            content {
              count      = slow_request.value.count
              interval   = slow_request.value.interval
              time_taken = slow_request.value.time_taken
            }
          }

          dynamic "slow_request_with_path" {
            for_each = auto_heal_setting.value.trigger.slow_request_with_path == null ? [] : [auto_heal_setting.value.trigger.slow_request_with_path]

            content {
              count      = slow_request_with_path.value.count
              interval   = slow_request_with_path.value.interval
              path       = slow_request_with_path.value.path
              time_taken = slow_request_with_path.value.time_taken
            }
          }

          dynamic "status_code" {
            for_each = auto_heal_setting.value.trigger.status_code

            content {
              count             = status_code.value.count
              interval          = status_code.value.interval
              path              = status_code.value.path
              status_code_range = status_code.value.status_code_range
              sub_status        = status_code.value.sub_status
              win32_status_code = status_code.value.win32_status_code
            }
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

  dynamic "backup" {
    for_each = var.backup == null ? [] : [var.backup]

    content {
      enabled             = backup.value.enabled
      name                = backup.value.name
      storage_account_url = backup.value.storage_account_url

      schedule {
        frequency_interval       = backup.value.schedule.frequency_interval
        frequency_unit           = backup.value.schedule.frequency_unit
        keep_at_least_one_backup = backup.value.schedule.keep_at_least_one_backup
        retention_period_days    = backup.value.schedule.retention_period_days
        start_time               = backup.value.schedule.start_time
      }
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

  name                                   = var.app_name
  enabled                                = var.app_enabled
  client_certificate_enabled             = var.client_certificate_enabled
  client_certificate_exclusion_paths     = var.client_certificate_exclusion_paths
  client_certificate_mode                = var.client_certificate_mode
  location                               = local.location
  resource_group_name                    = var.resource_group_name
  service_plan_id                        = var.app_service_plan_id
  app_settings                           = local.app_settings_merged
  https_only                             = local.https_only
  client_affinity_enabled                = var.client_affinity_enabled
  key_vault_reference_identity_id        = var.key_vault_reference_identity_id
  public_network_access_enabled          = var.public_network_access_enabled
  virtual_network_backup_restore_enabled = var.virtual_network_backup_restore_enabled
  virtual_network_image_pull_enabled     = var.virtual_network_image_pull_enabled
  virtual_network_subnet_id              = local.vnet_integration_subnet_id_resolved != "" ? local.vnet_integration_subnet_id_resolved : null
  zip_deploy_file                        = var.zip_deploy_file

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
      require_https          = var.auth_require_https
      runtime_version        = var.auth_runtime_version
      http_route_api_prefix  = var.auth_http_route_api_prefix
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
    api_definition_url                            = var.api_definition_url
    api_management_api_id                         = var.api_management_api_id
    app_command_line                              = var.app_command_line
    default_documents                             = var.default_documents
    vnet_route_all_enabled                        = var.vnet_route_all_enabled
    websockets_enabled                            = var.websockets_enabled
    container_registry_use_managed_identity       = local.container_registry_use_managed_identity
    container_registry_managed_identity_client_id = var.container_registry_managed_identity_client_id
    always_on                                     = var.always_on
    ftps_state                                    = var.ftps_state
    http2_enabled                                 = var.http2_enabled
    health_check_path                             = var.health_check_path
    health_check_eviction_time_in_min             = var.health_check_eviction_time_in_min
    load_balancing_mode                           = var.load_balancing_mode
    local_mysql_enabled                           = var.local_mysql_enabled
    managed_pipeline_mode                         = var.managed_pipeline_mode
    minimum_tls_version                           = var.minimum_tls_version
    remote_debugging_enabled                      = var.remote_debugging_enabled
    remote_debugging_version                      = var.remote_debugging_version
    scm_ip_restriction_default_action             = var.scm_ip_restriction_default_action
    scm_minimum_tls_version                       = var.scm_minimum_tls_version
    scm_type                                      = var.scm_type
    scm_use_main_ip_restriction                   = local.scm_ip_security_restrictions_use_main
    use_32_bit_worker                             = var.use_32_bit_worker
    windows_fx_version                            = var.windows_fx_version
    worker_count                                  = var.worker_count
    ip_restriction_default_action                 = var.ip_restriction_default_action

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
        action                    = ip_restriction.value.action
        description               = ip_restriction.value.description
        headers                   = ip_restriction.value.headers != null ? [ip_restriction.value.headers] : []
        ip_address                = ip_restriction.value.ip_address
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        service_tag               = ip_restriction.value.service_tag
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = var.scm_ip_restrictions

      content {
        action                    = scm_ip_restriction.value.action
        description               = scm_ip_restriction.value.description
        headers                   = scm_ip_restriction.value.headers != null ? [scm_ip_restriction.value.headers] : []
        ip_address                = scm_ip_restriction.value.ip_address
        name                      = scm_ip_restriction.value.name
        priority                  = scm_ip_restriction.value.priority
        service_tag               = scm_ip_restriction.value.service_tag
        virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id
      }
    }

    dynamic "application_stack" {
      for_each = var.application_stack == null ? toset([]) : toset([var.application_stack])

      content {
        docker_image_name            = application_stack.value.docker_image_name
        docker_registry_url          = application_stack.value.docker_registry_url
        docker_registry_username     = application_stack.value.docker_registry_username
        docker_registry_password     = application_stack.value.docker_registry_password
        current_stack                = application_stack.value.current_stack
        dotnet_core_version          = application_stack.value.dotnet_core_version
        dotnet_version               = application_stack.value.dotnet_version
        java_container               = application_stack.value.java_container
        java_container_version       = application_stack.value.java_container_version
        java_embedded_server_enabled = application_stack.value.java_embedded_server_enabled
        node_version                 = application_stack.value.node_version
        php_version                  = application_stack.value.php_version
        python                       = application_stack.value.python
        java_version                 = application_stack.value.java_version
        tomcat_version               = application_stack.value.tomcat_version
      }
    }

    dynamic "handler_mapping" {
      for_each = var.handler_mappings

      content {
        arguments             = handler_mapping.value.arguments
        extension             = handler_mapping.value.extension
        script_processor_path = handler_mapping.value.script_processor_path
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

    dynamic "auto_heal_setting" {
      for_each = var.auto_heal_setting == null ? [] : [var.auto_heal_setting]

      content {
        action {
          action_type                    = auto_heal_setting.value.action.action_type
          minimum_process_execution_time = auto_heal_setting.value.action.minimum_process_execution_time
        }

        trigger {
          dynamic "requests" {
            for_each = auto_heal_setting.value.trigger.requests == null ? [] : [auto_heal_setting.value.trigger.requests]

            content {
              count    = requests.value.count
              interval = requests.value.interval
            }
          }

          dynamic "slow_request" {
            for_each = auto_heal_setting.value.trigger.slow_request == null ? [] : [auto_heal_setting.value.trigger.slow_request]

            content {
              count      = slow_request.value.count
              interval   = slow_request.value.interval
              time_taken = slow_request.value.time_taken
            }
          }

          dynamic "slow_request_with_path" {
            for_each = auto_heal_setting.value.trigger.slow_request_with_path == null ? [] : [auto_heal_setting.value.trigger.slow_request_with_path]

            content {
              count      = slow_request_with_path.value.count
              interval   = slow_request_with_path.value.interval
              path       = slow_request_with_path.value.path
              time_taken = slow_request_with_path.value.time_taken
            }
          }

          dynamic "status_code" {
            for_each = auto_heal_setting.value.trigger.status_code

            content {
              count             = status_code.value.count
              interval          = status_code.value.interval
              path              = status_code.value.path
              status_code_range = status_code.value.status_code_range
              sub_status        = status_code.value.sub_status
              win32_status_code = status_code.value.win32_status_code
            }
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

  dynamic "backup" {
    for_each = var.backup == null ? [] : [var.backup]

    content {
      enabled             = backup.value.enabled
      name                = backup.value.name
      storage_account_url = backup.value.storage_account_url

      schedule {
        frequency_interval       = backup.value.schedule.frequency_interval
        frequency_unit           = backup.value.schedule.frequency_unit
        keep_at_least_one_backup = backup.value.schedule.keep_at_least_one_backup
        retention_period_days    = backup.value.schedule.retention_period_days
        start_time               = backup.value.schedule.start_time
      }
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

  name                           = var.diagnostic_setting_name
  target_resource_id             = local.web_app.id
  log_analytics_workspace_id     = trimspace(var.log_analytics_workspace_id) != "" ? var.log_analytics_workspace_id : null
  log_analytics_destination_type = trimspace(var.log_analytics_workspace_id) != "" ? var.log_analytics_destination_type : null
  storage_account_id             = try(trimspace(var.diagnostic_storage_account_id), "") != "" ? var.diagnostic_storage_account_id : null
  eventhub_authorization_rule_id = try(trimspace(var.diagnostic_eventhub_authorization_rule_id), "") != "" ? var.diagnostic_eventhub_authorization_rule_id : null
  eventhub_name                  = try(trimspace(var.diagnostic_eventhub_name), "") != "" ? var.diagnostic_eventhub_name : null

  dynamic "enabled_log" {
    for_each = toset(local.diagnostic_log_categories)

    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = toset(local.diagnostic_metric_categories)

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
  location            = local.location
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
