# Azure Key Vault

Provisions an Azure Key Vault with RBAC authorization, hardened network controls, certificate contacts, private connectivity, diagnostics, and optional access assignments.

## Features

- Uses Azure RBAC authorization by default.
- Disables public network access, enables network ACLs with a deny default, and enables purge protection by default.
- Supports direct IDs or shared-subscription lookups for private endpoint subnet and private DNS.
- Assigns Key Vault Administrator or Key Vault Secrets User to Microsoft Entra groups.
- Provides explicit, opt-in role grants for the current Terraform execution identity.
- Configures certificate contacts and Azure Monitor diagnostics.
- Generates a compliant name when `name` is omitted.
- Inherits resource-group tags and lets caller tags take precedence.

## Resources Created

- One Key Vault.
- Optional certificate contacts.
- Optional private endpoint and private DNS zone group.
- Optional Azure Monitor diagnostic setting.
- Optional Key Vault-scoped role assignments.
- An optional random suffix used only for generated naming.

The resource group, networking, private DNS zone, and Log Analytics workspace are existing dependencies.

## Prerequisites and Dependencies

- Terraform 1.6 or newer.
- An existing resource group.
- Optional private endpoint subnet and `privatelink.vaultcore.azure.net` private DNS zone.
- Optional Log Analytics workspace.
- Sufficient control-plane and RBAC permissions for every enabled resource and assignment.

## Provider Configuration

The module requires the default AzureRM provider, the `azurerm.prod` alias, AzureAD, and Random. `azurerm.prod` resolves shared-network subnet and DNS names and may point to the same subscription as the default provider.

```hcl
provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias = "prod"

  features {}
  subscription_id = var.shared_services_subscription_id
}

provider "azuread" {}

module "key_vault" {
  source = "./modules/keyvault"

  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
    azuread      = azuread
  }

  resource_group_name = "rg-orders-prod"
}
```

Provider credentials and configuration must remain in the calling root module.

## Basic Usage

```hcl
module "key_vault" {
  source = "./modules/keyvault"

  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
    azuread      = azuread
  }

  name                = "kv-orders-prod-001"
  resource_group_name = "rg-orders-prod"
  app_env             = "prod"
}
```

Runnable configurations are available in:

- [`examples/basic`](examples/basic/)
- [`examples/complete`](examples/complete/)
- [`examples/private-endpoint`](examples/private-endpoint/)

## Important Behavior and Secure Defaults

- Public network access is disabled, purge protection is enabled, RBAC authorization is enabled, and network ACLs default to deny.
- With the secure network defaults, configure a private endpoint or approved network ACL rules before expecting data-plane access.
- Purge protection cannot be disabled after Azure enables it. Treat that setting as a lifecycle decision.
- The module does not grant the Terraform caller vault permissions unless an explicit grant input is enabled.
- Group values may be object IDs or display names. Prefer object IDs because display names may be non-unique.
- Secrets, keys, and certificates are intentionally outside this module; manage them in separate, tightly controlled configurations.

## Private Connectivity

Prefer direct `private_endpoint_subnet_id` and `private_dns_zone_id` values. For name-based lookup, provide the subnet name, VNet name, network resource group, DNS zone name, and DNS resource group. Those lookups use `azurerm.prod`.

The private endpoint is deployed in the Key Vault resource group and attaches the existing `privatelink.vaultcore.azure.net` zone when supplied.

## Identity and RBAC

Admin groups receive Key Vault Administrator; user groups receive Key Vault Secrets User. Current-caller grants are opt-in and are intended for controlled bootstrap workflows. Reassess or remove broad bootstrap roles after ownership has transferred.

## Naming and Tagging

Set `name` explicitly for deterministic lifecycle behavior. If omitted, the module generates a name from workload, environment, location, and a random suffix. Caller tags override inherited resource-group tags.

Follow the repository [naming convention](../../docs/NAMING_CONVENTION.md) and [tagging standard](../../docs/TAGGING_STANDARD.md).

## Architecture

See [`docs/architecture.md`](docs/architecture.md) and the repository [private endpoint lookup pattern](../../docs/PRIVATE_ENDPOINT_PRIVATE_DNS_LOOKUP_PATTERN.md).

## Testing

`tests/unit.tftest.hcl` uses mocked AzureRM, AzureAD, and Random providers with plan-only runs, including the `azurerm.prod` lookup path:

```powershell
terraform init -backend=false
terraform validate
terraform test
```

No Azure resources are deployed by these tests.

