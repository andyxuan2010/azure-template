# Azure Bastion

Provisions a public Azure Bastion host and its network boundary in an existing VNet. The module requires a dedicated `AzureBastionSubnet`, supports Basic, Standard, and Premium SKUs, and can create or attach a Standard static public IP.

## Features

- Supports Basic, Standard, and Premium public Bastion deployments.
- Creates a Standard static public IP by default or accepts a caller-owned public IP.
- Exposes optional Standard and Premium features with SKU compatibility checks.
- Supports availability zones, deterministic naming, and resource-group tag inheritance.

## Resources Created

The module always creates one `azurerm_bastion_host`. It creates one `azurerm_public_ip` unless `public_ip_address_id` points to an existing address. The module does not create the VNet or Bastion subnet.

## Prerequisites and Dependencies

- Existing resource group in the target region
- Existing VNet and resource group with a dedicated subnet named exactly `AzureBastionSubnet`; the subnet and Bastion host must be in the same resource group
- Bastion subnet prefix of `/26` or larger, with no unrelated resources
- Existing Standard static public IP when using `public_ip_address_id`
- Network and public IP permissions for the Terraform execution identity

Azure requires the subnet to be dedicated to Bastion. Do not place unrelated resources in this subnet. If you attach an NSG or route table, follow Azure's Bastion-specific network requirements for the selected SKU and features.

## Provider Configuration

The caller supplies the default `azurerm` provider. This module does not create role assignments or require the `azurerm.prod` alias.

## Basic Usage

```hcl
module "bastion" {
  source = "./modules/bastion"

  name                = "bas-platform-cc-dev-001"
  resource_group_name = "rg-network-dev"
  location            = "canadacentral"
  subnet_id           = module.subnet.ids["AzureBastionSubnet"]
  sku                 = "Basic"

  workload = "platform"
  app_env  = "dev"
  tags     = { Owner = "CCOE" }
}
```

Use `public_ip_address_id` to attach an existing Standard static public IP. See [examples/basic](./examples/basic).

## Important Behavior and Secure Defaults

The host is reachable through its public IP. Bastion provides a managed access path to private VM addresses; it does not require public IPs on the target VMs. Apply least-privilege access controls to Bastion and review the network path from the Bastion subnet to target subnets.

Bastion incurs ongoing hourly and data transfer charges. SKU, scale units, zones, and connection features affect cost. Review the deployment plan and expected usage before apply.

Feature constraints follow Azure: file copy, IP-based connections, Kerberos, shareable links, and tunneling require Standard or Premium; session recording requires Premium. Basic uses two scale units. `zones` applies to both the host and a public IP created by this module.

## Networking

This module consumes the subnet ID and does not manage subnet properties. The Azure resource provider validates subnet sizing and region compatibility during deployment. The subnet name is checked from the resource ID, but its address prefix and exclusivity must be reviewed in the VNet/subnet configuration.

The module supports public deployments only. It does not create Bastion Developer or private-only Premium deployments, or configure target VMs and user access. Standard and Premium IP-based connection support can be enabled with `ip_connect_enabled`.

## Identity and RBAC

The module creates no managed identities or role assignments. The Terraform execution identity needs permissions to create or update the Bastion host and public IP and to join the subnet.

## Naming and Tagging

Set `name` explicitly or allow `bas-<workload>-<location-code>-<environment>-<instance>` generation. The created public IP defaults to `pip-<bastion-name>`. Caller tags override inherited resource-group tags. See the repository [naming convention](../../docs/60-security-governance/naming-convention.md) and [tagging standard](../../docs/60-security-governance/tagging-standard.md).

## Architecture

See [Architecture](docs/architecture.md) for the connection flow and the subnet, public IP, and NSG relationships.

## Testing

```powershell
terraform init -backend=false
terraform test -filter=tests/unit.tftest.hcl
```

The unit suite mocks AzureRM and uses plan-only assertions. It requires no Azure authentication and creates no resources.

## Known Limitations

