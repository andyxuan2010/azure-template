# Azure OpenAI

Provisions an Azure OpenAI account with hardened authentication and networking, managed identity, model deployments, customer-managed keys, private connectivity, diagnostics, and RBAC.

## Features

- Disables public network access and local key authentication by default.
- Enables system-assigned managed identity by default and supports user-assigned identities.
- Creates multiple Azure OpenAI model deployments with version, SKU, capacity, upgrade, RAI policy, and timeout controls.
- Supports network ACLs and an optional private endpoint with existing private DNS zones.
- Supports customer-managed encryption keys.
- Supports Custom Question Answering integration with Azure AI Search.
- Sends logs and metrics to Log Analytics, Storage, or Event Hub.
- Assigns Azure OpenAI data-plane roles to Microsoft Entra groups and caller-defined roles to other principals.
- Generates a compliant account name or accepts an explicit name.
- Inherits resource-group tags and lets caller tags take precedence.

## Resources Created

- One Azure OpenAI cognitive account.
- Zero or more model deployments.
- Optional private endpoint and private DNS zone group.
- Optional Azure Monitor diagnostic setting.
- Optional built-in and caller-defined role assignments.
- An optional random suffix used only for generated naming.

The resource group, private endpoint subnet, private DNS zones, Key Vault key, identities, Azure AI Search service, and monitoring destinations are existing dependencies.

## Prerequisites and Dependencies

- Terraform 1.6 or newer.
- Existing resource group in an Azure OpenAI-supported region.
- Approved Azure OpenAI access, regional model availability, deployment quota, and responsible-AI governance.
- Optional `privatelink.openai.azure.com` private DNS zone and private endpoint subnet.
- Optional Log Analytics workspace, diagnostic Storage Account, or Event Hub.
- Optional user-assigned identity and Key Vault key for customer-managed encryption.

## Provider Configuration

Configure providers in the calling root module:

```hcl
provider "azurerm" {
  features {}
}

provider "azuread" {}
```

AzureAD is used only when a group is supplied by display name. Prefer immutable group object IDs.

## Basic Usage

```hcl
module "openai" {
  source = "./modules/openai"

  name                = "oai-orders-prod-001"
  resource_group_name = "rg-orders-prod"
  location            = "canadacentral"

  deployments = {
    chat = {
      model_format = "OpenAI"
      model_name   = "gpt-4o-mini"
      sku_name     = "Standard"
      sku_capacity = 10
    }
  }
}
```

Runnable configurations are available in:

- [`examples/basic`](examples/basic/)
- [`examples/complete`](examples/complete/)
- [`examples/customer-managed-key`](examples/customer-managed-key/)

## Important Behavior and Secure Defaults

- Public network access and local key authentication are disabled by default; system-assigned identity is enabled.
- A secure account without a private endpoint is intentionally unreachable from normal clients until approved network access is composed.
- The primary and secondary access-key outputs are sensitive but remain in Terraform state. Avoid using them when local authentication is disabled.
- Model names, versions, SKUs, capacities, and availability vary by region and quota. Validate them before apply.
- The account resource does not deploy application prompts, content filters beyond referenced RAI policies, or client applications.

## Networking and Private Connectivity

Prefer a private endpoint, `network_acls.default_action = "Deny"`, and private DNS for production. The module consumes existing subnet and DNS zone IDs or can look them up by name through the default AzureRM provider.

Private endpoint creation does not create the DNS zone, VNet links, routes, or client network connectivity. Disabling public access before private DNS is working prevents clients from reaching the endpoint.

## Identity, RBAC, and Keys

Admin and user groups default to Cognitive Services OpenAI Contributor and Cognitive Services OpenAI User. Use the data-plane User role for application inference unless broader management access is required.

Customer-managed encryption requires a supported Key Vault key, a user-assigned identity client ID, and appropriate Key Vault permissions. The module validates the shape of the relationship but does not grant Key Vault access.

Custom Question Answering requires both the Azure AI Search service ID and access key. That key is sensitive and retained in state.

## Model Deployment Lifecycle

Treat each deployment map key as a stable Terraform address. Changing keys can replace deployments. Model version upgrade policy can allow Azure-controlled version changes; review upgrade behavior and application compatibility.

Capacity consumes regional quota and can incur material cost even when the account is idle.

