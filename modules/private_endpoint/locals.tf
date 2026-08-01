locals {
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

  location_code           = lookup(local.location_code_map, lower(trimspace(var.location)), lower(join("", regexall("[a-z0-9]", replace(var.location, " ", "")))))
  workload_code           = lower(join("", regexall("[a-z0-9-]", trimspace(var.workload))))
  generated_name          = substr("pep-${local.workload_code}-${local.location_code}-${var.app_env}-${trimspace(var.instance)}", 0, 80)
  private_endpoint_name   = trimspace(var.name) != "" ? trimspace(var.name) : local.generated_name
  service_connection_name = trimspace(var.private_service_connection_name) != "" ? trimspace(var.private_service_connection_name) : substr("psc-${local.private_endpoint_name}", 0, 80)

  virtual_network_resource_group_name = trimspace(var.virtual_network_resource_group_name) != "" ? trimspace(var.virtual_network_resource_group_name) : var.resource_group_name
  subnet_lookup_by_name               = trimspace(var.subnet_id) == "" && trimspace(var.subnet_name) != "" && trimspace(var.virtual_network_name) != ""
  subnet_id = trimspace(var.subnet_id) != "" ? trimspace(var.subnet_id) : (
    local.subnet_lookup_by_name ? data.azurerm_subnet.this[0].id : "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/invalid/providers/Microsoft.Network/virtualNetworks/invalid/subnets/invalid"
  )

  private_dns_zone_lookup_names = distinct(compact([for name in var.private_dns_zone_names : trimspace(name)]))
  private_dns_zone_ids = distinct(compact(concat(
    [for id in var.private_dns_zone_ids : trimspace(id)],
    [for _, zone in data.azurerm_private_dns_zone.this : zone.id]
  )))

  private_dns_zone_group_enabled = length(local.private_dns_zone_ids) > 0

  tags = merge(
    var.inherit_resource_group_tags ? coalesce(var.inherited_resource_group_tags, try(data.azurerm_resource_group.rg[0].tags, {})) : {},
    var.tags
  )
}
