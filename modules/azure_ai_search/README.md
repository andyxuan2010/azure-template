# Azure AI Search

Provisions an Azure AI Search service with private connectivity, managed identity, network restrictions, shared private links, diagnostics, and role assignments.

## Features

- Disables public network access and local key authentication by default.
- Supports service sizing, hosting mode, and semantic ranker configuration.
- Supports system-assigned and user-assigned managed identities.
- Creates optional private endpoints, private DNS associations, and shared private link resources.
- Supports IP allowlists for explicitly public deployments.
- Supports diagnostic settings and Azure RBAC assignments.

## Resources Created

The module always creates one `azurerm_search_service`. It conditionally creates:

- Shared private link services.
- A private endpoint and private DNS zone associations.
- Azure Monitor diagnostic settings.
- Azure RBAC role assignments.
- A random suffix for generated naming.

Existing resource groups, subnets, DNS zones, monitoring destinations, and Microsoft Entra groups are referenced or looked up but are not owned by this module.

## Prerequisites and Dependencies

- An existing resource group.
- A supported Search SKU and sufficient regional capacity.
- An existing subnet and `privatelink.search.windows.net` private DNS zone when private access is enabled.
- Target resources and approval processes for shared private links.
- Existing monitoring destinations when diagnostics are enabled.
- Terraform `>= 1.6.0`; AzureRM `>= 4.0, < 5.0`; AzureAD `>= 3.0, < 4.0`; Random `>= 3.0, < 4.0`.

## Provider Configuration

Configure providers in the calling root module:

```hcl
provider "azurerm" {
  features {}
}

provider "azuread" {}
```

AzureAD is used for optional group lookups. The Terraform identity needs permission to manage Search resources and any configured role assignments, private endpoints, and diagnostics.

## Basic Usage

See the executable [basic example](examples/basic/), [complete example](examples/complete/), and isolated [public firewall example](examples/public-firewall-nonproduction/).

```hcl
module "search" {
  source = "../../modules/azure_ai_search"

  resource_group_name             = azurerm_resource_group.ai.name
  location                        = azurerm_resource_group.ai.location
  workload_name                   = "knowledge"
  app_env                         = "prod"
  system_managed_identity_enabled = true
  public_network_access_enabled   = false
  local_authentication_enabled    = false
  inherit_resource_group_tags     = false
  tags                            = local.tags
}
```

## Important Behavior and Secure Defaults

- Public network access and local API-key authentication default to disabled.
- `allowed_ips` is valid only when public network access is enabled and accepts IPv4 addresses or CIDR ranges.
- Use either the legacy `identity` object or the current managed-identity inputs, not both.
- Customer-managed-key enforcement requires an identity, but key creation and service-specific key wiring remain outside this resource.
- Replica and partition counts directly affect capacity and cost. The free SKU ignores several scale settings.
- Diagnostic settings require a valid destination.

## Networking and Private Connectivity

Private endpoints use the caller-provided subnet. Associate the endpoint with the `privatelink.search.windows.net` private DNS zone, or provide equivalent enterprise DNS forwarding and records. Public access remains disabled unless explicitly enabled.

Shared private links originate from Search to supported dependent resources. They commonly require approval on the target resource after Terraform creates the request. The target resource lifecycle and approval are outside this module.

## Identity and RBAC

Use `system_managed_identity_enabled` and `identity_ids` for new compositions. The legacy `identity` input is retained for compatibility. The module can create role assignments from direct principal IDs and optional Microsoft Entra group names.

Key and query-key outputs are sensitive. Prefer managed identity and Search data-plane RBAC, and keep local authentication disabled.

## Naming and Tagging

Set `name` for an explicit globally unique Search service name. Otherwise, the module generates a name with an optional random suffix. Explicit tags override inherited resource-group tags.

## Architecture

See [Architecture](docs/architecture.md) for network, identity, dependency, and monitoring boundaries.

## Testing

The unit tests mock AzureRM, AzureAD, and Random:

```shell
terraform init -backend=false
terraform test
```

