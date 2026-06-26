# Examples

## Public HTTP Gateway

Deploy an Application Gateway with one public HTTP listener and one backend pool for an internal application endpoint.

## Path-Based Routing

```hcl
module "applicationgateway" {
  source = "./modules/applicationgateway"

  name                = "agw-platform-prod"
  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  subnet_id           = azurerm_subnet.application_gateway.id

  backend_address_pools = {
    web = { fqdns = ["web.internal.contoso.com"] }
    api = { fqdns = ["api.internal.contoso.com"] }
  }

  backend_http_settings = {
    https = {
      port     = 443
      protocol = "Https"
    }
  }

  http_listeners = {
    public = {
      frontend_port_name = "http"
      protocol           = "Http"
    }
  }

  url_path_maps = {
    application = {
      default_backend_address_pool_name  = "web"
      default_backend_http_settings_name = "https"
      path_rules = {
        api = {
          paths                      = ["/api/*"]
          backend_address_pool_name  = "api"
          backend_http_settings_name = "https"
        }
      }
    }
  }

  request_routing_rules = {
    application = {
      rule_type          = "PathBasedRouting"
      http_listener_name = "public"
      url_path_map_name  = "application"
      priority           = 100
    }
  }
}
```

## Log Analytics Diagnostics

```hcl
module "applicationgateway" {
  # Core gateway inputs omitted.

  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  diagnostic_setting_enabled_log_categories = [
    "ApplicationGatewayAccessLog",
    "ApplicationGatewayFirewallLog"
  ]
  diagnostic_setting_enabled_metric_categories = ["AllMetrics"]
}
```
