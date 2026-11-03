locals {
  resource_group_name            = trimspace(var.resource_group_name)
  resource_group_lookup_required = trimspace(var.location) == "" || (var.inherit_resource_group_tags && var.inherited_resource_group_tags == null)
  location                       = trimspace(var.location) != "" ? trimspace(var.location) : data.azurerm_resource_group.rg[0].location
  inherited_tags                 = var.inherit_resource_group_tags ? coalesce(var.inherited_resource_group_tags, try(data.azurerm_resource_group.rg[0].tags, {})) : {}
  location_normalized            = lower(join("", regexall("[a-z0-9]", replace(local.location, " ", ""))))
  location_code_resolved         = trimspace(var.location_code) != "" ? lower(trimspace(var.location_code)) : lookup(local.location_code_map, local.location_normalized, substr(local.location_normalized, 0, 3))
  workload_code                  = lower(join("", regexall("[a-z0-9-]", trimspace(var.workload))))
  instance_code                  = lower(join("", regexall("[a-z0-9-]", trimspace(var.instance))))
  generated_name_raw             = "ca-${local.workload_code}-${local.location_code_resolved}-${var.app_env}-${local.instance_code}"
  generated_name                 = trim(substr(local.generated_name_raw, 0, 32), "-")
  container_app_name             = trimspace(var.name) != "" ? trimspace(var.name) : local.generated_name
  workload_profile_name_resolved = trimspace(var.workload_profile_name) != "" ? trimspace(var.workload_profile_name) : null
  revision_suffix_resolved       = trimspace(var.revision_suffix) != "" ? trimspace(var.revision_suffix) : null
  identity_enabled               = var.identity_type != "None"
  identity_ids                   = distinct(compact([for id in var.identity_ids : trimspace(id)]))

  default_traffic_weight = {
    percentage      = 100
    latest_revision = true
    revision_suffix = null
    label           = null
  }

  ingress_traffic_weights = var.ingress == null ? [] : (
    length(var.ingress.traffic_weight) > 0 ? var.ingress.traffic_weight : [local.default_traffic_weight]
  )

  location_code_map = {
    australiaeast      = "aue"
    brazilsouth        = "brs"
    canadacentral      = "cc"
    canadaeast         = "ce"
    centralindia       = "cin"
    centralus          = "cus"
    eastasia           = "ea"
    eastus             = "eus"
    eastus2            = "eus2"
    francecentral      = "frc"
    germanywestcentral = "gwc"
    japaneast          = "jpe"
    koreacentral       = "krc"
    northcentralus     = "ncus"
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

  tags = merge(
    local.inherited_tags,
    var.tags
  )
}
