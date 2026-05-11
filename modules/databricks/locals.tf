locals {
  location    = trimspace(var.location) != "" ? var.location : data.azurerm_resource_group.rg.location
  common_tags = data.azurerm_resource_group.rg.tags

  workspace_name = trimspace(var.name) != "" ? var.name : "dbw${random_string.random[0].result}"

  merged_tags = merge(
    local.common_tags,
    var.tags,
    {
      module = "databricks"
    }
  )

  app_admin_group_values     = compact(coalesce(var.app_admin_group, []))
  app_user_group_values      = compact(coalesce(var.app_user_group, []))
  app_admin_group_object_ids = toset([for value in local.app_admin_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_admin_group_names      = toset([for value in local.app_admin_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_user_group_object_ids  = toset([for value in local.app_user_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_user_group_names       = toset([for value in local.app_user_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])

  enable_custom_parameters = var.custom_parameters != null
  enable_enhanced_security = var.enhanced_security_compliance != null
}
