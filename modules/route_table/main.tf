# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: route_table
# Description: Deploys Azure Route Tables for user-defined routing and traffic steering.
#              The module supports route definitions, BGP propagation controls, subnet associations through composition, diagnostics where applicable, and resource group tag inheritance for governance alignment.
# Owner: Cloud Center of Excellence (CCOE)
# Maintainer: Andy Xuan@CCOE
# Repository: CCOE-Azure/azure-template
#
# Created: 2026-04-17
# Modified: 2026-07-08
# Version: 1.3.0
#
# Change History:
# - 2026-04-17 v1.0.0: Established reusable route_table module baseline for the CCOE Azure IaC template library.
# - 2026-07-08 v1.0.0: Added standardized module metadata header with ownership, maintainer, license, dates, version, and change history.
#
# This Terraform module is maintained as part of the CCOE Azure IaC template library.
# Use, modification, and distribution are governed by the repository license and organizational policy.

resource "azurerm_route_table" "this" {
  name                          = local.route_table_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  bgp_route_propagation_enabled = !var.disable_bgp_route_propagation
  tags                          = local.merged_tags

  dynamic "route" {
    for_each = var.routes

    content {
      name                   = route.key
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = try(route.value.next_hop_in_ip_address, null)
    }
  }
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each = toset(var.subnet_ids)

  subnet_id      = each.value
  route_table_id = azurerm_route_table.this.id
}
