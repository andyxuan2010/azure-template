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
    try(data.azurerm_mssql_managed_instance.this.tags, {}),
    var.tags,
    {
      Environment = lookup(local.environment_tag_map, lower(trimspace(var.app_env)), upper(trimspace(var.app_env)))
      Workload    = trimspace(var.workload)
    }
  )

  app_admin_group_values     = compact(coalesce(var.app_admin_group, []))
  app_admin_group_object_ids = toset([for value in local.app_admin_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_admin_group_names      = toset([for value in local.app_admin_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_user_group_values      = compact(coalesce(var.app_user_group, []))
  app_user_group_object_ids  = toset([for value in local.app_user_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_user_group_names       = toset([for value in local.app_user_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])
}
