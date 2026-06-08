locals {
  environment_tag_map = {
    prod = "PROD"
    dev  = "DEV"
    qa   = "QA"
    test = "TEST"
    sbx  = "SBX"
    poc  = "POC"
  }

  tags = merge(
    var.inherit_resource_group_tags ? try(data.azurerm_resource_group.rg[0].tags, {}) : {},
    var.tags,
    {
      Environment = lookup(local.environment_tag_map, lower(trimspace(var.app_env)), upper(trimspace(var.app_env)))
      Workload    = trimspace(var.workload)
    }
  )
}
