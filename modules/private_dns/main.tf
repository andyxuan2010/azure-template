# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: private_dns
# Description: Deploys Azure Private DNS zones and related records or virtual network links for private endpoint name resolution.
#              The module supports zone creation, A/CNAME/TXT/MX/SRV records, SOA configuration, virtual network links, policy-compatible tag handling, and resource group tag inheritance for governance alignment.
# Owner: Cloud Center of Excellence (CCOE)
# Maintainer: Andy Xuan@CCOE
# Repository: CCOE-Azure/azure-template
#
# Created: 2026-04-17
# Modified: 2026-07-08
# Version: 1.3.0
#
# Change History:
# - 2026-04-17 v1.0.0: Established reusable private_dns module baseline for the CCOE Azure IaC template library.
# - 2026-07-08 v1.0.0: Added standardized module metadata header with ownership, maintainer, license, dates, version, and change history.
#
# This Terraform module is maintained as part of the CCOE Azure IaC template library.
# Use, modification, and distribution are governed by the repository license and organizational policy.

resource "azurerm_private_dns_zone" "this" {
  for_each = var.zones

  name                = each.key
  resource_group_name = var.resource_group_name
  tags                = local.merged_tags

  dynamic "soa_record" {
    for_each = try(each.value.soa_record, null) == null ? [] : [each.value.soa_record]

    content {
      email        = try(soa_record.value.email, null)
      expire_time  = try(soa_record.value.expire_time, null)
      minimum_ttl  = try(soa_record.value.minimum_ttl, null)
      refresh_time = try(soa_record.value.refresh_time, null)
      retry_time   = try(soa_record.value.retry_time, null)
      ttl          = try(soa_record.value.ttl, null)
      tags         = try(soa_record.value.tags, null)
    }
  }

}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = local.vnet_links

  name                  = each.value.name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.value.zone_name].name
  virtual_network_id    = each.value.virtual_network_id
  registration_enabled  = each.value.registration_enabled
  tags                  = merge(local.merged_tags, each.value.tags)

}

resource "azurerm_private_dns_a_record" "this" {
  for_each = local.a_records

  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.this[each.value.zone_name].name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records
  tags                = merge(local.merged_tags, each.value.tags)
}

resource "azurerm_private_dns_aaaa_record" "this" {
  for_each = local.aaaa_records

  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.this[each.value.zone_name].name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records
  tags                = merge(local.merged_tags, each.value.tags)
}

resource "azurerm_private_dns_cname_record" "this" {
  for_each = local.cname_records

  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.this[each.value.zone_name].name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  record              = each.value.record
  tags                = merge(local.merged_tags, each.value.tags)
}

resource "azurerm_private_dns_txt_record" "this" {
  for_each = local.txt_records

  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.this[each.value.zone_name].name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  tags                = merge(local.merged_tags, each.value.tags)

  dynamic "record" {
    for_each = each.value.records

    content {
      value = record.value
    }
  }
}
