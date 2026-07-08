resource "azurerm_virtual_network" "this" {
  count = var.create_virtual_network ? 1 : 0

  name                = trimspace(var.virtual_network_name) != "" ? trimspace(var.virtual_network_name) : "vnet-${local.name_prefix}"
  location            = var.location
  resource_group_name = local.vnet_rg_name
  address_space       = var.virtual_network_address_space
  tags                = local.tags
}

resource "azurerm_subnet" "this" {
  for_each = local.created_subnet_interfaces

  name                 = each.value.subnet_name
  resource_group_name  = local.vnet_rg_name
  virtual_network_name = local.vnet_name
  address_prefixes     = each.value.address_prefixes

  lifecycle {
    precondition {
      condition     = trimspace(local.vnet_name) != ""
      error_message = "virtual_network_name is required when creating subnets in a shared VNet."
    }

    precondition {
      condition     = trimspace(each.value.subnet_name) != "" && length(each.value.address_prefixes) > 0
      error_message = "Each interface requires subnet_name and address_prefixes when create_subnets is true."
    }
  }
}

resource "azurerm_network_security_group" "this" {
  count = var.create_network_security_group ? 1 : 0

  name                = trimspace(var.network_security_group_name) != "" ? trimspace(var.network_security_group_name) : "nsg-${local.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags

  dynamic "security_rule" {
    for_each = local.network_security_rules_effective

    content {
      name                         = security_rule.key
      priority                     = security_rule.value.priority
      direction                    = security_rule.value.direction
      access                       = security_rule.value.access
      protocol                     = security_rule.value.protocol
      source_port_range            = try(security_rule.value.source_port_range, null)
      source_port_ranges           = try(security_rule.value.source_port_ranges, null)
      destination_port_range       = try(security_rule.value.destination_port_range, null)
      destination_port_ranges      = try(security_rule.value.destination_port_ranges, null)
      source_address_prefix        = try(security_rule.value.source_address_prefix, null)
      source_address_prefixes      = try(security_rule.value.source_address_prefixes, null)
      destination_address_prefix   = try(security_rule.value.destination_address_prefix, null)
      destination_address_prefixes = try(security_rule.value.destination_address_prefixes, null)
      description                  = try(security_rule.value.description, null)
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.create_network_security_group ? {
    for name, interface in local.enabled_interfaces : name => interface
    if interface.associate_nsg
  } : {}

  subnet_id                 = local.interface_subnet_ids[each.key]
  network_security_group_id = azurerm_network_security_group.this[0].id
}

resource "azurerm_network_interface" "this" {
  for_each = local.nics

  name                           = "${local.name_prefix}-${each.value.instance_suffix}-${each.value.interface_name}-nic"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  accelerated_networking_enabled = each.value.accelerated_networking_enabled
  ip_forwarding_enabled          = each.value.enable_ip_forwarding
  tags                           = local.tags

  ip_configuration {
    name                          = "ipconfig1"
    primary                       = true
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = each.value.private_ip_address_allocation
    private_ip_address            = each.value.private_ip_address
  }

  lifecycle {
    precondition {
      condition     = trimspace(each.value.subnet_id) != ""
      error_message = "Every enabled interface must resolve to a subnet ID."
    }

    precondition {
      condition     = each.value.private_ip_address_allocation != "Static" || each.value.private_ip_address != null
      error_message = "Static interfaces require a private_ip_addresses entry for each deployed instance suffix."
    }
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  for_each = toset(local.instance_suffixes)

  name                = "${local.name_prefix}-${each.value}"
  computer_name       = substr(replace("${local.name_prefix}-${each.value}", "-", ""), 0, 64)
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  zone                = local.zones[each.value]
  admin_username      = var.admin_username
  admin_password      = local.admin_password_effective
  custom_data         = trimspace(var.custom_data) != "" ? base64encode(var.custom_data) : null

  disable_password_authentication = local.admin_ssh_key_enabled

  network_interface_ids = concat(
    [
      for name, interface in local.enabled_interfaces :
      azurerm_network_interface.this["${each.value}-${name}"].id
      if interface.primary
    ],
    [
      for name, interface in local.enabled_interfaces :
      azurerm_network_interface.this["${each.value}-${name}"].id
      if !interface.primary
    ]
  )

  dynamic "admin_ssh_key" {
    for_each = local.admin_ssh_key_enabled ? [local.admin_ssh_key_effective] : []

    content {
      username   = var.admin_username
      public_key = admin_ssh_key.value
    }
  }

  dynamic "plan" {
    for_each = var.marketplace_plan == null ? [] : [var.marketplace_plan]

    content {
      name      = plan.value.name
      product   = plan.value.product
      publisher = plan.value.publisher
    }
  }

  os_disk {
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type
    disk_size_gb         = try(var.os_disk.disk_size_gb, null)
  }

  source_image_reference {
    publisher = var.image.publisher
    offer     = var.image.offer
    sku       = var.image.sku
    version   = var.image.version
  }

  tags = local.tags

  lifecycle {
    precondition {
      condition     = length([for interface in values(local.enabled_interfaces) : interface if interface.primary]) == 1
      error_message = "Exactly one enabled interface must set primary = true."
    }

    precondition {
      condition     = local.admin_password_enabled || local.admin_ssh_key_enabled
      error_message = "Set admin_password or admin_ssh_public_key, or configure their Key Vault fallback secrets."
    }

    precondition {
      condition     = local.architecture != "active-passive" || alltrue([for suffix in ["a", "b"] : lookup(var.availability_zones, suffix, "") != ""])
      error_message = "active-passive architecture requires availability_zones entries for a and b."
    }
  }
}

resource "azurerm_public_ip" "external_lb" {
  count = local.public_ip_enabled ? 1 : 0

  name                = trimspace(var.external_load_balancer.public_ip_name) != "" ? var.external_load_balancer.public_ip_name : "pip-${local.name_prefix}-external-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = length(var.load_balancer_frontend_zones) > 0 ? var.load_balancer_frontend_zones : null
  domain_name_label   = trimspace(var.external_load_balancer.public_ip_domain_name) != "" ? var.external_load_balancer.public_ip_domain_name : null
  tags                = local.tags
}

resource "azurerm_lb" "internal" {
  count = local.internal_lb_enabled ? 1 : 0

  name                = trimspace(var.internal_load_balancer.name) != "" ? var.internal_load_balancer.name : "lb-${local.name_prefix}-internal"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  tags                = local.tags

  frontend_ip_configuration {
    name                          = "internal-frontend"
    subnet_id                     = local.interface_subnet_ids[var.internal_load_balancer.interface_name]
    private_ip_address            = try(var.internal_load_balancer.frontend_ip_address, null)
    private_ip_address_allocation = var.internal_load_balancer.frontend_allocation
    zones                         = length(var.load_balancer_frontend_zones) > 0 ? var.load_balancer_frontend_zones : null
  }

  lifecycle {
    precondition {
      condition     = local.internal_lb_interface != null
      error_message = "internal_load_balancer.interface_name must reference an enabled interface."
    }
  }
}

resource "azurerm_lb" "external" {
  count = local.external_lb_enabled ? 1 : 0

  name                = trimspace(var.external_load_balancer.name) != "" ? var.external_load_balancer.name : "lb-${local.name_prefix}-external"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  tags                = local.tags

  frontend_ip_configuration {
    name                          = "external-frontend"
    public_ip_address_id          = local.public_ip_enabled ? azurerm_public_ip.external_lb[0].id : null
    subnet_id                     = local.public_ip_enabled ? null : local.interface_subnet_ids[var.external_load_balancer.interface_name]
    private_ip_address            = local.public_ip_enabled ? null : try(var.external_load_balancer.frontend_ip_address, null)
    private_ip_address_allocation = local.public_ip_enabled ? null : var.external_load_balancer.frontend_allocation
    zones                         = local.public_ip_enabled || length(var.load_balancer_frontend_zones) == 0 ? null : var.load_balancer_frontend_zones
  }

  lifecycle {
    precondition {
      condition     = local.external_lb_interface != null
      error_message = "external_load_balancer.interface_name must reference an enabled interface."
    }
  }
}

resource "azurerm_lb_backend_address_pool" "internal" {
  count = local.internal_lb_enabled ? 1 : 0

  name            = "fortigate-internal"
  loadbalancer_id = azurerm_lb.internal[0].id
}

resource "azurerm_lb_backend_address_pool" "external" {
  count = local.external_lb_enabled ? 1 : 0

  name            = "fortigate-external"
  loadbalancer_id = azurerm_lb.external[0].id
}

resource "azurerm_network_interface_backend_address_pool_association" "internal" {
  for_each = local.internal_lb_enabled ? toset(local.instance_suffixes) : toset([])

  network_interface_id    = azurerm_network_interface.this["${each.value}-${var.internal_load_balancer.interface_name}"].id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.internal[0].id
}

resource "azurerm_network_interface_backend_address_pool_association" "external" {
  for_each = local.external_lb_enabled ? toset(local.instance_suffixes) : toset([])

  network_interface_id    = azurerm_network_interface.this["${each.value}-${var.external_load_balancer.interface_name}"].id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.external[0].id
}

resource "azurerm_lb_probe" "internal" {
  count = local.internal_lb_enabled ? 1 : 0

  name                = "fortigate-health"
  loadbalancer_id     = azurerm_lb.internal[0].id
  protocol            = var.internal_load_balancer.health_probe_protocol
  port                = var.internal_load_balancer.health_probe_port
  request_path        = contains(["Http", "Https"], var.internal_load_balancer.health_probe_protocol) ? try(var.internal_load_balancer.health_probe_request_path, null) : null
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_probe" "external" {
  count = local.external_lb_enabled ? 1 : 0

  name                = "fortigate-health"
  loadbalancer_id     = azurerm_lb.external[0].id
  protocol            = var.external_load_balancer.health_probe_protocol
  port                = var.external_load_balancer.health_probe_port
  request_path        = contains(["Http", "Https"], var.external_load_balancer.health_probe_protocol) ? try(var.external_load_balancer.health_probe_request_path, null) : null
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "internal" {
  count = local.internal_lb_enabled ? 1 : 0

  name                           = "fortigate-ha-ports"
  loadbalancer_id                = azurerm_lb.internal[0].id
  protocol                       = var.internal_load_balancer.enable_ha_ports ? "All" : "Tcp"
  frontend_port                  = var.internal_load_balancer.enable_ha_ports ? 0 : var.internal_load_balancer.health_probe_port
  backend_port                   = var.internal_load_balancer.enable_ha_ports ? 0 : var.internal_load_balancer.health_probe_port
  frontend_ip_configuration_name = "internal-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.internal[0].id]
  probe_id                       = azurerm_lb_probe.internal[0].id
  floating_ip_enabled            = var.internal_load_balancer.enable_floating_ip
  idle_timeout_in_minutes        = var.internal_load_balancer.idle_timeout_in_minutes
  disable_outbound_snat          = true
}

resource "azurerm_lb_rule" "external" {
  count = local.external_lb_enabled ? 1 : 0

  name                           = "fortigate-ha-ports"
  loadbalancer_id                = azurerm_lb.external[0].id
  protocol                       = var.external_load_balancer.enable_ha_ports ? "All" : "Tcp"
  frontend_port                  = var.external_load_balancer.enable_ha_ports ? 0 : var.external_load_balancer.health_probe_port
  backend_port                   = var.external_load_balancer.enable_ha_ports ? 0 : var.external_load_balancer.health_probe_port
  frontend_ip_configuration_name = "external-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.external[0].id]
  probe_id                       = azurerm_lb_probe.external[0].id
  floating_ip_enabled            = var.external_load_balancer.enable_floating_ip
  idle_timeout_in_minutes        = var.external_load_balancer.idle_timeout_in_minutes
  disable_outbound_snat          = true
}
