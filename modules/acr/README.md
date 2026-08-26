# Azure Container Registry

Provisions an Azure Container Registry with secure networking controls, managed identities, RBAC, private connectivity, Premium capabilities, and Azure Monitor diagnostics.

## Features

- Basic, Standard, and Premium registries with validation for SKU-specific features.
- System-assigned, user-assigned, or combined managed identities.
- Optional role assignments for the registry identity and Microsoft Entra groups.
- Network rules, private endpoints, and private DNS integration.
- Cross-subscription subnet and private DNS lookup through `azurerm.prod`.
- Customer-managed keys, geo-replication, retention, trust, quarantine, and zone redundancy.
- Log Analytics diagnostics with configurable log and metric categories.

## Resources Created

The module always creates an Azure Container Registry. Depending on its inputs, it can also create:

- Azure role assignments;
- a private endpoint and private DNS zone group;
- an Azure Monitor diagnostic setting;
- a random suffix used by generated naming.

## Prerequisites and Dependencies

- An existing resource group.
- AzureRM, AzureAD, and Random providers configured by the caller.
- For private connectivity, an existing subnet and optionally an existing private DNS zone.
- For diagnostics, an existing Log Analytics workspace.
- For customer-managed keys, an existing Key Vault key and user-assigned identity with the required access.

See the repository [module dependency guide](../../docs/MODULE_USAGE_AND_DEPENDENCIES.md) for composition order.

## Provider Configuration

The module declares `azurerm.prod` as a required configuration alias. Pass both AzureRM provider configurations even when they point to the same subscription:

```hcl
provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias = "prod"

  features {}
}

module "acr" {
  source = "./modules/acr"

  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name = "rg-platform-prod"
  app_env             = "prod"
}
```

Use `azurerm.prod` for subnet and private DNS lookups in a shared networking subscription. Provider configurations and credentials must remain in the root module.

## Basic Usage

```hcl
module "acr" {
  source = "./modules/acr"

  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name           = "rg-platform-prod"
  location                      = "canadacentral"
  app_env                       = "prod"
  sku                           = "Premium"
  public_network_access_enabled = false

  tags = {
    Owner = "Platform"
  }
}
```

Runnable configurations are available in:

- [`examples/basic`](examples/basic/)
- [`examples/complete`](examples/complete/)

## Important Behavior and Secure Defaults

- Administrative credentials and anonymous pull are disabled by default.
- Public network access should remain disabled for production registries using private endpoints.
- `export_policy_enabled = false` requires public network access to be disabled.
- Premium-only inputs require `sku = "Premium"`.
- Customer-managed keys require a user-assigned identity.
- A managed-identity role assignment requires `identity_type` to include `SystemAssigned`.
- IPv4 network-rule entries without a prefix are normalized to `/32`; IPv6 is not accepted by the module.
- Geo-replication locations must be unique and must not repeat the primary location.

## Networking and Private Connectivity

Private endpoint dependencies can be supplied by ID or looked up by name:

- Prefer `private_endpoint_subnet_id` and `private_dns_zone_id` when the caller already has module outputs.
- Use the subnet and DNS name/resource-group fields when shared resources must be discovered.
- Pass the shared-subscription provider as `azurerm.prod` for name-based lookups.

For a private registry, set `public_network_access_enabled = false`, enable the private endpoint, associate `privatelink.azurecr.io`, and verify that workloads use the private DNS resolution path.

## Identity and RBAC

Use managed identities rather than registry administrative credentials. The module can:

- grant Contributor to principals in `app_admin_group`;
- grant Reader to principals in `app_user_group`;
- assign caller-selected roles to the registry's system-assigned identity.

Prefer immutable Microsoft Entra object IDs over display names. Keep role scopes as narrow as possible.

## Naming and Tagging

An explicit `name` is accepted; otherwise, the module generates the registry name from its naming inputs. ACR names must meet Azure's globally unique, alphanumeric naming rules.

