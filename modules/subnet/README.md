# Azure Virtual Network Subnets

Creates and manages multiple subnets in an existing Azure Virtual Network, including delegations, service endpoints, network policy controls, optional NSG and route-table associations, and optional VNet-scoped RBAC.

## Features

- Creates a map of subnets with IPv4 or IPv6 address prefixes.
- Supports service endpoints, service endpoint policies, and service delegations.
- Controls private endpoint and private link service network policies.
- Associates existing network security groups and route tables.
- Grants Contributor or Reader on the parent VNet to selected Microsoft Entra groups.

## Resources Created

The module creates one subnet for every entry in `subnets`. NSG and route-table association resources are conditional per subnet. VNet-scoped role assignments are conditional.

The parent VNet is looked up only when `virtual_network_id` is empty. Microsoft Entra groups provided by display name are also looked up; neither dependency is managed.

See [architecture](docs/architecture.md) for composition and lifecycle guidance.

## Prerequisites and Dependencies

- An existing VNet and its resource group
- A non-overlapping address plan contained within the VNet address space
- Existing NSGs, route tables, and service endpoint policies referenced by ID
- Service-specific delegation requirements understood before subnet creation
- Microsoft Entra object IDs or unique group display names when RBAC is requested

## Provider Configuration

The caller must configure AzureRM 4.x and AzureAD 3.x. The execution identity needs subnet write access, join permissions for referenced NSGs and route tables, and role-assignment permissions when RBAC is requested.

## Basic Usage

```hcl
module "subnet" {
  source = "./modules/subnet"

  resource_group_name  = "rg-network-prod"
  virtual_network_name = "vnet-spoke-prod"
  virtual_network_id   = module.vnet.id

  subnets = {
    application = {
      address_prefixes = ["10.20.1.0/24"]
    }
  }
}
```

The complete executable configuration is in [`examples/basic`](examples/basic/).

## Important Behavior and Secure Defaults

- Subnet map keys become Azure subnet names. Renaming a key changes the Terraform address and replaces the subnet unless state is moved.
- NSG and route-table associations are created only when the corresponding `create_*_association` flag is true; supply the matching non-empty resource ID at the same time.
- Private endpoint network policies default to `Enabled`. Set the service-appropriate value explicitly for dedicated private endpoint subnets.
- Delegation, service endpoint, and policy changes can disrupt dependent services or be rejected while resources are attached.
- The module validates that CIDR host bits are aligned, but the caller remains responsible for overlap and VNet containment.

## Networking and Private Connectivity

Create separate subnets for workloads with conflicting delegations or policy requirements. Attach NSGs and route tables by ID so their lifecycles remain independent. Private endpoints require suitable network policy settings and separately managed private DNS.

## Identity and RBAC

`app_admin_group` receives Contributor and `app_user_group` receives Reader at the parent VNet scope, not individual subnet scope. Prefer immutable object IDs and grant these broad VNet roles only when required.

## Naming and Tagging

Subnet names are the `subnets` map keys. Azure subnets do not support ARM tags. Follow the repository [naming convention](../../docs/NAMING_CONVENTION.md); apply the [tagging standard](../../docs/TAGGING_STANDARD.md) to the parent VNet and associated resources.

## Examples

- [`basic`](examples/basic/): application and data subnets
- [`complete`](examples/complete/): private endpoint subnet plus NSG and route-table associations
- [`delegated-app-service`](examples/delegated-app-service/): subnet delegated to App Service

## Testing

`tests/unit.tftest.hcl` uses mocked AzureRM and AzureAD providers. Its three plan-only tests require no Azure authentication, create no resources, and incur no cost.

```powershell
terraform -chdir=modules/subnet init -backend=false
terraform -chdir=modules/subnet test
```

## Known Limitations

- The module does not create the parent VNet, NSGs, route tables, private endpoints, private DNS zones, or VNet peerings.
- It does not calculate address ranges or detect overlap with sibling subnets.
- Azure may prevent subnet replacement or mutation while delegated services, private endpoints, or other resources remain attached.
- Mocked tests cannot prove address availability, service delegation eligibility, join permissions, or Azure Policy behavior.

## Terraform Reference

The content below is generated from the module source. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 3.0, < 4.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >= 3.0, < 4.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, < 5.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_role_assignment.app_admin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_user_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_route_table_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | List of Entra group display names or object IDs that should receive Contributor access to the virtual network scope. Prefer object IDs when display names are not unique. | `list(string)` | `null` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment metadata retained for composition compatibility. | `string` | `"dev"` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | List of Entra group display names or object IDs that should receive Reader access to the virtual network scope. Prefer object IDs when display names are not unique. | `list(string)` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group containing the virtual network. | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Subnet definitions keyed by subnet name. | <pre>map(object({<br>    address_prefixes                              = list(string)<br>    service_endpoints                             = optional(list(string), [])<br>    service_endpoint_policy_ids                   = optional(list(string), [])<br>    private_endpoint_network_policies             = optional(string, "Enabled")<br>    private_link_service_network_policies_enabled = optional(bool, true)<br>    network_security_group_id                     = optional(string, "")<br>    create_network_security_group_association     = optional(bool, false)<br>    route_table_id                                = optional(string, "")<br>    create_route_table_association                = optional(bool, false)<br>    delegations = optional(map(object({<br>      name                    = string<br>      service_delegation_name = string<br>      actions                 = optional(list(string), [])<br>    })), {})<br>  }))</pre> | n/a | yes |
| <a name="input_virtual_network_id"></a> [virtual\_network\_id](#input\_virtual\_network\_id) | Optional virtual network resource ID used as the RBAC scope. When empty, the module looks up the virtual network by name and resource group. | `string` | `""` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the existing virtual network where subnets will be created. | `string` | n/a | yes |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload metadata retained for composition compatibility. | `string` | `"project"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address_prefixes"></a> [address\_prefixes](#output\_address\_prefixes) | Map of configured address prefixes keyed by subnet name. |
| <a name="output_app_admin_group_role_assignment_ids"></a> [app\_admin\_group\_role\_assignment\_ids](#output\_app\_admin\_group\_role\_assignment\_ids) | Map of Contributor role assignment IDs keyed by app\_admin\_group input. |
| <a name="output_app_user_group_role_assignment_ids"></a> [app\_user\_group\_role\_assignment\_ids](#output\_app\_user\_group\_role\_assignment\_ids) | Map of Reader role assignment IDs keyed by app\_user\_group input. |
| <a name="output_ids"></a> [ids](#output\_ids) | Map of subnet IDs keyed by subnet name. |
| <a name="output_names"></a> [names](#output\_names) | Map of subnet names keyed by subnet name. |
| <a name="output_network_security_group_association_ids"></a> [network\_security\_group\_association\_ids](#output\_network\_security\_group\_association\_ids) | Map of NSG association IDs keyed by subnet name. |
| <a name="output_route_table_association_ids"></a> [route\_table\_association\_ids](#output\_route\_table\_association\_ids) | Map of route table association IDs keyed by subnet name. |
<!-- END_TF_DOCS -->
