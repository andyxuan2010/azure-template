# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: vnet
# Description: Deploys Azure Virtual Networks for workload and platform network foundations.
#              The module supports address spaces, DNS settings, optional subnets, DDoS or related network configuration where provided, standardized naming, and resource group tag inheritance for governance alignment.
# Owner: Cloud Center of Excellence (CCOE)
# Maintainer: Andy Xuan@CCOE
# Repository: CCOE-Azure/azure-template
#
# Created: 2026-04-17
# Modified: 2026-07-08
# Version: 1.3.0
#
# Change History:
# - 2026-04-17 v1.0.0: Established reusable vnet module baseline for the CCOE Azure IaC template library.
# - 2026-07-08 v1.0.0: Added standardized module metadata header with ownership, maintainer, license, dates, version, and change history.
#
# This Terraform module is maintained as part of the CCOE Azure IaC template library.
# Use, modification, and distribution are governed by the repository license and organizational policy.

data "azurerm_resource_group" "rg" {
  count = local.resource_group_lookup_required ? 1 : 0

  name = var.resource_group_name
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
  length      = 4
  special     = false
  upper       = false
  min_numeric = 1
}

resource "azurerm_virtual_network" "this" {
  name                    = local.virtual_network_name
  location                = local.location
  resource_group_name     = var.resource_group_name
  address_space           = var.address_space
  dns_servers             = var.dns_servers
  bgp_community           = var.bgp_community
  edge_zone               = var.edge_zone
  flow_timeout_in_minutes = var.flow_timeout_in_minutes

  dynamic "ddos_protection_plan" {
    for_each = local.ddos_protection_enabled ? [1] : []

    content {
      id     = var.ddos_protection_plan_id
      enable = true
    }
  }

  tags = local.tags
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                                          = each.key
  resource_group_name                           = var.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.this.name
  address_prefixes                              = each.value.address_prefixes
  service_endpoints                             = each.value.service_endpoints
  service_endpoint_policy_ids                   = each.value.service_endpoint_policy_ids
  private_endpoint_network_policies             = each.value.private_endpoint_network_policies
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled

  dynamic "delegation" {
    for_each = each.value.delegations

    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_delegation_name
        actions = delegation.value.actions
      }
    }
  }
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = merge(
    { for object_id in local.app_admin_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_admin : "name:${name}" => group.object_id }
  )

  scope                = azurerm_virtual_network.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = merge(
    { for object_id in local.app_user_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_user : "name:${name}" => group.object_id }
  )

  scope                = azurerm_virtual_network.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostics ? 1 : 0

  name                       = "${azurerm_virtual_network.this.name}-diagnostic-setting"
  target_resource_id         = azurerm_virtual_network.this.id
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
