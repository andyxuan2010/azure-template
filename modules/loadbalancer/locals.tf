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

  tags = merge(
    var.inherit_resource_group_tags ? try(data.azurerm_resource_group.rg[0].tags, {}) : {},
    var.tags,
    {
      Environment = lookup(local.environment_tag_map, var.app_env, var.app_env)
      workload    = var.workload
    }
  )
}
