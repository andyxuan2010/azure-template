# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: policy
# Description: Manages Azure Policy definitions, initiatives, assignments, and exemptions for governance enforcement.
#              The module supports policy-as-code composition across scopes, parameterized assignments, role assignment requirements, and governance metadata while remaining separate from normal Azure ARM resource tag inheritance patterns.
# Owner: Cloud Center of Excellence (CCOE)
# Maintainer: Andy Xuan@CCOE
# Repository: CCOE-Azure/azure-template
#
# Created: 2026-04-17
# Modified: 2026-07-08
# Version: 1.3.0
#
# Change History:
# - 2026-04-17 v1.0.0: Established reusable policy module baseline for the CCOE Azure IaC template library.
# - 2026-07-08 v1.0.0: Added standardized module metadata header with ownership, maintainer, license, dates, version, and change history.
#
# This Terraform module is maintained as part of the CCOE Azure IaC template library.
# Use, modification, and distribution are governed by the repository license and organizational policy.

resource "azurerm_policy_definition" "this" {
  name                = local.policy_name
  policy_type         = var.policy_type
  mode                = var.mode
  display_name        = local.policy_display_name
  description         = try(trimspace(var.description), "") != "" ? var.description : null
  management_group_id = try(trimspace(var.management_group_id), "") != "" ? var.management_group_id : null
  policy_rule         = var.policy_rule
  parameters          = trimspace(var.parameters) != "" ? var.parameters : null
  metadata            = trimspace(var.metadata) != "" ? var.metadata : null
}

resource "azurerm_management_group_policy_assignment" "this" {
  count = var.create_assignment && local.assignment_scope_kind == "management_group" ? 1 : 0

  name                 = local.policy_name
  display_name         = local.assignment_display_name_effective
  description          = local.assignment_description_effective
  policy_definition_id = azurerm_policy_definition.this.id
  management_group_id  = var.assignment_scope
  parameters           = trimspace(var.assignment_parameters) != "" ? var.assignment_parameters : null
  metadata             = trimspace(var.assignment_metadata) != "" ? var.assignment_metadata : null
  not_scopes           = var.assignment_not_scopes
  enforce              = var.enforcement_mode
  location             = var.identity_type != null ? var.location : null

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []

    content {
      type = var.identity_type
    }
  }

  dynamic "non_compliance_message" {
    for_each = var.non_compliance_messages

    content {
      content                        = non_compliance_message.value.content
      policy_definition_reference_id = try(non_compliance_message.value.policy_definition_reference_id, null)
    }
  }

  dynamic "timeouts" {
    for_each = var.assignment_timeouts == null ? [] : [var.assignment_timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}

resource "azurerm_subscription_policy_assignment" "this" {
  count = var.create_assignment && local.assignment_scope_kind == "subscription" ? 1 : 0

  name                 = local.policy_name
  display_name         = local.assignment_display_name_effective
  description          = local.assignment_description_effective
  policy_definition_id = azurerm_policy_definition.this.id
  subscription_id      = var.assignment_scope
  parameters           = trimspace(var.assignment_parameters) != "" ? var.assignment_parameters : null
  metadata             = trimspace(var.assignment_metadata) != "" ? var.assignment_metadata : null
  not_scopes           = var.assignment_not_scopes
  enforce              = var.enforcement_mode
  location             = var.identity_type != null ? var.location : null

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []

    content {
      type = var.identity_type
    }
  }

  dynamic "non_compliance_message" {
    for_each = var.non_compliance_messages

    content {
      content                        = non_compliance_message.value.content
      policy_definition_reference_id = try(non_compliance_message.value.policy_definition_reference_id, null)
    }
  }

  dynamic "timeouts" {
    for_each = var.assignment_timeouts == null ? [] : [var.assignment_timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}

resource "azurerm_resource_group_policy_assignment" "this" {
  count = var.create_assignment && local.assignment_scope_kind == "resource_group" ? 1 : 0

  name                 = local.policy_name
  display_name         = local.assignment_display_name_effective
  description          = local.assignment_description_effective
  policy_definition_id = azurerm_policy_definition.this.id
  resource_group_id    = var.assignment_scope
  parameters           = trimspace(var.assignment_parameters) != "" ? var.assignment_parameters : null
  metadata             = trimspace(var.assignment_metadata) != "" ? var.assignment_metadata : null
  not_scopes           = var.assignment_not_scopes
  enforce              = var.enforcement_mode
  location             = var.identity_type != null ? var.location : null

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []

    content {
      type = var.identity_type
    }
  }

  dynamic "non_compliance_message" {
    for_each = var.non_compliance_messages

    content {
      content                        = non_compliance_message.value.content
      policy_definition_reference_id = try(non_compliance_message.value.policy_definition_reference_id, null)
    }
  }

  dynamic "timeouts" {
    for_each = var.assignment_timeouts == null ? [] : [var.assignment_timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
