locals {
  environment_tag_map = {
    prod = "PROD"
    dev  = "DEV"
    qa   = "QA"
    test = "TEST"
    sbx  = "SBX"
    poc  = "POC"
  }

  merged_tags = merge(
    var.inherit_resource_group_tags ? try(data.azurerm_resource_group.rg[0].tags, {}) : {},
    var.tags,
    {
      Environment = lookup(local.environment_tag_map, lower(trimspace(var.app_env)), upper(trimspace(var.app_env)))
      Workload    = trimspace(var.workload)
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
