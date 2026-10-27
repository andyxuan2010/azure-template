locals {
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

  read_resource_group = var.location == "" || (var.inherit_resource_group_tags && var.inherited_resource_group_tags == null)

  resolved_location = trimspace(var.location) != "" ? trimspace(var.location) : data.azurerm_resource_group.rg[0].location
  location_code     = trimspace(var.location_code) != "" ? trimspace(var.location_code) : lookup(local.location_code_map, lower(replace(local.resolved_location, " ", "")), lower(substr(join("", regexall("[a-z0-9]", replace(local.resolved_location, " ", ""))), 0, 3)))
  workload_code     = lower(join("", regexall("[a-z0-9-]", trimspace(var.workload_name != "" ? var.workload_name : var.workload))))
  generated_name    = substr("${var.name_prefix}-${local.workload_code}-${local.location_code}-${var.app_env}-${trimspace(var.instance)}", 0, 80)

  availability_set_name = trimspace(var.name) != "" ? trimspace(var.name) : local.generated_name

  tags = merge(
    var.inherit_resource_group_tags ? coalesce(var.inherited_resource_group_tags, try(data.azurerm_resource_group.rg[0].tags, {})) : {},
    var.tags
  )
}
