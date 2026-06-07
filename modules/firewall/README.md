# Firewall Module

Provision Azure Firewall with a policy-first baseline, Standard public IP management, optional forced tunneling, Virtual WAN hub mode, Firewall Policy controls, rule collection groups, diagnostics, and RBAC.

## Features

- Standard generated naming using `name_prefix`, `workload_name`, `app_env`, `location_code`, and optional random suffixes.
- Environment-specific tags plus inherited and caller-provided tags, without module-generated marker tags.
- VNet mode with created or supplied Standard public IPs, multiple IP configurations, and optional availability zones.
- Virtual WAN hub mode using `sku_name = "AZFW_Hub"` and `virtual_hub_id`.
- Firewall Policy creation by default, or attachment to an existing policy.
- DNS proxy enabled by default for policy-based deployments.
- Threat intelligence mode defaults to `Deny`.
- Premium policy options for IDPS, TLS inspection certificate, explicit proxy, and policy insights.
- Forced tunneling support with `AzureFirewallManagementSubnet` and created or supplied management public IP.
- Multiple Firewall Policy rule collection groups with application, network, and NAT collections.
- Backward-compatible `application_rule_collections`, `network_rule_collections`, and `nat_rule_collections` inputs.
- Diagnostics to Log Analytics, Storage Account archive, and Event Hub.
- Built-in Contributor and Reader assignments for Entra groups, plus generic firewall-scope RBAC assignments.

## Basic Usage

```hcl
module "firewall" {
  source = "./modules/firewall"

  resource_group_name = "rg-network-prod"
  location            = "canadacentral"
  workload_name       = "hub"
  app_env             = "prod"
  subnet_id           = module.vnet.subnet_ids["AzureFirewallSubnet"]
  zones               = ["1", "2", "3"]

  tags = {
    Owner = "CCOE"
  }
}
```

## Policy Rules

```hcl
module "firewall" {
  source = "./modules/firewall"

  resource_group_name = "rg-network-prod"
  location            = "canadacentral"
  name                = "afw-hub-prod-cc-001"
  subnet_id           = module.vnet.subnet_ids["AzureFirewallSubnet"]

  rule_collection_groups = {
    workload = {
      priority = 200
      application_rule_collections = {
        allow_platform = {
          priority = 210
          action   = "Allow"
          rules = {
            microsoft = {
              source_addresses  = ["10.10.0.0/16"]
              destination_fqdns = ["*.microsoft.com"]
              protocols = [
                {
                  type = "Https"
                  port = 443
                }
              ]
            }
          }
        }
      }
    }
  }
}
```

## Premium Forced Tunneling

```hcl
module "firewall" {
  source = "./modules/firewall"

  resource_group_name = "rg-network-prod"
  location            = "canadacentral"
  name                = "afw-hub-prod-cc-001"
  sku_tier            = "Premium"
  firewall_policy_sku = "Premium"
  subnet_id           = module.vnet.subnet_ids["AzureFirewallSubnet"]
  management_subnet_id = module.vnet.subnet_ids["AzureFirewallManagementSubnet"]

  intrusion_detection = {
    mode = "Deny"
  }

  tls_certificate = {
    name                = "fw-tls"
    key_vault_secret_id = azurerm_key_vault_secret.firewall_tls.id
  }
}
```

## Virtual Hub Firewall

```hcl
module "firewall" {
  source = "./modules/firewall"

  resource_group_name         = "rg-network-prod"
  location                    = "canadacentral"
  name                        = "afw-vhub-prod-cc-001"
  sku_name                    = "AZFW_Hub"
  create_public_ip            = false
  virtual_hub_id              = azurerm_virtual_hub.hub.id
  virtual_hub_public_ip_count = 2
}
```

## Notes

- Use `AzureFirewallSubnet` with at least `/26` address space for VNet-deployed firewalls.
- Use `AzureFirewallManagementSubnet` with at least `/26` address space when forced tunneling is enabled.
- Created public IPs are Standard and static, as required by Azure Firewall.
- Prefer Firewall Policy rule collection groups over classic firewall rule collections.
- Enable multiple availability zones in regions that support them for higher resiliency.
- Keep DNS proxy enabled when network rules depend on FQDN resolution consistency.

## Testing

