locals {
  environment_tag_map = {
    prod = "PROD"
    dev  = "DEV"
    qa   = "QA"
    test = "TEST"
    sbx  = "SBX"
    poc  = "POC"
  }

  location = trimspace(var.location) != "" ? trimspace(var.location) : data.azurerm_resource_group.rg[0].location

  region_code_map = {
    canadacentral  = "cc"
    canadaeast     = "ce"
    eastus         = "eus"
    eastus2        = "eus2"
    centralus      = "cus"
    southcentralus = "scus"
    northcentralus = "ncus"
    westus         = "wus"
    westus2        = "wus2"
    westus3        = "wus3"
  }
  suffix_map = {
    prod = "001"
    qa   = "301"
    dev  = "601"
    poc  = "701"
    test = "801"
    sbx  = "901"
  }
  suffix = lookup(local.suffix_map, var.app_env, "000")

  normalized_location = replace(replace(lower(local.location), " ", ""), "-", "")
  region_code         = lookup(local.region_code_map, local.normalized_location, substr(local.normalized_location, 0, 3))

  base_name = trimspace(var.name) != "" ? lower(trimspace(var.name)) : random_string.random[0].result

  # ACR name must be alphanumeric only and 5-50 characters. We remove hyphens.
  raw_acr_name = "acr${local.region_code}${local.base_name}${var.app_env}${local.suffix}"
  acr_name     = replace(local.raw_acr_name, "-", "")

  tags = merge(
    var.inherit_resource_group_tags ? coalesce(var.inherited_resource_group_tags, try(data.azurerm_resource_group.rg[0].tags, {})) : {},
    var.tags
  )

  network_rule_ip_rules = sort(distinct([
    for value in coalesce(var.network_rule_ip_rules, []) :
    strcontains(trimspace(value), "/") ? trimspace(value) : "${trimspace(value)}/32"
  ]))

  georeplications_by_location = {
    for location_key in sort([
      for rep in var.georeplications : lower(trimspace(rep.location))
    ]) :
    location_key => {
      location                  = trimspace(one([for rep in var.georeplications : rep.location if lower(trimspace(rep.location)) == location_key]))
      regional_endpoint_enabled = try(one([for rep in var.georeplications : rep.regional_endpoint_enabled if lower(trimspace(rep.location)) == location_key]), true)
      zone_redundancy_enabled   = try(one([for rep in var.georeplications : rep.zone_redundancy_enabled if lower(trimspace(rep.location)) == location_key]), false)
      tags                      = try(one([for rep in var.georeplications : rep.tags if lower(trimspace(rep.location)) == location_key]), {})
    }
  }

  managed_identity_role_assignments_effective = {
    for name, assignment in var.managed_identity_role_assignments : name => assignment
    if contains(["SystemAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
  }

  app_admin_group_object_ids = [
    for value in coalesce(var.app_admin_group, []) : value
    if length(regexall("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value)) > 0
  ]
  app_admin_group_names = {
    for value in coalesce(var.app_admin_group, []) : value => value
    if length(regexall("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value)) == 0
  }

  app_user_group_object_ids = [
    for value in coalesce(var.app_user_group, []) : value
    if length(regexall("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value)) > 0
  ]
  app_user_group_names = {
    for value in coalesce(var.app_user_group, []) : value => value
    if length(regexall("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value)) == 0
  }

  create_private_endpoint          = var.enable_private_endpoint
  private_endpoint_lookup_by_name  = local.create_private_endpoint && try(trimspace(var.private_endpoint_subnet_id), "") == ""
  private_endpoint_subnet_id_final = try(trimspace(var.private_endpoint_subnet_id), "") != "" ? var.private_endpoint_subnet_id : try(data.azurerm_subnet.pep[0].id, null)
  private_dns_zone_id_resolved     = try(trimspace(var.private_dns_zone_id), "") != "" ? var.private_dns_zone_id : try(data.azurerm_private_dns_zone.this[0].id, "")
}
