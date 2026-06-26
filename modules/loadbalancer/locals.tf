locals {
  tags = merge(
    var.inherit_resource_group_tags ? coalesce(var.inherited_resource_group_tags, try(data.azurerm_resource_group.rg[0].tags, {})) : {},
    var.tags
  )

  frontend_names     = [for frontend in var.frontend_ip_configurations : frontend.name]
  backend_pool_names = [for pool in var.backend_address_pools : pool.name]
  probe_names        = [for probe in var.probes : probe.name]
}
