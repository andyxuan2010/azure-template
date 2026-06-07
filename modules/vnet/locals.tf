locals {
  environment_tag_map = {
    prod = "PROD"
    dev  = "DEV"
    qa   = "QA"
    test = "TEST"
    sbx  = "SBX"
    poc  = "POC"
  }

  location    = var.location != "" ? var.location : data.azurerm_resource_group.rg.location
  common_tags = var.inherit_resource_group_tags ? data.azurerm_resource_group.rg.tags : {}

  tags = merge(
    local.common_tags,
    var.tags,
    {
      Environment = lookup(local.environment_tag_map, var.app_env, var.app_env)
      workload    = var.workload
    }
  )

  application_code_raw = try(data.azurerm_resource_group.rg.tags.application_id, "app")
  application_code     = lower(join("", regexall("[a-z0-9]", local.application_code_raw)))
  location_code        = lower(join("", regexall("[a-z0-9]", replace(local.location, " ", ""))))
  naming_seed          = substr("${local.application_code}${local.location_code}", 0, 45)
  generated_name       = substr("vnet-${local.naming_seed != "" ? local.naming_seed : "app"}-${try(random_string.random[0].result, "0000")}", 0, 64)
  virtual_network_name = var.name != "" ? var.name : local.generated_name

  ddos_protection_enabled = var.ddos_protection_plan_id != ""

  app_admin_group_values     = compact(coalesce(var.app_admin_group, []))
  app_user_group_values      = compact(coalesce(var.app_user_group, []))
  app_admin_group_object_ids = toset([for value in local.app_admin_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_admin_group_names      = toset([for value in local.app_admin_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_user_group_object_ids  = toset([for value in local.app_user_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_user_group_names       = toset([for value in local.app_user_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])
}
