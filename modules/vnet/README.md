# Azure Virtual Network

Provisions an Azure Virtual Network with optional subnets, DDoS plan attachment, custom DNS, VNet-scoped Microsoft Entra RBAC, and Log Analytics diagnostics.

## Features

- Creates a VNet from explicit IPv4 or IPv6 address spaces.
- Supports custom DNS servers, BGP community, edge zones, flow timeout, and an existing DDoS protection plan.
- Creates optional subnets with service endpoints, policies, delegations, and private-link controls.
- Grants Contributor or Reader on the VNet to selected Microsoft Entra groups.
- Supports plan-known resource-group location/tags and optional diagnostics.

## Resources Created

The module always creates one VNet and creates a random naming suffix when `name` is empty. It creates one subnet per `subnets` entry. Role assignments and one diagnostic setting are conditional.

The resource group and Microsoft Entra groups may be read but are not managed. The DDoS plan and Log Analytics workspace are referenced by ID.

See [architecture](docs/architecture.md) for network composition and lifecycle boundaries.

## Prerequisites and Dependencies

- An existing resource group
- A reviewed, non-overlapping address plan
- Existing custom DNS resolvers, DDoS plan, and Log Analytics workspace when those features are selected
- Microsoft Entra object IDs or unique display names when VNet RBAC is requested
- Network and role-assignment permissions at the target scope

## Provider Configuration

The caller must configure AzureRM 4.x, AzureAD 3.x, and Random 3.x. The module declares provider requirements but no provider configuration blocks.

## Basic Usage

```hcl
module "vnet" {
  source = "./modules/vnet"

  resource_group_name = "rg-network-prod"
  location            = "canadacentral"
  name                = "vnet-spoke-prod"
  address_space       = ["10.20.0.0/16"]
}
```

The complete executable configuration is in [`examples/basic`](examples/basic/).

## Important Behavior and Secure Defaults

- No subnets, peerings, firewall, NSGs, routes, or public connectivity are created by default.
- Set both `location` and `inherited_resource_group_tags` to avoid a resource-group lookup when the resource group is created in the same root plan.
- Subnet map keys become subnet names. Renaming keys changes Terraform resource addresses and can replace subnets unless state is moved.
- Enabling diagnostics requires a Log Analytics workspace ID.
- Attaching or replacing a DDoS plan, changing address space, DNS, delegation, or subnet policy settings can affect dependent workloads.

## Networking and Private Connectivity

The module can create subnets but intentionally leaves NSG and route-table association to the separate `subnet`, `nsg`, and `route_table` compositions. Private endpoints and private DNS are separate modules. The caller owns address overlap checks, routing design, DNS forwarding, and peering.

## Identity and RBAC

`app_admin_group` receives Contributor and `app_user_group` receives Reader at VNet scope. Prefer immutable object IDs over display names and avoid broad network Contributor access where a narrower operational model is available.

## Naming and Tagging

Set an explicit VNet name for stable naming. Otherwise the generated name combines workload/application metadata, location, and a random suffix. Caller tags override inherited resource-group tags. Subnets cannot be tagged. See the repository [naming convention](../../docs/NAMING_CONVENTION.md) and [tagging standard](../../docs/TAGGING_STANDARD.md).

## Examples

- [`basic`](examples/basic/): one VNet without subnets
- [`complete`](examples/complete/): application/private-endpoint subnets, RBAC, custom DNS, and diagnostics
- [`delegated-subnet`](examples/delegated-subnet/): App Service delegated subnet

## Testing

`tests/unit.tftest.hcl` uses mocked AzureRM, AzureAD, and Random providers. Its two plan-only tests require no Azure authentication, create no resources, and incur no cost.

```powershell
terraform -chdir=modules/vnet init -backend=false
terraform -chdir=modules/vnet test
```

## Known Limitations

- The module does not create VNet peerings, gateways, Bastion, firewalls, private endpoints, private DNS, NSGs, route tables, or subnet associations.
- It validates CIDR syntax and host-bit alignment but does not detect overlap with other VNets or subnets.
- VNet diagnostics expose only the categories supported by the selected AzureRM/Azure API combination.
- Mocked tests cannot prove address availability, DNS reachability, DDoS entitlement, Entra lookup uniqueness, or Azure Policy behavior.

