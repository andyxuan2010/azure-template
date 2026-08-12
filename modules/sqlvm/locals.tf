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
  workload_code     = lower(join("", regexall("[a-z0-9]", trimspace(var.workload_name != "" ? var.workload_name : var.workload))))

  instance_numbers = [
    for vm_index in range(var.vm_count) : format("%03d", var.instance_start + vm_index)
  ]

  generated_names = [
    for instance in local.instance_numbers : substr("${var.name_prefix}${local.workload_code}${local.location_code}${var.app_env}${instance}", 0, 15)
  ]

  vm_names = length(var.vm_names) > 0 ? var.vm_names : local.generated_names

  instances = {
    for vm_index, name in local.vm_names : tostring(vm_index) => {
      index         = vm_index
      name          = name
      computer_name = substr(replace(name, "-", ""), 0, 15)
      zone          = length(var.zones) > 0 ? var.zones[vm_index % length(var.zones)] : null
      private_ip    = length(var.private_ip_addresses) > 0 ? var.private_ip_addresses[vm_index] : null
    }
  }

  data_disk_instances = merge([
    for vm_key, vm in local.instances : {
      for disk_key, disk in var.data_disks : "${vm_key}|${disk_key}" => merge(disk, {
        vm_key   = vm_key
        disk_key = disk_key
        vm_name  = vm.name
        zone     = vm.zone
      })
    }
  ]...)

  tags = merge(
    var.inherit_resource_group_tags ? coalesce(var.inherited_resource_group_tags, try(data.azurerm_resource_group.rg[0].tags, {})) : {},
    var.tags
  )
}
