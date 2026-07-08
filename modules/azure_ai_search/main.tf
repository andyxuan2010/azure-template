# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: azure_ai_search
# Description: Deploys Azure AI Search services for indexed search and retrieval workloads.
#              The module supports SKU and capacity configuration, network access controls, managed identity, semantic search options, private endpoint integration, diagnostics, role assignments, and resource group tag inheritance for governance alignment.
# Owner: Cloud Center of Excellence (CCOE)
# Maintainer: Andy Xuan@CCOE
# Repository: CCOE-Azure/azure-template
#
# Created: 2026-05-14
# Modified: 2026-07-08
# Version: 1.3.0
#
# Change History:
# - 2026-05-14 v1.0.0: Established reusable azure_ai_search module baseline for the CCOE Azure IaC template library.
# - 2026-07-08 v1.0.0: Added standardized module metadata header with ownership, maintainer, license, dates, version, and change history.
#
# This Terraform module is maintained as part of the CCOE Azure IaC template library.
# Use, modification, and distribution are governed by the repository license and organizational policy.

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

resource "azurerm_search_service" "this" {
  name                                     = local.service_name
  resource_group_name                      = local.resource_group_name
  location                                 = local.location
  sku                                      = lower(trimspace(var.sku))
  replica_count                            = lower(trimspace(var.sku)) == "free" ? null : var.replica_count
  partition_count                          = lower(trimspace(var.sku)) == "free" ? null : var.partition_count
  hosting_mode                             = trimspace(var.hosting_mode)
  semantic_search_sku                      = trimspace(var.semantic_search_sku) != "" ? lower(trimspace(var.semantic_search_sku)) : null
  public_network_access_enabled            = var.public_network_access_enabled
  allowed_ips                              = length(local.allowed_ips) > 0 ? toset(local.allowed_ips) : null
  network_rule_bypass_option               = trimspace(var.network_rule_bypass_option)
  local_authentication_enabled             = var.local_authentication_enabled
  authentication_failure_mode              = trimspace(var.authentication_failure_mode) != "" ? trimspace(var.authentication_failure_mode) : null
  customer_managed_key_enforcement_enabled = var.customer_managed_key_enforcement_enabled
  tags                                     = local.merged_tags

  dynamic "identity" {
    for_each = local.identity_type != "" ? [1] : []

    content {
      type         = local.identity_type
      identity_ids = local.identity_ids
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
      condition     = lower(trimspace(var.sku)) != "free" || (!var.enable_private_endpoint && length(var.allowed_ips) == 0 && trimspace(var.semantic_search_sku) == "")
      error_message = "The free SKU does not support private endpoints, IP firewall rules, or semantic_search_sku."
    }

    precondition {
      condition     = trimspace(var.authentication_failure_mode) == "" || var.local_authentication_enabled
      error_message = "authentication_failure_mode can only be set when local_authentication_enabled is true."
    }

    precondition {
      condition     = lower(trimspace(var.hosting_mode)) != "highdensity" || lower(trimspace(var.sku)) == "standard3"
      error_message = "hosting_mode highDensity requires sku standard3."
    }

    precondition {
      condition     = lower(trimspace(var.hosting_mode)) != "highdensity" || contains([1, 2, 3], var.partition_count)
      error_message = "hosting_mode highDensity supports a maximum partition_count of 3."
    }

    precondition {
      condition     = !var.customer_managed_key_enforcement_enabled || local.identity_type != ""
      error_message = "customer_managed_key_enforcement_enabled requires a managed identity for customer-managed encryption workflows."
    }
  }
}

resource "azurerm_search_shared_private_link_service" "this" {
  for_each = var.shared_private_link_services

  name               = each.value.name
  search_service_id  = azurerm_search_service.this.id
  subresource_name   = each.value.subresource_name
  target_resource_id = each.value.target_resource_id
  request_message    = try(each.value.request_message, null)

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

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = local.app_admin_group_principal_ids

  scope                = azurerm_search_service.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = local.app_user_group_principal_ids

  scope                = azurerm_search_service.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                                  = azurerm_search_service.this.id
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

  name                          = "${var.private_endpoint_name_prefix}-${azurerm_search_service.this.name}"
  location                      = local.location
  resource_group_name           = local.resource_group_name
  subnet_id                     = local.private_endpoint_subnet_id_resolved
  custom_network_interface_name = trimspace(var.private_endpoint_network_interface_name) != "" ? var.private_endpoint_network_interface_name : null

  private_service_connection {
    name                           = "${var.private_service_connection_name_prefix}-${azurerm_search_service.this.name}"
    private_connection_resource_id = azurerm_search_service.this.id
    subresource_names              = ["searchService"]
    is_manual_connection           = var.private_endpoint_manual_connection_enabled
    request_message                = var.private_endpoint_manual_connection_enabled && trimspace(var.private_endpoint_request_message) != "" ? var.private_endpoint_request_message : null
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
  target_resource_id             = azurerm_search_service.this.id
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