The module merges inherited resource-group tags with caller tags. Follow the repository [naming convention](../../docs/NAMING_CONVENTION.md) and [tagging standard](../../docs/TAGGING_STANDARD.md).

## Testing

The current test is an integration plan test:

```powershell
terraform init -backend=false
terraform validate
terraform test
```

It contains plan and expected-failure runs only, so it does not apply resources. It configures real providers and can perform Azure or Microsoft Entra data lookups; valid credentials and network access may therefore be required.

## Known Limitations

- Private endpoint DNS association supports one ACR private DNS zone.
- Geo-replication and several security controls are available only with Premium SKU.
- Azure role-assignment creation requires the Terraform identity to have authorization at each requested scope.

## Terraform Reference

The content below is generated from the module source. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 3.0, < 4.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >= 3.0, < 4.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, < 5.0 |
| <a name="provider_azurerm.prod"></a> [azurerm.prod](#provider\_azurerm.prod) | >= 4.0, < 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0, < 4.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_container_registry.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.app_admin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_user_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.managed_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

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
| <a name="input_export_policy_enabled"></a> [export\_policy\_enabled](#input\_export\_policy\_enabled) | Whether export policy is enabled for the registry. | `bool` | `true` | no |
| <a name="input_georeplications"></a> [georeplications](#input\_georeplications) | A list of georeplication locations for the Container Registry. | <pre>list(object({<br>    location                  = string<br>    regional_endpoint_enabled = optional(bool, true)<br>    zone_redundancy_enabled   = optional(bool, false)<br>    tags                      = optional(map(string), {})<br>  }))</pre> | `[]` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Specifies a list of User Assigned Managed Identity IDs to be assigned to this Container Registry. Required if identity\_type contains UserAssigned. | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | Specifies the type of Managed Service Identity that should be configured on this Container Registry. Possible values are SystemAssigned, UserAssigned, SystemAssigned, UserAssigned, or None. | `string` | `"None"` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into Azure Container Registry resources. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance identifier used when name is not provided. | `string` | `"001"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the Azure Container Registry. If empty, the resource group's location is used. | `string` | `""` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace ID used when diagnostics are enabled. | `string` | `""` | no |
| <a name="input_managed_identity_role_assignments"></a> [managed\_identity\_role\_assignments](#input\_managed\_identity\_role\_assignments) | Role assignments to apply to the registry's system-assigned managed identity. Each item must set exactly one of role\_definition\_name or role\_definition\_id. | <pre>map(object({<br>    scope                = string<br>    role_definition_name = optional(string)<br>    role_definition_id   = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Optional Azure Container Registry name override. Leave empty to generate one from the naming convention. | `string` | `""` | no |
| <a name="input_network_rule_bypass_option"></a> [network\_rule\_bypass\_option](#input\_network\_rule\_bypass\_option) | Bypass option for the ACR network rule set. | `string` | `"AzureServices"` | no |
| <a name="input_network_rule_default_action"></a> [network\_rule\_default\_action](#input\_network\_rule\_default\_action) | Default action for the ACR network rule set. | `string` | `"Deny"` | no |
| <a name="input_network_rule_ip_rules"></a> [network\_rule\_ip\_rules](#input\_network\_rule\_ip\_rules) | Optional list of allowed public IPv4 addresses or CIDR ranges for ACR network rules. | `list(string)` | `[]` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Optional private DNS zone ID for the registry private endpoint. | `string` | `""` | no |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | Optional existing Private DNS zone name used to look up the registry private endpoint DNS zone when private\_dns\_zone\_id is not set. | `string` | `""` | no |
| <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name) | Resource group containing the Private DNS zone used for ACR private endpoint DNS lookup. | `string` | `""` | no |
| <a name="input_private_endpoint_network_resource_group_name"></a> [private\_endpoint\_network\_resource\_group\_name](#input\_private\_endpoint\_network\_resource\_group\_name) | Resource group containing the private endpoint virtual network when resolving the subnet by name. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | Subnet ID for the private endpoint. Leave empty to resolve it from subnet/vnet/resource group names. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#input\_private\_endpoint\_subnet\_name) | Private endpoint subnet name used when private\_endpoint\_subnet\_id is empty. | `string` | `""` | no |
| <a name="input_private_endpoint_vnet_name"></a> [private\_endpoint\_vnet\_name](#input\_private\_endpoint\_vnet\_name) | Private endpoint virtual network name used when private\_endpoint\_subnet\_id is empty. | `string` | `""` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is enabled for the registry. | `bool` | `false` | no |
| <a name="input_quarantine_policy_enabled"></a> [quarantine\_policy\_enabled](#input\_quarantine\_policy\_enabled) | Whether quarantine policy is enabled for the registry. | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Existing resource group name where the Azure Container Registry will be created. | `string` | n/a | yes |
| <a name="input_retention_policy_in_days"></a> [retention\_policy\_in\_days](#input\_retention\_policy\_in\_days) | The number of days to retain untagged manifests before purge. Supported only on Premium SKU. | `number` | `null` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | SKU for the Azure Container Registry. | `string` | `"Premium"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to resources created by this module. | `map(string)` | `{}` | no |
| <a name="input_trust_policy_enabled"></a> [trust\_policy\_enabled](#input\_trust\_policy\_enabled) | Whether trust policy is enabled for the registry. | `bool` | `false` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier used in tagging. | `string` | `"project"` | no |
| <a name="input_zone_redundancy_enabled"></a> [zone\_redundancy\_enabled](#input\_zone\_redundancy\_enabled) | Whether zone redundancy is enabled for the primary registry. Supported only on Premium SKU. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_password"></a> [admin\_password](#output\_admin\_password) | Admin password when admin access is enabled. |
| <a name="output_admin_username"></a> [admin\_username](#output\_admin\_username) | Admin username when admin access is enabled. |
| <a name="output_app_admin_group_role_assignment_ids"></a> [app\_admin\_group\_role\_assignment\_ids](#output\_app\_admin\_group\_role\_assignment\_ids) | Map of Contributor role assignment IDs keyed by app\_admin\_group input key. |
| <a name="output_app_user_group_role_assignment_ids"></a> [app\_user\_group\_role\_assignment\_ids](#output\_app\_user\_group\_role\_assignment\_ids) | Map of Reader role assignment IDs keyed by app\_user\_group input key. |
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | Diagnostic setting ID when diagnostics are enabled. |
| <a name="output_id"></a> [id](#output\_id) | Azure Container Registry resource ID. |
| <a name="output_identity"></a> [identity](#output\_identity) | Managed Identity of the Azure Container Registry. |
| <a name="output_location"></a> [location](#output\_location) | Azure region where the registry is deployed. |
| <a name="output_login_server"></a> [login\_server](#output\_login\_server) | Azure Container Registry login server. |
| <a name="output_managed_identity_role_assignment_ids"></a> [managed\_identity\_role\_assignment\_ids](#output\_managed\_identity\_role\_assignment\_ids) | Map of role assignment IDs created for the registry's system-assigned managed identity. |
| <a name="output_name"></a> [name](#output\_name) | Azure Container Registry name. |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | Principal ID of the registry managed identity when present. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint ID when enabled. |
| <a name="output_private_endpoint_ip_address"></a> [private\_endpoint\_ip\_address](#output\_private\_endpoint\_ip\_address) | Private endpoint IP address when enabled. |
| <a name="output_role_assignment_ids"></a> [role\_assignment\_ids](#output\_role\_assignment\_ids) | Role assignment IDs created for app\_admin\_group, app\_user\_group, and managed\_identity\_role\_assignments. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to the registry. |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | Tenant ID of the registry managed identity when present. |
<!-- END_TF_DOCS -->
