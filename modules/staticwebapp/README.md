# Azure Static Web App

Provisions one Azure Static Web App with normalized naming, resource-group tag inheritance, and the Azure Free plan as the default SKU. Optional repository integration, application settings, preview environments, managed identity, basic authentication, and public-network controls are exposed through typed inputs.

## Features

- Defaults to `sku_tier = "Free"` and `sku_size = "Free"`.
- Supports generated or explicit Static Web App names.
- Reads location and inherited tags from an existing resource group when requested.
- Supports repository-based deployment integration with a sensitive repository token.
- Supports application settings, preview environments, configuration-file changes, and public network access.
- Supports system-assigned and user-assigned managed identity.
- Supports optional basic authentication for all or staging environments.
- Exposes the deployment API key as a sensitive output.

## Resources Created

The module always creates one `azurerm_static_web_app`. The resource group is read but not managed. No App Service Plan is created for the Free plan.

See [architecture](docs/architecture.md) for the resource boundary and trust considerations.

## Prerequisites and Dependencies

- Terraform 1.6 or newer.
- AzureRM provider 4.x.
- An existing resource group.
- Azure permissions to create and manage Microsoft.Web static sites in the resource group.
- A protected repository token only when repository integration is enabled.

## Provider Configuration

Configure AzureRM in the calling root module:

```hcl
provider "azurerm" {
  features {}
}
```

## Basic Usage

```hcl
module "staticwebapp" {
  source = "./modules/staticwebapp"

  name                = "swa-orders-dev-001"
  resource_group_name = "rg-orders-dev"
  location            = "canadacentral"
}
```

The executable configurations are in [`examples/basic`](examples/basic/) and [`examples/complete`](examples/complete/).

## Free-plan Defaults

The module passes `sku_tier = "Free"` and `sku_size = "Free"` to Azure unless the caller explicitly selects `Standard`. The Free plan does not require or create an App Service Plan. Azure Static Web Apps can still incur costs for related services, deployment infrastructure, domains, monitoring, or other resources in the surrounding solution.

## Deployment Integration and Secrets

Set `repository_url`, `repository_branch`, and `repository_token` together. The module rejects partial repository configuration. The repository token and `api_key` output are sensitive; provide them through a protected secret mechanism and do not place them in source control or logs.

For CI/CD workflows that deploy with the Static Web App API key, review whether Azure updates repository metadata outside Terraform. If so, manage the resulting drift deliberately in the caller's lifecycle policy.

## Identity, Networking, and Authentication

Managed identity is disabled by default and does not receive RBAC permissions from this module. User-assigned identity IDs must be full Azure resource IDs. Public network access is enabled by default because Static Web Apps are intended to serve public web content; disable it only when the intended service behavior has been verified. Basic authentication is disabled by default and requires an explicit environment scope and sensitive password.

## Naming and Tagging

Provide `name` for a stable explicit name or leave it empty to generate a name from the `swa` prefix, workload, location code, environment, and instance. Caller tags override inherited resource-group tags.

Follow the repository [naming convention](../../docs/60-security-governance/naming-convention.md) and [tagging standard](../../docs/60-security-governance/tagging-standard.md).

## Testing

`tests/unit.tftest.hcl` uses a mocked AzureRM provider and plan-only tests. It creates no Azure resources and requires no Azure authentication.

```powershell
terraform init -backend=false
terraform validate
terraform test
```

## Known Limitations

