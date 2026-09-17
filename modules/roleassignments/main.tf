# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: roleassignments
# Description: Manages Azure role assignments for identities at subscription, resource group, or resource scopes.
#              The module supports deterministic role assignment keys, principal and role definition inputs, optional skip checks, and idempotent access-control composition outside normal Azure ARM resource tag inheritance patterns.
# Owner: Cloud Center of Excellence (CCOE)
# Maintainer: Andy Xuan@CCOE
# Repository: CCOE-Azure/azure-template
#
# Created: 2026-04-17
# Modified: 2026-07-08
# Version: 1.3.0
#
# Change History:
# - 2026-04-17 v1.0.0: Established reusable roleassignments module baseline for the CCOE Azure IaC template library.
# - 2026-07-08 v1.0.0: Added standardized module metadata header with ownership, maintainer, license, dates, version, and change history.
#
# This Terraform module is maintained as part of the CCOE Azure IaC template library.
# Use, modification, and distribution are governed by the repository license and organizational policy.

data "azuread_group" "this" {
  for_each = local.principal_name_assignments

  display_name = each.value
}

data "azurerm_role_definition" "this" {
  for_each = local.role_definition_name_assignments

  name  = each.value.name
  scope = each.value.scope
}

resource "azurerm_role_assignment" "this" {
  for_each = local.resolved_assignments

  name                 = local.role_assignment_names[each.key]
  scope                = each.value.scope
  role_definition_name = null
  role_definition_id   = each.value.role_definition_id
  principal_id         = each.value.principal_id
  principal_type       = each.value.principal_type != "" ? each.value.principal_type : null
  condition            = each.value.condition != "" ? each.value.condition : null
  condition_version    = each.value.condition_version != "" ? each.value.condition_version : null

  lifecycle {
    # The resolved role/principal IDs may be unknown during plan when a data
    # lookup is deferred. A precondition can be evaluated at apply without
    # producing a noisy "check block assertion known after apply" warning.
    precondition {
      condition     = length(values(local.role_assignment_names)) == length(toset(values(local.role_assignment_names)))
      error_message = "assignments must not contain duplicate logical role assignments after principal and role resolution."
    }
  }
}
