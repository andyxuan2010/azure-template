locals {
  location_resolved            = trimspace(var.location) != "" ? var.location : data.azurerm_resource_group.this.location
  dns_zone_partner_id_resolved = try(trimspace(var.dns_zone_partner_id), "") != "" ? var.dns_zone_partner_id : null

  location_code_map = {
    australiaeast      = "aue"
    brazilsouth        = "brs"
    canadacentral      = "cc"
    canadaeast         = "cae"
    centralindia       = "cin"
    centralus          = "cus"
    eastasia           = "ea"
    eastus             = "eus"
    eastus2            = "eus2"
    francecentral      = "frc"
    germanywestcentral = "gwc"
    japaneast          = "jpe"
    koreacentral       = "krc"
    northeurope        = "neu"
    southcentralus     = "scus"
    southeastasia      = "sea"
    uksouth            = "uks"
    ukwest             = "ukw"
    westcentralus      = "wcus"
    westeurope         = "weu"
    westus             = "wus"
    westus2            = "wus2"
    westus3            = "wus3"
  }

  location_code = lookup(local.location_code_map, lower(trimspace(local.location_resolved)), lower(join("", regexall("[a-z0-9]", replace(local.location_resolved, " ", "")))))
  workload_code = lower(join("", regexall("[a-z0-9-]", trimspace(var.workload))))
  generated_name = substr(
    "sqlmi-${local.workload_code}-${local.location_code}-${var.app_env}-${trimspace(var.instance)}",
    0,
    63
  )
  sqlmi_name = trimspace(var.name) != "" ? trimspace(var.name) : local.generated_name

  merged_tags = merge(
    var.inherit_resource_group_tags ? coalesce(var.inherited_resource_group_tags, data.azurerm_resource_group.this.tags) : {},
    var.tags
  )

  app_admin_group_values     = compact(coalesce(var.app_admin_group, []))
  entra_object_id_pattern    = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
  app_admin_group_object_ids = toset([for value in local.app_admin_group_values : value if can(regex(local.entra_object_id_pattern, value))])
  app_admin_group_names      = toset([for value in local.app_admin_group_values : value if !can(regex(local.entra_object_id_pattern, value))])
  app_user_group_values      = compact(coalesce(var.app_user_group, []))
  app_user_group_object_ids  = toset([for value in local.app_user_group_values : value if can(regex(local.entra_object_id_pattern, value))])
  app_user_group_names       = toset([for value in local.app_user_group_values : value if !can(regex(local.entra_object_id_pattern, value))])
}
