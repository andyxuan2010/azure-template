# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: private_endpoint
# Description: Deploys Azure Private Endpoints for private network access to supported Azure platform services.
#              The module supports private service connections, subnet lookup or explicit subnet IDs, private DNS zone group associations, generated naming, and resource group tag inheritance for governance alignment.
# Owner: Cloud Center of Excellence (CCOE)
# Maintainer: Andy Xuan@CCOE
# Repository: CCOE-Azure/azure-template
#
# Created: 2026-07-02
# Modified: 2026-07-08
# Version: 1.3.0
#
# Change History:
# - 2026-07-02 v1.0.0: Established reusable private_endpoint module baseline for the CCOE Azure IaC template library.
# - 2026-07-08 v1.0.0: Added standardized module metadata header with ownership, maintainer, license, dates, version, and change history.
#
# This Terraform module is maintained as part of the CCOE Azure IaC template library.
# Use, modification, and distribution are governed by the repository license and organizational policy.

resource "azurerm_private_endpoint" "this" {
  name                          = local.private_endpoint_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_id                     = local.subnet_id
  custom_network_interface_name = trimspace(var.custom_network_interface_name) != "" ? trimspace(var.custom_network_interface_name) : null
  tags                          = local.tags

  private_service_connection {
    name                           = local.service_connection_name
    private_connection_resource_id = trimspace(var.private_connection_resource_id)
    subresource_names              = var.subresource_names
    is_manual_connection           = var.is_manual_connection
    request_message                = var.is_manual_connection && trimspace(var.request_message) != "" ? trimspace(var.request_message) : null
  }

  dynamic "private_dns_zone_group" {
    for_each = local.private_dns_zone_group_enabled ? [1] : []

    content {
      name                 = var.private_dns_zone_group_name
      private_dns_zone_ids = local.private_dns_zone_ids
    }
  }

  dynamic "ip_configuration" {
    for_each = var.ip_configurations

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      subresource_name   = ip_configuration.value.subresource_name
      member_name        = try(ip_configuration.value.member_name, null)
    }
  }
}
