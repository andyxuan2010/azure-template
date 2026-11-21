# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: managedidentity
# Description: Deploys Azure user-assigned managed identities for secure workload authentication without embedded credentials.
#              The module supports standardized naming, identity creation, optional federated identity or role assignment composition, and resource group tag inheritance for governance alignment.
# Owner: Cloud Center of Excellence (CCOE)
# Maintainer: Andy Xuan@CCOE
# Repository: CCOE-Azure/azure-template
#
# Created: 2026-04-17
# Modified: 2026-07-08
# Version: 1.3.0
#
# Change History:
# - 2026-04-17 v1.0.0: Established reusable managedidentity module baseline for the CCOE Azure IaC template library.
# - 2026-07-08 v1.0.0: Added standardized module metadata header with ownership, maintainer, license, dates, version, and change history.
#
# This Terraform module is maintained as part of the CCOE Azure IaC template library.
# Use, modification, and distribution are governed by the repository license and organizational policy.

resource "azurerm_user_assigned_identity" "this" {
  name                = local.managed_identity_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = local.merged_tags
}

resource "azurerm_federated_identity_credential" "this" {
  for_each = var.federated_identity_credentials

  name      = each.key
  parent_id = azurerm_user_assigned_identity.this.id
  audience  = each.value.audience
  issuer    = each.value.issuer
  subject   = each.value.subject
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                = each.value.scope
  role_definition_name = try(each.value.role_definition_name, null)
  role_definition_id   = try(each.value.role_definition_id, null)
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}
