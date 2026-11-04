mock_provider "azurerm" {}

variables {
  name                = "agw-platform-dev"
  resource_group_name = "rg-platform-dev"
  location            = "canadacentral"
  subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-dev/providers/Microsoft.Network/virtualNetworks/vnet-platform-dev/subnets/snet-appgw"
  inherited_resource_group_tags = {
    CostCenter = "platform"
  }
  backend_address_pools = {
    app = {
      ip_addresses = ["10.42.1.4"]
    }
  }
  backend_http_settings = {
    app = {
      port     = 80
      protocol = "Http"
    }
  }
  http_listeners = {
    public = {
      frontend_port_name = "http"
      protocol           = "Http"
    }
  }
  request_routing_rules = {
    public = {
      rule_type                  = "Basic"
      http_listener_name         = "public"
      backend_address_pool_name  = "app"
      backend_http_settings_name = "app"
      priority                   = 100
    }
  }
}

run "plan" {
  command = plan

  assert {
    condition     = output.merged_tags["CostCenter"] == "platform"
    error_message = "Inherited resource-group tags were not applied."
  }
}

run "plan_path_based_routing" {
  command = plan

  variables {
    request_routing_rules = {
      public = {
        rule_type          = "PathBasedRouting"
        http_listener_name = "public"
        url_path_map_name  = "application"
        priority           = 100
      }
    }

    url_path_maps = {
      application = {
        default_backend_address_pool_name  = "app"
        default_backend_http_settings_name = "app"
        path_rules = {
          api = {
            paths                      = ["/api/*"]
            backend_address_pool_name  = "app"
            backend_http_settings_name = "app"
          }
        }
      }
    }
  }

  assert {
    condition     = contains(output.url_path_map_names, "application")
    error_message = "The path-based routing plan did not create the expected URL path map."
  }
}

run "plan_diagnostics" {
  command = plan

  variables {
    log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/log-platform"
    diagnostic_setting_enabled_log_categories = [
      "ApplicationGatewayAccessLog"
    ]
    diagnostic_setting_enabled_metric_categories = [
      "AllMetrics"
    ]
  }

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.this) == 1
    error_message = "Diagnostics inputs should create one diagnostic setting."
  }
}