## Naming and Tagging

Set `name` explicitly or use prefix, workload, environment, location code, instance, and optional random suffix inputs. Caller tags override inherited resource-group tags.

Follow the repository [naming convention](../../docs/NAMING_CONVENTION.md) and [tagging standard](../../docs/TAGGING_STANDARD.md).

## Architecture

See [`docs/architecture.md`](docs/architecture.md) for account, deployment, identity, encryption, network, and monitoring boundaries.

## Testing

`tests/unit.tftest.hcl` uses mocked AzureRM, AzureAD, and Random providers with plan-only runs:

```powershell
terraform init -backend=false
terraform validate
terraform test
```

No Azure OpenAI resources or model deployments are created by these tests.

## Known Limitations

- Private DNS zones, VNet links, subnets, Key Vault keys, identities, and monitoring destinations are not created.
- Model availability, quota, content filtering, and regional restrictions require live Azure validation.
- The module does not manage Azure AI Studio projects, prompt flows, application code, evaluations, or data sources.
- Name-based private network lookups use the default provider and are not cross-subscription aliases.

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
| [azurerm_cognitive_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account) | resource |
| [azurerm_cognitive_deployment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_deployment) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.app_admin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_user_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_timeouts"></a> [account\_timeouts](#input\_account\_timeouts) | Optional create/read/update/delete timeouts for the Azure OpenAI account. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | Optional list of Entra group display names or object IDs that receive the admin role on the Azure OpenAI account. | `list(string)` | `[]` | no |
| <a name="input_app_admin_role_definition_name"></a> [app\_admin\_role\_definition\_name](#input\_app\_admin\_role\_definition\_name) | Azure role assigned to app\_admin\_group principals at the Azure OpenAI account scope. | `string` | `"Cognitive Services OpenAI Contributor"` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used for standard tags and generated naming. | `string` | `"dev"` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | Optional list of Entra group display names or object IDs that receive the user role on the Azure OpenAI account. | `list(string)` | `[]` | no |
| <a name="input_app_user_role_definition_name"></a> [app\_user\_role\_definition\_name](#input\_app\_user\_role\_definition\_name) | Azure role assigned to app\_user\_group principals at the Azure OpenAI account scope. | `string` | `"Cognitive Services OpenAI User"` | no |
| <a name="input_custom_question_answering_search_service_id"></a> [custom\_question\_answering\_search\_service\_id](#input\_custom\_question\_answering\_search\_service\_id) | Optional Azure AI Search service ID for custom question answering scenarios. | `string` | `""` | no |
| <a name="input_custom_question_answering_search_service_key"></a> [custom\_question\_answering\_search\_service\_key](#input\_custom\_question\_answering\_search\_service\_key) | Optional Azure AI Search service key for custom question answering scenarios. | `string` | `""` | no |
| <a name="input_custom_subdomain_name"></a> [custom\_subdomain\_name](#input\_custom\_subdomain\_name) | Optional custom subdomain name for the Azure OpenAI account. Defaults to the account name to support Entra ID auth and private endpoints. | `string` | `""` | no |
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | Optional customer-managed key configuration. | <pre>object({<br>    key_vault_key_id   = string<br>    identity_client_id = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_deployments"></a> [deployments](#input\_deployments) | Optional Azure OpenAI model deployments keyed by deployment name. | <pre>map(object({<br>    model_format               = string<br>    model_name                 = string<br>    model_version              = optional(string)<br>    sku_name                   = string<br>    sku_capacity               = optional(number)<br>    sku_family                 = optional(string)<br>    sku_size                   = optional(string)<br>    sku_tier                   = optional(string)<br>    dynamic_throttling_enabled = optional(bool)<br>    rai_policy_name            = optional(string)<br>    version_upgrade_option     = optional(string)<br>    timeouts = optional(object({<br>      create = optional(string)<br>      read   = optional(string)<br>      update = optional(string)<br>      delete = optional(string)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_diagnostic_eventhub_authorization_rule_id"></a> [diagnostic\_eventhub\_authorization\_rule\_id](#input\_diagnostic\_eventhub\_authorization\_rule\_id) | Optional Event Hub authorization rule ID used to stream diagnostics. | `string` | `""` | no |
| <a name="input_diagnostic_eventhub_name"></a> [diagnostic\_eventhub\_name](#input\_diagnostic\_eventhub\_name) | Optional Event Hub name used to stream diagnostics. | `string` | `null` | no |
| <a name="input_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#input\_diagnostic\_log\_categories) | Diagnostic log categories to enable. Use AllLogs to emit the provider category group instead of individual categories. | `list(string)` | <pre>[<br>  "AllLogs"<br>]</pre> | no |
| <a name="input_diagnostic_log_category_groups"></a> [diagnostic\_log\_category\_groups](#input\_diagnostic\_log\_category\_groups) | Diagnostic log category groups to enable, for example allLogs or audit. | `list(string)` | `[]` | no |
| <a name="input_diagnostic_metric_categories"></a> [diagnostic\_metric\_categories](#input\_diagnostic\_metric\_categories) | Diagnostic metric categories to enable. | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| <a name="input_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#input\_diagnostic\_setting\_name) | Optional diagnostic setting name. Defaults to <account-name>-diagnostic-setting. | `string` | `""` | no |
| <a name="input_diagnostic_storage_account_id"></a> [diagnostic\_storage\_account\_id](#input\_diagnostic\_storage\_account\_id) | Optional Storage Account ID used to archive diagnostics. | `string` | `""` | no |
| <a name="input_dynamic_throttling_enabled"></a> [dynamic\_throttling\_enabled](#input\_dynamic\_throttling\_enabled) | Whether account-level dynamic throttling is enabled. AzureRM does not send this setting unless true. | `bool` | `false` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Whether to create diagnostic settings on the Azure OpenAI account. Diagnostics are also enabled automatically when any diagnostic destination ID is supplied. | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Whether to create a private endpoint for the Azure OpenAI account. | `bool` | `false` | no |
| <a name="input_fqdns"></a> [fqdns](#input\_fqdns) | Optional FQDN allow-list for the cognitive account. | `list(string)` | `[]` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Legacy managed identity configuration. Prefer system\_assigned\_identity\_enabled and identity\_ids for new deployments. | <pre>object({<br>    type         = string<br>    identity_ids = optional(set(string))<br>  })</pre> | `null` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Optional user-assigned managed identity IDs. Ignored when legacy identity is provided. | `list(string)` | `[]` | no |
| <a name="input_include_environment_in_name"></a> [include\_environment\_in\_name](#input\_include\_environment\_in\_name) | Whether generated Azure OpenAI names include app\_env. | `bool` | `true` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into module resources. The module only reads the resource group when this is true or location is empty. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Optional instance segment used when generated names do not use a random suffix. | `string` | `"001"` | no |
| <a name="input_local_auth_enabled"></a> [local\_auth\_enabled](#input\_local\_auth\_enabled) | Whether local authentication keys are enabled. Prefer Microsoft Entra ID auth for production. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Optional Azure region for the Azure OpenAI account. Leave empty to use the target resource group's location. | `string` | `""` | no |
| <a name="input_location_code"></a> [location\_code](#input\_location\_code) | Optional short location code used when the Azure OpenAI account name is generated. | `string` | `""` | no |
| <a name="input_log_analytics_destination_type"></a> [log\_analytics\_destination\_type](#input\_log\_analytics\_destination\_type) | Diagnostic Log Analytics destination type. | `string` | `null` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace ID used for diagnostics. | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Azure OpenAI account name. Leave empty to auto-generate a standardized name. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used when the Azure OpenAI account name is generated. | `string` | `"oai"` | no |
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | Optional network ACL configuration. | <pre>object({<br>    default_action = string<br>    bypass         = optional(string)<br>    ip_rules       = optional(set(string))<br>    virtual_network_rules = optional(set(object({<br>      subnet_id                            = string<br>      ignore_missing_vnet_service_endpoint = optional(bool)<br>    })))<br>  })</pre> | `null` | no |
| <a name="input_outbound_network_access_restricted"></a> [outbound\_network\_access\_restricted](#input\_outbound\_network\_access\_restricted) | Whether outbound network access is restricted. | `bool` | `false` | no |
| <a name="input_private_dns_zone_group_name"></a> [private\_dns\_zone\_group\_name](#input\_private\_dns\_zone\_group\_name) | Private DNS zone group name for the private endpoint. | `string` | `"default"` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Optional single private DNS zone ID to attach to the private endpoint. Use private\_dns\_zone\_ids for new configurations. | `string` | `""` | no |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | Optional list of private DNS zone IDs to attach to the private endpoint. | `list(string)` | `[]` | no |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | Existing private DNS zone name used when private DNS zone IDs are not supplied. | `string` | `""` | no |
| <a name="input_private_dns_zone_names"></a> [private\_dns\_zone\_names](#input\_private\_dns\_zone\_names) | Additional private DNS zone names to look up in private\_dns\_zone\_resource\_group\_name. | `list(string)` | `[]` | no |
| <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name) | Resource group containing existing private DNS zones used when private DNS zone IDs are not supplied. | `string` | `""` | no |
| <a name="input_private_endpoint_ip_configurations"></a> [private\_endpoint\_ip\_configurations](#input\_private\_endpoint\_ip\_configurations) | Optional static private endpoint IP configurations. | <pre>list(object({<br>    name               = string<br>    private_ip_address = string<br>    subresource_name   = optional(string, "account")<br>    member_name        = optional(string, "account")<br>  }))</pre> | `[]` | no |
| <a name="input_private_endpoint_manual_connection"></a> [private\_endpoint\_manual\_connection](#input\_private\_endpoint\_manual\_connection) | Whether the private endpoint connection should be manually approved. | `bool` | `false` | no |
| <a name="input_private_endpoint_manual_request_message"></a> [private\_endpoint\_manual\_request\_message](#input\_private\_endpoint\_manual\_request\_message) | Optional approval request message for manual private endpoint connections. | `string` | `""` | no |
| <a name="input_private_endpoint_name"></a> [private\_endpoint\_name](#input\_private\_endpoint\_name) | Optional private endpoint name. Defaults to pep-<account-name>. | `string` | `""` | no |
| <a name="input_private_endpoint_network_interface_name"></a> [private\_endpoint\_network\_interface\_name](#input\_private\_endpoint\_network\_interface\_name) | Optional custom network interface name for the private endpoint. | `string` | `""` | no |
| <a name="input_private_endpoint_network_resource_group_name"></a> [private\_endpoint\_network\_resource\_group\_name](#input\_private\_endpoint\_network\_resource\_group\_name) | Resource group containing the virtual network used to resolve the private endpoint subnet. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | Subnet ID for the private endpoint. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#input\_private\_endpoint\_subnet\_name) | Subnet name used to resolve the private endpoint subnet when private\_endpoint\_subnet\_id is not set. | `string` | `""` | no |
| <a name="input_private_endpoint_timeouts"></a> [private\_endpoint\_timeouts](#input\_private\_endpoint\_timeouts) | Optional create/read/update/delete timeouts for the private endpoint. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_private_endpoint_vnet_name"></a> [private\_endpoint\_vnet\_name](#input\_private\_endpoint\_vnet\_name) | Virtual network name used to resolve the private endpoint subnet when private\_endpoint\_subnet\_id is not set. | `string` | `""` | no |
| <a name="input_private_service_connection_name"></a> [private\_service\_connection\_name](#input\_private\_service\_connection\_name) | Optional private service connection name. | `string` | `""` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is enabled. | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group where the Azure OpenAI account will be deployed. | `string` | n/a | yes |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | Additional role assignments scoped to the Azure OpenAI account. | <pre>map(object({<br>    principal_id                           = string<br>    principal_type                         = optional(string)<br>    role_definition_name                   = optional(string)<br>    role_definition_id                     = optional(string)<br>    name                                   = optional(string)<br>    description                            = optional(string)<br>    condition                              = optional(string)<br>    condition_version                      = optional(string)<br>    delegated_managed_identity_resource_id = optional(string)<br>    skip_service_principal_aad_check       = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU name for the Azure OpenAI account. | `string` | `"S0"` | no |
| <a name="input_system_assigned_identity_enabled"></a> [system\_assigned\_identity\_enabled](#input\_system\_assigned\_identity\_enabled) | Whether to enable a system-assigned managed identity. Ignored when legacy identity is provided. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the Azure OpenAI resources. | `map(string)` | `{}` | no |
| <a name="input_use_random_suffix"></a> [use\_random\_suffix](#input\_use\_random\_suffix) | Whether generated Azure OpenAI names should include a random suffix. | `bool` | `true` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Deprecated compatibility input. Supply workload tags explicitly through tags. | `string` | `"project"` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Optional workload segment used when the Azure OpenAI account name is generated. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_admin_group_role_assignment_ids"></a> [app\_admin\_group\_role\_assignment\_ids](#output\_app\_admin\_group\_role\_assignment\_ids) | Admin role assignment IDs keyed by principal ID. |
| <a name="output_app_user_group_role_assignment_ids"></a> [app\_user\_group\_role\_assignment\_ids](#output\_app\_user\_group\_role\_assignment\_ids) | User role assignment IDs keyed by principal ID. |
| <a name="output_custom_subdomain_name"></a> [custom\_subdomain\_name](#output\_custom\_subdomain\_name) | The effective custom subdomain name configured on the Azure OpenAI account. |
| <a name="output_deployment_details"></a> [deployment\_details](#output\_deployment\_details) | Deployment details keyed by deployment name. |
| <a name="output_deployment_ids"></a> [deployment\_ids](#output\_deployment\_ids) | Deployment resource IDs keyed by deployment name. |
| <a name="output_deployment_names"></a> [deployment\_names](#output\_deployment\_names) | Deployment names keyed by deployment key. |
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | Diagnostic setting ID when diagnostics are enabled. |
| <a name="output_diagnostics_enabled"></a> [diagnostics\_enabled](#output\_diagnostics\_enabled) | Whether diagnostic settings are enabled. |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The Azure OpenAI endpoint. |
| <a name="output_id"></a> [id](#output\_id) | The Azure OpenAI account resource ID. |
| <a name="output_identity"></a> [identity](#output\_identity) | Managed identity details for the Azure OpenAI account. |
| <a name="output_identity_ids"></a> [identity\_ids](#output\_identity\_ids) | User-assigned managed identity IDs configured on the Azure OpenAI account. |
| <a name="output_identity_type"></a> [identity\_type](#output\_identity\_type) | Managed identity type configured on the Azure OpenAI account. |
| <a name="output_local_auth_enabled"></a> [local\_auth\_enabled](#output\_local\_auth\_enabled) | Whether local key-based authentication is enabled. |
| <a name="output_location"></a> [location](#output\_location) | The Azure region where the Azure OpenAI account is deployed. |
| <a name="output_location_code"></a> [location\_code](#output\_location\_code) | Short location code used for generated naming. |
| <a name="output_merged_tags"></a> [merged\_tags](#output\_merged\_tags) | Final merged tags applied to the Azure OpenAI account. |
| <a name="output_name"></a> [name](#output\_name) | The Azure OpenAI account name. |
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | The primary access key when local authentication is enabled. |
| <a name="output_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#output\_private\_dns\_zone\_ids) | Private DNS zone IDs associated with the private endpoint. |
| <a name="output_private_endpoint_fqdns"></a> [private\_endpoint\_fqdns](#output\_private\_endpoint\_fqdns) | Private endpoint FQDNs when private endpoint is enabled. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint ID when private endpoint is enabled. |
| <a name="output_private_endpoint_ip_addresses"></a> [private\_endpoint\_ip\_addresses](#output\_private\_endpoint\_ip\_addresses) | Private endpoint IP addresses when private endpoint is enabled. |
| <a name="output_private_endpoint_name"></a> [private\_endpoint\_name](#output\_private\_endpoint\_name) | Private endpoint name when private endpoint is enabled. |
| <a name="output_public_network_access_enabled"></a> [public\_network\_access\_enabled](#output\_public\_network\_access\_enabled) | Whether public network access is enabled. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name where the Azure OpenAI account is deployed. |
| <a name="output_role_assignment_count"></a> [role\_assignment\_count](#output\_role\_assignment\_count) | Total number of role assignments managed by this module. |
| <a name="output_role_assignment_ids"></a> [role\_assignment\_ids](#output\_role\_assignment\_ids) | Additional role assignment IDs keyed by input key. |
| <a name="output_secondary_access_key"></a> [secondary\_access\_key](#output\_secondary\_access\_key) | The secondary access key when local authentication is enabled. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to the Azure OpenAI account. |
<!-- END_TF_DOCS -->
