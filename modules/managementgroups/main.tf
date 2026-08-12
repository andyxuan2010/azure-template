# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: managementgroups
# Description: Manages Azure Management Group hierarchy and metadata for tenant-level governance structure.
#              The module supports creation or association of management groups, parent-child relationships, scope metadata, and tag-style metadata inputs where supported by the management group resource model.
# Owner: Cloud Center of Excellence (CCOE)
# Maintainer: Andy Xuan@CCOE
# Repository: CCOE-Azure/azure-template
#
# Created: 2026-04-17
# Modified: 2026-07-08
# Version: 1.3.0
#
# Change History:
# - 2026-04-17 v1.0.0: Established reusable managementgroups module baseline for the CCOE Azure IaC template library.
# - 2026-07-08 v1.0.0: Added standardized module metadata header with ownership, maintainer, license, dates, version, and change history.
#
# This Terraform module is maintained as part of the CCOE Azure IaC template library.
# Use, modification, and distribution are governed by the repository license and organizational policy.

resource "random_string" "suffix" {
  count = trimspace(var.name) == "" ? 1 : 0

  length  = 4
  upper   = false
  special = false
}

resource "azurerm_management_group" "this" {
  display_name               = local.display_name
  name                       = local.management_group_name
  parent_management_group_id = try(trimspace(var.parent_management_group_id), "") != "" ? var.parent_management_group_id : null
  subscription_ids           = local.subscription_ids
}
