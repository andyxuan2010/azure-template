# Azure Application Gateway

Provisions an Azure Application Gateway v2 with a public frontend, backend routing, optional Web Application Firewall (WAF), managed identity, availability zones, and Azure Monitor diagnostics.

## Features

- Supports Standard_v2 and WAF_v2 SKUs with fixed capacity or autoscaling.
- Configures HTTP and HTTPS listeners, probes, backend pools, backend settings, basic routing, and path-based routing.
- Supports a public frontend and an additional static private frontend.
- Supports inline WAF configuration or an existing WAF policy.
- Supports user-assigned managed identities for certificate access.
- Sends selected logs and metrics to Log Analytics.
- Merges inherited resource-group tags with caller tags.

## Resources Created

The module always creates:

- one Azure Application Gateway;
- one Standard, static Azure Public IP address.

It conditionally creates an Azure Monitor diagnostic setting. The target resource group is read but not managed.

## Prerequisites and Dependencies

- An existing resource group.
- A dedicated Application Gateway subnet. Do not place unrelated resources in that subnet.
- Backend IP addresses or fully qualified domain names reachable from the gateway subnet.
- Optional Log Analytics workspace, WAF policy, and user-assigned identity.
- For HTTPS listeners, base64-encoded PFX certificate data and its password.
- Azure permissions to create network resources, diagnostics, and any identity association.

Pass dependency IDs from the modules that own them. See the repository [module dependency guide](../../docs/MODULE_USAGE_AND_DEPENDENCIES.md).

## Provider Configuration

Configure AzureRM in the calling root module:

```hcl
provider "azurerm" {
  features {}
}
```

The provider must target the subscription containing the resource group, subnet, and referenced resources.

## Basic Usage

```hcl
module "application_gateway" {
  source = "./modules/applicationgateway"

  name                = "agw-platform-dev"
  resource_group_name = "rg-platform-dev"
  location            = "canadacentral"
  subnet_id           = module.vnet.subnet_ids["application-gateway"]

  backend_address_pools = {
    app = { ip_addresses = ["192.0.2.10"] }
  }

  backend_http_settings = {
    app = { port = 80, protocol = "Http" }
  }

  http_listeners = {
    public = { frontend_port_name = "http", protocol = "Http" }
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
```

Runnable configurations are available in:

- [`examples/basic`](examples/basic/)
- [`examples/complete`](examples/complete/)

## Important Behavior and Secure Defaults

- The module always creates a public IP and public frontend. Use listener rules, NSGs, WAF, and backend controls appropriate to the exposure.
- Use WAF_v2 in Prevention mode for reviewed production internet ingress.
- Fixed `capacity` is ignored when `autoscale_configuration` is set.
- `sku_name` and `sku_tier` must both be Standard_v2 or both be WAF_v2.
- Routing map keys are stable Terraform identities; changing them can replace nested configuration.
- Certificate data and passwords are represented in Terraform state. Protect the state backend and avoid committing certificate material.
- Availability-zone and WAF capabilities vary by region and can increase cost.

## Networking and Private Connectivity

The gateway requires a dedicated subnet and creates a public frontend. `private_ip_address` adds a static private frontend but does not remove the public frontend.

Verify:

- the subnet is large enough for autoscaling and upgrades;
- NSGs and user-defined routes permit Azure infrastructure and backend health probes;
- backend FQDNs resolve from the gateway subnet;
- the selected private address belongs to the gateway subnet;
- listener and routing-rule frontend names match the configured frontend.

## Identity and RBAC

Supply user-assigned identity resource IDs when the gateway needs to retrieve certificates from Key Vault. The module attaches identities but does not grant Key Vault permissions. Create least-privilege assignments at the certificate or vault scope in the calling composition.

## Naming and Tagging

Set `name` explicitly or let the module generate one from its naming inputs. Public IP naming follows the gateway unless `public_ip_name` is supplied.

Caller tags override inherited resource-group tags. Follow the repository [naming convention](../../docs/NAMING_CONVENTION.md) and [tagging standard](../../docs/TAGGING_STANDARD.md).

## Testing

`tests/unit.tftest.hcl` uses a mocked AzureRM provider and plan-only runs:

```powershell
terraform init -backend=false
terraform validate
terraform test
```

The test does not authenticate to Azure or create resources.

## Known Limitations

- A public IP and public frontend are always created; a private-only gateway is not supported.
- Key Vault certificate references are not modeled directly; HTTPS certificates use PFX data supplied to Terraform.
- The module does not create the subnet, WAF policy, identities, certificates, DNS records, or backend services.
- Diagnostic settings currently target Log Analytics only.

