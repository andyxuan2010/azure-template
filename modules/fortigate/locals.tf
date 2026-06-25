locals {
  architecture      = lower(trimspace(var.architecture))
  instance_suffixes = local.architecture == "active-passive" ? ["a", "b"] : ["a"]
  vnet_rg_name      = trimspace(var.virtual_network_resource_group_name) != "" ? trimspace(var.virtual_network_resource_group_name) : var.resource_group_name
  vnet_name         = var.create_virtual_network ? azurerm_virtual_network.this[0].name : trimspace(var.virtual_network_name)
  vnet_id           = var.create_virtual_network ? azurerm_virtual_network.this[0].id : null

  enabled_interfaces = {
    for name, interface in var.interfaces : name => interface
    if contains(interface.enabled_architectures, local.architecture)
  }

  created_subnet_interfaces = {
    for name, interface in local.enabled_interfaces : name => interface
    if var.create_subnets
  }

  interface_subnet_ids = {
    for name, interface in local.enabled_interfaces :
    name => var.create_subnets ? azurerm_subnet.this[name].id : interface.subnet_id
  }

  nics = {
    for pair in setproduct(local.instance_suffixes, keys(local.enabled_interfaces)) :
    "${pair[0]}-${pair[1]}" => {
      instance_suffix                = pair[0]
      interface_name                 = pair[1]
      interface_role                 = lower(local.enabled_interfaces[pair[1]].role)
      subnet_id                      = local.interface_subnet_ids[pair[1]]
      primary                        = local.enabled_interfaces[pair[1]].primary
      private_ip_address_allocation  = local.enabled_interfaces[pair[1]].private_ip_address_allocation
      private_ip_address             = lookup(local.enabled_interfaces[pair[1]].private_ip_addresses, pair[0], null)
      enable_ip_forwarding           = local.enabled_interfaces[pair[1]].enable_ip_forwarding
      accelerated_networking_enabled = local.enabled_interfaces[pair[1]].accelerated_networking_enabled
    }
  }

  zones = {
    for suffix in local.instance_suffixes :
    suffix => local.architecture == "single" ? (trimspace(var.single_zone) != "" ? trimspace(var.single_zone) : null) : lookup(var.availability_zones, suffix, null)
  }

  tags = merge(
    var.tags,
    {
      FortiGateArchitecture = local.architecture
      FortiGateLicenseType  = upper(var.license_type)
      ManagementAccessModel = lower(var.management_access_model)
      PublicAdminAccess     = "false"
    }
  )

  internal_lb_enabled = local.architecture == "active-passive" && var.internal_load_balancer.enabled
  external_lb_enabled = local.architecture == "active-passive" && var.external_load_balancer.enabled
  public_ip_enabled   = local.external_lb_enabled && var.external_load_balancer.create_public_ip

  internal_lb_interface = try(local.enabled_interfaces[var.internal_load_balancer.interface_name], null)
  external_lb_interface = try(local.enabled_interfaces[var.external_load_balancer.interface_name], null)
}
