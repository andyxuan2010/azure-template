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

  location_code = lookup(local.location_code_map, lower(trimspace(var.location)), substr(lower(join("", regexall("[a-z0-9]", replace(var.location, " ", "")))), 0, 3))
  workload_code = lower(join("", regexall("[a-z0-9-]", trimspace(var.workload))))

  generated_name       = substr("bas-${local.workload_code}-${local.location_code}-${var.app_env}-${trimspace(var.instance)}", 0, 80)
  bastion_name         = trimspace(var.name) != "" ? trimspace(var.name) : local.generated_name
  public_ip_name       = trimspace(var.public_ip_name) != "" ? trimspace(var.public_ip_name) : substr("pip-${local.bastion_name}", 0, 80)
  create_public_ip     = trimspace(var.public_ip_address_id) == ""
  public_ip_address_id = local.create_public_ip ? azurerm_public_ip.this[0].id : trimspace(var.public_ip_address_id)

  tags = merge(
    var.inherit_resource_group_tags ? coalesce(var.inherited_resource_group_tags, try(data.azurerm_resource_group.rg[0].tags, {})) : {},
    var.tags
  )
}
