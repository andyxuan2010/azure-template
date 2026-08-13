# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: functionapp
# Description: Deploys Azure Function Apps for event-driven serverless workloads on Windows, Linux, or container hosting plans.
#              The module supports storage integration, managed identity, app settings, authentication, deployment configuration, Application Insights, diagnostics, private endpoint and VNet integration, and resource group tag inheritance for governance alignment.
# Owner: Cloud Center of Excellence (CCOE)
# Maintainer: Andy Xuan@CCOE
# Repository: CCOE-Azure/azure-template
#
# Created: 2026-04-17
# Modified: 2026-07-08
# Version: 1.3.0
#
# Change History:
# - 2026-04-17 v1.0.0: Established reusable functionapp module baseline for the CCOE Azure IaC template library.
# - 2026-07-08 v1.0.0: Added standardized module metadata header with ownership, maintainer, license, dates, version, and change history.
#
# This Terraform module is maintained as part of the CCOE Azure IaC template library.
# Use, modification, and distribution are governed by the repository license and organizational policy.

data "azurerm_resource_group" "rg" {
  count = local.resource_group_lookup_required ? 1 : 0

  name = local.resource_group_name
}

data "azurerm_storage_account" "function" {
  count = local.storage_account_lookup_required ? 1 : 0

  name                = local.storage_account_name_resolved
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

resource "azurerm_linux_function_app" "key" {
  count = local.is_windows || var.storage_uses_managed_identity ? 0 : 1

  name                                           = local.function_app_name
  location                                       = local.location
  resource_group_name                            = local.resource_group_name
  service_plan_id                                = var.service_plan_id
  storage_account_name                           = local.storage_uses_key_vault_secret ? null : local.storage_account_name_resolved
  storage_account_access_key                     = local.storage_account_access_key
  storage_key_vault_secret_id                    = local.storage_key_vault_secret_id
  functions_extension_version                    = var.functions_extension_version
  builtin_logging_enabled                        = var.builtin_logging_enabled
  enabled                                        = var.enabled
  https_only                                     = var.https_only
  public_network_access_enabled                  = var.public_network_access_enabled
  client_certificate_enabled                     = var.client_certificate_enabled
  client_certificate_mode                        = var.client_certificate_mode
  client_certificate_exclusion_paths             = var.client_certificate_exclusion_paths
  content_share_force_disabled                   = var.content_share_force_disabled
  ftp_publish_basic_authentication_enabled       = var.ftp_publish_basic_authentication_enabled
  webdeploy_publish_basic_authentication_enabled = var.webdeploy_publish_basic_authentication_enabled
  virtual_network_backup_restore_enabled         = var.virtual_network_backup_restore_enabled
  virtual_network_subnet_id                      = local.vnet_integration_subnet_id_resolved
  vnet_image_pull_enabled                        = var.vnet_image_pull_enabled
  key_vault_reference_identity_id                = local.key_vault_reference_identity_id_resolved
  app_settings                                   = var.app_settings
  daily_memory_time_quota                        = var.daily_memory_time_quota
  zip_deploy_file                                = var.zip_deploy_file
  tags                                           = local.merged_tags

  dynamic "connection_string" {
    for_each = var.connection_strings

    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  site_config {
    always_on                                     = var.always_on
    api_definition_url                            = var.api_definition_url
    api_management_api_id                         = var.api_management_api_id
    app_command_line                              = var.app_command_line
    app_scale_limit                               = var.app_scale_limit
    application_insights_connection_string        = var.application_insights_connection_string
    application_insights_key                      = var.application_insights_key
    container_registry_managed_identity_client_id = var.container_registry_managed_identity_client_id
    container_registry_use_managed_identity       = var.container_registry_use_managed_identity
    default_documents                             = var.default_documents
    elastic_instance_minimum                      = var.elastic_instance_minimum
    ftps_state                                    = var.ftps_state
    health_check_eviction_time_in_min             = var.health_check_eviction_time_in_min
    health_check_path                             = var.health_check_path
    http2_enabled                                 = var.http2_enabled
    ip_restriction_default_action                 = var.ip_restriction_default_action
    load_balancing_mode                           = var.load_balancing_mode
    managed_pipeline_mode                         = var.managed_pipeline_mode
    minimum_tls_version                           = var.minimum_tls_version
    pre_warmed_instance_count                     = var.pre_warmed_instance_count
    remote_debugging_enabled                      = var.remote_debugging_enabled
    remote_debugging_version                      = var.remote_debugging_version
    runtime_scale_monitoring_enabled              = var.runtime_scale_monitoring_enabled
    scm_ip_restriction_default_action             = var.scm_ip_restriction_default_action
    scm_minimum_tls_version                       = var.scm_minimum_tls_version
    scm_use_main_ip_restriction                   = var.scm_use_main_ip_restriction
    use_32_bit_worker                             = var.use_32_bit_worker
    vnet_route_all_enabled                        = var.vnet_route_all_enabled
    websockets_enabled                            = var.websockets_enabled
    worker_count                                  = var.worker_count

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

        dynamic "docker" {
          for_each = try(application_stack.value.docker, null) == null ? [] : [application_stack.value.docker]

          content {
            image_name        = docker.value.image_name
            image_tag         = docker.value.image_tag
            registry_url      = docker.value.registry_url
            registry_username = try(docker.value.registry_username, null)
            registry_password = try(docker.value.registry_password, null)
          }
        }
      }
    }

    dynamic "app_service_logs" {
      for_each = var.app_service_logs == null ? [] : [var.app_service_logs]

      content {
        disk_quota_mb         = try(app_service_logs.value.disk_quota_mb, null)
        retention_period_days = try(app_service_logs.value.retention_period_days, null)
      }
    }

    dynamic "cors" {
      for_each = var.cors == null ? [] : [var.cors]

      content {
        allowed_origins     = try(cors.value.allowed_origins, [])
        support_credentials = try(cors.value.support_credentials, false)
      }
    }

    dynamic "ip_restriction" {
      for_each = var.ip_restrictions

      content {
        action                    = try(ip_restriction.value.action, "Allow")
        description               = try(ip_restriction.value.description, null)
        headers                   = try(ip_restriction.value.headers, null)
        ip_address                = try(ip_restriction.value.ip_address, null)
        name                      = try(ip_restriction.value.name, null)
        priority                  = try(ip_restriction.value.priority, null)
        service_tag               = try(ip_restriction.value.service_tag, null)
        virtual_network_subnet_id = try(ip_restriction.value.virtual_network_subnet_id, null)
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = var.scm_ip_restrictions

      content {
        action                    = try(scm_ip_restriction.value.action, "Allow")
        description               = try(scm_ip_restriction.value.description, null)
        headers                   = try(scm_ip_restriction.value.headers, null)
        ip_address                = try(scm_ip_restriction.value.ip_address, null)
        name                      = try(scm_ip_restriction.value.name, null)
        priority                  = try(scm_ip_restriction.value.priority, null)
        service_tag               = try(scm_ip_restriction.value.service_tag, null)
        virtual_network_subnet_id = try(scm_ip_restriction.value.virtual_network_subnet_id, null)
      }
    }
  }

  dynamic "auth_settings" {
    for_each = var.auth_settings == null ? [] : [var.auth_settings]

    content {
      additional_login_parameters    = try(auth_settings.value.additional_login_parameters, null)
      allowed_external_redirect_urls = try(auth_settings.value.allowed_external_redirect_urls, null)
      default_provider               = try(auth_settings.value.default_provider, null)
      enabled                        = auth_settings.value.enabled
      issuer                         = try(auth_settings.value.issuer, null)
      runtime_version                = try(auth_settings.value.runtime_version, null)
      token_refresh_extension_hours  = try(auth_settings.value.token_refresh_extension_hours, null)
      token_store_enabled            = try(auth_settings.value.token_store_enabled, null)
      unauthenticated_client_action  = try(auth_settings.value.unauthenticated_client_action, null)

      dynamic "active_directory" {
        for_each = try(auth_settings.value.active_directory, null) == null ? [] : [auth_settings.value.active_directory]

        content {
          allowed_audiences          = try(active_directory.value.allowed_audiences, null)
          client_id                  = active_directory.value.client_id
          client_secret              = try(active_directory.value.client_secret, null)
          client_secret_setting_name = try(active_directory.value.client_secret_setting_name, null)
        }
      }
    }
  }

  dynamic "auth_settings_v2" {
    for_each = var.auth_settings_v2 == null ? [] : [var.auth_settings_v2]

    content {
      auth_enabled                            = try(auth_settings_v2.value.auth_enabled, true)
      config_file_path                        = try(auth_settings_v2.value.config_file_path, null)
      default_provider                        = try(auth_settings_v2.value.default_provider, null)
      excluded_paths                          = try(auth_settings_v2.value.excluded_paths, null)
      forward_proxy_convention                = try(auth_settings_v2.value.forward_proxy_convention, null)
      forward_proxy_custom_host_header_name   = try(auth_settings_v2.value.forward_proxy_custom_host_header_name, null)
      forward_proxy_custom_scheme_header_name = try(auth_settings_v2.value.forward_proxy_custom_scheme_header_name, null)
      http_route_api_prefix                   = try(auth_settings_v2.value.http_route_api_prefix, "/.auth")
      require_authentication                  = try(auth_settings_v2.value.require_authentication, true)
      require_https                           = try(auth_settings_v2.value.require_https, true)
      runtime_version                         = try(auth_settings_v2.value.runtime_version, "~1")
      unauthenticated_action                  = try(auth_settings_v2.value.unauthenticated_action, "RedirectToLoginPage")

      dynamic "active_directory_v2" {
        for_each = try(auth_settings_v2.value.active_directory_v2, null) == null ? [] : [auth_settings_v2.value.active_directory_v2]

        content {
          allowed_applications                 = try(active_directory_v2.value.allowed_applications, null)
          allowed_audiences                    = try(active_directory_v2.value.allowed_audiences, null)
          allowed_groups                       = try(active_directory_v2.value.allowed_groups, null)
          allowed_identities                   = try(active_directory_v2.value.allowed_identities, null)
          client_id                            = active_directory_v2.value.client_id
          client_secret_certificate_thumbprint = try(active_directory_v2.value.client_secret_certificate_thumbprint, null)
          client_secret_setting_name           = try(active_directory_v2.value.client_secret_setting_name, null)
          jwt_allowed_client_applications      = try(active_directory_v2.value.jwt_allowed_client_applications, null)
          jwt_allowed_groups                   = try(active_directory_v2.value.jwt_allowed_groups, null)
          login_parameters                     = try(active_directory_v2.value.login_parameters, null)
          tenant_auth_endpoint                 = active_directory_v2.value.tenant_auth_endpoint
          www_authentication_disabled          = try(active_directory_v2.value.www_authentication_disabled, null)
        }
      }

      dynamic "custom_oidc_v2" {
        for_each = try(auth_settings_v2.value.custom_oidc_v2, [])

        content {
          client_id                     = custom_oidc_v2.value.client_id
          name                          = custom_oidc_v2.value.name
          name_claim_type               = try(custom_oidc_v2.value.name_claim_type, null)
          openid_configuration_endpoint = custom_oidc_v2.value.openid_configuration_endpoint
          scopes                        = try(custom_oidc_v2.value.scopes, null)
        }
      }

      dynamic "login" {
        for_each = [try(auth_settings_v2.value.login, {})]

        content {
          allowed_external_redirect_urls    = try(login.value.allowed_external_redirect_urls, null)
          cookie_expiration_convention      = try(login.value.cookie_expiration_convention, null)
          cookie_expiration_time            = try(login.value.cookie_expiration_time, null)
          logout_endpoint                   = try(login.value.logout_endpoint, null)
          nonce_expiration_time             = try(login.value.nonce_expiration_time, null)
          preserve_url_fragments_for_logins = try(login.value.preserve_url_fragments_for_logins, null)
          token_refresh_extension_time      = try(login.value.token_refresh_extension_time, null)
          token_store_enabled               = try(login.value.token_store_enabled, true)
          token_store_path                  = try(login.value.token_store_path, null)
          token_store_sas_setting_name      = try(login.value.token_store_sas_setting_name, null)
          validate_nonce                    = try(login.value.validate_nonce, true)
        }
      }
    }
  }

  dynamic "backup" {
    for_each = var.backup == null ? [] : [var.backup]

    content {
      enabled             = try(backup.value.enabled, true)
      name                = backup.value.name
      storage_account_url = backup.value.storage_account_url

      schedule {
        frequency_interval       = backup.value.schedule.frequency_interval
        frequency_unit           = backup.value.schedule.frequency_unit
        keep_at_least_one_backup = try(backup.value.schedule.keep_at_least_one_backup, null)
        retention_period_days    = try(backup.value.schedule.retention_period_days, null)
        start_time               = try(backup.value.schedule.start_time, null)
      }
    }
  }

  dynamic "identity" {
    for_each = local.identity_type != "" ? [1] : []

    content {
      type         = local.identity_type
      identity_ids = length(local.identity_ids) > 0 ? local.identity_ids : null
    }
  }

  dynamic "storage_account" {
    for_each = var.storage_mounts

    content {
      access_key   = storage_account.value.access_key
      account_name = storage_account.value.account_name
      mount_path   = try(storage_account.value.mount_path, null)
      name         = storage_account.value.name
      share_name   = storage_account.value.share_name
      type         = storage_account.value.type
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

  name                                           = local.function_app_name
  location                                       = local.location
  resource_group_name                            = local.resource_group_name
  service_plan_id                                = var.service_plan_id
  storage_account_name                           = local.storage_account_name_resolved
  storage_uses_managed_identity                  = true
  functions_extension_version                    = var.functions_extension_version
  builtin_logging_enabled                        = var.builtin_logging_enabled
  enabled                                        = var.enabled
  https_only                                     = var.https_only
  public_network_access_enabled                  = var.public_network_access_enabled
  client_certificate_enabled                     = var.client_certificate_enabled
  client_certificate_mode                        = var.client_certificate_mode
  client_certificate_exclusion_paths             = var.client_certificate_exclusion_paths
  content_share_force_disabled                   = var.content_share_force_disabled
  ftp_publish_basic_authentication_enabled       = var.ftp_publish_basic_authentication_enabled
  webdeploy_publish_basic_authentication_enabled = var.webdeploy_publish_basic_authentication_enabled
  virtual_network_backup_restore_enabled         = var.virtual_network_backup_restore_enabled
  virtual_network_subnet_id                      = local.vnet_integration_subnet_id_resolved
  vnet_image_pull_enabled                        = var.vnet_image_pull_enabled
  key_vault_reference_identity_id                = local.key_vault_reference_identity_id_resolved
  app_settings                                   = var.app_settings
  daily_memory_time_quota                        = var.daily_memory_time_quota
  zip_deploy_file                                = var.zip_deploy_file
  tags                                           = local.merged_tags

  dynamic "connection_string" {
    for_each = var.connection_strings

    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  site_config {
    always_on                                     = var.always_on
    api_definition_url                            = var.api_definition_url
    api_management_api_id                         = var.api_management_api_id
    app_command_line                              = var.app_command_line
    app_scale_limit                               = var.app_scale_limit
    application_insights_connection_string        = var.application_insights_connection_string
    application_insights_key                      = var.application_insights_key
    container_registry_managed_identity_client_id = var.container_registry_managed_identity_client_id
    container_registry_use_managed_identity       = var.container_registry_use_managed_identity
    default_documents                             = var.default_documents
    elastic_instance_minimum                      = var.elastic_instance_minimum
    ftps_state                                    = var.ftps_state
    health_check_eviction_time_in_min             = var.health_check_eviction_time_in_min
    health_check_path                             = var.health_check_path
    http2_enabled                                 = var.http2_enabled
    ip_restriction_default_action                 = var.ip_restriction_default_action
    load_balancing_mode                           = var.load_balancing_mode
    managed_pipeline_mode                         = var.managed_pipeline_mode
    minimum_tls_version                           = var.minimum_tls_version
    pre_warmed_instance_count                     = var.pre_warmed_instance_count
    remote_debugging_enabled                      = var.remote_debugging_enabled
    remote_debugging_version                      = var.remote_debugging_version
    runtime_scale_monitoring_enabled              = var.runtime_scale_monitoring_enabled
    scm_ip_restriction_default_action             = var.scm_ip_restriction_default_action
    scm_minimum_tls_version                       = var.scm_minimum_tls_version
    scm_use_main_ip_restriction                   = var.scm_use_main_ip_restriction
    use_32_bit_worker                             = var.use_32_bit_worker
    vnet_route_all_enabled                        = var.vnet_route_all_enabled
    websockets_enabled                            = var.websockets_enabled
    worker_count                                  = var.worker_count

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

        dynamic "docker" {
          for_each = try(application_stack.value.docker, null) == null ? [] : [application_stack.value.docker]

          content {
            image_name        = docker.value.image_name
            image_tag         = docker.value.image_tag
            registry_url      = docker.value.registry_url
            registry_username = try(docker.value.registry_username, null)
            registry_password = try(docker.value.registry_password, null)
          }
        }
      }
    }

    dynamic "app_service_logs" {
      for_each = var.app_service_logs == null ? [] : [var.app_service_logs]

      content {
        disk_quota_mb         = try(app_service_logs.value.disk_quota_mb, null)
        retention_period_days = try(app_service_logs.value.retention_period_days, null)
      }
    }

    dynamic "cors" {
      for_each = var.cors == null ? [] : [var.cors]

      content {
        allowed_origins     = try(cors.value.allowed_origins, [])
        support_credentials = try(cors.value.support_credentials, false)
      }
    }

    dynamic "ip_restriction" {
      for_each = var.ip_restrictions

      content {
        action                    = try(ip_restriction.value.action, "Allow")
        description               = try(ip_restriction.value.description, null)
        headers                   = try(ip_restriction.value.headers, null)
        ip_address                = try(ip_restriction.value.ip_address, null)
        name                      = try(ip_restriction.value.name, null)
        priority                  = try(ip_restriction.value.priority, null)
        service_tag               = try(ip_restriction.value.service_tag, null)
        virtual_network_subnet_id = try(ip_restriction.value.virtual_network_subnet_id, null)
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = var.scm_ip_restrictions

      content {
        action                    = try(scm_ip_restriction.value.action, "Allow")
        description               = try(scm_ip_restriction.value.description, null)
        headers                   = try(scm_ip_restriction.value.headers, null)
        ip_address                = try(scm_ip_restriction.value.ip_address, null)
        name                      = try(scm_ip_restriction.value.name, null)
        priority                  = try(scm_ip_restriction.value.priority, null)
        service_tag               = try(scm_ip_restriction.value.service_tag, null)
        virtual_network_subnet_id = try(scm_ip_restriction.value.virtual_network_subnet_id, null)
      }
    }
  }

  dynamic "auth_settings" {
    for_each = var.auth_settings == null ? [] : [var.auth_settings]

    content {
      additional_login_parameters    = try(auth_settings.value.additional_login_parameters, null)
      allowed_external_redirect_urls = try(auth_settings.value.allowed_external_redirect_urls, null)
      default_provider               = try(auth_settings.value.default_provider, null)
      enabled                        = auth_settings.value.enabled
      issuer                         = try(auth_settings.value.issuer, null)
      runtime_version                = try(auth_settings.value.runtime_version, null)
      token_refresh_extension_hours  = try(auth_settings.value.token_refresh_extension_hours, null)
      token_store_enabled            = try(auth_settings.value.token_store_enabled, null)
      unauthenticated_client_action  = try(auth_settings.value.unauthenticated_client_action, null)

      dynamic "active_directory" {
        for_each = try(auth_settings.value.active_directory, null) == null ? [] : [auth_settings.value.active_directory]

        content {
          allowed_audiences          = try(active_directory.value.allowed_audiences, null)
          client_id                  = active_directory.value.client_id
          client_secret              = try(active_directory.value.client_secret, null)
          client_secret_setting_name = try(active_directory.value.client_secret_setting_name, null)
        }
      }
    }
  }

  dynamic "auth_settings_v2" {
    for_each = var.auth_settings_v2 == null ? [] : [var.auth_settings_v2]

    content {
      auth_enabled                            = try(auth_settings_v2.value.auth_enabled, true)
      config_file_path                        = try(auth_settings_v2.value.config_file_path, null)
      default_provider                        = try(auth_settings_v2.value.default_provider, null)
      excluded_paths                          = try(auth_settings_v2.value.excluded_paths, null)
      forward_proxy_convention                = try(auth_settings_v2.value.forward_proxy_convention, null)
      forward_proxy_custom_host_header_name   = try(auth_settings_v2.value.forward_proxy_custom_host_header_name, null)
      forward_proxy_custom_scheme_header_name = try(auth_settings_v2.value.forward_proxy_custom_scheme_header_name, null)
      http_route_api_prefix                   = try(auth_settings_v2.value.http_route_api_prefix, "/.auth")
      require_authentication                  = try(auth_settings_v2.value.require_authentication, true)
      require_https                           = try(auth_settings_v2.value.require_https, true)
      runtime_version                         = try(auth_settings_v2.value.runtime_version, "~1")
      unauthenticated_action                  = try(auth_settings_v2.value.unauthenticated_action, "RedirectToLoginPage")

      dynamic "active_directory_v2" {
        for_each = try(auth_settings_v2.value.active_directory_v2, null) == null ? [] : [auth_settings_v2.value.active_directory_v2]

        content {
          allowed_applications                 = try(active_directory_v2.value.allowed_applications, null)
          allowed_audiences                    = try(active_directory_v2.value.allowed_audiences, null)
          allowed_groups                       = try(active_directory_v2.value.allowed_groups, null)
          allowed_identities                   = try(active_directory_v2.value.allowed_identities, null)
          client_id                            = active_directory_v2.value.client_id
          client_secret_certificate_thumbprint = try(active_directory_v2.value.client_secret_certificate_thumbprint, null)
          client_secret_setting_name           = try(active_directory_v2.value.client_secret_setting_name, null)
          jwt_allowed_client_applications      = try(active_directory_v2.value.jwt_allowed_client_applications, null)
          jwt_allowed_groups                   = try(active_directory_v2.value.jwt_allowed_groups, null)
          login_parameters                     = try(active_directory_v2.value.login_parameters, null)
          tenant_auth_endpoint                 = active_directory_v2.value.tenant_auth_endpoint
          www_authentication_disabled          = try(active_directory_v2.value.www_authentication_disabled, null)
        }
      }

      dynamic "custom_oidc_v2" {
        for_each = try(auth_settings_v2.value.custom_oidc_v2, [])

        content {
          client_id                     = custom_oidc_v2.value.client_id
          name                          = custom_oidc_v2.value.name
          name_claim_type               = try(custom_oidc_v2.value.name_claim_type, null)
          openid_configuration_endpoint = custom_oidc_v2.value.openid_configuration_endpoint
          scopes                        = try(custom_oidc_v2.value.scopes, null)
        }
      }

      dynamic "login" {
        for_each = [try(auth_settings_v2.value.login, {})]

        content {
          allowed_external_redirect_urls    = try(login.value.allowed_external_redirect_urls, null)
          cookie_expiration_convention      = try(login.value.cookie_expiration_convention, null)
          cookie_expiration_time            = try(login.value.cookie_expiration_time, null)
          logout_endpoint                   = try(login.value.logout_endpoint, null)
          nonce_expiration_time             = try(login.value.nonce_expiration_time, null)
          preserve_url_fragments_for_logins = try(login.value.preserve_url_fragments_for_logins, null)
          token_refresh_extension_time      = try(login.value.token_refresh_extension_time, null)
          token_store_enabled               = try(login.value.token_store_enabled, true)
          token_store_path                  = try(login.value.token_store_path, null)
          token_store_sas_setting_name      = try(login.value.token_store_sas_setting_name, null)
          validate_nonce                    = try(login.value.validate_nonce, true)
        }
      }
    }
  }

  dynamic "backup" {
    for_each = var.backup == null ? [] : [var.backup]

    content {
      enabled             = try(backup.value.enabled, true)
      name                = backup.value.name
      storage_account_url = backup.value.storage_account_url

      schedule {
        frequency_interval       = backup.value.schedule.frequency_interval
        frequency_unit           = backup.value.schedule.frequency_unit
        keep_at_least_one_backup = try(backup.value.schedule.keep_at_least_one_backup, null)
        retention_period_days    = try(backup.value.schedule.retention_period_days, null)
        start_time               = try(backup.value.schedule.start_time, null)
      }
    }
  }

  dynamic "identity" {
    for_each = local.identity_type != "" ? [1] : []

    content {
      type         = local.identity_type
      identity_ids = length(local.identity_ids) > 0 ? local.identity_ids : null
    }
  }

  dynamic "storage_account" {
    for_each = var.storage_mounts

    content {
      access_key   = storage_account.value.access_key
      account_name = storage_account.value.account_name
      mount_path   = try(storage_account.value.mount_path, null)
      name         = storage_account.value.name
      share_name   = storage_account.value.share_name
      type         = storage_account.value.type
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

  name                                           = local.function_app_name
  location                                       = local.location
  resource_group_name                            = local.resource_group_name
  service_plan_id                                = var.service_plan_id
  storage_account_name                           = local.storage_uses_key_vault_secret ? null : local.storage_account_name_resolved
  storage_account_access_key                     = local.storage_account_access_key
  storage_key_vault_secret_id                    = local.storage_key_vault_secret_id
  functions_extension_version                    = var.functions_extension_version
  builtin_logging_enabled                        = var.builtin_logging_enabled
  enabled                                        = var.enabled
  https_only                                     = var.https_only
  public_network_access_enabled                  = var.public_network_access_enabled
  client_certificate_enabled                     = var.client_certificate_enabled
  client_certificate_mode                        = var.client_certificate_mode
  client_certificate_exclusion_paths             = var.client_certificate_exclusion_paths
  content_share_force_disabled                   = var.content_share_force_disabled
  ftp_publish_basic_authentication_enabled       = var.ftp_publish_basic_authentication_enabled
  webdeploy_publish_basic_authentication_enabled = var.webdeploy_publish_basic_authentication_enabled
  virtual_network_backup_restore_enabled         = var.virtual_network_backup_restore_enabled
  virtual_network_subnet_id                      = local.vnet_integration_subnet_id_resolved
  vnet_image_pull_enabled                        = var.vnet_image_pull_enabled
  key_vault_reference_identity_id                = local.key_vault_reference_identity_id_resolved
  app_settings                                   = var.app_settings
  daily_memory_time_quota                        = var.daily_memory_time_quota
  zip_deploy_file                                = var.zip_deploy_file
  tags                                           = local.merged_tags

  dynamic "connection_string" {
    for_each = var.connection_strings

    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  site_config {
    always_on                              = var.always_on
    api_definition_url                     = var.api_definition_url
    api_management_api_id                  = var.api_management_api_id
    app_command_line                       = var.app_command_line
    app_scale_limit                        = var.app_scale_limit
    application_insights_connection_string = var.application_insights_connection_string
    application_insights_key               = var.application_insights_key
    default_documents                      = var.default_documents
    elastic_instance_minimum               = var.elastic_instance_minimum
    ftps_state                             = var.ftps_state
    health_check_eviction_time_in_min      = var.health_check_eviction_time_in_min
    health_check_path                      = var.health_check_path
    http2_enabled                          = var.http2_enabled
    ip_restriction_default_action          = var.ip_restriction_default_action
    load_balancing_mode                    = var.load_balancing_mode
    managed_pipeline_mode                  = var.managed_pipeline_mode
    minimum_tls_version                    = var.minimum_tls_version
    pre_warmed_instance_count              = var.pre_warmed_instance_count
    remote_debugging_enabled               = var.remote_debugging_enabled
    remote_debugging_version               = var.remote_debugging_version
    runtime_scale_monitoring_enabled       = var.runtime_scale_monitoring_enabled
    scm_ip_restriction_default_action      = var.scm_ip_restriction_default_action
    scm_minimum_tls_version                = var.scm_minimum_tls_version
    scm_use_main_ip_restriction            = var.scm_use_main_ip_restriction
    use_32_bit_worker                      = var.use_32_bit_worker
    vnet_route_all_enabled                 = var.vnet_route_all_enabled
    websockets_enabled                     = var.websockets_enabled
    worker_count                           = var.worker_count

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

    dynamic "app_service_logs" {
      for_each = var.app_service_logs == null ? [] : [var.app_service_logs]

      content {
        disk_quota_mb         = try(app_service_logs.value.disk_quota_mb, null)
        retention_period_days = try(app_service_logs.value.retention_period_days, null)
      }
    }

    dynamic "cors" {
      for_each = var.cors == null ? [] : [var.cors]

      content {
        allowed_origins     = try(cors.value.allowed_origins, [])
        support_credentials = try(cors.value.support_credentials, false)
      }
    }

    dynamic "ip_restriction" {
      for_each = var.ip_restrictions

      content {
        action                    = try(ip_restriction.value.action, "Allow")
        description               = try(ip_restriction.value.description, null)
        headers                   = try(ip_restriction.value.headers, null)
        ip_address                = try(ip_restriction.value.ip_address, null)
        name                      = try(ip_restriction.value.name, null)
        priority                  = try(ip_restriction.value.priority, null)
        service_tag               = try(ip_restriction.value.service_tag, null)
        virtual_network_subnet_id = try(ip_restriction.value.virtual_network_subnet_id, null)
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = var.scm_ip_restrictions

      content {
        action                    = try(scm_ip_restriction.value.action, "Allow")
        description               = try(scm_ip_restriction.value.description, null)
        headers                   = try(scm_ip_restriction.value.headers, null)
        ip_address                = try(scm_ip_restriction.value.ip_address, null)
        name                      = try(scm_ip_restriction.value.name, null)
        priority                  = try(scm_ip_restriction.value.priority, null)
        service_tag               = try(scm_ip_restriction.value.service_tag, null)
        virtual_network_subnet_id = try(scm_ip_restriction.value.virtual_network_subnet_id, null)
      }
    }
  }

  dynamic "auth_settings" {
    for_each = var.auth_settings == null ? [] : [var.auth_settings]

    content {
      additional_login_parameters    = try(auth_settings.value.additional_login_parameters, null)
      allowed_external_redirect_urls = try(auth_settings.value.allowed_external_redirect_urls, null)
      default_provider               = try(auth_settings.value.default_provider, null)
      enabled                        = auth_settings.value.enabled
      issuer                         = try(auth_settings.value.issuer, null)
      runtime_version                = try(auth_settings.value.runtime_version, null)
      token_refresh_extension_hours  = try(auth_settings.value.token_refresh_extension_hours, null)
      token_store_enabled            = try(auth_settings.value.token_store_enabled, null)
      unauthenticated_client_action  = try(auth_settings.value.unauthenticated_client_action, null)

      dynamic "active_directory" {
        for_each = try(auth_settings.value.active_directory, null) == null ? [] : [auth_settings.value.active_directory]

        content {
          allowed_audiences          = try(active_directory.value.allowed_audiences, null)
          client_id                  = active_directory.value.client_id
          client_secret              = try(active_directory.value.client_secret, null)
          client_secret_setting_name = try(active_directory.value.client_secret_setting_name, null)
        }
      }
    }
  }

  dynamic "auth_settings_v2" {
    for_each = var.auth_settings_v2 == null ? [] : [var.auth_settings_v2]

    content {
      auth_enabled                            = try(auth_settings_v2.value.auth_enabled, true)
      config_file_path                        = try(auth_settings_v2.value.config_file_path, null)
      default_provider                        = try(auth_settings_v2.value.default_provider, null)
      excluded_paths                          = try(auth_settings_v2.value.excluded_paths, null)
      forward_proxy_convention                = try(auth_settings_v2.value.forward_proxy_convention, null)
      forward_proxy_custom_host_header_name   = try(auth_settings_v2.value.forward_proxy_custom_host_header_name, null)
      forward_proxy_custom_scheme_header_name = try(auth_settings_v2.value.forward_proxy_custom_scheme_header_name, null)
      http_route_api_prefix                   = try(auth_settings_v2.value.http_route_api_prefix, "/.auth")
      require_authentication                  = try(auth_settings_v2.value.require_authentication, true)
      require_https                           = try(auth_settings_v2.value.require_https, true)
      runtime_version                         = try(auth_settings_v2.value.runtime_version, "~1")
      unauthenticated_action                  = try(auth_settings_v2.value.unauthenticated_action, "RedirectToLoginPage")

      dynamic "active_directory_v2" {
        for_each = try(auth_settings_v2.value.active_directory_v2, null) == null ? [] : [auth_settings_v2.value.active_directory_v2]

        content {
          allowed_applications                 = try(active_directory_v2.value.allowed_applications, null)
          allowed_audiences                    = try(active_directory_v2.value.allowed_audiences, null)
          allowed_groups                       = try(active_directory_v2.value.allowed_groups, null)
          allowed_identities                   = try(active_directory_v2.value.allowed_identities, null)
          client_id                            = active_directory_v2.value.client_id
          client_secret_certificate_thumbprint = try(active_directory_v2.value.client_secret_certificate_thumbprint, null)
          client_secret_setting_name           = try(active_directory_v2.value.client_secret_setting_name, null)
          jwt_allowed_client_applications      = try(active_directory_v2.value.jwt_allowed_client_applications, null)
          jwt_allowed_groups                   = try(active_directory_v2.value.jwt_allowed_groups, null)
          login_parameters                     = try(active_directory_v2.value.login_parameters, null)
          tenant_auth_endpoint                 = active_directory_v2.value.tenant_auth_endpoint
          www_authentication_disabled          = try(active_directory_v2.value.www_authentication_disabled, null)
        }
      }

      dynamic "custom_oidc_v2" {
        for_each = try(auth_settings_v2.value.custom_oidc_v2, [])

        content {
          client_id                     = custom_oidc_v2.value.client_id
          name                          = custom_oidc_v2.value.name
          name_claim_type               = try(custom_oidc_v2.value.name_claim_type, null)
          openid_configuration_endpoint = custom_oidc_v2.value.openid_configuration_endpoint
          scopes                        = try(custom_oidc_v2.value.scopes, null)
        }
      }

      dynamic "login" {
        for_each = [try(auth_settings_v2.value.login, {})]

        content {
          allowed_external_redirect_urls    = try(login.value.allowed_external_redirect_urls, null)
          cookie_expiration_convention      = try(login.value.cookie_expiration_convention, null)
          cookie_expiration_time            = try(login.value.cookie_expiration_time, null)
          logout_endpoint                   = try(login.value.logout_endpoint, null)
          nonce_expiration_time             = try(login.value.nonce_expiration_time, null)
          preserve_url_fragments_for_logins = try(login.value.preserve_url_fragments_for_logins, null)
          token_refresh_extension_time      = try(login.value.token_refresh_extension_time, null)
          token_store_enabled               = try(login.value.token_store_enabled, true)
          token_store_path                  = try(login.value.token_store_path, null)
          token_store_sas_setting_name      = try(login.value.token_store_sas_setting_name, null)
          validate_nonce                    = try(login.value.validate_nonce, true)
        }
      }
    }
  }

  dynamic "backup" {
    for_each = var.backup == null ? [] : [var.backup]

    content {
      enabled             = try(backup.value.enabled, true)
      name                = backup.value.name
      storage_account_url = backup.value.storage_account_url

      schedule {
        frequency_interval       = backup.value.schedule.frequency_interval
        frequency_unit           = backup.value.schedule.frequency_unit
        keep_at_least_one_backup = try(backup.value.schedule.keep_at_least_one_backup, null)
        retention_period_days    = try(backup.value.schedule.retention_period_days, null)
        start_time               = try(backup.value.schedule.start_time, null)
      }
    }
  }

  dynamic "identity" {
    for_each = local.identity_type != "" ? [1] : []

    content {
      type         = local.identity_type
      identity_ids = length(local.identity_ids) > 0 ? local.identity_ids : null
    }
  }

  dynamic "storage_account" {
    for_each = var.storage_mounts

    content {
      access_key   = storage_account.value.access_key
      account_name = storage_account.value.account_name
      mount_path   = try(storage_account.value.mount_path, null)
      name         = storage_account.value.name
      share_name   = storage_account.value.share_name
      type         = storage_account.value.type
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

  name                                           = local.function_app_name
  location                                       = local.location
  resource_group_name                            = local.resource_group_name
  service_plan_id                                = var.service_plan_id
  storage_account_name                           = local.storage_account_name_resolved
  storage_uses_managed_identity                  = true
  functions_extension_version                    = var.functions_extension_version
  builtin_logging_enabled                        = var.builtin_logging_enabled
  enabled                                        = var.enabled
  https_only                                     = var.https_only
  public_network_access_enabled                  = var.public_network_access_enabled
  client_certificate_enabled                     = var.client_certificate_enabled
  client_certificate_mode                        = var.client_certificate_mode
  client_certificate_exclusion_paths             = var.client_certificate_exclusion_paths
  content_share_force_disabled                   = var.content_share_force_disabled
  ftp_publish_basic_authentication_enabled       = var.ftp_publish_basic_authentication_enabled
  webdeploy_publish_basic_authentication_enabled = var.webdeploy_publish_basic_authentication_enabled
  virtual_network_backup_restore_enabled         = var.virtual_network_backup_restore_enabled
  virtual_network_subnet_id                      = local.vnet_integration_subnet_id_resolved
  vnet_image_pull_enabled                        = var.vnet_image_pull_enabled
  key_vault_reference_identity_id                = local.key_vault_reference_identity_id_resolved
  app_settings                                   = var.app_settings
  daily_memory_time_quota                        = var.daily_memory_time_quota
  zip_deploy_file                                = var.zip_deploy_file
  tags                                           = local.merged_tags

  dynamic "connection_string" {
    for_each = var.connection_strings

    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  site_config {
    always_on                              = var.always_on
    api_definition_url                     = var.api_definition_url
    api_management_api_id                  = var.api_management_api_id
    app_command_line                       = var.app_command_line
    app_scale_limit                        = var.app_scale_limit
    application_insights_connection_string = var.application_insights_connection_string
    application_insights_key               = var.application_insights_key
    default_documents                      = var.default_documents
    elastic_instance_minimum               = var.elastic_instance_minimum
    ftps_state                             = var.ftps_state
    health_check_eviction_time_in_min      = var.health_check_eviction_time_in_min
    health_check_path                      = var.health_check_path
    http2_enabled                          = var.http2_enabled
    ip_restriction_default_action          = var.ip_restriction_default_action
    load_balancing_mode                    = var.load_balancing_mode
    managed_pipeline_mode                  = var.managed_pipeline_mode
    minimum_tls_version                    = var.minimum_tls_version
    pre_warmed_instance_count              = var.pre_warmed_instance_count
    remote_debugging_enabled               = var.remote_debugging_enabled
    remote_debugging_version               = var.remote_debugging_version
    runtime_scale_monitoring_enabled       = var.runtime_scale_monitoring_enabled
    scm_ip_restriction_default_action      = var.scm_ip_restriction_default_action
    scm_minimum_tls_version                = var.scm_minimum_tls_version
    scm_use_main_ip_restriction            = var.scm_use_main_ip_restriction
    use_32_bit_worker                      = var.use_32_bit_worker
    vnet_route_all_enabled                 = var.vnet_route_all_enabled
    websockets_enabled                     = var.websockets_enabled
    worker_count                           = var.worker_count

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

    dynamic "app_service_logs" {
      for_each = var.app_service_logs == null ? [] : [var.app_service_logs]

      content {
        disk_quota_mb         = try(app_service_logs.value.disk_quota_mb, null)
        retention_period_days = try(app_service_logs.value.retention_period_days, null)
      }
    }

    dynamic "cors" {
      for_each = var.cors == null ? [] : [var.cors]

      content {
        allowed_origins     = try(cors.value.allowed_origins, [])
        support_credentials = try(cors.value.support_credentials, false)
      }
    }

    dynamic "ip_restriction" {
      for_each = var.ip_restrictions

      content {
        action                    = try(ip_restriction.value.action, "Allow")
        description               = try(ip_restriction.value.description, null)
        headers                   = try(ip_restriction.value.headers, null)
        ip_address                = try(ip_restriction.value.ip_address, null)
        name                      = try(ip_restriction.value.name, null)
        priority                  = try(ip_restriction.value.priority, null)
        service_tag               = try(ip_restriction.value.service_tag, null)
        virtual_network_subnet_id = try(ip_restriction.value.virtual_network_subnet_id, null)
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = var.scm_ip_restrictions

      content {
        action                    = try(scm_ip_restriction.value.action, "Allow")
        description               = try(scm_ip_restriction.value.description, null)
        headers                   = try(scm_ip_restriction.value.headers, null)
        ip_address                = try(scm_ip_restriction.value.ip_address, null)
        name                      = try(scm_ip_restriction.value.name, null)
        priority                  = try(scm_ip_restriction.value.priority, null)
        service_tag               = try(scm_ip_restriction.value.service_tag, null)
        virtual_network_subnet_id = try(scm_ip_restriction.value.virtual_network_subnet_id, null)
      }
    }
  }

  dynamic "auth_settings" {
    for_each = var.auth_settings == null ? [] : [var.auth_settings]

    content {
      additional_login_parameters    = try(auth_settings.value.additional_login_parameters, null)
      allowed_external_redirect_urls = try(auth_settings.value.allowed_external_redirect_urls, null)
      default_provider               = try(auth_settings.value.default_provider, null)
      enabled                        = auth_settings.value.enabled
      issuer                         = try(auth_settings.value.issuer, null)
      runtime_version                = try(auth_settings.value.runtime_version, null)
      token_refresh_extension_hours  = try(auth_settings.value.token_refresh_extension_hours, null)
      token_store_enabled            = try(auth_settings.value.token_store_enabled, null)
      unauthenticated_client_action  = try(auth_settings.value.unauthenticated_client_action, null)

      dynamic "active_directory" {
        for_each = try(auth_settings.value.active_directory, null) == null ? [] : [auth_settings.value.active_directory]

        content {
          allowed_audiences          = try(active_directory.value.allowed_audiences, null)
          client_id                  = active_directory.value.client_id
          client_secret              = try(active_directory.value.client_secret, null)
          client_secret_setting_name = try(active_directory.value.client_secret_setting_name, null)
        }
      }
    }
  }

  dynamic "auth_settings_v2" {
    for_each = var.auth_settings_v2 == null ? [] : [var.auth_settings_v2]

    content {
      auth_enabled                            = try(auth_settings_v2.value.auth_enabled, true)
      config_file_path                        = try(auth_settings_v2.value.config_file_path, null)
      default_provider                        = try(auth_settings_v2.value.default_provider, null)
      excluded_paths                          = try(auth_settings_v2.value.excluded_paths, null)
      forward_proxy_convention                = try(auth_settings_v2.value.forward_proxy_convention, null)
      forward_proxy_custom_host_header_name   = try(auth_settings_v2.value.forward_proxy_custom_host_header_name, null)
      forward_proxy_custom_scheme_header_name = try(auth_settings_v2.value.forward_proxy_custom_scheme_header_name, null)
      http_route_api_prefix                   = try(auth_settings_v2.value.http_route_api_prefix, "/.auth")
      require_authentication                  = try(auth_settings_v2.value.require_authentication, true)
      require_https                           = try(auth_settings_v2.value.require_https, true)
      runtime_version                         = try(auth_settings_v2.value.runtime_version, "~1")
      unauthenticated_action                  = try(auth_settings_v2.value.unauthenticated_action, "RedirectToLoginPage")

      dynamic "active_directory_v2" {
        for_each = try(auth_settings_v2.value.active_directory_v2, null) == null ? [] : [auth_settings_v2.value.active_directory_v2]

        content {
          allowed_applications                 = try(active_directory_v2.value.allowed_applications, null)
          allowed_audiences                    = try(active_directory_v2.value.allowed_audiences, null)
          allowed_groups                       = try(active_directory_v2.value.allowed_groups, null)
          allowed_identities                   = try(active_directory_v2.value.allowed_identities, null)
          client_id                            = active_directory_v2.value.client_id
          client_secret_certificate_thumbprint = try(active_directory_v2.value.client_secret_certificate_thumbprint, null)
          client_secret_setting_name           = try(active_directory_v2.value.client_secret_setting_name, null)
          jwt_allowed_client_applications      = try(active_directory_v2.value.jwt_allowed_client_applications, null)
          jwt_allowed_groups                   = try(active_directory_v2.value.jwt_allowed_groups, null)
          login_parameters                     = try(active_directory_v2.value.login_parameters, null)
          tenant_auth_endpoint                 = active_directory_v2.value.tenant_auth_endpoint
          www_authentication_disabled          = try(active_directory_v2.value.www_authentication_disabled, null)
        }
      }

      dynamic "custom_oidc_v2" {
        for_each = try(auth_settings_v2.value.custom_oidc_v2, [])

        content {
          client_id                     = custom_oidc_v2.value.client_id
          name                          = custom_oidc_v2.value.name
          name_claim_type               = try(custom_oidc_v2.value.name_claim_type, null)
          openid_configuration_endpoint = custom_oidc_v2.value.openid_configuration_endpoint
          scopes                        = try(custom_oidc_v2.value.scopes, null)
        }
      }

      dynamic "login" {
        for_each = [try(auth_settings_v2.value.login, {})]

        content {
          allowed_external_redirect_urls    = try(login.value.allowed_external_redirect_urls, null)
          cookie_expiration_convention      = try(login.value.cookie_expiration_convention, null)
          cookie_expiration_time            = try(login.value.cookie_expiration_time, null)
          logout_endpoint                   = try(login.value.logout_endpoint, null)
          nonce_expiration_time             = try(login.value.nonce_expiration_time, null)
          preserve_url_fragments_for_logins = try(login.value.preserve_url_fragments_for_logins, null)
          token_refresh_extension_time      = try(login.value.token_refresh_extension_time, null)
          token_store_enabled               = try(login.value.token_store_enabled, true)
          token_store_path                  = try(login.value.token_store_path, null)
          token_store_sas_setting_name      = try(login.value.token_store_sas_setting_name, null)
          validate_nonce                    = try(login.value.validate_nonce, true)
        }
      }
    }
  }

  dynamic "backup" {
    for_each = var.backup == null ? [] : [var.backup]

    content {
      enabled             = try(backup.value.enabled, true)
      name                = backup.value.name
      storage_account_url = backup.value.storage_account_url

      schedule {
        frequency_interval       = backup.value.schedule.frequency_interval
        frequency_unit           = backup.value.schedule.frequency_unit
        keep_at_least_one_backup = try(backup.value.schedule.keep_at_least_one_backup, null)
        retention_period_days    = try(backup.value.schedule.retention_period_days, null)
        start_time               = try(backup.value.schedule.start_time, null)
      }
    }
  }

  dynamic "identity" {
    for_each = local.identity_type != "" ? [1] : []

    content {
      type         = local.identity_type
      identity_ids = length(local.identity_ids) > 0 ? local.identity_ids : null
    }
  }

  dynamic "storage_account" {
    for_each = var.storage_mounts

    content {
      access_key   = storage_account.value.access_key
      account_name = storage_account.value.account_name
      mount_path   = try(storage_account.value.mount_path, null)
      name         = storage_account.value.name
      share_name   = storage_account.value.share_name
      type         = storage_account.value.type
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

  name                          = local.private_endpoint_name
  location                      = local.location
  resource_group_name           = local.resource_group_name
  subnet_id                     = local.private_endpoint_subnet_id_resolved
  custom_network_interface_name = local.private_endpoint_network_interface_name
  tags                          = local.merged_tags

  private_service_connection {
    name                           = local.private_service_connection_name
    private_connection_resource_id = local.function_app.id
    subresource_names              = ["sites"]
    is_manual_connection           = var.private_endpoint_manual_connection
    request_message                = local.private_endpoint_manual_request_message
  }

  dynamic "ip_configuration" {
    for_each = var.private_endpoint_ip_configurations

    content {
      member_name        = try(ip_configuration.value.member_name, "sites")
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      subresource_name   = try(ip_configuration.value.subresource_name, "sites")
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
  target_resource_id             = local.function_app.id
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

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = local.app_admin_group_principal_ids

  scope                = local.function_app.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = local.app_user_group_principal_ids

  scope                = local.function_app.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                                  = local.function_app.id
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
