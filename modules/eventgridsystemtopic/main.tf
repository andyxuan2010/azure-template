# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: eventgridsystemtopic
# Description: Deploys an Azure Event Grid System Topic for an existing Azure resource.
#              The module supports normalized naming, topic type and source-resource configuration,
#              optional managed identity, timeouts, and resource group tag inheritance.
# Owner: Cloud Center of Excellence (CCOE)
# Maintainer: Andy Xuan@CCOE
# Repository: CCOE-Azure/azure-template
#
# Created: 2026-09-19
# Modified: 2026-09-19
# Version: 1.0.0
#
# Change History:
# - 2026-09-19 v1.0.0: Established the standardized Event Grid System Topic module baseline.
#
# This Terraform module is maintained as part of the CCOE Azure IaC template library.
# Use, modification, and distribution are governed by the repository license and organizational policy.

resource "azurerm_eventgrid_system_topic" "this" {
  name                = local.eventgrid_system_topic_name
  resource_group_name = var.resource_group_name
  location            = local.resolved_location
  topic_type          = var.topic_type
  source_resource_id  = var.source_resource_id
  tags                = local.tags

  dynamic "identity" {
    for_each = var.identity_type == null ? [] : [var.identity_type]

    content {
      type         = identity.value
      identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : null
    }
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
        var.identity_type == null ||
        (contains(["SystemAssigned", "SystemAssigned, UserAssigned"], var.identity_type) && (var.identity_type == "SystemAssigned" || length(var.identity_ids) > 0)) ||
        (var.identity_type == "UserAssigned" && length(var.identity_ids) > 0)
      )
      error_message = "User-assigned identity types require at least one identity_id."
    }
  }
}
