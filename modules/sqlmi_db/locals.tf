locals {
  workload_code = lower(join("", regexall("[a-z0-9-]", trimspace(var.workload))))
  database_name = trimspace(var.name) != "" ? trimspace(var.name) : (trimspace(var.app_sqlmi_db) != "" ? trimspace(var.app_sqlmi_db) : substr("sqmidb-${local.workload_code}-${var.app_env}-${trimspace(var.instance)}", 0, 128))

  environment_tag_map = {
    prod = "PROD"
    dev  = "DEV"
    qa   = "QA"
    test = "TEST"
    sbx  = "SBX"
    poc  = "POC"
  }

  tags = merge(
    var.inherit_resource_group_tags ? coalesce(var.inherited_resource_group_tags, try(data.azurerm_resource_group.rg[0].tags, {})) : {},
    var.tags
  )

  entra_object_id_pattern    = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
  app_admin_group_values     = distinct(compact([for value in coalesce(var.app_admin_group, []) : trimspace(value)]))
  app_admin_group_object_ids = toset([for value in local.app_admin_group_values : value if can(regex(local.entra_object_id_pattern, value))])
  app_admin_group_names      = toset([for value in local.app_admin_group_values : value if !can(regex(local.entra_object_id_pattern, value))])
  app_user_group_values      = distinct(compact([for value in coalesce(var.app_user_group, []) : trimspace(value)]))
  app_user_group_object_ids  = toset([for value in local.app_user_group_values : value if can(regex(local.entra_object_id_pattern, value))])
  app_user_group_names       = toset([for value in local.app_user_group_values : value if !can(regex(local.entra_object_id_pattern, value))])
}
