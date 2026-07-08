resource "azurerm_public_ip" "this" {
  name                = local.public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones
  tags                = local.merged_tags
}

resource "azurerm_application_gateway" "this" {
  name                = local.application_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = var.zones
  http2_enabled       = var.enable_http2
  firewall_policy_id  = var.gateway_firewall_policy_id
  tags                = local.merged_tags

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = local.use_autoscale ? null : var.capacity
  }

  dynamic "autoscale_configuration" {
    for_each = local.use_autoscale ? [var.autoscale_configuration] : []

    content {
      min_capacity = autoscale_configuration.value.min_capacity
      max_capacity = autoscale_configuration.value.max_capacity
    }
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.this.id
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.private_ip_address != null ? [1] : []
    content {
      name                          = "${local.frontend_ip_configuration_name}-private"
      subnet_id                     = var.subnet_id
      private_ip_address            = var.private_ip_address
      private_ip_address_allocation = "Static"
    }
  }

  dynamic "ssl_policy" {
    for_each = var.ssl_policy != null ? [var.ssl_policy] : []
    content {
      policy_type          = ssl_policy.value.policy_type
      policy_name          = ssl_policy.value.policy_type == "Predefined" ? ssl_policy.value.policy_name : null
      min_protocol_version = ssl_policy.value.policy_type != "Predefined" ? ssl_policy.value.min_protocol_version : null
      cipher_suites        = ssl_policy.value.policy_type != "Predefined" ? ssl_policy.value.cipher_suites : null
    }
  }

  dynamic "frontend_port" {
    for_each = var.frontend_ports

    content {
      name = frontend_port.key
      port = frontend_port.value
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools

    content {
      name         = backend_address_pool.key
      fqdns        = try(backend_address_pool.value.fqdns, [])
      ip_addresses = try(backend_address_pool.value.ip_addresses, [])
    }
  }

  dynamic "probe" {
    for_each = var.probes

    content {
      name                                      = probe.key
      protocol                                  = probe.value.protocol
      path                                      = probe.value.path
      host                                      = probe.value.host
      interval                                  = probe.value.interval
      timeout                                   = probe.value.timeout
      unhealthy_threshold                       = probe.value.unhealthy_threshold
      pick_host_name_from_backend_http_settings = probe.value.pick_host_name_from_backend_http_settings
      minimum_servers                           = probe.value.minimum_servers

      match {
        status_code = probe.value.match_status_codes
      }
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings

    content {
      name                                = backend_http_settings.key
      cookie_based_affinity               = backend_http_settings.value.cookie_based_affinity
      path                                = try(backend_http_settings.value.path, null)
      port                                = backend_http_settings.value.port
      protocol                            = backend_http_settings.value.protocol
      request_timeout                     = backend_http_settings.value.request_timeout
      host_name                           = try(backend_http_settings.value.host_name, null)
      probe_name                          = try(backend_http_settings.value.probe_name, null)
      pick_host_name_from_backend_address = backend_http_settings.value.pick_host_name_from_backend_address
    }
  }

  dynamic "ssl_certificate" {
    for_each = var.ssl_certificates

    content {
      name     = ssl_certificate.key
      data     = ssl_certificate.value.data
      password = ssl_certificate.value.password
    }
  }

  dynamic "http_listener" {
    for_each = var.http_listeners

    content {
      name                           = http_listener.key
      frontend_ip_configuration_name = try(http_listener.value.frontend_ip_configuration_name, local.frontend_ip_configuration_name)
      frontend_port_name             = http_listener.value.frontend_port_name
      protocol                       = http_listener.value.protocol
      host_name                      = try(http_listener.value.host_name, null)
      host_names                     = try(http_listener.value.host_names, [])
      ssl_certificate_name           = try(http_listener.value.ssl_certificate_name, null)
      require_sni                    = http_listener.value.require_sni
      firewall_policy_id             = try(http_listener.value.firewall_policy_id, null)
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.request_routing_rules

    content {
      name                       = request_routing_rule.key
      rule_type                  = request_routing_rule.value.rule_type
      http_listener_name         = request_routing_rule.value.http_listener_name
      backend_address_pool_name  = try(request_routing_rule.value.backend_address_pool_name, null)
      backend_http_settings_name = try(request_routing_rule.value.backend_http_settings_name, null)
      url_path_map_name          = try(request_routing_rule.value.url_path_map_name, null)
      priority                   = try(request_routing_rule.value.priority, null)
    }
  }

  dynamic "url_path_map" {
    for_each = var.url_path_maps

    content {
      name                               = url_path_map.key
      default_backend_address_pool_name  = url_path_map.value.default_backend_address_pool_name
      default_backend_http_settings_name = url_path_map.value.default_backend_http_settings_name

      dynamic "path_rule" {
        for_each = url_path_map.value.path_rules

        content {
          name                       = path_rule.key
          paths                      = path_rule.value.paths
          backend_address_pool_name  = path_rule.value.backend_address_pool_name
          backend_http_settings_name = path_rule.value.backend_http_settings_name
        }
      }
    }
  }

  dynamic "waf_configuration" {
    for_each = local.waf_configuration_enabled ? [var.waf_configuration] : []

    content {
      enabled                  = waf_configuration.value.enabled
      firewall_mode            = waf_configuration.value.firewall_mode
      rule_set_type            = waf_configuration.value.rule_set_type
      rule_set_version         = waf_configuration.value.rule_set_version
      request_body_check       = waf_configuration.value.request_body_check
      file_upload_limit_mb     = waf_configuration.value.file_upload_limit_mb
      max_request_body_size_kb = waf_configuration.value.max_request_body_size_kb
    }
  }

  dynamic "identity" {
    for_each = length(var.identity_ids) > 0 ? [1] : []

    content {
      type         = "UserAssigned"
      identity_ids = var.identity_ids
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = local.diagnostics_enabled ? 1 : 0

  name                       = var.diagnostic_setting_name
  target_resource_id         = azurerm_application_gateway.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = toset(var.diagnostic_setting_enabled_log_categories)

    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = toset(var.diagnostic_setting_enabled_metric_categories)

    content {
      category = enabled_metric.value
    }
  }
}
