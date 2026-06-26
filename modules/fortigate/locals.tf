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

  admin_credentials_key_vault_id_effective = trimspace(var.admin_credentials_key_vault_id)
  admin_password_secret_name_effective     = trimspace(var.admin_password_secret_name)
  admin_ssh_key_secret_name_effective      = trimspace(var.admin_ssh_key_secret_name)

  admin_password_input_effective = trimspace(nonsensitive(var.admin_password))
  admin_ssh_key_input_effective  = trimspace(nonsensitive(var.admin_ssh_public_key))
  admin_password_input_provided  = nonsensitive(local.admin_password_input_effective != "")
  admin_ssh_key_input_provided   = nonsensitive(local.admin_ssh_key_input_effective != "")

  admin_credentials_key_vault_enabled = local.admin_credentials_key_vault_id_effective != ""
  admin_password_secret_lookup_enabled = nonsensitive(
    local.admin_credentials_key_vault_enabled &&
    !local.admin_password_input_provided &&
    local.admin_password_secret_name_effective != ""
  )
  admin_ssh_key_secret_lookup_enabled = nonsensitive(
    local.admin_credentials_key_vault_enabled &&
    !local.admin_ssh_key_input_provided &&
    local.admin_ssh_key_secret_name_effective != ""
  )

  admin_password_secret_value = try(trimspace(data.azurerm_key_vault_secret.admin_password["active"].value), "")
  admin_ssh_key_secret_value  = try(trimspace(data.azurerm_key_vault_secret.admin_ssh_key["active"].value), "")

  admin_password_effective = try(coalesce(
    local.admin_password_input_effective != "" ? local.admin_password_input_effective : null,
    local.admin_password_secret_value != "" ? local.admin_password_secret_value : null
  ), null)
  admin_ssh_key_effective = try(coalesce(
    local.admin_ssh_key_input_effective != "" ? local.admin_ssh_key_input_effective : null,
    local.admin_ssh_key_secret_value != "" ? local.admin_ssh_key_secret_value : null
  ), null)
  admin_password_enabled = nonsensitive(local.admin_password_effective != null)
  admin_ssh_key_enabled  = nonsensitive(local.admin_ssh_key_effective != null)

  admin_ssh_network_security_rules = {
    for index, source in var.admin_ssh_source_address_prefixes :
    "Allow-SSH-${index}" => {
      priority                   = 1001 + index
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = source
      destination_address_prefix = "*"
      description                = "Allow FortiGate SSH administration from trusted source ${source}."
    }
  }
  network_security_rules_effective = merge(
    local.admin_ssh_network_security_rules,
    var.network_security_rules
  )

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