## Terraform Reference

The content below is generated from the module source. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, < 5.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_application_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used for policy validation. Supply environment tags explicitly through tags. | `string` | `"dev"` | no |
| <a name="input_autoscale_configuration"></a> [autoscale\_configuration](#input\_autoscale\_configuration) | Optional autoscale configuration. When set, fixed capacity is not used. | <pre>object({<br>    min_capacity = optional(number, 1)<br>    max_capacity = optional(number, 2)<br>  })</pre> | `null` | no |
| <a name="input_backend_address_pools"></a> [backend\_address\_pools](#input\_backend\_address\_pools) | Backend address pools keyed by pool name. | <pre>map(object({<br>    fqdns        = optional(list(string), [])<br>    ip_addresses = optional(list(string), [])<br>  }))</pre> | `{}` | no |
| <a name="input_backend_http_settings"></a> [backend\_http\_settings](#input\_backend\_http\_settings) | Backend HTTP settings keyed by setting name. | <pre>map(object({<br>    port                                = number<br>    protocol                            = string<br>    cookie_based_affinity               = optional(string, "Disabled")<br>    request_timeout                     = optional(number, 30)<br>    host_name                           = optional(string)<br>    path                                = optional(string)<br>    probe_name                          = optional(string)<br>    pick_host_name_from_backend_address = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_capacity"></a> [capacity](#input\_capacity) | Fixed instance capacity when autoscale\_configuration is not used. | `number` | `2` | no |
| <a name="input_diagnostic_setting_enabled_log_categories"></a> [diagnostic\_setting\_enabled\_log\_categories](#input\_diagnostic\_setting\_enabled\_log\_categories) | Optional diagnostic log categories to enable for Application Gateway. | `list(string)` | `[]` | no |
| <a name="input_diagnostic_setting_enabled_metric_categories"></a> [diagnostic\_setting\_enabled\_metric\_categories](#input\_diagnostic\_setting\_enabled\_metric\_categories) | Optional diagnostic metric categories to enable for Application Gateway. | `list(string)` | `[]` | no |
| <a name="input_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#input\_diagnostic\_setting\_name) | Name of the Application Gateway diagnostic setting. | `string` | `"application-gateway-diagnostics"` | no |
| <a name="input_enable_http2"></a> [enable\_http2](#input\_enable\_http2) | Enable HTTP/2 on the Application Gateway. | `bool` | `true` | no |
| <a name="input_frontend_ports"></a> [frontend\_ports](#input\_frontend\_ports) | Frontend ports keyed by port name. | `map(number)` | <pre>{<br>  "http": 80<br>}</pre> | no |
| <a name="input_gateway_firewall_policy_id"></a> [gateway\_firewall\_policy\_id](#input\_gateway\_firewall\_policy\_id) | Optional global Web Application Firewall policy resource ID attached to the Application Gateway. | `string` | `null` | no |
| <a name="input_http_listeners"></a> [http\_listeners](#input\_http\_listeners) | HTTP listeners keyed by listener name. | <pre>map(object({<br>    frontend_port_name             = string<br>    protocol                       = string<br>    host_name                      = optional(string)<br>    host_names                     = optional(list(string), [])<br>    ssl_certificate_name           = optional(string)<br>    require_sni                    = optional(bool, false)<br>    firewall_policy_id             = optional(string)<br>    frontend_ip_configuration_name = optional(string, "public")<br>  }))</pre> | n/a | yes |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Optional user-assigned managed identity IDs attached to the Application Gateway. | `list(string)` | `[]` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into Application Gateway resources. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance identifier used when name is not provided. | `string` | `"001"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the Application Gateway. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Optional Log Analytics workspace resource ID for Application Gateway diagnostics. | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Optional Application Gateway name override. Leave empty to generate one from the naming convention. | `string` | `""` | no |
| <a name="input_private_ip_address"></a> [private\_ip\_address](#input\_private\_ip\_address) | Optional static private IP address for an additional private frontend IP configuration. | `string` | `null` | no |
| <a name="input_probes"></a> [probes](#input\_probes) | Health probes keyed by probe name. | <pre>map(object({<br>    protocol                                  = string<br>    path                                      = optional(string, "/")<br>    host                                      = optional(string, "127.0.0.1")<br>    interval                                  = optional(number, 30)<br>    timeout                                   = optional(number, 30)<br>    unhealthy_threshold                       = optional(number, 3)<br>    pick_host_name_from_backend_http_settings = optional(bool, false)<br>    minimum_servers                           = optional(number, 0)<br>    match_status_codes                        = optional(list(string), ["200-399"])<br>  }))</pre> | `{}` | no |
| <a name="input_public_ip_name"></a> [public\_ip\_name](#input\_public\_ip\_name) | Public IP resource name. Leave empty to derive from the gateway name. | `string` | `""` | no |
| <a name="input_request_routing_rules"></a> [request\_routing\_rules](#input\_request\_routing\_rules) | Request routing rules keyed by rule name. | <pre>map(object({<br>    rule_type                  = string<br>    http_listener_name         = string<br>    backend_address_pool_name  = optional(string)<br>    backend_http_settings_name = optional(string)<br>    url_path_map_name          = optional(string)<br>    priority                   = optional(number)<br>  }))</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group where the Application Gateway will be created. | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | Application Gateway SKU name. | `string` | `"Standard_v2"` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | Application Gateway SKU tier. | `string` | `"Standard_v2"` | no |
| <a name="input_ssl_certificates"></a> [ssl\_certificates](#input\_ssl\_certificates) | SSL certificates keyed by certificate name. Certificate data must be base64-encoded PFX content. | <pre>map(object({<br>    data     = string<br>    password = string<br>  }))</pre> | `{}` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | Optional SSL policy configuration for the Application Gateway. | <pre>object({<br>    policy_type          = string<br>    policy_name          = optional(string)<br>    min_protocol_version = optional(string)<br>    cipher_suites        = optional(list(string))<br>  })</pre> | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Dedicated subnet resource ID used by the Application Gateway gateway IP configuration. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to Application Gateway resources. | `map(string)` | `{}` | no |
| <a name="input_url_path_maps"></a> [url\_path\_maps](#input\_url\_path\_maps) | URL path maps keyed by name for PathBasedRouting rules. | <pre>map(object({<br>    default_backend_address_pool_name  = string<br>    default_backend_http_settings_name = string<br>    path_rules = map(object({<br>      paths                      = list(string)<br>      backend_address_pool_name  = string<br>      backend_http_settings_name = string<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_waf_configuration"></a> [waf\_configuration](#input\_waf\_configuration) | Optional WAF configuration. Required when using the WAF\_v2 SKU. | <pre>object({<br>    enabled                  = optional(bool, true)<br>    firewall_mode            = optional(string, "Prevention")<br>    rule_set_type            = optional(string, "OWASP")<br>    rule_set_version         = optional(string, "3.2")<br>    request_body_check       = optional(bool, true)<br>    file_upload_limit_mb     = optional(number, 100)<br>    max_request_body_size_kb = optional(number, 128)<br>  })</pre> | `null` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Deprecated compatibility input. Supply workload tags explicitly through tags. | `string` | `"project"` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Optional availability zones. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_address_pool_names"></a> [backend\_address\_pool\_names](#output\_backend\_address\_pool\_names) | Backend address pool names defined on the Application Gateway. |
| <a name="output_backend_http_settings_names"></a> [backend\_http\_settings\_names](#output\_backend\_http\_settings\_names) | Backend HTTP settings names defined on the Application Gateway. |
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | Application Gateway diagnostic setting ID, or null when diagnostics are not configured. |
| <a name="output_frontend_ip_configuration_name"></a> [frontend\_ip\_configuration\_name](#output\_frontend\_ip\_configuration\_name) | Frontend IP configuration name exposed by this module. |
| <a name="output_http_listener_names"></a> [http\_listener\_names](#output\_http\_listener\_names) | HTTP listener names defined on the Application Gateway. |
| <a name="output_id"></a> [id](#output\_id) | Application Gateway ID. |
| <a name="output_location"></a> [location](#output\_location) | Azure region of the Application Gateway. |
| <a name="output_merged_tags"></a> [merged\_tags](#output\_merged\_tags) | Final merged tags applied to Application Gateway resources. |
| <a name="output_name"></a> [name](#output\_name) | Application Gateway name. |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | Public IP address attached to the Application Gateway frontend. |
| <a name="output_public_ip_id"></a> [public\_ip\_id](#output\_public\_ip\_id) | Public IP ID attached to the Application Gateway frontend. |
| <a name="output_request_routing_rule_names"></a> [request\_routing\_rule\_names](#output\_request\_routing\_rule\_names) | Request routing rule names defined on the Application Gateway. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group name containing the Application Gateway. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to the Application Gateway. |
| <a name="output_url_path_map_names"></a> [url\_path\_map\_names](#output\_url\_path\_map\_names) | URL path map names defined on the Application Gateway. |
<!-- END_TF_DOCS -->
