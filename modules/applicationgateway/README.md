# Application Gateway Module

Create an Azure Application Gateway v2 with a public frontend, backend pools, listeners, basic or path-based routing, optional WAF, and optional Log Analytics diagnostics.

## Overview

- Providers: `azurerm`
- Inputs: core resource settings plus maps for `frontend_ports`, `backend_address_pools`, `backend_http_settings`, `http_listeners`, and `request_routing_rules`
- Outputs: gateway identity, public IP details, and configured listener/rule names
- Terraform tests: `tests/live.tftest.hcl`

## Features

- Creates a Standard public IP and one Application Gateway resource.
- Supports `Standard_v2` and `WAF_v2` SKUs.
- Supports fixed capacity or autoscale configuration.
- Supports HTTP and HTTPS listeners.
- Supports URL path maps and path rules for `PathBasedRouting`.
- Supports optional WAF and user-assigned managed identity attachment.
- Supports Application Gateway logs and metrics through an Azure Monitor diagnostic setting.
- Merges caller tags over optional resource-group tags; the module does not synthesize governance tags.

## Basic Usage

```hcl
module "applicationgateway" {
  source = "./modules/applicationgateway"

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

  tags = {
    Owner = "Platform"
  }
}
```

## Key Inputs

- `name`: Application Gateway name. `string` (required)
- `resource_group_name`: Resource group for the gateway. `string` (required)
- `location`: Azure region. `string` (required)
- `subnet_id`: Dedicated subnet resource ID for the gateway. `string` (required)
- `frontend_ports`: Frontend ports keyed by name. `map(number)` (default: `{ http = 80 }`)
- `backend_address_pools`: Backend pools keyed by name. `map(object)` (default: `{}`)
- `backend_http_settings`: Backend HTTP settings keyed by name. `map(object)` (default: `{}`)
- `http_listeners`: Listener definitions keyed by name. `map(object)` (required)
- `request_routing_rules`: Routing rule definitions keyed by name. `map(object)` (required)
- `url_path_maps`: URL path maps used by `PathBasedRouting` rules. `map(object)` (default: `{}`)
- `autoscale_configuration`: Optional autoscale settings. `object` (default: `null`)
- `waf_configuration`: Optional WAF settings, required for `WAF_v2`. `object` (default: `null`)
- `inherited_resource_group_tags`: Optional plan-known resource-group tags. Supplying this avoids a data-source read during planning.
- `log_analytics_workspace_id`: Workspace destination for diagnostics. Categories must also be supplied.

## Notable Outputs

- `id`: Application Gateway ID
- `name`: Application Gateway name
- `public_ip_id`: Public IP resource ID
- `public_ip_address`: Public IP address
- `backend_address_pool_names`: Backend pool names
- `backend_http_settings_names`: Backend HTTP settings names
- `http_listener_names`: Listener names
- `request_routing_rule_names`: Routing rule names
- `url_path_map_names`: URL path map names
- `diagnostic_setting_id`: Diagnostic setting ID, or `null`

## Testing

Run module tests from the module directory:

```powershell
terraform test
terraform test -filter='tests\live.tftest.hcl'
```

The test file uses a mocked AzureRM provider and does not deploy resources.
