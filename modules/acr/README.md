# Azure Container Registry Module

Provision Azure Container Registry with optional RBAC, network rules, private endpoints, and diagnostics.

## Overview

- Providers: `azuread` `3.8.0`, `azurerm` `4.65.0`, `random` `3.8.1`
- Inputs: 28
- Outputs: 8
- Nested modules: 0
- Terraform tests: `tests/live.tftest.hcl`

## Features

- Creates managed resources including `azurerm_container_registry`, `azurerm_monitor_diagnostic_setting`, `azurerm_private_endpoint`, `azurerm_role_assignment`, `azurerm_string`.
- Supports resource-level RBAC inputs for administrative and read-only access patterns.
- Supports private endpoint configuration using direct IDs or lookup inputs for the subnet and private DNS zone.
- Supports optional diagnostic settings to Log Analytics.
- Includes Terraform test coverage files: `tests/live.tftest.hcl`.

## Basic Usage

```hcl
module "acr" {
  source = "./modules/acr"
  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name = "rg-example-prod"
  location            = "eastus"

  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Key Inputs

- `resource_group_name`: Existing resource group name where the Azure Container Registry will be created. `string` (required)
- `location`: Azure region for the Azure Container Registry. `string` (required)
- `app_admin_group`: Entra groups that receive Contributor on the registry resource. Values may be display names or object IDs. `list(string)` (default: null)
- `app_user_group`: Entra groups that receive Reader on the registry resource. Values may be display names or object IDs. `list(string)` (default: null)
- `enable_diagnostics`: Whether to create a diagnostic setting for the registry. `bool` (default: false)
- `enable_private_endpoint`: Whether to create a private endpoint for the registry. `bool` (default: false)
- `log_analytics_workspace_id`: Log Analytics workspace ID used when diagnostics are enabled. `string` (default: "")
- `private_dns_zone_id`: Optional private DNS zone ID for the registry private endpoint. `string` (default: "")
- `private_dns_zone_name`: Optional existing Private DNS zone name resolved through `azurerm.prod` when `private_dns_zone_id` is not set. `string` (default: `""`)
- `private_dns_zone_resource_group_name`: Resource group containing the private DNS zone used for lookup. `string` (default: `""`)
- `tags`: Tags applied to resources created by this module. `map(string)` (default: {})

## Private DNS Options

Use one of these patterns for private endpoint DNS:

- Direct ID via `private_dns_zone_id`
- Lookup by name via `private_dns_zone_name` plus `private_dns_zone_resource_group_name`

## Notable Outputs

- `admin_password`: Admin password when admin access is enabled.
- `admin_username`: Admin username when admin access is enabled.
- `id`: Azure Container Registry resource ID.
- `login_server`: Azure Container Registry login server.
- `name`: Azure Container Registry name.
- `private_endpoint_id`: Private endpoint ID when enabled.
- `role_assignment_ids`: Role assignment IDs created for app_admin_group and app_user_group.
- `tags`: Effective tags applied to the registry.

## Testing

Run module tests from the module directory:

```powershell
terraform test
```

- `terraform test -filter='tests\live.tftest.hcl'`

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

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
| [azurerm_container_registry.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.app_admin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_user_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azuread_group.app_admin](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azuread_group.app_user](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azurerm_private_dns_zone.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |
| [azurerm_subnet.pep](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_enabled"></a> [admin\_enabled](#input\_admin\_enabled) | Whether the admin user is enabled for the registry. | `bool` | `false` | no |
| <a name="input_anonymous_pull_enabled"></a> [anonymous\_pull\_enabled](#input\_anonymous\_pull\_enabled) | Whether anonymous pull access is enabled. | `bool` | `false` | no |
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | Entra groups that receive Contributor on the registry resource. Values may be display names or object IDs. | `list(string)` | `null` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Environment, the environment name such as 'sbx','test', 'prod', 'dev','qa', 'poc' | `string` | `"dev"` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | Entra groups that receive Reader on the registry resource. Values may be display names or object IDs. | `list(string)` | `null` | no |
| <a name="input_customer_managed_key_id"></a> [customer\_managed\_key\_id](#input\_customer\_managed\_key\_id) | Specifies the Key Vault Key ID to use to encrypt the Container Registry. | `string` | `null` | no |
| <a name="input_customer_managed_key_identity_client_id"></a> [customer\_managed\_key\_identity\_client\_id](#input\_customer\_managed\_key\_identity\_client\_id) | Specifies the client ID of the user assigned identity to use to encrypt the Container Registry. Requires customer\_managed\_key\_id. | `string` | `null` | no |
| <a name="input_data_endpoint_enabled"></a> [data\_endpoint\_enabled](#input\_data\_endpoint\_enabled) | Whether dedicated data endpoints are enabled. | `bool` | `false` | no |
| <a name="input_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#input\_diagnostic\_log\_categories) | Diagnostic log categories to enable. | `list(string)` | <pre>[<br>  "ContainerRegistryRepositoryEvents",<br>  "ContainerRegistryLoginEvents"<br>]</pre> | no |
| <a name="input_diagnostic_metric_categories"></a> [diagnostic\_metric\_categories](#input\_diagnostic\_metric\_categories) | Diagnostic metric categories to enable. | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Whether to create a diagnostic setting for the registry. | `bool` | `false` | no |
| <a name="input_enable_network_rule_set"></a> [enable\_network\_rule\_set](#input\_enable\_network\_rule\_set) | Whether to configure ACR network rules. | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Whether to create a private endpoint for the registry. | `bool` | `false` | no |
| <a name="input_georeplications"></a> [georeplications](#input\_georeplications) | A list of georeplication locations for the Container Registry. | <pre>list(object({<br>    location                = string<br>    zone_redundancy_enabled = optional(bool, false)<br>    tags                    = optional(map(string), {})<br>  }))</pre> | `[]` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Specifies a list of User Assigned Managed Identity IDs to be assigned to this Container Registry. Required if identity\_type contains UserAssigned. | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | Specifies the type of Managed Service Identity that should be configured on this Container Registry. Possible values are SystemAssigned, UserAssigned, SystemAssigned, UserAssigned, or None. | `string` | `"None"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the Azure Container Registry. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace ID used when diagnostics are enabled. | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Default prefix of the resource name that will be created. Leave empty to auto-generate. | `string` | `""` | no |
| <a name="input_network_rule_bypass_option"></a> [network\_rule\_bypass\_option](#input\_network\_rule\_bypass\_option) | Bypass option for the ACR network rule set. | `string` | `"AzureServices"` | no |
| <a name="input_network_rule_default_action"></a> [network\_rule\_default\_action](#input\_network\_rule\_default\_action) | Default action for the ACR network rule set. | `string` | `"Deny"` | no |
| <a name="input_network_rule_ip_rules"></a> [network\_rule\_ip\_rules](#input\_network\_rule\_ip\_rules) | Optional list of allowed public IP CIDR ranges for ACR network rules. | `list(string)` | `[]` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Optional private DNS zone ID for the registry private endpoint. | `string` | `""` | no |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | Optional existing Private DNS zone name used to look up the registry private endpoint DNS zone when private\_dns\_zone\_id is not set. | `string` | `""` | no |
| <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name) | Resource group containing the Private DNS zone used for ACR private endpoint DNS lookup. | `string` | `""` | no |
| <a name="input_private_endpoint_network_resource_group_name"></a> [private\_endpoint\_network\_resource\_group\_name](#input\_private\_endpoint\_network\_resource\_group\_name) | Resource group containing the private endpoint virtual network when resolving the subnet by name. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | Subnet ID for the private endpoint. Leave empty to resolve it from subnet/vnet/resource group names. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#input\_private\_endpoint\_subnet\_name) | Private endpoint subnet name used when private\_endpoint\_subnet\_id is empty. | `string` | `""` | no |
| <a name="input_private_endpoint_vnet_name"></a> [private\_endpoint\_vnet\_name](#input\_private\_endpoint\_vnet\_name) | Private endpoint virtual network name used when private\_endpoint\_subnet\_id is empty. | `string` | `""` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is enabled for the registry. | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Existing resource group name where the Azure Container Registry will be created. | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | SKU for the Azure Container Registry. | `string` | `"Premium"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to resources created by this module. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_password"></a> [admin\_password](#output\_admin\_password) | Admin password when admin access is enabled. |
| <a name="output_admin_username"></a> [admin\_username](#output\_admin\_username) | Admin username when admin access is enabled. |
| <a name="output_id"></a> [id](#output\_id) | Azure Container Registry resource ID. |
| <a name="output_identity"></a> [identity](#output\_identity) | Managed Identity of the Azure Container Registry. |
| <a name="output_login_server"></a> [login\_server](#output\_login\_server) | Azure Container Registry login server. |
| <a name="output_name"></a> [name](#output\_name) | Azure Container Registry name. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint ID when enabled. |
| <a name="output_role_assignment_ids"></a> [role\_assignment\_ids](#output\_role\_assignment\_ids) | Role assignment IDs created for app\_admin\_group and app\_user\_group. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to the registry. |
<!-- END_TF_DOCS -->