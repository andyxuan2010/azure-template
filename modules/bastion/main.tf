# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: bastion
# Description: Deploys an Azure Bastion host with a dedicated public IP or an existing Standard public IP.
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

resource "azurerm_public_ip" "this" {
  count = local.create_public_ip ? 1 : 0

  name                = local.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones
  tags                = local.tags
}

resource "azurerm_bastion_host" "this" {
  name                = local.bastion_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku

  copy_paste_enabled        = var.copy_paste_enabled
  file_copy_enabled         = var.file_copy_enabled
  ip_connect_enabled        = var.ip_connect_enabled
  kerberos_enabled          = var.kerberos_enabled
  scale_units               = var.scale_units
  shareable_link_enabled    = var.shareable_link_enabled
  tunneling_enabled         = var.tunneling_enabled
  session_recording_enabled = var.session_recording_enabled
  zones                     = var.zones
  tags                      = local.tags

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = trimspace(var.subnet_id)
    public_ip_address_id = local.public_ip_address_id
  }
}
