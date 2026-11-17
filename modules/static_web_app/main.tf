# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: staticwebapp
# Description: Deploys Azure Static Web Apps with the Free plan as the default.
#              The module supports repository integration, application settings, preview environments,
#              public network access, optional managed identity, basic authentication, and tag inheritance.
# Owner: Cloud Center of Excellence (CCOE)
# Maintainer: Andy Xuan@CCOE
# Repository: CCOE-Azure/azure-template
#
# Created: 2026-09-19
# Modified: 2026-09-19
# Version: 1.0.0
#
# Change History:
# - 2026-09-19 v1.0.0: Established the standardized Static Web App module with Free-plan defaults.
#
# This Terraform module is maintained as part of the CCOE Azure IaC template library.
# Use, modification, and distribution are governed by the repository license and organizational policy.

resource "azurerm_static_web_app" "this" {
  name                = local.static_web_app_name
  resource_group_name = var.resource_group_name
  location            = local.resolved_location

  sku_tier                           = var.sku_tier
  sku_size                           = var.sku_size
  app_settings                       = var.app_settings
  configuration_file_changes_enabled = var.configuration_file_changes_enabled
  preview_environments_enabled       = var.preview_environments_enabled
  public_network_access_enabled      = var.public_network_access_enabled
  repository_branch                  = var.repository_branch
  repository_token                   = var.repository_token
  repository_url                     = var.repository_url
  tags                               = local.tags

  dynamic "basic_auth" {
    for_each = var.basic_auth == null ? [] : [nonsensitive(var.basic_auth)]

    content {
      environments = basic_auth.value.environments
      password     = basic_auth.value.password
    }
  }

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
        (var.repository_url == null && var.repository_branch == null && var.repository_token == null) ||
        (try(trimspace(var.repository_url), "") != "" && try(trimspace(var.repository_branch), "") != "" && try(trimspace(nonsensitive(var.repository_token)), "") != "")
      )
      error_message = "repository_url, repository_branch, and repository_token must either all be null or all be non-empty."
    }

    precondition {
      condition     = var.sku_tier == var.sku_size
      error_message = "sku_tier and sku_size must match for a Static Web App SKU."
    }

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
