# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: subscription_vending
# Description: Vends Azure subscriptions and bootstrap resource groups for governed landing zone onboarding.
#              The module supports subscription aliasing or assignment workflows, management group placement, bootstrap resource groups, policy and role composition, and canonical tag propagation for downstream resource modules.
# Owner: Cloud Center of Excellence (CCOE)
# Maintainer: Andy Xuan@CCOE
# Repository: CCOE-Azure/azure-template
#
# Created: 2026-04-17
# Modified: 2026-07-08
# Version: 1.3.0
#
# Change History:
# - 2026-04-17 v1.0.0: Established reusable subscription_vending module baseline for the CCOE Azure IaC template library.
# - 2026-07-08 v1.0.0: Added standardized module metadata header with ownership, maintainer, license, dates, version, and change history.
#
# This Terraform module is maintained as part of the CCOE Azure IaC template library.
# Use, modification, and distribution are governed by the repository license and organizational policy.

resource "azurerm_subscription" "this" {
  count = var.subscription_alias_enabled ? 1 : 0

  subscription_name = local.subscription_name
  alias             = var.subscription_alias_name
  billing_scope_id  = var.billing_scope_id
}

resource "azurerm_management_group_subscription_association" "this" {
  count = var.enable_management_group_association ? 1 : 0

  management_group_id = var.management_group_id
  subscription_id     = local.subscription_id
}

resource "azurerm_resource_provider_registration" "this" {
  for_each = toset(var.resource_provider_registrations)

  name = each.value
}

resource "azurerm_resource_group" "bootstrap" {
  for_each = var.bootstrap_resource_groups

  name     = each.value.name
  location = each.value.location
  tags     = merge(local.merged_tags, each.value.tags)
}
