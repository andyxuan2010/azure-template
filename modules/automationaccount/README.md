# Azure Automation Account

Provisions an Azure Automation Account with private-by-default access, managed identity, customer-managed encryption, RBAC, diagnostics, runbooks, schedules, job schedules, and typed Automation variables.

## Features

- Disables local authentication and public network access by default.
- Enables system-assigned identity by default and supports user-assigned identities.
- Supports customer-managed key encryption.
- Creates Webhook and DSC/Hybrid Worker private endpoints with optional private DNS association.
- Sends diagnostics to Log Analytics, Storage Account, or Event Hub.
- Supports Entra group and generic Automation Account-scope role assignments.
- Creates runbooks, schedules, job schedules, and string, bool, integer, datetime, or object variables.
- Supports explicit or generated names and inherited resource-group tags.

## Resources Created

The module always creates one Azure Automation Account and can create a random naming suffix. Depending on inputs, it can also create:

- Azure role assignments;
- Webhook and DSC/Hybrid Worker private endpoints and DNS zone groups;
- an Azure Monitor diagnostic setting;
- runbooks, schedules, job schedules, and Automation variables.

Existing resource groups, subnets, private DNS zones, keys, identities, monitoring destinations, and Entra groups are referenced but not managed.

## Prerequisites and Dependencies

- An existing resource group.
- Optional private endpoint subnet and `privatelink.azure-automation.net` private DNS zone.
- Optional Log Analytics, Storage Account, or Event Hub diagnostic destination.
- Optional user-assigned identity and Key Vault key for customer-managed encryption.
- Principals and role definitions for requested RBAC.
- Reviewed, version-pinned runbook source content when using external links.

Read the module [architecture guide](docs/architecture.md) and repository [dependency guide](../../docs/MODULE_USAGE_AND_DEPENDENCIES.md) before enabling production private access or runbook automation.

## Provider Configuration

Configure providers in the calling root:

```hcl
provider "azurerm" {
  features {}
}

provider "azuread" {}
```

Random is configured implicitly by Terraform. AzureAD is used only for group lookups. The Terraform identity needs permissions for the Automation Account and every enabled child resource or role assignment.

## Basic Usage

```hcl
module "automation" {
  source = "./modules/automationaccount"

  resource_group_name = "rg-operations-prod"
  location            = "canadacentral"
  workload_name       = "operations"
  app_env             = "prod"

  local_auth_enabled              = false
  public_access_enabled           = false
  system_managed_identity_enabled = true
}
```

Runnable configurations are available in:

- [`examples/basic`](examples/basic/)
- [`examples/complete`](examples/complete/)
- [`examples/runbooks-and-schedules`](examples/runbooks-and-schedules/)

## Important Behavior and Secure Defaults

- Local authentication and public access are disabled, and system-assigned identity is enabled, by default.
- A private-by-default account is not reachable until private endpoint, DNS, routing, and client access are configured.
- Customer-managed encryption requires an appropriate managed identity and a Key Vault key ID.
- Automation variable values, including encrypted values, remain in Terraform state. Do not use them for secrets unless the backend protection and risk are explicitly accepted.
- Runbook source links should be immutable or cryptographically pinned.
- Job schedule map keys provide Terraform identity; changing them can recreate associations.
- Random generated names are stable in state but differ across new deployments.

## Networking and Private Connectivity

Webhook and DSC/Hybrid Worker endpoints are distinct subresources and can be enabled independently. Prefer a direct `private_endpoint_subnet_id`; name-based lookup inputs remain for compatibility.

Use `privatelink.azure-automation.net`, confirm private DNS visibility from workers and administration paths, and keep public access disabled for production. The module does not configure NSGs, routes, VNet links, or worker connectivity.

## Identity and RBAC

Use system-assigned identity for the normal account lifecycle or user-assigned identity when ownership must be independent. The module can assign roles to the account identity and can create plan-stable principal assignments at the Automation Account scope.

