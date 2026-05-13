locals {
  merged_tags = merge(
    var.tags,
    {
      module = "private_dns"
    }
  )

  vnet_links = merge([
    for zone_name, zone in var.zones : {
      for link_name, link in zone.vnet_links :
      "${zone_name}/${link_name}" => merge(link, { zone_name = zone_name, name = link_name })
    }
  ]...)

  a_records = merge([
    for zone_name, zone in var.zones : {
      for record_name, record in zone.a_records :
      "${zone_name}/${record_name}" => merge(record, { zone_name = zone_name, name = record_name })
    }
  ]...)
}