## Terraform Reference

The content below is generated from the module source. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 3.0, < 4.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >= 3.0, < 4.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, < 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0, < 4.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_role_assignment.app_admin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_user_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The address spaces applied to the virtual network. | `list(string)` | n/a | yes |
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | List of Entra group display names or object IDs that should receive Contributor access to the virtual network. Prefer object IDs when display names are not unique. | `list(string)` | `null` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used for the generated Environment tag. | `string` | `"dev"` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | List of Entra group display names or object IDs that should receive Reader access to the virtual network. Prefer object IDs when display names are not unique. | `list(string)` | `null` | no |
| <a name="input_bgp_community"></a> [bgp\_community](#input\_bgp\_community) | Optional BGP community value for the virtual network. | `string` | `null` | no |
| <a name="input_ddos_protection_plan_id"></a> [ddos\_protection\_plan\_id](#input\_ddos\_protection\_plan\_id) | Optional DDoS protection plan ID to associate with the virtual network. | `string` | `""` | no |
| <a name="input_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#input\_diagnostic\_log\_categories) | Diagnostic log categories to enable. | `list(string)` | `[]` | no |
| <a name="input_diagnostic_metric_categories"></a> [diagnostic\_metric\_categories](#input\_diagnostic\_metric\_categories) | Diagnostic metric categories to enable. | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | Optional custom DNS server IP addresses for the virtual network. | `list(string)` | `[]` | no |
| <a name="input_edge_zone"></a> [edge\_zone](#input\_edge\_zone) | Optional Edge Zone where the virtual network will be deployed. | `string` | `null` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Enable diagnostic settings for the virtual network. | `bool` | `false` | no |
| <a name="input_flow_timeout_in_minutes"></a> [flow\_timeout\_in\_minutes](#input\_flow\_timeout\_in\_minutes) | Optional flow timeout in minutes for the virtual network. | `number` | `null` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into virtual network resources. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where to deploy the resource. If empty, the resource group's location is used. | `string` | `""` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace resource ID for diagnostics. Required when enable\_diagnostics is true. | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Virtual network name. If empty, the module auto-generates a compliant name. | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the virtual network will be deployed. | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Optional subnet definitions keyed by subnet name. | <pre>map(object({<br>    address_prefixes                              = list(string)<br>    service_endpoints                             = optional(list(string), [])<br>    service_endpoint_policy_ids                   = optional(list(string), [])<br>    private_endpoint_network_policies             = optional(string, "Enabled")<br>    private_link_service_network_policies_enabled = optional(bool, true)<br>    delegations = optional(map(object({<br>      name                    = string<br>      service_delegation_name = string<br>      actions                 = optional(list(string), [])<br>    })), {})<br>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resources. | `map(string)` | `{}` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier used in tagging. | `string` | `"project"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address_space"></a> [address\_space](#output\_address\_space) | The address spaces configured on the virtual network. |
| <a name="output_app_admin_group_role_assignment_ids"></a> [app\_admin\_group\_role\_assignment\_ids](#output\_app\_admin\_group\_role\_assignment\_ids) | Map of Contributor role assignment IDs keyed by app\_admin\_group input. |
| <a name="output_app_user_group_role_assignment_ids"></a> [app\_user\_group\_role\_assignment\_ids](#output\_app\_user\_group\_role\_assignment\_ids) | Map of Reader role assignment IDs keyed by app\_user\_group input. |
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | The ID of the diagnostic setting, if created. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the virtual network. |
| <a name="output_location"></a> [location](#output\_location) | The location of the virtual network. |
| <a name="output_name"></a> [name](#output\_name) | The name of the virtual network. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group containing the virtual network. |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Map of subnet IDs keyed by subnet name. |
| <a name="output_subnet_names"></a> [subnet\_names](#output\_subnet\_names) | Map of subnet names keyed by subnet name. |
| <a name="output_tags"></a> [tags](#output\_tags) | The effective tags assigned to the virtual network. |
<!-- END_TF_DOCS -->
