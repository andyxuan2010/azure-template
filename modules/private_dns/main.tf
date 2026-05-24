resource "azurerm_private_dns_zone" "this" {
  for_each = var.zones

  name                = each.key
  resource_group_name = var.resource_group_name
  #tags                = local.merged_tags

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
