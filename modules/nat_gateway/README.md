# Azure NAT Gateway

Provides explicit outbound internet connectivity for one or more existing subnets by associating them with a NAT Gateway and one or more public IPs. Supports Standard and zone-redundant StandardV2 SKUs, multiple subnet associations in one VNet, and tag inheritance.

## Features

- Supports Standard or StandardV2 NAT Gateway SKUs and the matching public IP SKU.
- Creates one or more static IPv4 public IP addresses or attaches caller-owned public IP IDs.
- Associates the gateway with one or more existing subnets in the same VNet.
- Supports Standard SKU zone selection and configurable outbound idle timeout.
- Uses generated names, resource-group tag inheritance, and caller tag overrides.

## Resources Created

The module always creates one `azurerm_nat_gateway`, one subnet association per `subnet_ids` value, and one public IP association per configured public IP. It creates `public_ip_count` public IP resources when `public_ip_address_ids` is empty. When existing IDs are supplied, public IP resources remain caller-owned.

The module does not create virtual networks, subnets, public IP prefixes, or network security rules.

## Prerequisites and Dependencies

- Existing resource group and Azure region
- One or more existing subnets in the same virtual network
- Existing public IPs, if using `public_ip_address_ids`; their SKU must match `sku_name`
- IPv4 subnet workloads using Standard-compatible networking; Basic SKU resources are not supported with NAT Gateway
- NSG and user-defined routes that permit the intended outbound path

## Provider Configuration

The caller supplies the default `azurerm` provider. The execution identity needs permission to create the NAT Gateway and public IP resources and to associate the gateway with each subnet.

## Basic Usage

```hcl
module "nat_gateway" {
  source = "./modules/nat_gateway"

  name                = "nat-platform-cc-dev-001"
  resource_group_name = "rg-network-dev"
  location            = "canadacentral"
  subnet_ids          = [module.subnet.ids["application"]]

  sku_name = "Standard"
  tags     = { Owner = "CCOE" }
}
```

By default, the module creates one Standard static public IP. See [examples/basic](./examples/basic) and [examples/complete](./examples/complete).

## Important Behavior and Secure Defaults

NAT Gateway provides outbound source NAT for subnet workloads and allows response traffic for outbound connections. It does not provide unsolicited inbound connectivity or inbound load balancing. It becomes the default next hop for internet-bound traffic from associated subnets; user-defined routes or other network controls can affect that path.

NAT Gateway and its public IP resources have ongoing charges. More IPs add SNAT capacity. Monitor SNAT connection metrics and size the address count for peak outbound connection demand. Azure supports at most 16 public IP addresses per gateway; this module does not manage public IP prefixes.

The public IP addresses created by this module use Static allocation, IPv4, and the SKU matching the gateway. For StandardV2, Azure requires StandardV2 public IPs and the gateway is zone-redundant by default. The `zones` input must be empty for StandardV2. For Standard, `zones` may be omitted or contain one zone; zone configuration cannot be changed in place.

## Networking

Every associated subnet must belong to the same virtual network. The module validates the resource ID format but does not query subnet ownership. It also does not verify the SKU of caller-owned public IPs, whether another resource already owns a subnet association, or whether effective routes and NSG rules allow internet egress.

NAT Gateway is one part of outbound network design. Do not associate the same subnet with another NAT Gateway, and avoid managing its NAT association from multiple Terraform states. Review any existing Azure Firewall, load balancer, instance-level public IP, or route-table behavior before applying.

## Identity and RBAC

The module creates no managed identities or role assignments. Grant the Terraform execution identity least-privilege network resource write and subnet join permissions.

## Naming and Tagging

Set `name` explicitly or allow `nat-<workload>-<location-code>-<environment>-<instance>` generation. Created public IPs default to `pip-<gateway-name>-001`, with incrementing suffixes for multiple addresses. Caller tags override inherited resource-group tags. See the repository [naming convention](../../docs/60-security-governance/naming-convention.md) and [tagging standard](../../docs/60-security-governance/tagging-standard.md).

## Architecture

See [Architecture](docs/architecture.md) for the outbound flow and the subnet, public IP, and NAT gateway relationships.

