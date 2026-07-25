# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: availabilityset
# Description: Deploys Azure Availability Sets for VM placement resiliency within a datacenter.
#              The module supports standardized naming, fault and update domain configuration, optional proximity placement group association, and resource group tag inheritance for governance alignment.
# Owner: Cloud Center of Excellence (CCOE)
# Maintainer: Andy Xuan@CCOE
# Repository: CCOE-Azure/azure-template
#
# Created: 2026-07-07
# Modified: 2026-07-08
# Version: 1.3.0
#
# Change History:
# - 2026-07-07 v1.0.0: Established reusable availabilityset module baseline for the CCOE Azure IaC template library.
# - 2026-07-08 v1.0.0: Added standardized module metadata header with ownership, maintainer, license, dates, version, and change history.
#
# This Terraform module is maintained as part of the CCOE Azure IaC template library.
# Use, modification, and distribution are governed by the repository license and organizational policy.

resource "azurerm_availability_set" "this" {
  name                         = local.availability_set_name
  location                     = local.resolved_location
  resource_group_name          = var.resource_group_name
  platform_fault_domain_count  = var.platform_fault_domain_count
  platform_update_domain_count = var.platform_update_domain_count
  proximity_placement_group_id = var.proximity_placement_group_id
  managed                      = var.managed
  tags                         = local.tags

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}
