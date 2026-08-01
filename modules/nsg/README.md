# Azure Network Security Group

Provisions an Azure Network Security Group with inline rules and optional ownership of subnet or network-interface associations.

## Features

- Creates an NSG with generated or explicit naming.
- Defines inbound and outbound rules through a keyed map.
- Supports singular or plural ports and address prefixes.
- Supports Application Security Group sources and destinations.
- Validates protocols, priorities, duplicate direction/priority pairs, and mutually exclusive rule fields.
- Associates the NSG with existing subnets and network interfaces by direct lists or stable keyed maps.
- Inherits resource-group tags and lets caller tags take precedence.

## Resources Created

- One Network Security Group.
- Zero or more subnet-to-NSG associations.
- Zero or more network-interface-to-NSG associations.

The resource group, VNet, subnets, network interfaces, Application Security Groups, flow logs, and diagnostics are existing or separately managed dependencies.

## Prerequisites and Dependencies

- Terraform 1.6 or newer.
- Existing resource group and Azure region.
- Existing subnet, NIC, or Application Security Group IDs for optional associations and rule references.
- A reviewed network flow matrix covering source, destination, port, protocol, direction, and justification.

## Provider Configuration

Configure AzureRM in the calling root module:

```hcl
provider "azurerm" {
  features {}
}
```

## Basic Usage

```hcl
module "application_nsg" {
  source = "./modules/nsg"

  name                = "nsg-orders-prod-001"
  resource_group_name = "rg-orders-prod"
  location            = "canadacentral"

  security_rules = {
    allow_https_from_gateway = {
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "10.20.0.0/24"
      destination_address_prefix = "*"
    }
  }
}
```

Runnable configurations are available in:

- [`examples/basic`](examples/basic/)
- [`examples/complete`](examples/complete/)
- [`examples/associations`](examples/associations/)

## Rule Design and Safety

- Rule priorities must be unique within each direction.
- Use narrow CIDRs, service tags, Application Security Groups, and destination ports.
- Avoid unrestricted management ports such as SSH or RDP.
- Azure's default NSG rules remain in effect after custom rules are added.
- NSGs are stateful packet filters, not application firewalls or TLS inspection devices.
- Inline rules and separate `azurerm_network_security_rule` resources must not manage the same NSG.

## Association Ownership

Each subnet or NIC can have only one active NSG association. Enable associations here only when this module owns that binding lifecycle. Do not also manage the same association in a VNet, NIC, VM, or another NSG module.

Use keyed association maps when IDs are unknown until apply; stable keys avoid `for_each` values derived from unknown IDs.

## Naming and Tagging

Set `name` explicitly or use workload, location, environment, and instance inputs. Caller tags override inherited resource-group tags.

Follow the repository [naming convention](../../docs/NAMING_CONVENTION.md) and [tagging standard](../../docs/TAGGING_STANDARD.md).

## Testing

`tests/unit.tftest.hcl` uses a mocked AzureRM provider with plan-only and expected-failure runs:

```powershell
terraform init -backend=false
terraform validate
terraform test
```

No Azure resources are deployed by these tests.

## Known Limitations

- Flow logs, Network Watcher integration, diagnostic settings, Application Security Groups, and route tables are not managed.
- The module does not analyze effective security rules across subnet and NIC NSGs.
- Plan-time validation cannot prove end-to-end reachability or detect every shadowed rule.

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
| [azurerm_network_interface_security_group_association.by_name](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_interface_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_subnet_network_security_group_association.by_name](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment metadata retained for interface compatibility. | `string` | `"dev"` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into NSG resources. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance identifier used when name is not provided. | `string` | `"001"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the NSG. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Optional Network Security Group name override. Leave empty to generate one from the naming convention. | `string` | `""` | no |
| <a name="input_network_interface_associations"></a> [network\_interface\_associations](#input\_network\_interface\_associations) | Network interface IDs to associate to the NSG, keyed by stable caller-defined names. Use this when NIC IDs are unknown until apply. | `map(string)` | `{}` | no |
| <a name="input_network_interface_ids"></a> [network\_interface\_ids](#input\_network\_interface\_ids) | Network interface IDs to associate to the NSG. | `list(string)` | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group where the NSG will be created. | `string` | n/a | yes |
| <a name="input_security_rules"></a> [security\_rules](#input\_security\_rules) | Map of NSG rules keyed by rule name. | <pre>map(object({<br>    priority                                   = number<br>    direction                                  = string<br>    access                                     = string<br>    protocol                                   = string<br>    source_port_range                          = optional(string)<br>    source_port_ranges                         = optional(list(string))<br>    destination_port_range                     = optional(string)<br>    destination_port_ranges                    = optional(list(string))<br>    source_address_prefix                      = optional(string)<br>    source_address_prefixes                    = optional(list(string))<br>    destination_address_prefix                 = optional(string)<br>    destination_address_prefixes               = optional(list(string))<br>    source_application_security_group_ids      = optional(list(string))<br>    destination_application_security_group_ids = optional(list(string))<br>    description                                = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_subnet_associations"></a> [subnet\_associations](#input\_subnet\_associations) | Subnet IDs to associate to the NSG, keyed by stable caller-defined names. Use this when subnet IDs are unknown until apply. | `map(string)` | `{}` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs to associate to the NSG. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the NSG. | `map(string)` | `{}` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier used in tagging. | `string` | `"project"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The resource ID of the NSG. |
| <a name="output_merged_tags"></a> [merged\_tags](#output\_merged\_tags) | Final merged tags applied to the NSG. |
| <a name="output_name"></a> [name](#output\_name) | The NSG name. |
| <a name="output_network_interface_association_ids"></a> [network\_interface\_association\_ids](#output\_network\_interface\_association\_ids) | NIC association resource IDs keyed by NIC ID. |
| <a name="output_security_rule_names"></a> [security\_rule\_names](#output\_security\_rule\_names) | Security rule names configured in the NSG. |
| <a name="output_subnet_association_ids"></a> [subnet\_association\_ids](#output\_subnet\_association\_ids) | Subnet association resource IDs keyed by subnet ID. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to the NSG. |
<!-- END_TF_DOCS -->