## Testing

```powershell
terraform init -backend=false
terraform test -filter=tests/unit.tftest.hcl
```

The unit suite mocks AzureRM and uses plan-only assertions. It requires no Azure authentication and creates no resources.

## Known Limitations

- This module supports IPv4 public IP addresses only; IPv6 public IPs and NAT64 are not configured.
- It does not create or attach public IP prefixes.
- Caller-owned public IP IDs are checked for resource ID shape but not SKU, region, allocation method, or existing associations.
- StandardV2 is available only in supported Azure regions; confirm regional availability and quota before deployment.
- The module cannot verify that all supplied subnets belong to the same VNet, that their routes permit egress, or that the subnet association is not owned by another state.
- Adding a NAT Gateway changes outbound egress for every associated subnet and can disrupt workloads that rely on another outbound path.

## Terraform Reference

The content below is generated by `terraform-docs`. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, < 5.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) | resource |
| [azurerm_nat_gateway_public_ip_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_association) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_subnet_nat_gateway_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used when name is not provided. | `string` | `"dev"` | no |
| <a name="input_idle_timeout_in_minutes"></a> [idle\_timeout\_in\_minutes](#input\_idle\_timeout\_in\_minutes) | Outbound flow idle timeout in minutes. | `number` | `4` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into the NAT Gateway and module-created public IPs. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and tag inheritance is enabled, the module reads the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance identifier used when name is not provided. | `string` | `"001"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the NAT Gateway and any module-created public IPs. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Optional NAT Gateway name override. Leave empty to generate one from the naming convention. | `string` | `""` | no |
| <a name="input_public_ip_address_ids"></a> [public\_ip\_address\_ids](#input\_public\_ip\_address\_ids) | Optional existing public IP resource IDs. If empty, the module creates public\_ip\_count addresses using the selected NAT Gateway SKU. | `list(string)` | `[]` | no |
| <a name="input_public_ip_count"></a> [public\_ip\_count](#input\_public\_ip\_count) | Number of Standard or StandardV2 static public IP addresses created when public\_ip\_address\_ids is empty. | `number` | `1` | no |
| <a name="input_public_ip_name_prefix"></a> [public\_ip\_name\_prefix](#input\_public\_ip\_name\_prefix) | Optional prefix for module-created public IP names. A numeric suffix is appended to each name. | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group where the NAT Gateway and any module-created public IPs will be created. | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | NAT Gateway SKU. Standard is zonal or no-zone; StandardV2 is zone-redundant and requires StandardV2 public IPs. | `string` | `"Standard"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | One or more existing subnet IDs to associate with the NAT Gateway. All subnets must be in the same virtual network. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the NAT Gateway and any module-created public IPs. | `map(string)` | `{}` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier used when name is not provided. | `string` | `"project"` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Optional single availability zone for a Standard NAT Gateway. Must be empty for StandardV2. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | NAT Gateway resource ID. |
| <a name="output_managed_public_ip_addresses"></a> [managed\_public\_ip\_addresses](#output\_managed\_public\_ip\_addresses) | Allocated IP addresses for public IPs created by this module. Empty when caller-owned public IP IDs are used. |
| <a name="output_name"></a> [name](#output\_name) | NAT Gateway name. |
| <a name="output_public_ip_address_ids"></a> [public\_ip\_address\_ids](#output\_public\_ip\_address\_ids) | Public IP resource IDs associated with the NAT Gateway. |
| <a name="output_public_ip_association_ids"></a> [public\_ip\_association\_ids](#output\_public\_ip\_association\_ids) | NAT Gateway public IP association IDs keyed by the stable association key. |
| <a name="output_resource_guid"></a> [resource\_guid](#output\_resource\_guid) | NAT Gateway resource GUID. |
| <a name="output_sku_name"></a> [sku\_name](#output\_sku\_name) | NAT Gateway SKU. |
| <a name="output_subnet_association_ids"></a> [subnet\_association\_ids](#output\_subnet\_association\_ids) | Subnet association IDs keyed by subnet resource ID. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to the NAT Gateway and module-created public IPs. |
<!-- END_TF_DOCS -->
