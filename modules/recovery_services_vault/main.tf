# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: recovery_services_vault
# Description: Creates an Azure Recovery Services vault for Azure Backup.
# Owner: Cloud Center of Excellence (CCOE)
# Maintainer: Andy Xuan@CCOE
# Repository: CCOE-Azure/azure-template
#
# Created: 2026-10-27
# Modified: 2026-10-27
# Version: 1.0.0
#
# This Terraform module is maintained as part of the CCOE Azure IaC template library.
# Use, modification, and distribution are governed by the repository license and organizational policy.

resource "azurerm_recovery_services_vault" "this" {
  name                          = local.vault_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.sku
  storage_mode_type             = var.storage_mode_type
  cross_region_restore_enabled  = var.cross_region_restore_enabled
  public_network_access_enabled = var.public_network_access_enabled
  immutability                  = var.immutability
  tags                          = local.tags
}
