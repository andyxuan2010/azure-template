# Azure AI Services

Provisions an Azure AI Services or Cognitive Services account with private connectivity, managed identity, model deployments, responsible AI policies, diagnostics, and role assignments.

## Features

- Supports `AIServices`, `OpenAI`, and the broader Cognitive Services account kinds.
- Disables public network access and local key authentication by default.
- Supports system-assigned and user-assigned managed identities.
- Creates optional model deployments and responsible AI policies.
- Supports private endpoints, private DNS associations, network ACLs, and AIServices network injection.
- Supports customer-managed keys, storage attachments, diagnostic settings, and Azure RBAC assignments.

## Resources Created

The module always creates one `azurerm_cognitive_account`. It conditionally creates:

- Cognitive deployments and responsible AI policies.
- A private endpoint and private DNS zone associations.
- Azure Monitor diagnostic settings.
- Azure RBAC role assignments.
- A random suffix when generated naming requests one.

Existing resource groups, subnets, private DNS zones, monitoring destinations, identities, keys, storage accounts, and Microsoft Entra groups are looked up or referenced but not owned by this module.

## Prerequisites and Dependencies

- An existing resource group.
- Provider registration, regional availability, quota, and model access for the selected account kind and deployments.
- A delegated subnet for AIServices network injection, when enabled.
- A private-endpoint subnet and the appropriate private DNS zone when private connectivity is enabled.
- Existing Log Analytics, Storage, or Event Hub destinations when diagnostics are enabled.
- Existing managed identities and Key Vault key permissions when using customer-managed keys.
- Terraform `>= 1.6.0`; AzureRM `>= 4.0, < 5.0`; AzureAD `>= 3.0, < 4.0`; Random `>= 3.0, < 4.0`.

## Provider Configuration

Configure providers in the calling root module. AzureRM manages Azure resources, AzureAD resolves optional group-based assignments, and Random supports generated names.

```hcl
provider "azurerm" {
  features {}
}

provider "azuread" {}
```

The Terraform execution identity needs access to the target subscription and any cross-resource dependencies. Creating role assignments also requires role-assignment permissions at the configured scopes.

## Basic Usage

See the executable [basic example](examples/basic/) and the production-oriented [complete example](examples/complete/).

```hcl
module "ai_services" {
  source = "../../modules/azure_ai_service"

  resource_group_name              = azurerm_resource_group.ai.name
  location                         = azurerm_resource_group.ai.location
  workload_name                    = "claims"
  app_env                          = "prod"
  system_managed_identity_enabled  = true
  public_network_access_enabled    = false
  local_auth_enabled               = false
  inherit_resource_group_tags      = false
  tags                             = local.tags
}
```

## Important Behavior and Secure Defaults

- Public network access and local authentication keys default to disabled.
- A custom subdomain is generated when Azure requires one for private endpoints, network ACLs, or token authentication.
- Use either the legacy `identity` object or the current identity inputs, not both.
- Customer-managed keys, project management, and network injection require a managed identity.
- Project management and network injection are limited to `AIServices`.
- Model deployments and responsible AI policies are limited to `AIServices` and `OpenAI`.
- Model names, versions, SKUs, and capacity are region- and quota-dependent and can fail during apply even when Terraform validation passes.
- Diagnostic settings require at least one valid destination.

## Networking and Private Connectivity

Public access is disabled by default. For private access, supply a private-endpoint subnet ID and the relevant private DNS zone IDs; the module creates the endpoint and zone association. The usual Azure AI Services DNS zone is selected according to the account kind and organization design.

Network ACLs apply to the service endpoint and require a custom subdomain. AIServices network injection is a separate outbound networking feature and requires an identity plus a properly delegated subnet. Network resources remain caller-owned.

## Identity and RBAC

New compositions should use `system_managed_identity_enabled` and `identity_ids`. The legacy `identity` object remains for compatibility. The module can create Azure RBAC assignments for principal IDs and can resolve configured Microsoft Entra group display names through AzureAD.

Do not expose the sensitive key outputs. Keep local authentication disabled and grant workload identities the least-privileged data-plane or control-plane roles required by the selected service.

## Naming and Tagging

Set `name` for an explicit globally unique account name. Otherwise, the module generates a name and can append a random suffix. Explicit `tags` override inherited resource-group tags with the same key.

## Architecture

See [Architecture](docs/architecture.md) for resource boundaries, private connectivity, identity, deployment, and monitoring relationships.

## Testing

The test suite uses mocked AzureRM, AzureAD, and Random providers and does not deploy live Azure resources:

```shell
terraform init -backend=false
terraform test
```