- The module does not create resource groups, custom domains, DNS records, deployment workflows, repositories, or RBAC assignments.
- Repository-token rotation and Azure-side repository metadata changes require explicit lifecycle and secret-management decisions in the caller.
- Mocked tests cannot prove Azure regional SKU support, repository webhook behavior, deployment success, DNS, or policy effects.

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
| [azurerm_static_web_app.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/static_web_app) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used when the Static Web App name is generated. | `string` | `"dev"` | no |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | Key-value application settings for the Static Web App. | `map(string)` | `{}` | no |
| <a name="input_basic_auth"></a> [basic\_auth](#input\_basic\_auth) | Optional basic authentication configuration for all or staging environments. | <pre>object({<br>    environments = string<br>    password     = string<br>  })</pre> | `null` | no |
| <a name="input_configuration_file_changes_enabled"></a> [configuration\_file\_changes\_enabled](#input\_configuration\_file\_changes\_enabled) | Whether changes to the Static Web App configuration file are permitted. | `bool` | `true` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | User-assigned managed identity resource IDs used when identity\_type includes UserAssigned. | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | Optional managed identity type for the Static Web App. | `string` | `null` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into the Static Web App. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags. When null and inheritance is enabled, the module reads the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance identifier used when the Static Web App name is generated. | `string` | `"001"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the Static Web App. Leave empty to use the existing resource group's location. | `string` | `""` | no |
| <a name="input_location_code"></a> [location\_code](#input\_location\_code) | Optional short location code used when the Static Web App name is generated. | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Optional Static Web App name override. Leave empty to generate one from the naming convention. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used when the Static Web App name is generated. | `string` | `"swa"` | no |
| <a name="input_preview_environments_enabled"></a> [preview\_environments\_enabled](#input\_preview\_environments\_enabled) | Whether preview or staging environments are enabled. | `bool` | `true` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is enabled for the Static Web App. | `bool` | `true` | no |
| <a name="input_repository_branch"></a> [repository\_branch](#input\_repository\_branch) | Optional repository branch used for Static Web App deployment integration. Set with repository\_url and repository\_token; partial configuration is rejected at plan time. | `string` | `null` | no |
| <a name="input_repository_token"></a> [repository\_token](#input\_repository\_token) | Optional repository token with deployment administration privileges. Set with repository\_url and repository\_branch; partial configuration is rejected at plan time. | `string` | `null` | no |
| <a name="input_repository_url"></a> [repository\_url](#input\_repository\_url) | Optional repository URL used for Static Web App deployment integration. Set with repository\_branch and repository\_token; partial configuration is rejected at plan time. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the existing resource group where the Static Web App is deployed. | `string` | n/a | yes |
| <a name="input_sku_size"></a> [sku\_size](#input\_sku\_size) | Static Web App SKU size. Free is the default size and Standard is optional. | `string` | `"Free"` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | Static Web App SKU tier. Free is the default plan and Standard is optional. | `string` | `"Free"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the Static Web App. Caller tags override inherited resource-group tags. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional timeouts for Static Web App create, read, update, and delete operations. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Compatibility workload segment used when workload\_name is empty. | `string` | `"project"` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Optional workload segment used when the Static Web App name is generated. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_key"></a> [api\_key](#output\_api\_key) | The Static Web App deployment API key. |
| <a name="output_default_host_name"></a> [default\_host\_name](#output\_default\_host\_name) | The default host name assigned to the Static Web App. |
| <a name="output_id"></a> [id](#output\_id) | The resource ID of the Static Web App. |
| <a name="output_identity_principal_id"></a> [identity\_principal\_id](#output\_identity\_principal\_id) | The principal ID of the managed identity, if one is configured. |
| <a name="output_identity_tenant_id"></a> [identity\_tenant\_id](#output\_identity\_tenant\_id) | The tenant ID of the managed identity, if one is configured. |
| <a name="output_location"></a> [location](#output\_location) | The Azure region of the Static Web App. |
| <a name="output_name"></a> [name](#output\_name) | The Static Web App name. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group containing the Static Web App. |
| <a name="output_sku_size"></a> [sku\_size](#output\_sku\_size) | The configured Static Web App SKU size. |
| <a name="output_sku_tier"></a> [sku\_tier](#output\_sku\_tier) | The configured Static Web App SKU tier. |
| <a name="output_tags"></a> [tags](#output\_tags) | The effective tags applied to the Static Web App. |
<!-- END_TF_DOCS -->
