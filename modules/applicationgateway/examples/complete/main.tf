terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "application_gateway" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  subnet_id                     = var.subnet_id
  app_env                       = "prod"
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}
  sku_name                      = "WAF_v2"
  sku_tier                      = "WAF_v2"
  zones                         = ["1", "2", "3"]

  autoscale_configuration = {
    min_capacity = 2
    max_capacity = 5
  }

  frontend_ports = {
    https = 443
  }

  ssl_policy = {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101S"
  }

  ssl_certificates = {
    application = {
      data     = var.ssl_certificate_data
      password = var.ssl_certificate_password
    }
  }

  backend_address_pools = {
    web = {
      ip_addresses = var.web_backend_ip_addresses
    }
    api = {
      ip_addresses = var.api_backend_ip_addresses
    }
  }

  probes = {
    application = {
      protocol = "Http"
      path     = "/health"
    }
  }

  backend_http_settings = {
    application = {
      port       = 80
      protocol   = "Http"
      probe_name = "application"
    }
  }

  http_listeners = {
    public_https = {
      frontend_port_name   = "https"
      protocol             = "Https"
      host_name            = var.hostname
      ssl_certificate_name = "application"
      require_sni          = true
    }
  }

  url_path_maps = {
    application = {
      default_backend_address_pool_name  = "web"
      default_backend_http_settings_name = "application"
      path_rules = {
        api = {
          paths                      = ["/api/*"]
          backend_address_pool_name  = "api"
          backend_http_settings_name = "application"
        }
      }
    }
  }

  request_routing_rules = {
    application = {
      rule_type          = "PathBasedRouting"
      http_listener_name = "public_https"
      url_path_map_name  = "application"
      priority           = 100
    }
  }

  waf_configuration = {
    enabled       = true
    firewall_mode = "Prevention"
  }

  log_analytics_workspace_id = var.log_analytics_workspace_id
  diagnostic_setting_enabled_log_categories = [
    "ApplicationGatewayAccessLog",
    "ApplicationGatewayFirewallLog"
  ]
  diagnostic_setting_enabled_metric_categories = ["AllMetrics"]

  tags = {
    Environment    = "prod"
    Owner          = "Platform"
    BusinessImpact = "High"
    DataClass      = "Internal"
  }
}
