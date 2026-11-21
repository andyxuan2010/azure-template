# Azure API Management

Creates an Azure API Management service in an existing resource group with a system-assigned identity, optional VNet integration, inherited tags, and legacy TLS protocols and ciphers disabled.

## Features

- Supports API Management tiers and caller-selected capacity.
- Supports External or Internal VNet integration with an existing subnet.
- Enables a system-assigned managed identity and HTTP/2 by default.
- Inherits resource group tags and lets caller tags override them.

## Resources Created

Creates one `azurerm_api_management` service. Azure may create service-managed resources. The module does not create APIs, products, backends, policies, private DNS, subnet, diagnostics, or custom domains.

## Prerequisites and Dependencies

- An existing resource group and supported Azure region.
- Publisher name and contact email.
- For VNet modes, an existing subnet meeting API Management subnet requirements and network security rules. The caller owns subnet delegation, routes, and DNS.
- API Management capacity and regional quota. SKU cost varies substantially; Developer is intended for non-production use.

## Provider Configuration

The caller supplies the default `azurerm` provider, version 4.x. The execution identity needs permission to create and manage API Management services and read the resource group when tag inheritance uses a lookup.

## Usage

```hcl
module "api_management" {
  source = "./modules/api_management"

  name                = "apim-platform-dev-001"
  location            = "Canada Central"
  resource_group_name = "rg-platform-dev"
  publisher_name      = "Contoso Platform"
  publisher_email     = "platform@example.com"
  sku_name            = "Developer_1"

  workload = "platform"
  app_env  = "dev"
  tags     = { Owner = "CCOE" }
}
```

See [examples/basic](./examples/basic/README.md).

## Important Behavior and Secure Defaults

- System-assigned managed identity is always enabled; grant it only the permissions needed by API policies and backends.
- SSL 3.0, TLS 1.0/1.1, and legacy cipher suites are disabled. Use HTTPS for clients and backends.
- Public network access defaults to enabled for initial provisioning. Set it false only when the service deployment and required management/gateway paths are reachable through the selected network design; disabling it does not itself configure private access.
- The default Developer SKU is not a production SLA tier. Select and size a production SKU deliberately.
- A VNet deployment requires an existing subnet and supported SKU/region combination. API Management network requirements include management and gateway connectivity; validate the current Azure requirements before deployment.

## Naming and Tagging

Set a service name explicitly or use a generated name based on workload, environment, and instance. Resource group tags are inherited by default; `tags` overrides matching inherited values. See the repository [naming convention](../../docs/60-security-governance/naming-convention.md) and [tagging standard](../../docs/60-security-governance/tagging-standard.md).

## Testing

The basic example provides an executable configuration. The module unit test in `tests/unit.tftest.hcl` uses a mocked AzureRM provider and plan-only assertions; it requires no Azure credentials.

## Known Limitations

- This module provisions the service only. API definitions, products, policies, backends, diagnostics, custom domains, and private DNS are separate compositions.
- Network topology, subnet sizing, required routes, firewall rules, and DNS are caller-owned.
- Service creation and deletion can take a long time. Azure may soft-delete services depending on provider feature configuration.

## Terraform Reference

The reference below is generated from the module source.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, < 5.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_api_management.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used when generating the service name. | `string` | `"dev"` | no |
| <a name="input_enable_http2"></a> [enable\_http2](#input\_enable\_http2) | Whether HTTP/2 is enabled for the API Management gateway. | `bool` | `true` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to inherit tags from the existing resource group. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional resource group tags supplied by the caller to avoid a data source lookup. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance identifier used when generating the service name. | `string` | `"001"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the API Management service. | `string` | n/a | yes |
| <a name="input_min_api_version"></a> [min\_api\_version](#input\_min\_api\_version) | Optional minimum API version accepted by the management plane. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Optional globally unique API Management service name. Empty generates a name from workload, environment, and instance. | `string` | `""` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether the API Management management plane accepts public network access. | `bool` | `true` | no |
| <a name="input_publisher_email"></a> [publisher\_email](#input\_publisher\_email) | Contact email displayed in the API Management developer portal. | `string` | n/a | yes |
| <a name="input_publisher_name"></a> [publisher\_name](#input\_publisher\_name) | Organization name displayed in the API Management developer portal. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the existing resource group for API Management. | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | API Management SKU and capacity, such as Developer\_1, Standard\_1, or Premium\_1. | `string` | `"Developer_1"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Existing subnet ID delegated/configured for API Management. Required for External or Internal network mode. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags. Caller values override inherited resource group tags. | `map(string)` | `{}` | no |
| <a name="input_virtual_network_type"></a> [virtual\_network\_type](#input\_virtual\_network\_type) | API Management network mode. External and Internal require an existing delegated subnet\_id. | `string` | `"None"` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier used when generating the service name. | `string` | `"project"` | no |
<!-- END_TF_DOCS -->