Prefer immutable Entra object IDs, set exactly one role definition name or ID per generic assignment, and keep downstream access scoped to the exact resources a runbook operates.

## Naming and Tagging

Set `name` explicitly or generate it from prefix, workload, environment, location code, instance, and optional random suffix inputs. Disable random suffixes only when deterministic naming and collision handling are deliberate.

Caller tags override inherited resource-group tags. Follow the repository [naming convention](../../docs/NAMING_CONVENTION.md) and [tagging standard](../../docs/TAGGING_STANDARD.md).

## Testing

`tests/unit.tftest.hcl` uses mocked AzureRM, AzureAD, and Random providers with plan-only and expected-failure runs:

```powershell
terraform init -backend=false
terraform validate
terraform test
```

The test does not authenticate to Azure, execute runbooks, or create resources.

## Known Limitations

- The module does not deploy Hybrid Runbook Workers or configure their host connectivity.
- Private DNS VNet links, subnet policies, NSGs, and routes are external dependencies.
- Runbook content execution is not tested by Terraform plan tests.
- Secrets and encrypted Automation variables are visible to Terraform state.
- Region, runtime, PowerShell/Python version, and schedule behavior remain subject to Azure Automation support.

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
| [azurerm_automation_account.azure_automationaccount](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_account) | resource |
| [azurerm_automation_job_schedule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_job_schedule) | resource |
| [azurerm_automation_runbook.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_runbook) | resource |
| [azurerm_automation_schedule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_schedule) | resource |
| [azurerm_automation_variable_bool.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_bool) | resource |
| [azurerm_automation_variable_datetime.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_datetime) | resource |
| [azurerm_automation_variable_int.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_int) | resource |
| [azurerm_automation_variable_object.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_object) | resource |
| [azurerm_automation_variable_string.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_string) | resource |
| [azurerm_monitor_diagnostic_setting.automation_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.pep](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.app_admin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_user_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.managed_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | Microsoft Entra group display names or object IDs granted Contributor on the Automation Account. | `list(string)` | `[]` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used for standard tags and generated naming. | `string` | `"dev"` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | Microsoft Entra group display names or object IDs granted Reader on the Automation Account. | `list(string)` | `[]` | no |
| <a name="input_bool_variables"></a> [bool\_variables](#input\_bool\_variables) | Boolean variables to create in the Automation Account. | <pre>map(object({<br>    name        = string<br>    value       = bool<br>    description = optional(string)<br>    encrypted   = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_datetime_variables"></a> [datetime\_variables](#input\_datetime\_variables) | RFC3339 datetime variables to create in the Automation Account. | <pre>map(object({<br>    name        = string<br>    value       = string<br>    description = optional(string)<br>    encrypted   = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_diagnostic_eventhub_authorization_rule_id"></a> [diagnostic\_eventhub\_authorization\_rule\_id](#input\_diagnostic\_eventhub\_authorization\_rule\_id) | Optional Event Hub authorization rule resource ID for diagnostics. | `string` | `null` | no |
| <a name="input_diagnostic_eventhub_name"></a> [diagnostic\_eventhub\_name](#input\_diagnostic\_eventhub\_name) | Optional Event Hub name for diagnostics when using an Event Hub destination. | `string` | `null` | no |
| <a name="input_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#input\_diagnostic\_log\_categories) | Diagnostic log categories to enable. Use diagnostic\_log\_category\_groups for Azure Monitor category groups such as allLogs. | `list(string)` | <pre>[<br>  "JobLogs",<br>  "JobStreams",<br>  "AuditEvent"<br>]</pre> | no |
| <a name="input_diagnostic_log_category_groups"></a> [diagnostic\_log\_category\_groups](#input\_diagnostic\_log\_category\_groups) | Diagnostic log category groups to enable, for example allLogs. | `list(string)` | `[]` | no |
| <a name="input_diagnostic_metric_categories"></a> [diagnostic\_metric\_categories](#input\_diagnostic\_metric\_categories) | Diagnostic metric categories to enable. | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| <a name="input_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#input\_diagnostic\_setting\_name) | Optional diagnostic setting name. When empty, the module uses <automation-account-name>-diagnostic-setting. | `string` | `""` | no |
| <a name="input_diagnostic_storage_account_id"></a> [diagnostic\_storage\_account\_id](#input\_diagnostic\_storage\_account\_id) | Optional Storage Account resource ID for diagnostic archive. | `string` | `null` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Enable diagnostic settings for the Automation Account. Diagnostics are also enabled when at least one diagnostic destination is supplied. | `bool` | `false` | no |
| <a name="input_enable_hrw_private_endpoint"></a> [enable\_hrw\_private\_endpoint](#input\_enable\_hrw\_private\_endpoint) | When set, explicitly controls creation of the DSCAndHybridWorker private endpoint. Leave null to use the legacy private\_endpoint\_subresource\_name behavior. | `bool` | `null` | no |
| <a name="input_enable_webhook_private_endpoint"></a> [enable\_webhook\_private\_endpoint](#input\_enable\_webhook\_private\_endpoint) | When set, explicitly controls creation of the Webhook private endpoint. Leave null to use the legacy private\_endpoint\_subresource\_name behavior. | `bool` | `null` | no |
| <a name="input_encryption"></a> [encryption](#input\_encryption) | Optional customer-managed key configuration for Automation Account encryption. | <pre>object({<br>    key_vault_key_id          = string<br>    user_assigned_identity_id = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | User-assigned managed identity IDs to attach to the Automation Account. | `list(string)` | `[]` | no |
| <a name="input_include_environment_in_name"></a> [include\_environment\_in\_name](#input\_include\_environment\_in\_name) | Whether generated Automation Account names include app\_env. | `bool` | `true` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into module resources. The module only reads the resource group when this is true or location is empty. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Optional instance segment used when generated names do not use a random suffix. | `string` | `"001"` | no |
| <a name="input_int_variables"></a> [int\_variables](#input\_int\_variables) | Integer variables to create in the Automation Account. | <pre>map(object({<br>    name        = string<br>    value       = number<br>    description = optional(string)<br>    encrypted   = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_job_schedules"></a> [job\_schedules](#input\_job\_schedules) | Links between Automation Runbooks and schedules, keyed by a stable name. runbook\_name and schedule\_name may reference resources created by this module by map key or by actual name. | <pre>map(object({<br>    runbook_name  = string<br>    schedule_name = string<br>    parameters    = optional(map(string), {})<br>    run_on        = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_local_auth_enabled"></a> [local\_auth\_enabled](#input\_local\_auth\_enabled) | Whether to allow non-Entra local authentication for the Automation Account. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where to deploy the resource. If empty, the resource group's location is used. | `string` | `""` | no |
| <a name="input_location_code"></a> [location\_code](#input\_location\_code) | Optional short location code used when the Automation Account name is generated. | `string` | `""` | no |
| <a name="input_log_analytics_destination_type"></a> [log\_analytics\_destination\_type](#input\_log\_analytics\_destination\_type) | Destination type for Log Analytics diagnostics. | `string` | `"Dedicated"` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Optional Log Analytics workspace resource ID for diagnostics. | `string` | `""` | no |
| <a name="input_managed_identity_role_assignments"></a> [managed\_identity\_role\_assignments](#input\_managed\_identity\_role\_assignments) | Role assignments to apply to the Automation Account system-assigned managed identity. Each entry must include scope and exactly one of role\_definition\_name or role\_definition\_id. | <pre>map(object({<br>    scope                = string<br>    role_definition_name = optional(string)<br>    role_definition_id   = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Automation Account name. If empty, the module auto-generates a compliant name. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used when the Automation Account name is generated. | `string` | `"aa"` | no |
| <a name="input_object_variables"></a> [object\_variables](#input\_object\_variables) | Object variables to create in the Automation Account. Value must be a JSON-encoded string, for example jsonencode({ key = "value" }). | <pre>map(object({<br>    name        = string<br>    value       = string<br>    description = optional(string)<br>    encrypted   = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_pep_vnet_name"></a> [pep\_vnet\_name](#input\_pep\_vnet\_name) | Legacy input: VNet name for private endpoint subnet lookup. Prefer private\_endpoint\_vnet\_name. | `string` | `""` | no |
| <a name="input_pep_vnet_resource_group_name"></a> [pep\_vnet\_resource\_group\_name](#input\_pep\_vnet\_resource\_group\_name) | Legacy input: VNet resource group for private endpoint subnet lookup. Prefer private\_endpoint\_network\_resource\_group\_name. | `string` | `""` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Optional private DNS zone resource ID to link to created private endpoints. | `string` | `""` | no |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | Optional private DNS zone name to look up and link to created private endpoints when private\_dns\_zone\_id is not set. For Azure Automation, use privatelink.azure-automation.net. | `string` | `""` | no |
| <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name) | Resource group containing private\_dns\_zone\_name when using private DNS zone lookup. | `string` | `""` | no |
| <a name="input_private_endpoint_name_prefix"></a> [private\_endpoint\_name\_prefix](#input\_private\_endpoint\_name\_prefix) | Prefix used for generated private endpoint names. | `string` | `"pep"` | no |
| <a name="input_private_endpoint_network_resource_group_name"></a> [private\_endpoint\_network\_resource\_group\_name](#input\_private\_endpoint\_network\_resource\_group\_name) | Resource group name of the VNet containing private\_endpoint\_subnet\_name when private\_endpoint\_subnet\_id is not set. | `string` | `null` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | Subnet ID for the private endpoint. If set, subnet name/VNet/RG lookup is skipped. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#input\_private\_endpoint\_subnet\_name) | Name of the existing subnet for private endpoint lookup when private\_endpoint\_subnet\_id is not set. | `string` | `null` | no |
| <a name="input_private_endpoint_subresource_name"></a> [private\_endpoint\_subresource\_name](#input\_private\_endpoint\_subresource\_name) | Automation Account private endpoint subresource to connect. Valid values are Webhook or DSCAndHybridWorker. The legacy value DscAndHybridWorker is also accepted and normalized. | `string` | `"Webhook"` | no |
| <a name="input_private_endpoint_vnet_exceptions"></a> [private\_endpoint\_vnet\_exceptions](#input\_private\_endpoint\_vnet\_exceptions) | Legacy behavior only: list of VNet names that should default to PrivateEndpoint2 instead of PrivateEndpoint when private\_endpoint\_subnet\_name is not provided. | `list(string)` | <pre>[<br>  "dv1vnt001"<br>]</pre> | no |
| <a name="input_private_endpoint_vnet_name"></a> [private\_endpoint\_vnet\_name](#input\_private\_endpoint\_vnet\_name) | Name of the VNet containing private\_endpoint\_subnet\_name when private\_endpoint\_subnet\_id is not set. | `string` | `null` | no |
| <a name="input_private_service_connection_name_prefix"></a> [private\_service\_connection\_name\_prefix](#input\_private\_service\_connection\_name\_prefix) | Prefix used for generated private service connection names. | `string` | `"psc"` | no |
| <a name="input_public_access_enabled"></a> [public\_access\_enabled](#input\_public\_access\_enabled) | Whether the Automation Account public endpoint can be reached from the Internet. | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the Automation Account will be deployed. | `string` | n/a | yes |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | Additional role assignments to create at the Automation Account scope, keyed by a stable name. | <pre>map(object({<br>    principal_id                           = string<br>    role_definition_name                   = optional(string)<br>    role_definition_id                     = optional(string)<br>    principal_type                         = optional(string)<br>    description                            = optional(string)<br>    name                                   = optional(string)<br>    condition                              = optional(string)<br>    condition_version                      = optional(string)<br>    delegated_managed_identity_resource_id = optional(string)<br>    skip_service_principal_aad_check       = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_runbooks"></a> [runbooks](#input\_runbooks) | Automation Runbooks to create, keyed by a stable name. Use publish\_content\_link for content hosted externally or content for inline runbook text. | <pre>map(object({<br>    name                     = string<br>    runbook_type             = string<br>    log_verbose              = optional(bool, false)<br>    log_progress             = optional(bool, false)<br>    description              = optional(string)<br>    content                  = optional(string)<br>    runtime_environment_name = optional(string)<br>    log_activity_trace_level = optional(number)<br>    tags                     = optional(map(string), {})<br>    publish_content_link = optional(object({<br>      uri     = string<br>      version = optional(string)<br>      hash = optional(object({<br>        algorithm = string<br>        value     = string<br>      }))<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_schedules"></a> [schedules](#input\_schedules) | Automation schedules to create, keyed by a stable name. | <pre>map(object({<br>    name        = string<br>    frequency   = string<br>    description = optional(string)<br>    interval    = optional(number)<br>    start_time  = optional(string)<br>    expiry_time = optional(string)<br>    timezone    = optional(string)<br>    week_days   = optional(list(string))<br>    month_days  = optional(list(number))<br>    monthly_occurrences = optional(list(object({<br>      day        = string<br>      occurrence = number<br>    })), [])<br>  }))</pre> | `{}` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU name of the Automation Account. | `string` | `"Basic"` | no |
| <a name="input_string_variables"></a> [string\_variables](#input\_string\_variables) | String variables to create in the Automation Account. Values are stored in Terraform state even when encrypted in Azure. | <pre>map(object({<br>    name        = string<br>    value       = string<br>    description = optional(string)<br>    encrypted   = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_system_managed_identity_enabled"></a> [system\_managed\_identity\_enabled](#input\_system\_managed\_identity\_enabled) | Whether to enable a system-assigned managed identity for the Automation Account. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to module resources. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional timeouts for Automation Account create, read, update, and delete operations. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_use_random_suffix"></a> [use\_random\_suffix](#input\_use\_random\_suffix) | Whether generated Automation Account names should include a random suffix. | `bool` | `true` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier used in tagging. | `string` | `"project"` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Optional workload segment used when the Automation Account name is generated. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_admin_group_principal_ids"></a> [app\_admin\_group\_principal\_ids](#output\_app\_admin\_group\_principal\_ids) | Map of resolved app admin group principal IDs. |
| <a name="output_app_admin_group_role_assignment_ids"></a> [app\_admin\_group\_role\_assignment\_ids](#output\_app\_admin\_group\_role\_assignment\_ids) | Map of Contributor role assignment IDs keyed by app\_admin\_group principal ID. |
| <a name="output_app_env"></a> [app\_env](#output\_app\_env) | The deployment environment used for tags and generated names. |
| <a name="output_app_user_group_principal_ids"></a> [app\_user\_group\_principal\_ids](#output\_app\_user\_group\_principal\_ids) | Map of resolved app user group principal IDs. |
| <a name="output_app_user_group_role_assignment_ids"></a> [app\_user\_group\_role\_assignment\_ids](#output\_app\_user\_group\_role\_assignment\_ids) | Map of Reader role assignment IDs keyed by app\_user\_group principal ID. |
| <a name="output_automation_variable_ids"></a> [automation\_variable\_ids](#output\_automation\_variable\_ids) | Automation variable IDs grouped by variable type. |
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | The ID of the diagnostic setting, if created. |
| <a name="output_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#output\_diagnostic\_setting\_name) | The diagnostic setting name when diagnostics are enabled. |
| <a name="output_diagnostics_enabled"></a> [diagnostics\_enabled](#output\_diagnostics\_enabled) | Whether the module creates a diagnostic setting. |
| <a name="output_dsc_server_endpoint"></a> [dsc\_server\_endpoint](#output\_dsc\_server\_endpoint) | The DSC server endpoint associated with the Automation Account. |
| <a name="output_hybrid_service_url"></a> [hybrid\_service\_url](#output\_hybrid\_service\_url) | The hybrid service URL used for hybrid worker onboarding. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Automation Account. |
| <a name="output_identity"></a> [identity](#output\_identity) | The identity block of the Automation Account. |
| <a name="output_identity_type"></a> [identity\_type](#output\_identity\_type) | The managed identity type enabled on the Automation Account. |
| <a name="output_job_schedule_ids"></a> [job\_schedule\_ids](#output\_job\_schedule\_ids) | Map of Automation Job Schedule IDs keyed by job schedule key. |
| <a name="output_local_authentication_enabled"></a> [local\_authentication\_enabled](#output\_local\_authentication\_enabled) | Whether local authentication is enabled for the Automation Account. |
| <a name="output_location"></a> [location](#output\_location) | The location of the Automation Account. |
| <a name="output_location_code"></a> [location\_code](#output\_location\_code) | The short location code used by generated names. |
| <a name="output_managed_identity_role_assignment_ids"></a> [managed\_identity\_role\_assignment\_ids](#output\_managed\_identity\_role\_assignment\_ids) | Map of managed identity role assignment IDs keyed by assignment name. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Automation Account. |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | The principal ID of the system-assigned managed identity, when enabled. |
| <a name="output_private_dns_zone_id"></a> [private\_dns\_zone\_id](#output\_private\_dns\_zone\_id) | Resolved private DNS zone ID linked to private endpoints, if configured. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | The ID of a private endpoint when exactly one exists, otherwise the legacy/default endpoint if present. |
| <a name="output_private_endpoint_ids"></a> [private\_endpoint\_ids](#output\_private\_endpoint\_ids) | Map of private endpoint IDs keyed by endpoint selector. |
| <a name="output_private_endpoint_name"></a> [private\_endpoint\_name](#output\_private\_endpoint\_name) | The name of a private endpoint when exactly one exists, otherwise the legacy/default endpoint if present. |
| <a name="output_private_endpoint_names"></a> [private\_endpoint\_names](#output\_private\_endpoint\_names) | Map of private endpoint names keyed by endpoint selector. |
| <a name="output_public_network_access_enabled"></a> [public\_network\_access\_enabled](#output\_public\_network\_access\_enabled) | Whether public network access is enabled for the Automation Account. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group containing the Automation Account. |
| <a name="output_role_assignment_count"></a> [role\_assignment\_count](#output\_role\_assignment\_count) | Total number of role assignments created by this module. |
| <a name="output_role_assignment_ids"></a> [role\_assignment\_ids](#output\_role\_assignment\_ids) | Map of additional role assignment IDs keyed by assignment name. |
| <a name="output_runbook_ids"></a> [runbook\_ids](#output\_runbook\_ids) | Map of Automation Runbook IDs keyed by runbook key. |
| <a name="output_runbook_names"></a> [runbook\_names](#output\_runbook\_names) | Map of Automation Runbook names keyed by runbook key. |
| <a name="output_schedule_ids"></a> [schedule\_ids](#output\_schedule\_ids) | Map of Automation Schedule IDs keyed by schedule key. |
| <a name="output_schedule_names"></a> [schedule\_names](#output\_schedule\_names) | Map of Automation Schedule names keyed by schedule key. |
| <a name="output_sku_name"></a> [sku\_name](#output\_sku\_name) | The SKU name of the Automation Account. |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags assigned to the Automation Account. |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | The tenant ID of the system-assigned managed identity, when enabled. |
<!-- END_TF_DOCS -->
