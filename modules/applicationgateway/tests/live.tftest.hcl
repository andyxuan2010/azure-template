provider "azurerm" {
  features {}
}

variables {
  name                = "agw-platform-dev"
  resource_group_name = "rg-platform-dev"
  location            = "canadacentral"
  subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-dev/providers/Microsoft.Network/virtualNetworks/vnet-platform-dev/subnets/snet-appgw"
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
}
