# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: nat_gateway
# Description: Deploys an Azure NAT Gateway with public IPs and subnet associations.
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

resource "azurerm_nat_gateway" "this" {
  name                    = local.nat_gateway_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = var.sku_name
  idle_timeout_in_minutes = var.idle_timeout_in_minutes
  zones                   = var.sku_name == "StandardV2" || length(var.zones) == 0 ? null : var.zones
  tags                    = local.tags
}

resource "azurerm_public_ip" "this" {
  count = length(var.public_ip_address_ids) == 0 ? var.public_ip_count : 0

  name                = "${local.public_ip_name_prefix}-${format("%03d", count.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = var.sku_name
  sku_tier            = "Regional"
  ip_version          = "IPv4"
  zones               = var.sku_name == "StandardV2" ? ["1", "2", "3"] : length(var.zones) == 0 ? null : var.zones
  tags                = local.tags
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  for_each = local.public_ip_association_targets

  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = each.value
}

resource "azurerm_subnet_nat_gateway_association" "this" {
  for_each = toset(var.subnet_ids)

  subnet_id      = each.value
  nat_gateway_id = azurerm_nat_gateway.this.id
}