Validate every configuration under `examples/` separately with `terraform init -backend=false` and `terraform validate`.

## Known Limitations

- This module creates account-level infrastructure; application indexes, agents, prompts, and other service-specific data-plane content remain outside its scope.
- Azure quota, model version availability, deployment capacity, and content-filter support cannot be proven by an offline plan.
- Private DNS zones, Key Vault keys and permissions, identities, networks, and monitoring destinations are caller-owned.
- Some service settings and deployment changes can cause replacement or operational interruption.

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
| [azurerm_cognitive_account_rai_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account_rai_policy) | resource |
| [azurerm_cognitive_deployment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_deployment) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.app_admin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_user_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | Optional list of Entra group display names or object IDs that will have Contributor access to the Azure AI Services account. | `list(string)` | `[]` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used for standard tags and generated naming. | `string` | `"dev"` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | Optional list of Entra group display names or object IDs that will have Reader access to the Azure AI Services account. | `list(string)` | `[]` | no |
| <a name="input_custom_question_answering"></a> [custom\_question\_answering](#input\_custom\_question\_answering) | Optional Custom Question Answering search dependency for TextAnalytics accounts. | <pre>object({<br>    search_service_id  = string<br>    search_service_key = string<br>  })</pre> | `null` | no |
| <a name="input_custom_subdomain_name"></a> [custom\_subdomain\_name](#input\_custom\_subdomain\_name) | Optional custom subdomain name. Required by Azure for private endpoints, network ACLs, and Entra ID token authentication; the module auto-generates it when needed. | `string` | `""` | no |
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | Optional customer-managed key configuration. | <pre>object({<br>    key_vault_key_id   = string<br>    identity_client_id = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_deployments"></a> [deployments](#input\_deployments) | Optional Cognitive Services deployments, commonly used for Azure OpenAI or Azure AI Foundry model deployments. | <pre>map(object({<br>    name                       = string<br>    dynamic_throttling_enabled = optional(bool)<br>    rai_policy_name            = optional(string)<br>    version_upgrade_option     = optional(string)<br>    model = object({<br>      format  = string<br>      name    = string<br>      version = optional(string)<br>    })<br>    sku = object({<br>      name     = string<br>      tier     = optional(string)<br>      size     = optional(string)<br>      family   = optional(string)<br>      capacity = optional(number)<br>    })<br>    timeouts = optional(object({<br>      create = optional(string)<br>      read   = optional(string)<br>      update = optional(string)<br>      delete = optional(string)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_diagnostic_eventhub_authorization_rule_id"></a> [diagnostic\_eventhub\_authorization\_rule\_id](#input\_diagnostic\_eventhub\_authorization\_rule\_id) | Optional Event Hub authorization rule resource ID for diagnostics. | `string` | `null` | no |
| <a name="input_diagnostic_eventhub_name"></a> [diagnostic\_eventhub\_name](#input\_diagnostic\_eventhub\_name) | Optional Event Hub name for diagnostics when using an Event Hub destination. | `string` | `null` | no |
| <a name="input_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#input\_diagnostic\_log\_categories) | Diagnostic log categories to enable. Use diagnostic\_log\_category\_groups for Azure Monitor category groups such as allLogs. | `list(string)` | <pre>[<br>  "Audit"<br>]</pre> | no |
| <a name="input_diagnostic_log_category_groups"></a> [diagnostic\_log\_category\_groups](#input\_diagnostic\_log\_category\_groups) | Diagnostic log category groups to enable, for example allLogs. | `list(string)` | `[]` | no |
| <a name="input_diagnostic_metric_categories"></a> [diagnostic\_metric\_categories](#input\_diagnostic\_metric\_categories) | Diagnostic metric categories to enable. | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| <a name="input_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#input\_diagnostic\_setting\_name) | Optional diagnostic setting name. When empty, the module uses <account-name>-diagnostic-setting. | `string` | `""` | no |
| <a name="input_diagnostic_storage_account_id"></a> [diagnostic\_storage\_account\_id](#input\_diagnostic\_storage\_account\_id) | Optional Storage Account resource ID for diagnostic archive. | `string` | `null` | no |
| <a name="input_dynamic_throttling_enabled"></a> [dynamic\_throttling\_enabled](#input\_dynamic\_throttling\_enabled) | Whether dynamic throttling is enabled. The provider omits this for OpenAI and AIServices kinds. | `bool` | `false` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Whether to create diagnostic settings on the Azure AI Services account. Diagnostics are also enabled when at least one diagnostic destination is supplied. | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Whether to create a private endpoint for the Azure AI Services account. | `bool` | `false` | no |
| <a name="input_fqdns"></a> [fqdns](#input\_fqdns) | Optional list of outbound FQDNs. | `list(string)` | `[]` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Legacy managed identity configuration. Prefer system\_managed\_identity\_enabled and identity\_ids for new usage. | <pre>object({<br>    type         = string<br>    identity_ids = optional(set(string))<br>  })</pre> | `null` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | User-assigned managed identity IDs to attach to the Azure AI Services account. Ignored when legacy identity is set. | `list(string)` | `[]` | no |
| <a name="input_include_environment_in_name"></a> [include\_environment\_in\_name](#input\_include\_environment\_in\_name) | Whether generated Azure AI Services names include app\_env. | `bool` | `true` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into module resources. The module only reads the resource group when this is true or location is empty. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Optional instance segment used when generated names do not use a random suffix. | `string` | `"001"` | no |
| <a name="input_kind"></a> [kind](#input\_kind) | Cognitive Services account kind. AIServices is the Azure AI Foundry superset and is the default for this module. | `string` | `"AIServices"` | no |
| <a name="input_local_auth_enabled"></a> [local\_auth\_enabled](#input\_local\_auth\_enabled) | Whether local authentication keys are enabled. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Optional Azure region for the Azure AI Services account. Leave empty to use the target resource group's location. | `string` | `""` | no |
| <a name="input_location_code"></a> [location\_code](#input\_location\_code) | Optional short location code used when the Azure AI Services account name is generated. | `string` | `""` | no |
| <a name="input_log_analytics_destination_type"></a> [log\_analytics\_destination\_type](#input\_log\_analytics\_destination\_type) | Destination type for Log Analytics diagnostics. | `string` | `"Dedicated"` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Optional Log Analytics workspace ID used for diagnostics. | `string` | `""` | no |
| <a name="input_metrics_advisor"></a> [metrics\_advisor](#input\_metrics\_advisor) | Optional Metrics Advisor settings. Only applicable when kind is MetricsAdvisor. | <pre>object({<br>    aad_client_id   = string<br>    aad_tenant_id   = string<br>    super_user_name = string<br>    website_name    = string<br>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Azure AI Services account name. Leave empty to auto-generate a unique name. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used when the Azure AI Services account name is generated. | `string` | `"ais"` | no |
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | Optional network ACL configuration. When set, Azure requires a custom subdomain. | <pre>object({<br>    default_action = string<br>    bypass         = optional(string)<br>    ip_rules       = optional(set(string))<br>    virtual_network_rules = optional(set(object({<br>      subnet_id                            = string<br>      ignore_missing_vnet_service_endpoint = optional(bool)<br>    })))<br>  })</pre> | `null` | no |
| <a name="input_network_injection"></a> [network\_injection](#input\_network\_injection) | Optional network injection configuration for AI Foundry agent networking. Only supported when kind is AIServices. | <pre>object({<br>    scenario  = optional(string, "agent")<br>    subnet_id = string<br>  })</pre> | `null` | no |
| <a name="input_outbound_network_access_restricted"></a> [outbound\_network\_access\_restricted](#input\_outbound\_network\_access\_restricted) | Whether outbound network access is restricted. | `bool` | `false` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Optional single private DNS zone ID to attach to the private endpoint. Use private\_dns\_zone\_ids for new configurations. | `string` | `""` | no |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | Optional list of private DNS zone IDs to attach to the private endpoint. | `list(string)` | `[]` | no |
| <a name="input_private_dns_zone_names"></a> [private\_dns\_zone\_names](#input\_private\_dns\_zone\_names) | Optional private DNS zone names to resolve and attach to the private endpoint when IDs are not supplied. | `list(string)` | `[]` | no |
| <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name) | Resource group containing the private DNS zones referenced by private\_dns\_zone\_names. | `string` | `null` | no |
| <a name="input_private_endpoint_ip_configurations"></a> [private\_endpoint\_ip\_configurations](#input\_private\_endpoint\_ip\_configurations) | Optional static IP configurations for the private endpoint. | <pre>list(object({<br>    name               = string<br>    private_ip_address = string<br>    subresource_name   = optional(string, "account")<br>    member_name        = optional(string, "account")<br>  }))</pre> | `[]` | no |
| <a name="input_private_endpoint_manual_connection_enabled"></a> [private\_endpoint\_manual\_connection\_enabled](#input\_private\_endpoint\_manual\_connection\_enabled) | Whether the private endpoint connection is created as a manual approval request. | `bool` | `false` | no |
| <a name="input_private_endpoint_name_prefix"></a> [private\_endpoint\_name\_prefix](#input\_private\_endpoint\_name\_prefix) | Prefix used for generated private endpoint names. | `string` | `"pep"` | no |
| <a name="input_private_endpoint_network_interface_name"></a> [private\_endpoint\_network\_interface\_name](#input\_private\_endpoint\_network\_interface\_name) | Optional custom network interface name for the private endpoint. | `string` | `""` | no |
| <a name="input_private_endpoint_network_resource_group_name"></a> [private\_endpoint\_network\_resource\_group\_name](#input\_private\_endpoint\_network\_resource\_group\_name) | Resource group containing the virtual network used to resolve the private endpoint subnet. | `string` | `""` | no |
| <a name="input_private_endpoint_request_message"></a> [private\_endpoint\_request\_message](#input\_private\_endpoint\_request\_message) | Optional request message used when private\_endpoint\_manual\_connection\_enabled is true. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | Subnet ID for the private endpoint. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#input\_private\_endpoint\_subnet\_name) | Subnet name used to resolve the private endpoint subnet when private\_endpoint\_subnet\_id is not set. | `string` | `""` | no |
| <a name="input_private_endpoint_vnet_name"></a> [private\_endpoint\_vnet\_name](#input\_private\_endpoint\_vnet\_name) | Virtual network name used to resolve the private endpoint subnet when private\_endpoint\_subnet\_id is not set. | `string` | `""` | no |
| <a name="input_private_service_connection_name_prefix"></a> [private\_service\_connection\_name\_prefix](#input\_private\_service\_connection\_name\_prefix) | Prefix used for generated private service connection names. | `string` | `"psc"` | no |
| <a name="input_project_management_enabled"></a> [project\_management\_enabled](#input\_project\_management\_enabled) | Whether project management is enabled. Supported when kind is AIServices. | `bool` | `false` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is enabled. | `bool` | `false` | no |
| <a name="input_qna_runtime_endpoint"></a> [qna\_runtime\_endpoint](#input\_qna\_runtime\_endpoint) | Optional QnA Maker runtime endpoint for legacy QnAMaker scenarios. | `string` | `""` | no |
| <a name="input_rai_policies"></a> [rai\_policies](#input\_rai\_policies) | Optional Responsible AI policies for Cognitive Services deployments. | <pre>map(object({<br>    name             = string<br>    base_policy_name = string<br>    mode             = optional(string)<br>    tags             = optional(map(string), {})<br>    content_filters = list(object({<br>      name               = string<br>      filter_enabled     = bool<br>      block_enabled      = bool<br>      severity_threshold = string<br>      source             = string<br>    }))<br>    timeouts = optional(object({<br>      create = optional(string)<br>      read   = optional(string)<br>      update = optional(string)<br>      delete = optional(string)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group where the Azure AI Services account will be deployed. | `string` | n/a | yes |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | Additional role assignments to create at the Azure AI Services account scope, keyed by a stable name. | <pre>map(object({<br>    principal_id                           = string<br>    role_definition_name                   = optional(string)<br>    role_definition_id                     = optional(string)<br>    principal_type                         = optional(string)<br>    description                            = optional(string)<br>    name                                   = optional(string)<br>    condition                              = optional(string)<br>    condition_version                      = optional(string)<br>    delegated_managed_identity_resource_id = optional(string)<br>    skip_service_principal_aad_check       = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU name for the Azure AI Services account. | `string` | `"S0"` | no |
| <a name="input_storage"></a> [storage](#input\_storage) | Optional storage account attachments for Azure AI Services. | <pre>list(object({<br>    storage_account_id = string<br>    identity_client_id = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_system_managed_identity_enabled"></a> [system\_managed\_identity\_enabled](#input\_system\_managed\_identity\_enabled) | Whether to enable a system-assigned managed identity. Ignored when legacy identity is set. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the Azure AI Services account. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional timeouts for Cognitive account create, read, update, and delete operations. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_use_random_suffix"></a> [use\_random\_suffix](#input\_use\_random\_suffix) | Whether generated Azure AI Services names should include a random suffix. | `bool` | `true` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier used in tagging. | `string` | `"project"` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Optional workload segment used when the Azure AI Services account name is generated. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_admin_group_principal_ids"></a> [app\_admin\_group\_principal\_ids](#output\_app\_admin\_group\_principal\_ids) | Map of resolved app admin group principal IDs. |
| <a name="output_app_admin_group_role_assignment_ids"></a> [app\_admin\_group\_role\_assignment\_ids](#output\_app\_admin\_group\_role\_assignment\_ids) | Contributor role assignment IDs keyed by principal ID. |
| <a name="output_app_env"></a> [app\_env](#output\_app\_env) | The deployment environment used for tags and generated names. |
| <a name="output_app_user_group_principal_ids"></a> [app\_user\_group\_principal\_ids](#output\_app\_user\_group\_principal\_ids) | Map of resolved app user group principal IDs. |
| <a name="output_app_user_group_role_assignment_ids"></a> [app\_user\_group\_role\_assignment\_ids](#output\_app\_user\_group\_role\_assignment\_ids) | Reader role assignment IDs keyed by principal ID. |
| <a name="output_custom_subdomain_name"></a> [custom\_subdomain\_name](#output\_custom\_subdomain\_name) | The effective custom subdomain name configured on the Azure AI Services account. |
| <a name="output_deployment_ids"></a> [deployment\_ids](#output\_deployment\_ids) | Map of Cognitive deployment IDs keyed by input key. |
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | Diagnostic setting ID when diagnostics are enabled. |
| <a name="output_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#output\_diagnostic\_setting\_name) | Diagnostic setting name when diagnostics are enabled. |
| <a name="output_diagnostics_enabled"></a> [diagnostics\_enabled](#output\_diagnostics\_enabled) | Boolean flag indicating whether diagnostics are enabled. |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The Azure AI Services endpoint. |
| <a name="output_id"></a> [id](#output\_id) | The Azure AI Services account resource ID. |
| <a name="output_identity"></a> [identity](#output\_identity) | Managed identity details for the Azure AI Services account. |
| <a name="output_identity_type"></a> [identity\_type](#output\_identity\_type) | The managed identity type enabled on the Azure AI Services account. |
| <a name="output_kind"></a> [kind](#output\_kind) | The Cognitive Services account kind. |
| <a name="output_local_auth_enabled"></a> [local\_auth\_enabled](#output\_local\_auth\_enabled) | Whether local authentication keys are enabled. |
| <a name="output_location"></a> [location](#output\_location) | The Azure region where the Azure AI Services account is deployed. |
| <a name="output_location_code"></a> [location\_code](#output\_location\_code) | The short location code used by generated names. |
| <a name="output_merged_tags"></a> [merged\_tags](#output\_merged\_tags) | Final merged tags applied to the Azure AI Services account. |
| <a name="output_name"></a> [name](#output\_name) | The Azure AI Services account name. |
| <a name="output_outbound_network_access_restricted"></a> [outbound\_network\_access\_restricted](#output\_outbound\_network\_access\_restricted) | Whether outbound network access is restricted. |
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | The primary access key when local authentication is enabled. |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | The principal ID of the system-assigned managed identity, when enabled. |
| <a name="output_private_endpoint_fqdns"></a> [private\_endpoint\_fqdns](#output\_private\_endpoint\_fqdns) | Private endpoint FQDNs when private endpoint is enabled. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint ID when private endpoint is enabled. |
| <a name="output_private_endpoint_ip_addresses"></a> [private\_endpoint\_ip\_addresses](#output\_private\_endpoint\_ip\_addresses) | Private endpoint IP addresses when private endpoint is enabled. |
| <a name="output_private_endpoint_name"></a> [private\_endpoint\_name](#output\_private\_endpoint\_name) | Private endpoint name when private endpoint is enabled. |
| <a name="output_project_management_enabled"></a> [project\_management\_enabled](#output\_project\_management\_enabled) | Whether project management is enabled. |
| <a name="output_public_network_access_enabled"></a> [public\_network\_access\_enabled](#output\_public\_network\_access\_enabled) | Whether public network access is enabled. |
| <a name="output_rai_policy_ids"></a> [rai\_policy\_ids](#output\_rai\_policy\_ids) | Map of Responsible AI policy IDs keyed by input key. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name where the Azure AI Services account is deployed. |
| <a name="output_role_assignment_count"></a> [role\_assignment\_count](#output\_role\_assignment\_count) | Total number of role assignments created by this module. |
| <a name="output_role_assignment_ids"></a> [role\_assignment\_ids](#output\_role\_assignment\_ids) | Map of additional role assignment IDs keyed by assignment name. |
| <a name="output_secondary_access_key"></a> [secondary\_access\_key](#output\_secondary\_access\_key) | The secondary access key when local authentication is enabled. |
| <a name="output_sku_name"></a> [sku\_name](#output\_sku\_name) | The Cognitive Services account SKU. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to the Azure AI Services account. |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | The tenant ID of the system-assigned managed identity, when enabled. |
<!-- END_TF_DOCS -->
