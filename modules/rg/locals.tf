locals {
  location_code       = lower(join("", regexall("[a-z0-9]", replace(var.location, " ", ""))))
  generated_name      = substr("rg-${local.location_code != "" ? local.location_code : "app"}-${try(random_string.random[0].result, "0000")}", 0, 90)
  resource_group_name = var.name != "" ? var.name : local.generated_name

  tags = merge(
    var.tags,
    {
      module = "rg"
    }
  )

  lock_notes_effective = trimspace(var.lock_notes) != "" ? var.lock_notes : "Managed by Terraform"

  app_admin_group_values = tolist(toset(compact([
    for value in coalesce(var.app_admin_group, []) : trimspace(value)
  ])))
  app_user_group_values = tolist(toset(compact([
    for value in coalesce(var.app_user_group, []) : trimspace(value)
  ])))

  entra_object_id_pattern = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"

  app_admin_group_object_ids = toset([for value in local.app_admin_group_values : value if can(regex(local.entra_object_id_pattern, value))])
  app_admin_group_names      = toset([for value in local.app_admin_group_values : value if !can(regex(local.entra_object_id_pattern, value))])
  app_user_group_object_ids  = toset([for value in local.app_user_group_values : value if can(regex(local.entra_object_id_pattern, value))])
  app_user_group_names       = toset([for value in local.app_user_group_values : value if !can(regex(local.entra_object_id_pattern, value))])
}