Run module validation and tests from the module directory:

```powershell
terraform fmt -check -recursive
terraform validate
terraform test
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 3.8.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.73.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_firewall.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall) | resource |
| [azurerm_firewall_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy) | resource |
| [azurerm_firewall_policy_rule_collection_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy_rule_collection_group) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_public_ip.management](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_role_assignment.app_admin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_user_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azuread_group.app_admin](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azuread_group.app_user](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | Optional list of Entra group display names or object IDs that will have Contributor access to the firewall. | `list(string)` | `[]` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used for standard tags and generated naming. | `string` | `"dev"` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | Optional list of Entra group display names or object IDs that will have Reader access to the firewall. | `list(string)` | `[]` | no |
| <a name="input_application_rule_collections"></a> [application\_rule\_collections](#input\_application\_rule\_collections) | Backward-compatible application rule collections placed into the default rule collection group. | <pre>map(object({<br>    name     = optional(string)<br>    priority = number<br>    action   = string<br>    rules = map(object({<br>      name                  = optional(string)<br>      description           = optional(string)<br>      source_addresses      = optional(list(string), [])<br>      source_ip_groups      = optional(list(string), [])<br>      destination_addresses = optional(list(string), [])<br>      destination_fqdns     = optional(list(string), [])<br>      destination_urls      = optional(list(string), [])<br>      destination_fqdn_tags = optional(list(string), [])<br>      terminate_tls         = optional(bool)<br>      web_categories        = optional(list(string), [])<br>      protocols = list(object({<br>        type = string<br>        port = number<br>      }))<br>      http_headers = optional(list(object({<br>        name  = string<br>        value = string<br>      })), [])<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_auto_learn_private_ranges_enabled"></a> [auto\_learn\_private\_ranges\_enabled](#input\_auto\_learn\_private\_ranges\_enabled) | Whether the Firewall Policy auto-learns private IP ranges. | `bool` | `false` | no |
| <a name="input_base_policy_id"></a> [base\_policy\_id](#input\_base\_policy\_id) | Optional base Firewall Policy ID. | `string` | `""` | no |
| <a name="input_create_firewall_policy"></a> [create\_firewall\_policy](#input\_create\_firewall\_policy) | Whether to create and attach an Azure Firewall Policy. | `bool` | `true` | no |
| <a name="input_create_public_ip"></a> [create\_public\_ip](#input\_create\_public\_ip) | Whether to create Standard public IP addresses for VNet-deployed firewalls. | `bool` | `true` | no |
| <a name="input_diagnostic_eventhub_authorization_rule_id"></a> [diagnostic\_eventhub\_authorization\_rule\_id](#input\_diagnostic\_eventhub\_authorization\_rule\_id) | Optional Event Hub authorization rule resource ID for diagnostics. | `string` | `null` | no |
| <a name="input_diagnostic_eventhub_name"></a> [diagnostic\_eventhub\_name](#input\_diagnostic\_eventhub\_name) | Optional Event Hub name for diagnostics when using an Event Hub destination. | `string` | `null` | no |
| <a name="input_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#input\_diagnostic\_log\_categories) | Diagnostic log categories to enable. Use diagnostic\_log\_category\_groups for Azure Monitor category groups such as allLogs. | `list(string)` | <pre>[<br>  "AZFWApplicationRule",<br>  "AZFWNetworkRule",<br>  "AZFWNatRule",<br>  "AZFWThreatIntel",<br>  "AZFWDnsQuery",<br>  "AZFWIdpsSignature"<br>]</pre> | no |
| <a name="input_diagnostic_log_category_groups"></a> [diagnostic\_log\_category\_groups](#input\_diagnostic\_log\_category\_groups) | Diagnostic log category groups to enable, for example allLogs. | `list(string)` | `[]` | no |
| <a name="input_diagnostic_metric_categories"></a> [diagnostic\_metric\_categories](#input\_diagnostic\_metric\_categories) | Diagnostic metric categories to enable. | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| <a name="input_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#input\_diagnostic\_setting\_name) | Optional diagnostic setting name. When empty, the module uses <firewall-name>-diagnostic-setting. | `string` | `""` | no |
| <a name="input_diagnostic_storage_account_id"></a> [diagnostic\_storage\_account\_id](#input\_diagnostic\_storage\_account\_id) | Optional Storage Account resource ID for diagnostic archive. | `string` | `null` | no |
| <a name="input_diagnostic_timeouts"></a> [diagnostic\_timeouts](#input\_diagnostic\_timeouts) | Optional timeouts for diagnostic setting create, read, update, and delete operations. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_dns_proxy_enabled"></a> [dns\_proxy\_enabled](#input\_dns\_proxy\_enabled) | Whether DNS proxy is enabled. Recommended when network rules use FQDNs. | `bool` | `true` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | Optional custom DNS servers for Azure Firewall or the attached policy. | `list(string)` | `[]` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Whether to create diagnostic settings on the Azure Firewall. Diagnostics are also enabled when at least one diagnostic destination is supplied. | `bool` | `false` | no |
| <a name="input_explicit_proxy"></a> [explicit\_proxy](#input\_explicit\_proxy) | Optional Firewall Policy explicit proxy configuration. | <pre>object({<br>    enabled         = optional(bool)<br>    http_port       = optional(number)<br>    https_port      = optional(number)<br>    enable_pac_file = optional(bool)<br>    pac_file_port   = optional(number)<br>    pac_file        = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_firewall_policy_id"></a> [firewall\_policy\_id](#input\_firewall\_policy\_id) | Existing Firewall Policy ID to attach when create\_firewall\_policy is false. | `string` | `""` | no |
| <a name="input_firewall_policy_identity_ids"></a> [firewall\_policy\_identity\_ids](#input\_firewall\_policy\_identity\_ids) | User-assigned managed identity IDs to attach to the Firewall Policy. | `list(string)` | `[]` | no |
| <a name="input_firewall_policy_name"></a> [firewall\_policy\_name](#input\_firewall\_policy\_name) | Firewall Policy name. Leave empty to derive from the firewall name. | `string` | `""` | no |
| <a name="input_firewall_policy_sku"></a> [firewall\_policy\_sku](#input\_firewall\_policy\_sku) | Firewall Policy SKU tier. Leave empty to inherit sku\_tier. | `string` | `""` | no |
| <a name="input_firewall_policy_timeouts"></a> [firewall\_policy\_timeouts](#input\_firewall\_policy\_timeouts) | Optional timeouts for Firewall Policy create, read, update, and delete operations. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_include_environment_in_name"></a> [include\_environment\_in\_name](#input\_include\_environment\_in\_name) | Whether generated Azure Firewall names include app\_env. | `bool` | `true` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into module resources. The module only reads the resource group when this is true or location is empty. | `bool` | `false` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Optional instance segment used when generated names do not use a random suffix. | `string` | `"001"` | no |
| <a name="input_intrusion_detection"></a> [intrusion\_detection](#input\_intrusion\_detection) | Optional Premium Firewall Policy IDPS configuration. | <pre>object({<br>    mode           = optional(string, "Alert")<br>    private_ranges = optional(list(string))<br>    signature_overrides = optional(list(object({<br>      id    = optional(string)<br>      state = optional(string)<br>    })), [])<br>    traffic_bypass = optional(list(object({<br>      name                  = string<br>      protocol              = string<br>      description           = optional(string)<br>      source_addresses      = optional(set(string))<br>      source_ip_groups      = optional(set(string))<br>      destination_addresses = optional(set(string))<br>      destination_ip_groups = optional(set(string))<br>      destination_ports     = optional(set(string))<br>    })), [])<br>  })</pre> | `null` | no |
| <a name="input_ip_configuration_name"></a> [ip\_configuration\_name](#input\_ip\_configuration\_name) | Name for the primary Azure Firewall IP configuration. | `string` | `"ipconfig"` | no |
| <a name="input_location"></a> [location](#input\_location) | Optional Azure region for the firewall. Leave empty to use the target resource group's location. | `string` | `""` | no |
| <a name="input_location_code"></a> [location\_code](#input\_location\_code) | Optional short location code used when the Azure Firewall name is generated. | `string` | `""` | no |
| <a name="input_log_analytics_destination_type"></a> [log\_analytics\_destination\_type](#input\_log\_analytics\_destination\_type) | Destination type for Log Analytics diagnostics. | `string` | `"Dedicated"` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Optional Log Analytics workspace ID used for diagnostics. | `string` | `""` | no |
| <a name="input_management_ip_configuration_name"></a> [management\_ip\_configuration\_name](#input\_management\_ip\_configuration\_name) | Name for the Azure Firewall management IP configuration. | `string` | `"mgmt-ipconfig"` | no |
| <a name="input_management_public_ip_domain_name_label"></a> [management\_public\_ip\_domain\_name\_label](#input\_management\_public\_ip\_domain\_name\_label) | Optional DNS label for the created management public IP. | `string` | `""` | no |
| <a name="input_management_public_ip_id"></a> [management\_public\_ip\_id](#input\_management\_public\_ip\_id) | Existing Standard public IP ID for the management IP configuration. When empty and management\_subnet\_id is set, the module creates one. | `string` | `""` | no |
| <a name="input_management_public_ip_name"></a> [management\_public\_ip\_name](#input\_management\_public\_ip\_name) | Name for the created management public IP. | `string` | `""` | no |
| <a name="input_management_public_ip_prefix_id"></a> [management\_public\_ip\_prefix\_id](#input\_management\_public\_ip\_prefix\_id) | Optional public IP prefix ID used by the created management public IP. | `string` | `""` | no |
| <a name="input_management_subnet_id"></a> [management\_subnet\_id](#input\_management\_subnet\_id) | AzureFirewallManagementSubnet ID for forced tunneling scenarios. | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Azure Firewall name. Leave empty to auto-generate a standardized name. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used when the Azure Firewall name is generated. | `string` | `"afw"` | no |
| <a name="input_nat_rule_collections"></a> [nat\_rule\_collections](#input\_nat\_rule\_collections) | Backward-compatible NAT rule collections placed into the default rule collection group. | <pre>map(object({<br>    name     = optional(string)<br>    priority = number<br>    action   = string<br>    rules = map(object({<br>      name                = optional(string)<br>      description         = optional(string)<br>      source_addresses    = optional(list(string), [])<br>      source_ip_groups    = optional(list(string), [])<br>      destination_address = optional(string)<br>      destination_ports   = optional(list(string), [])<br>      translated_address  = optional(string)<br>      translated_fqdn     = optional(string)<br>      translated_port     = string<br>      protocols           = list(string)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_network_rule_collections"></a> [network\_rule\_collections](#input\_network\_rule\_collections) | Backward-compatible network rule collections placed into the default rule collection group. | <pre>map(object({<br>    name     = optional(string)<br>    priority = number<br>    action   = string<br>    rules = map(object({<br>      name                  = optional(string)<br>      description           = optional(string)<br>      source_addresses      = optional(list(string), [])<br>      source_ip_groups      = optional(list(string), [])<br>      destination_addresses = optional(list(string), [])<br>      destination_ip_groups = optional(list(string), [])<br>      destination_fqdns     = optional(list(string), [])<br>      destination_ports     = list(string)<br>      protocols             = list(string)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_policy_insights"></a> [policy\_insights](#input\_policy\_insights) | Optional Firewall Policy insights configuration. | <pre>object({<br>    enabled                            = bool<br>    default_log_analytics_workspace_id = string<br>    retention_in_days                  = optional(number)<br>    log_analytics_workspaces = optional(list(object({<br>      id                = string<br>      firewall_location = string<br>    })), [])<br>  })</pre> | `null` | no |
| <a name="input_private_ip_ranges"></a> [private\_ip\_ranges](#input\_private\_ip\_ranges) | Private CIDR ranges that Azure Firewall should not SNAT. Leave empty to use Azure Firewall defaults. | `list(string)` | `[]` | no |
| <a name="input_public_ip_count"></a> [public\_ip\_count](#input\_public\_ip\_count) | Number of Standard public IP addresses to create when create\_public\_ip is true. | `number` | `1` | no |
| <a name="input_public_ip_domain_name_label_scope"></a> [public\_ip\_domain\_name\_label\_scope](#input\_public\_ip\_domain\_name\_label\_scope) | Optional domain name label scope for created public IPs. | `string` | `null` | no |
| <a name="input_public_ip_domain_name_labels"></a> [public\_ip\_domain\_name\_labels](#input\_public\_ip\_domain\_name\_labels) | Optional DNS labels for created firewall public IPs by zero-based index. | `list(string)` | `[]` | no |
| <a name="input_public_ip_idle_timeout_in_minutes"></a> [public\_ip\_idle\_timeout\_in\_minutes](#input\_public\_ip\_idle\_timeout\_in\_minutes) | TCP idle timeout in minutes for created public IPs. | `number` | `4` | no |
| <a name="input_public_ip_ids"></a> [public\_ip\_ids](#input\_public\_ip\_ids) | Existing Standard public IP resource IDs to attach to VNet-deployed firewalls. | `list(string)` | `[]` | no |
| <a name="input_public_ip_name"></a> [public\_ip\_name](#input\_public\_ip\_name) | Name for the first created public IP. Leave empty to derive from the firewall name. | `string` | `""` | no |
| <a name="input_public_ip_prefix_id"></a> [public\_ip\_prefix\_id](#input\_public\_ip\_prefix\_id) | Optional public IP prefix ID used by created public IPs. | `string` | `""` | no |
| <a name="input_public_ip_reverse_fqdn"></a> [public\_ip\_reverse\_fqdn](#input\_public\_ip\_reverse\_fqdn) | Optional reverse FQDN for created firewall public IPs. | `string` | `""` | no |
| <a name="input_public_ip_sku_tier"></a> [public\_ip\_sku\_tier](#input\_public\_ip\_sku\_tier) | Public IP SKU tier. | `string` | `"Regional"` | no |
| <a name="input_public_ip_tags"></a> [public\_ip\_tags](#input\_public\_ip\_tags) | Optional IP tags for created public IPs. | `map(string)` | `{}` | no |
| <a name="input_public_ip_timeouts"></a> [public\_ip\_timeouts](#input\_public\_ip\_timeouts) | Optional timeouts for created Public IP create, read, update, and delete operations. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_public_ip_version"></a> [public\_ip\_version](#input\_public\_ip\_version) | Public IP address version. | `string` | `"IPv4"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group where the Azure Firewall and related resources will be created. | `string` | n/a | yes |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | Additional role assignments to create at the Azure Firewall scope, keyed by stable name. | <pre>map(object({<br>    principal_id                           = string<br>    role_definition_name                   = optional(string)<br>    role_definition_id                     = optional(string)<br>    principal_type                         = optional(string)<br>    description                            = optional(string)<br>    name                                   = optional(string)<br>    condition                              = optional(string)<br>    condition_version                      = optional(string)<br>    delegated_managed_identity_resource_id = optional(string)<br>    skip_service_principal_aad_check       = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_rule_collection_group_priority"></a> [rule\_collection\_group\_priority](#input\_rule\_collection\_group\_priority) | Priority for the backward-compatible default rule collection group. | `number` | `100` | no |
| <a name="input_rule_collection_groups"></a> [rule\_collection\_groups](#input\_rule\_collection\_groups) | Additional Firewall Policy rule collection groups keyed by stable name. | <pre>map(object({<br>    name     = optional(string)<br>    priority = number<br>    application_rule_collections = optional(map(object({<br>      name     = optional(string)<br>      priority = number<br>      action   = string<br>      rules = map(object({<br>        name                  = optional(string)<br>        description           = optional(string)<br>        source_addresses      = optional(list(string), [])<br>        source_ip_groups      = optional(list(string), [])<br>        destination_addresses = optional(list(string), [])<br>        destination_fqdns     = optional(list(string), [])<br>        destination_urls      = optional(list(string), [])<br>        destination_fqdn_tags = optional(list(string), [])<br>        terminate_tls         = optional(bool)<br>        web_categories        = optional(list(string), [])<br>        protocols = list(object({<br>          type = string<br>          port = number<br>        }))<br>        http_headers = optional(list(object({<br>          name  = string<br>          value = string<br>        })), [])<br>      }))<br>    })), {})<br>    network_rule_collections = optional(map(object({<br>      name     = optional(string)<br>      priority = number<br>      action   = string<br>      rules = map(object({<br>        name                  = optional(string)<br>        description           = optional(string)<br>        source_addresses      = optional(list(string), [])<br>        source_ip_groups      = optional(list(string), [])<br>        destination_addresses = optional(list(string), [])<br>        destination_ip_groups = optional(list(string), [])<br>        destination_fqdns     = optional(list(string), [])<br>        destination_ports     = list(string)<br>        protocols             = list(string)<br>      }))<br>    })), {})<br>    nat_rule_collections = optional(map(object({<br>      name     = optional(string)<br>      priority = number<br>      action   = string<br>      rules = map(object({<br>        name                = optional(string)<br>        description         = optional(string)<br>        source_addresses    = optional(list(string), [])<br>        source_ip_groups    = optional(list(string), [])<br>        destination_address = optional(string)<br>        destination_ports   = optional(list(string), [])<br>        translated_address  = optional(string)<br>        translated_fqdn     = optional(string)<br>        translated_port     = string<br>        protocols           = list(string)<br>      }))<br>    })), {})<br>    timeouts = optional(object({<br>      create = optional(string)<br>      read   = optional(string)<br>      update = optional(string)<br>      delete = optional(string)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | Azure Firewall deployment mode. | `string` | `"AZFW_VNet"` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | Azure Firewall SKU tier. | `string` | `"Standard"` | no |
| <a name="input_sql_redirect_allowed"></a> [sql\_redirect\_allowed](#input\_sql\_redirect\_allowed) | Whether SQL redirect traffic filtering is allowed in the Firewall Policy. | `bool` | `false` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | AzureFirewallSubnet ID for VNet-deployed Azure Firewall. Required when sku\_name is AZFW\_VNet. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to firewall resources. | `map(string)` | `{}` | no |
| <a name="input_threat_intelligence_allowlist_fqdns"></a> [threat\_intelligence\_allowlist\_fqdns](#input\_threat\_intelligence\_allowlist\_fqdns) | FQDNs excluded from threat intelligence filtering. | `set(string)` | `[]` | no |
| <a name="input_threat_intelligence_allowlist_ip_addresses"></a> [threat\_intelligence\_allowlist\_ip\_addresses](#input\_threat\_intelligence\_allowlist\_ip\_addresses) | IP addresses or CIDRs excluded from threat intelligence filtering. | `set(string)` | `[]` | no |
| <a name="input_threat_intelligence_mode"></a> [threat\_intelligence\_mode](#input\_threat\_intelligence\_mode) | Threat intelligence mode for the Firewall Policy or firewall. | `string` | `"Deny"` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional timeouts for Azure Firewall create, read, update, and delete operations. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_tls_certificate"></a> [tls\_certificate](#input\_tls\_certificate) | Optional Premium TLS inspection certificate configuration. | <pre>object({<br>    name                = string<br>    key_vault_secret_id = string<br>  })</pre> | `null` | no |
| <a name="input_use_random_suffix"></a> [use\_random\_suffix](#input\_use\_random\_suffix) | Whether generated Azure Firewall names should include a random suffix. | `bool` | `true` | no |
| <a name="input_virtual_hub_id"></a> [virtual\_hub\_id](#input\_virtual\_hub\_id) | Virtual Hub ID for Virtual WAN hub-deployed firewalls. Required when sku\_name is AZFW\_Hub. | `string` | `""` | no |
| <a name="input_virtual_hub_public_ip_count"></a> [virtual\_hub\_public\_ip\_count](#input\_virtual\_hub\_public\_ip\_count) | Number of public IPs assigned by Azure for a Virtual Hub firewall. | `number` | `1` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Optional workload segment used when the Azure Firewall name is generated. | `string` | `""` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Optional availability zones. For production regions that support zones, prefer multiple zones such as ["1", "2", "3"]. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_admin_group_principal_ids"></a> [app\_admin\_group\_principal\_ids](#output\_app\_admin\_group\_principal\_ids) | Map of resolved app admin group principal IDs. |
| <a name="output_app_admin_group_role_assignment_ids"></a> [app\_admin\_group\_role\_assignment\_ids](#output\_app\_admin\_group\_role\_assignment\_ids) | Contributor role assignment IDs keyed by principal ID. |
| <a name="output_app_env"></a> [app\_env](#output\_app\_env) | Deployment environment used for tags and generated names. |
| <a name="output_app_user_group_principal_ids"></a> [app\_user\_group\_principal\_ids](#output\_app\_user\_group\_principal\_ids) | Map of resolved app user group principal IDs. |
| <a name="output_app_user_group_role_assignment_ids"></a> [app\_user\_group\_role\_assignment\_ids](#output\_app\_user\_group\_role\_assignment\_ids) | Reader role assignment IDs keyed by principal ID. |
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | Diagnostic setting ID when diagnostics are enabled. |
| <a name="output_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#output\_diagnostic\_setting\_name) | Diagnostic setting name when diagnostics are enabled. |
| <a name="output_diagnostics_enabled"></a> [diagnostics\_enabled](#output\_diagnostics\_enabled) | Boolean flag indicating whether diagnostics are enabled. |
| <a name="output_firewall_policy_id"></a> [firewall\_policy\_id](#output\_firewall\_policy\_id) | Firewall Policy ID attached to the firewall. |
| <a name="output_firewall_policy_name"></a> [firewall\_policy\_name](#output\_firewall\_policy\_name) | Firewall Policy name when created by the module. |
| <a name="output_firewall_policy_sku"></a> [firewall\_policy\_sku](#output\_firewall\_policy\_sku) | Effective Firewall Policy SKU. |
| <a name="output_id"></a> [id](#output\_id) | Azure Firewall ID. |
| <a name="output_location"></a> [location](#output\_location) | Azure region where the Azure Firewall is deployed. |
| <a name="output_location_code"></a> [location\_code](#output\_location\_code) | The short location code used by generated names. |
| <a name="output_management_ip_configuration_enabled"></a> [management\_ip\_configuration\_enabled](#output\_management\_ip\_configuration\_enabled) | Whether a management IP configuration is planned for forced tunneling. |
| <a name="output_management_private_ip_address"></a> [management\_private\_ip\_address](#output\_management\_private\_ip\_address) | Azure Firewall management private IP address when forced tunneling is configured. |
| <a name="output_management_public_ip_address"></a> [management\_public\_ip\_address](#output\_management\_public\_ip\_address) | Created management public IP address when the module creates it. |
| <a name="output_management_public_ip_id"></a> [management\_public\_ip\_id](#output\_management\_public\_ip\_id) | Management public IP ID when forced tunneling is configured. |
| <a name="output_merged_tags"></a> [merged\_tags](#output\_merged\_tags) | Final merged tags applied to firewall resources. |
| <a name="output_name"></a> [name](#output\_name) | Azure Firewall name. |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Primary Azure Firewall private IP address. |
| <a name="output_public_ip_addresses"></a> [public\_ip\_addresses](#output\_public\_ip\_addresses) | Created firewall public IP addresses keyed by public IP index. |
| <a name="output_public_ip_count"></a> [public\_ip\_count](#output\_public\_ip\_count) | Number of firewall public IP IDs planned or supplied. |
| <a name="output_public_ip_id"></a> [public\_ip\_id](#output\_public\_ip\_id) | First created or supplied firewall public IP ID. |
| <a name="output_public_ip_ids"></a> [public\_ip\_ids](#output\_public\_ip\_ids) | Firewall public IP IDs attached to VNet-deployed firewalls. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group where the Azure Firewall is deployed. |
| <a name="output_role_assignment_count"></a> [role\_assignment\_count](#output\_role\_assignment\_count) | Total number of role assignments created by this module. |
| <a name="output_role_assignment_ids"></a> [role\_assignment\_ids](#output\_role\_assignment\_ids) | Map of additional role assignment IDs keyed by assignment name. |
| <a name="output_rule_collection_group_count"></a> [rule\_collection\_group\_count](#output\_rule\_collection\_group\_count) | Number of Firewall Policy rule collection groups planned by this module. |
| <a name="output_rule_collection_group_id"></a> [rule\_collection\_group\_id](#output\_rule\_collection\_group\_id) | First Firewall Policy rule collection group ID when created. |
| <a name="output_rule_collection_group_ids"></a> [rule\_collection\_group\_ids](#output\_rule\_collection\_group\_ids) | Firewall Policy rule collection group IDs keyed by group key. |
| <a name="output_sku_name"></a> [sku\_name](#output\_sku\_name) | Azure Firewall SKU name. |
| <a name="output_sku_tier"></a> [sku\_tier](#output\_sku\_tier) | Azure Firewall SKU tier. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to the Azure Firewall. |
<!-- END_TF_DOCS -->
