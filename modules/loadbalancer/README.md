# Azure Load Balancer

Provisions a public or internal Azure Load Balancer with frontend configurations, backend pools, health probes, load-balancing rules, outbound rules, validation, and normalized tags.

## Features

- Supports public and private frontend IP configurations.
- Supports Standard, Basic, and Gateway SKUs plus regional or global tiers where Azure permits them.
- Creates named backend pools, TCP/HTTP/HTTPS probes, load-balancing rules, and outbound rules.
- Validates cross-references between rules, probes, pools, and frontends at plan time.
- Supports floating IP, session persistence, TCP reset, idle timeouts, and outbound port allocation.
- Inherits resource-group tags and lets caller tags take precedence.

## Resources Created

- One Azure Load Balancer.
- Zero or more backend address pools.
- Zero or more health probes.
- Zero or more load-balancing rules.
- Zero or more outbound rules.

The resource group, public IPs, frontend subnets, and backend NIC or IP configuration associations are existing or caller-managed dependencies.

## Prerequisites and Dependencies

- Terraform 1.6 or newer.
- Existing resource group.
- Existing public IP for each public frontend or subnet for each private frontend.
- Caller-managed backend membership, such as NIC-to-pool associations.
- Network security rules that allow probe and application traffic.

## Provider Configuration

Configure AzureRM in the calling root module:

```hcl
provider "azurerm" {
  features {}
}
```

## Basic Usage

```hcl
module "load_balancer" {
  source = "./modules/loadbalancer"

  name                = "lb-orders-prod"
  resource_group_name = "rg-orders-prod"
  location            = "canadacentral"

  frontend_ip_configurations = [{
    name                          = "internal"
    subnet_id                     = module.vnet.subnet_ids["snet-application"]
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.20.1.10"
  }]

  backend_address_pools = [{
    name = "application"
  }]
}
```

Runnable configurations are available in:

- [`examples/basic`](examples/basic/)
- [`examples/complete`](examples/complete/)

## Important Behavior

- The module creates empty backend pools but does not attach NICs or backend addresses.
- Public IP resources are not created by this module.
- Rule, probe, pool, and frontend names must match exactly; validations reject unresolved references.
- For Standard Load Balancer, outbound access should be designed explicitly with outbound rules, NAT Gateway, or another approved egress path.
- `disable_outbound_snat` and outbound rules must be considered together to avoid ambiguous egress behavior.

## Networking

Health probes originate from Azure's platform probe service; allow them in NSGs and guest firewalls. A load-balancing rule does not automatically open backend NSGs or operating-system firewalls.

For internal frontends, choose Dynamic allocation or a valid available static address in the selected subnet. Public and private frontends can coexist when supported by the selected SKU and tier.

## Naming and Tagging

Set an explicit Azure-valid Load Balancer name. Caller tags override inherited resource-group tags.

Follow the repository [naming convention](../../docs/NAMING_CONVENTION.md) and [tagging standard](../../docs/TAGGING_STANDARD.md).

## Testing

`tests/unit.tftest.hcl` uses a mocked AzureRM provider with a plan-only run:

```powershell
terraform init -backend=false
terraform validate
terraform test
```

No Azure resources are deployed by these tests.

## Known Limitations

- Backend pool membership and inbound NAT rules are not managed.
- Public IPs, NAT Gateway, Network Security Groups, and route tables are not managed.
- Gateway Load Balancer and global-tier capabilities remain subject to Azure regional and SKU restrictions.

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
| [azurerm_lb.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb_backend_address_pool.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_outbound_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_outbound_rule) | resource |
| [azurerm_lb_probe.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment (dev, staging, prod, sbx, test, qa) | `string` | `"dev"` | no |
| <a name="input_backend_address_pools"></a> [backend\_address\_pools](#input\_backend\_address\_pools) | List of backend address pools to create. | <pre>list(object({<br>    name = string<br>  }))</pre> | `[]` | no |
| <a name="input_frontend_ip_configurations"></a> [frontend\_ip\_configurations](#input\_frontend\_ip\_configurations) | List of frontend IP configurations. | <pre>list(object({<br>    name                          = string<br>    public_ip_address_id          = optional(string)<br>    subnet_id                     = optional(string)<br>    private_ip_address            = optional(string)<br>    private_ip_address_allocation = optional(string, "Dynamic")<br>    zones                         = optional(list(string))<br>  }))</pre> | n/a | yes |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into Load Balancer resources. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance identifier used when name is not provided. | `string` | `"001"` | no |
| <a name="input_lb_rules"></a> [lb\_rules](#input\_lb\_rules) | List of load balancing rules. | <pre>list(object({<br>    name                           = string<br>    protocol                       = string<br>    frontend_port                  = number<br>    backend_port                   = number<br>    frontend_ip_configuration_name = string<br>    backend_address_pool_name      = optional(string)<br>    probe_name                     = optional(string)<br>    enable_floating_ip             = optional(bool, false)<br>    idle_timeout_in_minutes        = optional(number, 4)<br>    load_distribution              = optional(string, "Default")<br>    disable_outbound_snat          = optional(bool, false)<br>    enable_tcp_reset               = optional(bool, false)<br>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Optional Load Balancer name override. Leave empty to generate one from the naming convention. | `string` | `""` | no |
| <a name="input_outbound_rules"></a> [outbound\_rules](#input\_outbound\_rules) | Standard Load Balancer outbound rules. | <pre>list(object({<br>    name                           = string<br>    protocol                       = optional(string, "All")<br>    backend_address_pool_name      = string<br>    frontend_ip_configuration_name = string<br>    allocated_outbound_ports       = optional(number, 0)<br>    enable_tcp_reset               = optional(bool, true)<br>    idle_timeout_in_minutes        = optional(number, 4)<br>  }))</pre> | `[]` | no |
| <a name="input_probes"></a> [probes](#input\_probes) | List of health probes. | <pre>list(object({<br>    name                = string<br>    protocol            = string<br>    port                = number<br>    request_path        = optional(string)<br>    interval_in_seconds = optional(number, 15)<br>    number_of_probes    = optional(number, 2)<br>  }))</pre> | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group. | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU of the Azure Load Balancer. Accepted values are Basic, Standard and Gateway. | `string` | `"Standard"` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | The SKU tier of this Load Balancer. Possible values are Global and Regional. | `string` | `"Regional"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the resources. | `map(string)` | `{}` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Deprecated compatibility input. Supply workload tags explicitly through tags. | `string` | `"project"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_address_pool_ids"></a> [backend\_address\_pool\_ids](#output\_backend\_address\_pool\_ids) | Map of backend address pool IDs keyed by name. |
| <a name="output_frontend_ip_configurations"></a> [frontend\_ip\_configurations](#output\_frontend\_ip\_configurations) | A list of frontend IP configuration objects. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Load Balancer. |
| <a name="output_name"></a> [name](#output\_name) | The Name of the Load Balancer. |
| <a name="output_outbound_rule_ids"></a> [outbound\_rule\_ids](#output\_outbound\_rule\_ids) | Map of outbound rule IDs keyed by name. |
| <a name="output_probe_ids"></a> [probe\_ids](#output\_probe\_ids) | Map of probe IDs keyed by name. |
| <a name="output_rule_ids"></a> [rule\_ids](#output\_rule\_ids) | Map of rule IDs keyed by name. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to the Load Balancer. |
<!-- END_TF_DOCS -->
