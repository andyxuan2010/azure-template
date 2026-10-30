# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: functionappflex
# Description: Deploys Azure Function Apps on the Flex Consumption hosting model.
#              The module supports Flex runtime and blob-container configuration, managed identity,
#              instance scaling, always-ready instances, VNet integration, app settings, and tag inheritance.
# Owner: Cloud Center of Excellence (CCOE)
# Maintainer: Andy Xuan@CCOE
# Repository: CCOE-Azure/azure-template
#
# Created: 2026-09-19
# Modified: 2026-09-19
# Version: 1.0.0
#
# Change History:
# - 2026-09-19 v1.0.0: Established the standardized Flex Consumption Function App module baseline.
#
# This Terraform module is maintained as part of the CCOE Azure IaC template library.
# Use, modification, and distribution are governed by the repository license and organizational policy.

resource "azurerm_function_app_flex_consumption" "this" {
  name                = local.function_app_name
  resource_group_name = var.resource_group_name
  location            = local.resolved_location
  service_plan_id     = var.service_plan_id

  runtime_name                                   = var.runtime_name
  runtime_version                                = var.runtime_version
  storage_container_type                         = var.storage_container_type
  storage_container_endpoint                     = var.storage_container_endpoint
  storage_authentication_type                    = var.storage_authentication_type
  storage_access_key                             = var.storage_access_key
  storage_user_assigned_identity_id              = var.storage_user_assigned_identity_id
  instance_memory_in_mb                          = var.instance_memory_in_mb
  maximum_instance_count                         = var.maximum_instance_count
  http_concurrency                               = var.http_concurrency
  enabled                                        = var.enabled
  https_only                                     = var.https_only
  public_network_access_enabled                  = var.public_network_access_enabled
  client_certificate_enabled                     = var.client_certificate_enabled
  client_certificate_mode                        = var.client_certificate_mode
  client_certificate_exclusion_paths             = var.client_certificate_exclusion_paths
  webdeploy_publish_basic_authentication_enabled = var.webdeploy_publish_basic_authentication_enabled
  virtual_network_subnet_id                      = var.virtual_network_subnet_id
  app_settings                                   = var.app_settings
  zip_deploy_file                                = var.zip_deploy_file
  tags                                           = local.tags

  dynamic "identity" {
    for_each = var.identity_type == null ? [] : [var.identity_type]

    content {
      type         = identity.value
      identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : null
    }
  }

  dynamic "always_ready" {
    for_each = var.always_ready

    content {
      name           = always_ready.key
      instance_count = always_ready.value
    }
  }

  site_config {
    app_command_line                       = var.app_command_line
    application_insights_connection_string = var.application_insights_connection_string
    application_insights_key               = var.application_insights_key
    default_documents                      = var.default_documents
    health_check_eviction_time_in_min      = var.health_check_eviction_time_in_min
    health_check_path                      = var.health_check_path
    http2_enabled                          = var.http2_enabled
    minimum_tls_version                    = var.minimum_tls_version
    runtime_scale_monitoring_enabled       = var.runtime_scale_monitoring_enabled
    scm_minimum_tls_version                = var.scm_minimum_tls_version
    use_32_bit_worker                      = var.use_32_bit_worker
    vnet_route_all_enabled                 = var.vnet_route_all_enabled
    websockets_enabled                     = var.websockets_enabled
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }

  lifecycle {
    precondition {
      condition = (
        (var.storage_authentication_type == "StorageAccountConnectionString" && try(trimspace(nonsensitive(var.storage_access_key)), "") != "" && var.storage_user_assigned_identity_id == null) ||
        (var.storage_authentication_type == "UserAssignedIdentity" && try(trimspace(var.storage_user_assigned_identity_id), "") != "" && nonsensitive(var.storage_access_key) == null)
      )
      error_message = "StorageAccountConnectionString requires storage_access_key and UserAssignedIdentity requires storage_user_assigned_identity_id; do not set both."
    }

    precondition {
      condition = (
        var.identity_type == null ||
        (contains(["SystemAssigned", "SystemAssigned, UserAssigned"], var.identity_type) && (var.identity_type == "SystemAssigned" || length(var.identity_ids) > 0)) ||
        (var.identity_type == "UserAssigned" && length(var.identity_ids) > 0)
      )
      error_message = "User-assigned identity types require at least one identity_id."
    }

    precondition {
      condition = (
        var.storage_user_assigned_identity_id == null ||
        (var.identity_type != null && contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type) && contains(var.identity_ids, var.storage_user_assigned_identity_id))
      )
      error_message = "storage_user_assigned_identity_id must also be assigned to the Function App through identity_type and identity_ids."
    }
  }
}