Validate the example directories independently before use.

## Known Limitations

- The module manages the Search service but not indexes, indexers, skillsets, data sources, synonym maps, or application data.
- Shared private-link approval is not guaranteed by creation of the request.
- SKU availability, capacity, semantic ranker behavior, and SLA requirements vary by region.
- Private DNS zones, target resources, identities, and monitoring destinations remain caller-owned.

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
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.app_admin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_user_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_search_service.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/search_service) | resource |
| [azurerm_search_shared_private_link_service.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/search_shared_private_link_service) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips) | Optional list of public IPv4 addresses or CIDR ranges allowed to access the Azure AI Search service when public network access is enabled. | `list(string)` | `[]` | no |
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | Optional list of Entra group display names or object IDs that will have Contributor access to the Azure AI Search service. | `list(string)` | `[]` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used for standard tags and generated naming. | `string` | `"dev"` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | Optional list of Entra group display names or object IDs that will have Reader access to the Azure AI Search service. | `list(string)` | `[]` | no |
| <a name="input_authentication_failure_mode"></a> [authentication\_failure\_mode](#input\_authentication\_failure\_mode) | Optional authentication failure mode when local authentication and Entra authentication are both supported. | `string` | `""` | no |
| <a name="input_customer_managed_key_enforcement_enabled"></a> [customer\_managed\_key\_enforcement\_enabled](#input\_customer\_managed\_key\_enforcement\_enabled) | Whether the Search service enforces customer-managed encryption for non-customer resources. Azure AI Search key wiring is performed outside this resource. | `bool` | `false` | no |
| <a name="input_diagnostic_eventhub_authorization_rule_id"></a> [diagnostic\_eventhub\_authorization\_rule\_id](#input\_diagnostic\_eventhub\_authorization\_rule\_id) | Optional Event Hub authorization rule resource ID for diagnostics. | `string` | `null` | no |
| <a name="input_diagnostic_eventhub_name"></a> [diagnostic\_eventhub\_name](#input\_diagnostic\_eventhub\_name) | Optional Event Hub name for diagnostics when using an Event Hub destination. | `string` | `null` | no |
| <a name="input_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#input\_diagnostic\_log\_categories) | Diagnostic log categories to enable. Use diagnostic\_log\_category\_groups for Azure Monitor category groups such as allLogs. | `list(string)` | <pre>[<br>  "OperationLogs"<br>]</pre> | no |
| <a name="input_diagnostic_log_category_groups"></a> [diagnostic\_log\_category\_groups](#input\_diagnostic\_log\_category\_groups) | Diagnostic log category groups to enable, for example allLogs. | `list(string)` | `[]` | no |
| <a name="input_diagnostic_metric_categories"></a> [diagnostic\_metric\_categories](#input\_diagnostic\_metric\_categories) | Diagnostic metric categories to enable. | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| <a name="input_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#input\_diagnostic\_setting\_name) | Optional diagnostic setting name. When empty, the module uses <search-service-name>-diagnostic-setting. | `string` | `""` | no |
| <a name="input_diagnostic_storage_account_id"></a> [diagnostic\_storage\_account\_id](#input\_diagnostic\_storage\_account\_id) | Optional Storage Account resource ID for diagnostic archive. | `string` | `null` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Whether to create diagnostic settings on the Azure AI Search service. Diagnostics are also enabled when at least one diagnostic destination is supplied. | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Whether to create a private endpoint for the Azure AI Search service. | `bool` | `false` | no |
| <a name="input_hosting_mode"></a> [hosting\_mode](#input\_hosting\_mode) | Hosting mode for the Azure AI Search service. | `string` | `"default"` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Legacy managed identity configuration. Prefer system\_managed\_identity\_enabled and identity\_ids for new usage. | <pre>object({<br>    type         = string<br>    identity_ids = optional(set(string))<br>  })</pre> | `null` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | User-assigned managed identity IDs to attach to the Azure AI Search service. Ignored when legacy identity is set. | `list(string)` | `[]` | no |
| <a name="input_include_environment_in_name"></a> [include\_environment\_in\_name](#input\_include\_environment\_in\_name) | Whether generated Azure AI Search names include app\_env. | `bool` | `true` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into module resources. The module only reads the resource group when this is true or location is empty. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Optional instance segment used when generated names do not use a random suffix. | `string` | `"001"` | no |
| <a name="input_local_authentication_enabled"></a> [local\_authentication\_enabled](#input\_local\_authentication\_enabled) | Whether API-key based local authentication is enabled. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Optional Azure region for the Azure AI Search service. Leave empty to use the target resource group's location. | `string` | `""` | no |
| <a name="input_location_code"></a> [location\_code](#input\_location\_code) | Optional short location code used when the Azure AI Search service name is generated. | `string` | `""` | no |
| <a name="input_log_analytics_destination_type"></a> [log\_analytics\_destination\_type](#input\_log\_analytics\_destination\_type) | Destination type for Log Analytics diagnostics. | `string` | `"Dedicated"` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Optional Log Analytics workspace ID used for diagnostics. | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Azure AI Search service name. Leave empty to auto-generate a unique name. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used when the Azure AI Search service name is generated. | `string` | `"srch"` | no |
| <a name="input_network_rule_bypass_option"></a> [network\_rule\_bypass\_option](#input\_network\_rule\_bypass\_option) | Whether trusted Azure services may bypass network rules. | `string` | `"None"` | no |
| <a name="input_partition_count"></a> [partition\_count](#input\_partition\_count) | Partition count for the Azure AI Search service. Ignored for the free SKU. | `number` | `1` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Optional single private DNS zone ID to attach to the private endpoint. Use private\_dns\_zone\_ids for new configurations. | `string` | `""` | no |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | Optional list of private DNS zone IDs to attach to the private endpoint. | `list(string)` | `[]` | no |
| <a name="input_private_dns_zone_names"></a> [private\_dns\_zone\_names](#input\_private\_dns\_zone\_names) | Optional private DNS zone names to resolve and attach to the private endpoint when IDs are not supplied. | `list(string)` | `[]` | no |
| <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name) | Resource group containing the private DNS zones referenced by private\_dns\_zone\_names. | `string` | `null` | no |
| <a name="input_private_endpoint_manual_connection_enabled"></a> [private\_endpoint\_manual\_connection\_enabled](#input\_private\_endpoint\_manual\_connection\_enabled) | Whether the private endpoint connection is created as a manual approval request. | `bool` | `false` | no |
| <a name="input_private_endpoint_name_prefix"></a> [private\_endpoint\_name\_prefix](#input\_private\_endpoint\_name\_prefix) | Prefix used for generated private endpoint names. | `string` | `"pep"` | no |
| <a name="input_private_endpoint_network_interface_name"></a> [private\_endpoint\_network\_interface\_name](#input\_private\_endpoint\_network\_interface\_name) | Optional custom network interface name for the private endpoint. | `string` | `""` | no |
| <a name="input_private_endpoint_network_resource_group_name"></a> [private\_endpoint\_network\_resource\_group\_name](#input\_private\_endpoint\_network\_resource\_group\_name) | Resource group containing the virtual network used to resolve the private endpoint subnet. | `string` | `""` | no |
| <a name="input_private_endpoint_request_message"></a> [private\_endpoint\_request\_message](#input\_private\_endpoint\_request\_message) | Optional request message used when private\_endpoint\_manual\_connection\_enabled is true. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | Subnet ID for the private endpoint. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#input\_private\_endpoint\_subnet\_name) | Subnet name used to resolve the private endpoint subnet when private\_endpoint\_subnet\_id is not set. | `string` | `""` | no |
| <a name="input_private_endpoint_vnet_name"></a> [private\_endpoint\_vnet\_name](#input\_private\_endpoint\_vnet\_name) | Virtual network name used to resolve the private endpoint subnet when private\_endpoint\_subnet\_id is not set. | `string` | `""` | no |
| <a name="input_private_service_connection_name_prefix"></a> [private\_service\_connection\_name\_prefix](#input\_private\_service\_connection\_name\_prefix) | Prefix used for generated private service connection names. | `string` | `"psc"` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is enabled. | `bool` | `false` | no |
| <a name="input_replica_count"></a> [replica\_count](#input\_replica\_count) | Replica count for the Azure AI Search service. Ignored for the free SKU. | `number` | `1` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group where the Azure AI Search service will be deployed. | `string` | n/a | yes |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | Additional role assignments to create at the Azure AI Search service scope, keyed by a stable name. | <pre>map(object({<br>    principal_id                           = string<br>    role_definition_name                   = optional(string)<br>    role_definition_id                     = optional(string)<br>    principal_type                         = optional(string)<br>    description                            = optional(string)<br>    name                                   = optional(string)<br>    condition                              = optional(string)<br>    condition_version                      = optional(string)<br>    delegated_managed_identity_resource_id = optional(string)<br>    skip_service_principal_aad_check       = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_semantic_search_sku"></a> [semantic\_search\_sku](#input\_semantic\_search\_sku) | Optional semantic ranker SKU for the Azure AI Search service. | `string` | `""` | no |
| <a name="input_shared_private_link_services"></a> [shared\_private\_link\_services](#input\_shared\_private\_link\_services) | Shared private link resources that allow Azure AI Search to privately reach dependency services such as Storage, Key Vault, SQL, Cosmos DB, or OpenAI. | <pre>map(object({<br>    name               = string<br>    subresource_name   = string<br>    target_resource_id = string<br>    request_message    = optional(string)<br>    timeouts = optional(object({<br>      create = optional(string)<br>      read   = optional(string)<br>      update = optional(string)<br>      delete = optional(string)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | SKU for the Azure AI Search service. | `string` | `"standard"` | no |
| <a name="input_system_managed_identity_enabled"></a> [system\_managed\_identity\_enabled](#input\_system\_managed\_identity\_enabled) | Whether to enable a system-assigned managed identity. Ignored when legacy identity is set. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the Azure AI Search service. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional timeouts for Search service create, read, update, and delete operations. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_use_random_suffix"></a> [use\_random\_suffix](#input\_use\_random\_suffix) | Whether generated Azure AI Search names should include a random suffix. | `bool` | `true` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier used in tagging. | `string` | `"project"` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Optional workload segment used when the Azure AI Search service name is generated. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_admin_group_principal_ids"></a> [app\_admin\_group\_principal\_ids](#output\_app\_admin\_group\_principal\_ids) | Map of resolved app admin group principal IDs. |
| <a name="output_app_admin_group_role_assignment_ids"></a> [app\_admin\_group\_role\_assignment\_ids](#output\_app\_admin\_group\_role\_assignment\_ids) | Contributor role assignment IDs keyed by principal ID. |
| <a name="output_app_env"></a> [app\_env](#output\_app\_env) | The deployment environment used for tags and generated names. |
| <a name="output_app_user_group_principal_ids"></a> [app\_user\_group\_principal\_ids](#output\_app\_user\_group\_principal\_ids) | Map of resolved app user group principal IDs. |
| <a name="output_app_user_group_role_assignment_ids"></a> [app\_user\_group\_role\_assignment\_ids](#output\_app\_user\_group\_role\_assignment\_ids) | Reader role assignment IDs keyed by principal ID. |
| <a name="output_customer_managed_key_encryption_compliance_status"></a> [customer\_managed\_key\_encryption\_compliance\_status](#output\_customer\_managed\_key\_encryption\_compliance\_status) | Customer-managed key encryption compliance status reported by Azure AI Search. |
| <a name="output_customer_managed_key_enforcement_enabled"></a> [customer\_managed\_key\_enforcement\_enabled](#output\_customer\_managed\_key\_enforcement\_enabled) | Whether customer-managed key enforcement is enabled. |
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | Diagnostic setting ID when diagnostics are enabled. |
| <a name="output_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#output\_diagnostic\_setting\_name) | Diagnostic setting name when diagnostics are enabled. |
| <a name="output_diagnostics_enabled"></a> [diagnostics\_enabled](#output\_diagnostics\_enabled) | Boolean flag indicating whether diagnostics are enabled. |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The Azure AI Search endpoint. |
| <a name="output_hosting_mode"></a> [hosting\_mode](#output\_hosting\_mode) | The hosting mode configured on the Azure AI Search service. |
| <a name="output_id"></a> [id](#output\_id) | The Azure AI Search service resource ID. |
| <a name="output_identity"></a> [identity](#output\_identity) | Managed identity details for the Azure AI Search service. |
| <a name="output_identity_type"></a> [identity\_type](#output\_identity\_type) | The managed identity type enabled on the Azure AI Search service. |
| <a name="output_local_authentication_enabled"></a> [local\_authentication\_enabled](#output\_local\_authentication\_enabled) | Whether API-key local authentication is enabled. |
| <a name="output_location"></a> [location](#output\_location) | The Azure region where the Azure AI Search service is deployed. |
| <a name="output_location_code"></a> [location\_code](#output\_location\_code) | The short location code used by generated names. |
| <a name="output_merged_tags"></a> [merged\_tags](#output\_merged\_tags) | Final merged tags applied to the Azure AI Search service. |
| <a name="output_name"></a> [name](#output\_name) | The Azure AI Search service name. |
| <a name="output_partition_count"></a> [partition\_count](#output\_partition\_count) | The partition count configured on the Azure AI Search service. |
| <a name="output_primary_key"></a> [primary\_key](#output\_primary\_key) | The primary admin key. |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | The principal ID of the system-assigned managed identity, when enabled. |
| <a name="output_private_endpoint_fqdns"></a> [private\_endpoint\_fqdns](#output\_private\_endpoint\_fqdns) | Private endpoint FQDNs when private endpoint is enabled. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint ID when private endpoint is enabled. |
| <a name="output_private_endpoint_ip_addresses"></a> [private\_endpoint\_ip\_addresses](#output\_private\_endpoint\_ip\_addresses) | Private endpoint IP addresses when private endpoint is enabled. |
| <a name="output_private_endpoint_name"></a> [private\_endpoint\_name](#output\_private\_endpoint\_name) | Private endpoint name when private endpoint is enabled. |
| <a name="output_public_network_access_enabled"></a> [public\_network\_access\_enabled](#output\_public\_network\_access\_enabled) | Whether public network access is enabled. |
| <a name="output_query_keys"></a> [query\_keys](#output\_query\_keys) | The query keys exposed by the Azure AI Search service. |
| <a name="output_replica_count"></a> [replica\_count](#output\_replica\_count) | The replica count configured on the Azure AI Search service. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name where the Azure AI Search service is deployed. |
| <a name="output_role_assignment_count"></a> [role\_assignment\_count](#output\_role\_assignment\_count) | Total number of role assignments created by this module. |
| <a name="output_role_assignment_ids"></a> [role\_assignment\_ids](#output\_role\_assignment\_ids) | Map of additional role assignment IDs keyed by assignment name. |
| <a name="output_secondary_key"></a> [secondary\_key](#output\_secondary\_key) | The secondary admin key. |
| <a name="output_semantic_search_sku"></a> [semantic\_search\_sku](#output\_semantic\_search\_sku) | The semantic search SKU configured on the Azure AI Search service. |
| <a name="output_shared_private_link_service_ids"></a> [shared\_private\_link\_service\_ids](#output\_shared\_private\_link\_service\_ids) | Map of shared private link resource IDs keyed by input key. |
| <a name="output_shared_private_link_service_statuses"></a> [shared\_private\_link\_service\_statuses](#output\_shared\_private\_link\_service\_statuses) | Map of shared private link resource approval statuses keyed by input key. |
| <a name="output_sku"></a> [sku](#output\_sku) | The Azure AI Search service SKU. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to the Azure AI Search service. |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | The tenant ID of the system-assigned managed identity, when enabled. |
<!-- END_TF_DOCS -->