## Known Limitations

- Access policies are not modeled; the module is designed for Azure RBAC authorization.
- Private DNS zones and virtual network links are not created.
- The module does not create secrets, keys, certificates, or their rotation workflows.
- Azure RBAC propagation is eventually consistent and may affect immediate post-apply data-plane operations.

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
| <a name="provider_azurerm.prod"></a> [azurerm.prod](#provider\_azurerm.prod) | >= 4.0, < 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0, < 4.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_certificate_contacts.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate_contacts) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.app_admin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_user_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.current_terraform_service_principal](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | List of Entra group display names or object IDs that should receive Key Vault Administrator access. Prefer object IDs when display names are not unique. | `list(string)` | `null` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment (dev, staging, prod, sbx, test, qa) | `string` | `"dev"` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | List of Entra group display names or object IDs that should receive Key Vault Secrets User access. Prefer object IDs when display names are not unique. | `list(string)` | `null` | no |
| <a name="input_contacts"></a> [contacts](#input\_contacts) | A list of contacts for the Key Vault certificates. | <pre>list(object({<br>    email = string<br>    name  = optional(string)<br>    phone = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#input\_diagnostic\_log\_categories) | Diagnostic log categories to enable. | `list(string)` | <pre>[<br>  "AuditEvent"<br>]</pre> | no |
| <a name="input_diagnostic_metric_categories"></a> [diagnostic\_metric\_categories](#input\_diagnostic\_metric\_categories) | Diagnostic metric categories to enable. | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Enable diagnostic settings for the Key Vault. | `bool` | `false` | no |
| <a name="input_enable_network_acls"></a> [enable\_network\_acls](#input\_enable\_network\_acls) | Whether to configure Key Vault network ACLs. | `bool` | `true` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Whether to create a private endpoint for the Key Vault. | `bool` | `false` | no |
| <a name="input_enable_rbac_authorization"></a> [enable\_rbac\_authorization](#input\_enable\_rbac\_authorization) | Whether Azure RBAC is used instead of access policies. | `bool` | `true` | no |
| <a name="input_enabled_for_deployment"></a> [enabled\_for\_deployment](#input\_enabled\_for\_deployment) | Whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the vault. | `bool` | `false` | no |
| <a name="input_enabled_for_disk_encryption"></a> [enabled\_for\_disk\_encryption](#input\_enabled\_for\_disk\_encryption) | Whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. | `bool` | `false` | no |
| <a name="input_enabled_for_template_deployment"></a> [enabled\_for\_template\_deployment](#input\_enabled\_for\_template\_deployment) | Whether Azure Resource Manager is permitted to retrieve secrets from the vault. | `bool` | `false` | no |
| <a name="input_grant_current_caller_reader_roles"></a> [grant\_current\_caller\_reader\_roles](#input\_grant\_current\_caller\_reader\_roles) | Whether to grant the current Terraform caller the Key Vault Crypto User and Key Vault Secrets User roles. | `bool` | `false` | no |
| <a name="input_grant_current_caller_secrets_officer"></a> [grant\_current\_caller\_secrets\_officer](#input\_grant\_current\_caller\_secrets\_officer) | Whether to grant the current Terraform caller the Key Vault Secrets Officer role when full current-caller Key Vault roles are disabled. | `bool` | `false` | no |
| <a name="input_grant_current_terraform_service_principal_key_vault_roles"></a> [grant\_current\_terraform\_service\_principal\_key\_vault\_roles](#input\_grant\_current\_terraform\_service\_principal\_key\_vault\_roles) | Whether to assign Contributor and Key Vault Administrator to the current Terraform execution identity at the Key Vault scope for control-plane and data-plane access. | `bool` | `false` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into Key Vault resources. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where to deploy the resource. If empty, the resource group's location is used. | `string` | `""` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace resource ID for diagnostics. | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Key Vault name. If empty, the module auto-generates a compliant name. | `string` | `""` | no |
| <a name="input_network_acls_bypass"></a> [network\_acls\_bypass](#input\_network\_acls\_bypass) | Traffic classes to bypass the network ACLs. | `string` | `"AzureServices"` | no |
| <a name="input_network_acls_default_action"></a> [network\_acls\_default\_action](#input\_network\_acls\_default\_action) | Default action for Key Vault network ACLs. | `string` | `"Deny"` | no |
| <a name="input_network_acls_ip_rules"></a> [network\_acls\_ip\_rules](#input\_network\_acls\_ip\_rules) | IPv4 addresses or CIDR ranges allowed by the Key Vault network ACLs. | `list(string)` | `[]` | no |
| <a name="input_network_acls_virtual_network_subnet_ids"></a> [network\_acls\_virtual\_network\_subnet\_ids](#input\_network\_acls\_virtual\_network\_subnet\_ids) | Subnet resource IDs allowed by the Key Vault network ACLs. | `list(string)` | `[]` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Optional Private DNS zone ID to attach to the Key Vault private endpoint. | `string` | `""` | no |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | Optional existing Private DNS zone name used to look up the Key Vault private endpoint DNS zone when private\_dns\_zone\_id is not set. | `string` | `null` | no |
| <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name) | Resource group containing the Private DNS zone used for Key Vault private endpoint DNS lookup. | `string` | `null` | no |
| <a name="input_private_endpoint_network_resource_group_name"></a> [private\_endpoint\_network\_resource\_group\_name](#input\_private\_endpoint\_network\_resource\_group\_name) | Resource group containing the virtual network used for private endpoint subnet lookup. | `string` | `null` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | Subnet ID for the private endpoint. If set, subnet lookup inputs are ignored. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#input\_private\_endpoint\_subnet\_name) | Existing subnet name used for private endpoint lookup when private\_endpoint\_subnet\_id is not set. | `string` | `null` | no |
| <a name="input_private_endpoint_vnet_name"></a> [private\_endpoint\_vnet\_name](#input\_private\_endpoint\_vnet\_name) | Existing virtual network name used for private endpoint subnet lookup. | `string` | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether the Key Vault public endpoint is reachable. | `bool` | `false` | no |
| <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled) | Whether purge protection is enabled. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the Key Vault will be deployed. | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | Key Vault SKU name. | `string` | `"standard"` | no |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | Soft delete retention in days. | `number` | `90` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resources. | `map(string)` | `{}` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Tenant ID for the Key Vault. If empty, the current caller tenant is used. | `string` | `""` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Deprecated compatibility input. Supply workload tags explicitly through tags. | `string` | `"project"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_admin_group_role_assignment_ids"></a> [app\_admin\_group\_role\_assignment\_ids](#output\_app\_admin\_group\_role\_assignment\_ids) | Map of Key Vault Administrator role assignment IDs keyed by app\_admin\_group input. |
| <a name="output_app_user_group_role_assignment_ids"></a> [app\_user\_group\_role\_assignment\_ids](#output\_app\_user\_group\_role\_assignment\_ids) | Map of Key Vault Secrets User role assignment IDs keyed by app\_user\_group input. |
| <a name="output_certificate_contacts_id"></a> [certificate\_contacts\_id](#output\_certificate\_contacts\_id) | The Key Vault certificate contacts resource ID, if contacts are configured. |
| <a name="output_current_caller_secrets_officer_role_assignment_id"></a> [current\_caller\_secrets\_officer\_role\_assignment\_id](#output\_current\_caller\_secrets\_officer\_role\_assignment\_id) | The backward-compatible Key Vault Secrets Officer role assignment ID granted to the current Terraform caller when full current-caller Key Vault roles are disabled. |
| <a name="output_current_terraform_service_principal_role_assignment_ids"></a> [current\_terraform\_service\_principal\_role\_assignment\_ids](#output\_current\_terraform\_service\_principal\_role\_assignment\_ids) | Map of role assignment IDs created for the current Terraform execution identity. |
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | The ID of the diagnostic setting, if created. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Key Vault. |
| <a name="output_location"></a> [location](#output\_location) | The location of the Key Vault. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Key Vault. |
| <a name="output_private_endpoint_fqdns"></a> [private\_endpoint\_fqdns](#output\_private\_endpoint\_fqdns) | Private endpoint FQDNs, if created. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | The ID of the private endpoint, if created. |
| <a name="output_private_endpoint_ip_addresses"></a> [private\_endpoint\_ip\_addresses](#output\_private\_endpoint\_ip\_addresses) | Private endpoint IP addresses, if created. |
| <a name="output_private_endpoint_name"></a> [private\_endpoint\_name](#output\_private\_endpoint\_name) | The name of the private endpoint, if created. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group containing the Key Vault. |
| <a name="output_tags"></a> [tags](#output\_tags) | The effective tags assigned to the Key Vault. |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | The tenant ID configured on the Key Vault. |
| <a name="output_vault_uri"></a> [vault\_uri](#output\_vault\_uri) | The URI of the Key Vault. |
<!-- END_TF_DOCS -->
