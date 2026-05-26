locals {
  environment_tag_map = {
    prod    = "Production"
    dev     = "Development"
    qa      = "QA"
    test    = "Test"
    sbx     = "Sandbox"
    poc     = "POC"
    staging = "Staging"
  }

  merged_tags = merge(
    var.inherit_resource_group_tags ? try(data.azurerm_resource_group.rg[0].tags, {}) : {},
    var.tags,
    {
      Environment = lookup(local.environment_tag_map, var.app_env, var.app_env)
      workload    = var.workload
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