- Existing public IP IDs are syntactically validated, but their Standard SKU, static allocation, region, and exclusive use must be confirmed by the caller.
- Availability zones must be supported in the target region, and a caller-owned public IP must meet Azure's zone compatibility requirements.
- The module does not create or validate the subnet address prefix or NSG rules.
- Developer and private-only deployments have different network requirements and are outside this module.
- Bastion creation, SKU changes, and scaling can take several minutes and incur ongoing charges.

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
| [azurerm_bastion_host.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used when name is not provided. | `string` | `"dev"` | no |
| <a name="input_copy_paste_enabled"></a> [copy\_paste\_enabled](#input\_copy\_paste\_enabled) | Whether copy and paste is enabled for Bastion sessions. | `bool` | `true` | no |
| <a name="input_file_copy_enabled"></a> [file\_copy\_enabled](#input\_file\_copy\_enabled) | Whether file transfer is enabled. Azure supports this only for Standard or Premium SKU. | `bool` | `false` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into Bastion resources. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inheritance is enabled, the module reads the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance identifier used when name is not provided. | `string` | `"001"` | no |
| <a name="input_ip_connect_enabled"></a> [ip\_connect\_enabled](#input\_ip\_connect\_enabled) | Whether IP-based connections are enabled. Azure supports this only for Standard or Premium SKU. | `bool` | `false` | no |
| <a name="input_kerberos_enabled"></a> [kerberos\_enabled](#input\_kerberos\_enabled) | Whether Kerberos authentication is enabled. Azure supports this only for Standard or Premium SKU. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the Bastion host and any module-created public IP. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Optional Bastion host name override. Leave empty to generate one from the naming convention. | `string` | `""` | no |
| <a name="input_public_ip_address_id"></a> [public\_ip\_address\_id](#input\_public\_ip\_address\_id) | Optional existing Standard, static public IP resource ID. When empty, the module creates a Standard static public IP. | `string` | `""` | no |
| <a name="input_public_ip_name"></a> [public\_ip\_name](#input\_public\_ip\_name) | Optional name for the public IP created by this module. Ignored when public\_ip\_address\_id is supplied. | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group where the Bastion host and any module-created public IP will be created. | `string` | n/a | yes |
| <a name="input_scale_units"></a> [scale\_units](#input\_scale\_units) | Bastion scale units. Azure supports values from 2 to 50; Basic remains at 2. | `number` | `2` | no |
| <a name="input_session_recording_enabled"></a> [session\_recording\_enabled](#input\_session\_recording\_enabled) | Whether session recording is enabled. Azure supports this only for Premium SKU. | `bool` | `false` | no |
| <a name="input_shareable_link_enabled"></a> [shareable\_link\_enabled](#input\_shareable\_link\_enabled) | Whether shareable links are enabled. Azure supports this only for Standard or Premium SKU. | `bool` | `false` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | Public Azure Bastion SKU. Developer and private-only deployments are not supported by this module. | `string` | `"Basic"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Resource ID of the existing dedicated AzureBastionSubnet in the host virtual network. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the Bastion host and any module-created public IP. | `map(string)` | `{}` | no |
| <a name="input_tunneling_enabled"></a> [tunneling\_enabled](#input\_tunneling\_enabled) | Whether native client tunneling is enabled. Azure supports this only for Standard or Premium SKU. | `bool` | `false` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier used when name is not provided. | `string` | `"project"` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Optional availability zones for the Bastion host and module-created public IP. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | Fully qualified domain name for the Bastion host. |
| <a name="output_id"></a> [id](#output\_id) | Bastion host resource ID. |
| <a name="output_name"></a> [name](#output\_name) | Bastion host name. |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | Allocated address for the module-created public IP, or null when using a caller-owned public IP. |
| <a name="output_public_ip_address_id"></a> [public\_ip\_address\_id](#output\_public\_ip\_address\_id) | Public IP resource ID attached to the Bastion host. |
| <a name="output_sku"></a> [sku](#output\_sku) | Bastion host SKU. |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | Dedicated AzureBastionSubnet resource ID used by the host. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to the Bastion host and any module-created public IP. |
<!-- END_TF_DOCS -->
