# Azure App Service Plan

Provisions Linux, Windows, or Windows Container App Service hosting capacity with optional zone balancing, platform-managed scaling, Azure Monitor autoscale, diagnostics, and Microsoft Entra group RBAC.

## Features

- Supports Linux, Windows, and Windows Container service plans.
- Supports App Service Environment placement and Elastic Premium worker limits.
- Supports availability-zone balancing on compatible Premium SKUs.
- Supports Premium plan automatic scale or Azure Monitor metric-based autoscale.
- Configures CPU, memory, custom metric, scheduled, predictive, email, and webhook autoscale behavior.
- Sends diagnostics to Log Analytics, Storage Account, or Event Hub.
- Assigns Contributor and Reader access to Microsoft Entra groups.
- Merges inherited resource-group tags with caller tags.

## Resources Created

The module always creates one Azure App Service Plan. Depending on inputs, it can also create:

- one Azure Monitor autoscale setting;
- one Azure Monitor diagnostic setting;
- Contributor and Reader role assignments for Entra groups.

The resource group and optional Entra groups and monitoring destinations are looked up but not managed.

## Prerequisites and Dependencies

- An existing resource group.
- A supported region and sufficient quota for the selected SKU and worker count.
- Optional App Service Environment.
- Optional Log Analytics, Storage Account, or Event Hub diagnostic destination.
- Optional Entra groups for plan-scope RBAC.
- Downstream Web Apps or Function Apps whose operating system and capabilities match the plan.

See the repository [module dependency guide](../../docs/MODULE_USAGE_AND_DEPENDENCIES.md) before composing workload modules.

## Provider Configuration

Configure AzureRM and AzureAD in the calling root:

```hcl
provider "azurerm" {
  features {}
}

provider "azuread" {}
```

AzureAD is used only when group RBAC inputs are non-empty.

## Basic Usage

```hcl
module "appserviceplan" {
  source = "./modules/appserviceplan"

  name                = "asp-orders-dev"
  resource_group_name = "rg-orders-dev"
  location            = "canadacentral"
  os_type             = "Linux"
  sku_name            = "B1"
}
```

Runnable configurations are available in:

- [`examples/basic`](examples/basic/)
- [`examples/complete`](examples/complete/)
- [`examples/autoscale`](examples/autoscale/)

## Important Behavior and Secure Defaults

- `sku_name` is required because capacity, cost, and supported features are workload decisions.
- Plan operating system must match every attached Web App or Function App.
- Azure Monitor autoscale and Premium plan automatic scale are mutually exclusive.
- When Azure Monitor autoscale is enabled, keep `worker_count = 1`; the autoscale profile controls capacity.
- Zone balancing requires a compatible Premium SKU and at least three workers.
- Autoscale thresholds, schedules, and predictive behavior can materially affect cost and capacity.
- App Service Environment placement and SKU changes can be replacement-sensitive or restricted by Azure.

## Networking and Private Connectivity

The App Service Plan itself does not create VNet integration or private endpoints. Those controls belong to the hosted application modules. An App Service Environment can supply isolated network hosting through `app_service_environment_id`.

Plan subnet capacity and regional support in the workload modules before selecting a SKU or scaling range.

## Identity and RBAC

The plan does not own a managed identity. Optional group RBAC assigns Contributor or Reader at the plan scope. Prefer immutable Entra object IDs and grant application identities access at the narrow downstream-resource scope instead.

## Naming and Tagging

Set `name` explicitly or let the module generate one from workload, environment, and instance inputs. Caller tags override inherited resource-group tags.

Follow the repository [naming convention](../../docs/NAMING_CONVENTION.md) and [tagging standard](../../docs/TAGGING_STANDARD.md).

## Testing

`tests/unit.tftest.hcl` uses mocked AzureRM and AzureAD providers with plan-only runs:

```powershell
terraform init -backend=false
terraform validate
terraform test
```

The test does not authenticate to Azure or create billable plans.

## Known Limitations

- The module creates hosting capacity only; it does not create Web Apps, Function Apps, private endpoints, or VNet integration.
- SKU capabilities, zone support, worker limits, and autoscale behavior vary by region.
- Azure Monitor autoscale custom metrics must already exist and be emitted consistently.
- Plan-scope Contributor can be broader than application teams need; use a narrower role when possible.

## Terraform Reference

The content below is generated from the module source. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 3.0, < 4.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >= 3.0, < 4.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, < 5.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_autoscale_setting.app_service_plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_autoscale_setting) | resource |
| [azurerm_monitor_diagnostic_setting.app_service_plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_role_assignment.app_admin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_user_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_service_plan.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | List of Microsoft Entra group display names or object IDs that should receive Contributor access to the App Service Plan. | `list(string)` | `[]` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment. | `string` | `"dev"` | no |
| <a name="input_app_service_environment_id"></a> [app\_service\_environment\_id](#input\_app\_service\_environment\_id) | The ID of the App Service Environment to create this Service Plan in. | `string` | `null` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | List of Microsoft Entra group display names or object IDs that should receive Reader access to the App Service Plan. | `list(string)` | `[]` | no |
| <a name="input_autoscale_cpu_threshold_scale_down"></a> [autoscale\_cpu\_threshold\_scale\_down](#input\_autoscale\_cpu\_threshold\_scale\_down) | CPU percentage threshold to scale down (0-100) | `number` | `25` | no |
| <a name="input_autoscale_cpu_threshold_scale_up"></a> [autoscale\_cpu\_threshold\_scale\_up](#input\_autoscale\_cpu\_threshold\_scale\_up) | CPU percentage threshold to scale up (0-100) | `number` | `75` | no |
| <a name="input_autoscale_custom_rules"></a> [autoscale\_custom\_rules](#input\_autoscale\_custom\_rules) | Additional autoscale rules to add to the default profile. | <pre>list(object({<br>    metric_name              = string<br>    metric_namespace         = optional(string)<br>    operator                 = string<br>    threshold                = number<br>    statistic                = optional(string, "Average")<br>    time_aggregation         = optional(string, "Average")<br>    time_grain               = optional(string, "PT1M")<br>    time_window              = optional(string, "PT5M")<br>    divide_by_instance_count = optional(bool, false)<br>    direction                = string<br>    type                     = optional(string, "ChangeCount")<br>    value                    = number<br>    cooldown                 = optional(string, "PT5M")<br>    dimensions = optional(list(object({<br>      name     = string<br>      operator = string<br>      values   = list(string)<br>    })), [])<br>  }))</pre> | `[]` | no |
| <a name="input_autoscale_default_capacity"></a> [autoscale\_default\_capacity](#input\_autoscale\_default\_capacity) | Default number of instances for autoscale | `number` | `1` | no |
| <a name="input_autoscale_enabled"></a> [autoscale\_enabled](#input\_autoscale\_enabled) | Whether the autoscale setting is enabled after creation. | `bool` | `true` | no |
| <a name="input_autoscale_fixed_date"></a> [autoscale\_fixed\_date](#input\_autoscale\_fixed\_date) | Optional fixed date schedule for the autoscale profile. | <pre>object({<br>    timezone = optional(string)<br>    start    = string<br>    end      = string<br>  })</pre> | `null` | no |
| <a name="input_autoscale_max_capacity"></a> [autoscale\_max\_capacity](#input\_autoscale\_max\_capacity) | Maximum number of instances for autoscale | `number` | `3` | no |
| <a name="input_autoscale_memory_threshold_scale_down"></a> [autoscale\_memory\_threshold\_scale\_down](#input\_autoscale\_memory\_threshold\_scale\_down) | Memory percentage threshold to scale down (0-100) | `number` | `40` | no |
| <a name="input_autoscale_memory_threshold_scale_up"></a> [autoscale\_memory\_threshold\_scale\_up](#input\_autoscale\_memory\_threshold\_scale\_up) | Memory percentage threshold to scale up (0-100) | `number` | `80` | no |
| <a name="input_autoscale_metric_time_grain"></a> [autoscale\_metric\_time\_grain](#input\_autoscale\_metric\_time\_grain) | Time grain used by default autoscale metric triggers. | `string` | `"PT1M"` | no |
| <a name="input_autoscale_metric_time_window"></a> [autoscale\_metric\_time\_window](#input\_autoscale\_metric\_time\_window) | Time window used by default autoscale metric triggers. | `string` | `"PT5M"` | no |
| <a name="input_autoscale_min_capacity"></a> [autoscale\_min\_capacity](#input\_autoscale\_min\_capacity) | Minimum number of instances for autoscale | `number` | `1` | no |
| <a name="input_autoscale_notifications"></a> [autoscale\_notifications](#input\_autoscale\_notifications) | Optional autoscale email and webhook notifications. | <pre>object({<br>    email = optional(object({<br>      send_to_subscription_administrator    = optional(bool, false)<br>      send_to_subscription_co_administrator = optional(bool, false)<br>      custom_emails                         = optional(list(string), [])<br>    }))<br>    webhooks = optional(list(object({<br>      service_uri = string<br>      properties  = optional(map(string), {})<br>    })), [])<br>  })</pre> | `null` | no |
| <a name="input_autoscale_predictive"></a> [autoscale\_predictive](#input\_autoscale\_predictive) | Optional predictive autoscale configuration. | <pre>object({<br>    scale_mode      = string<br>    look_ahead_time = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_autoscale_profile_name"></a> [autoscale\_profile\_name](#input\_autoscale\_profile\_name) | Name of the default autoscale profile. | `string` | `"default"` | no |
| <a name="input_autoscale_recurrence"></a> [autoscale\_recurrence](#input\_autoscale\_recurrence) | Optional recurrence schedule for the autoscale profile. | <pre>object({<br>    timezone = optional(string)<br>    days     = list(string)<br>    hours    = list(number)<br>    minutes  = list(number)<br>  })</pre> | `null` | no |
| <a name="input_autoscale_scale_down_cooldown"></a> [autoscale\_scale\_down\_cooldown](#input\_autoscale\_scale\_down\_cooldown) | Cooldown used by scale-down actions. | `string` | `"PT5M"` | no |
| <a name="input_autoscale_scale_down_increment"></a> [autoscale\_scale\_down\_increment](#input\_autoscale\_scale\_down\_increment) | Number of instances to remove when scaling down | `number` | `1` | no |
| <a name="input_autoscale_scale_up_cooldown"></a> [autoscale\_scale\_up\_cooldown](#input\_autoscale\_scale\_up\_cooldown) | Cooldown used by scale-up actions. | `string` | `"PT5M"` | no |
| <a name="input_autoscale_scale_up_increment"></a> [autoscale\_scale\_up\_increment](#input\_autoscale\_scale\_up\_increment) | Number of instances to add when scaling up | `number` | `1` | no |
| <a name="input_diagnostic_eventhub_authorization_rule_id"></a> [diagnostic\_eventhub\_authorization\_rule\_id](#input\_diagnostic\_eventhub\_authorization\_rule\_id) | Optional Event Hub authorization rule resource ID for diagnostic settings. | `string` | `null` | no |
| <a name="input_diagnostic_eventhub_name"></a> [diagnostic\_eventhub\_name](#input\_diagnostic\_eventhub\_name) | Optional Event Hub name for diagnostic settings when using an Event Hub destination. | `string` | `null` | no |
| <a name="input_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#input\_diagnostic\_log\_categories) | List of log categories to enable for diagnostics | `list(string)` | `[]` | no |
| <a name="input_diagnostic_metrics"></a> [diagnostic\_metrics](#input\_diagnostic\_metrics) | List of metrics to enable for diagnostics | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| <a name="input_diagnostic_storage_account_id"></a> [diagnostic\_storage\_account\_id](#input\_diagnostic\_storage\_account\_id) | Optional Storage Account resource ID for diagnostic settings. | `string` | `null` | no |
| <a name="input_enable_autoscale"></a> [enable\_autoscale](#input\_enable\_autoscale) | Enable autoscale settings for the App Service Plan | `bool` | `false` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Enable diagnostics for the App Service Plan | `bool` | `false` | no |
| <a name="input_enable_memory_autoscale"></a> [enable\_memory\_autoscale](#input\_enable\_memory\_autoscale) | Enable autoscale based on memory percentage | `bool` | `false` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into App Service Plan resources. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance identifier used when name is not provided. | `string` | `"001"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region. If empty, the resource group's location is used. | `string` | `""` | no |
| <a name="input_log_analytics_destination_type"></a> [log\_analytics\_destination\_type](#input\_log\_analytics\_destination\_type) | Log Analytics destination type for diagnostics. | `string` | `"Dedicated"` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics Workspace ID for diagnostics | `string` | `null` | no |
| <a name="input_maximum_elastic_worker_count"></a> [maximum\_elastic\_worker\_count](#input\_maximum\_elastic\_worker\_count) | The maximum number of workers to use in an Elastic SKU Plan. | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Optional App Service Plan name override. Leave empty to generate one from the naming convention. | `string` | `""` | no |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | OS type for the App Service Plan. Possible values: Windows, Linux, WindowsContainer | `string` | `"Linux"` | no |
| <a name="input_per_site_scaling_enabled"></a> [per\_site\_scaling\_enabled](#input\_per\_site\_scaling\_enabled) | Enable per site scaling | `bool` | `false` | no |
| <a name="input_premium_plan_auto_scale_enabled"></a> [premium\_plan\_auto\_scale\_enabled](#input\_premium\_plan\_auto\_scale\_enabled) | Enable automatic scale for Premium plans that support platform-managed automatic scaling. | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group where the App Service Plan will be created | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU name for the App Service Plan (e.g., B1, S1, P1v3, EP1) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the App Service Plan | `map(string)` | `{}` | no |
| <a name="input_worker_count"></a> [worker\_count](#input\_worker\_count) | Number of workers. Should be set to 1 when autoscaling is enabled to avoid conflicts. | `number` | `1` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Deprecated compatibility input. Supply workload tags explicitly through tags. | `string` | `"project"` | no |
| <a name="input_zone_balancing_enabled"></a> [zone\_balancing\_enabled](#input\_zone\_balancing\_enabled) | Enable zone balancing | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_admin_group_role_assignment_ids"></a> [app\_admin\_group\_role\_assignment\_ids](#output\_app\_admin\_group\_role\_assignment\_ids) | Map of Contributor role assignment IDs keyed by app\_admin\_group principal ID. |
| <a name="output_app_user_group_role_assignment_ids"></a> [app\_user\_group\_role\_assignment\_ids](#output\_app\_user\_group\_role\_assignment\_ids) | Map of Reader role assignment IDs keyed by app\_user\_group principal ID. |
| <a name="output_autoscale_config"></a> [autoscale\_config](#output\_autoscale\_config) | Autoscale configuration details |
| <a name="output_autoscale_setting_id"></a> [autoscale\_setting\_id](#output\_autoscale\_setting\_id) | ID of the autoscale setting |
| <a name="output_autoscale_setting_name"></a> [autoscale\_setting\_name](#output\_autoscale\_setting\_name) | Name of the autoscale setting |
| <a name="output_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#output\_diagnostic\_log\_categories) | Effective diagnostic log categories enabled for the App Service Plan. |
| <a name="output_diagnostic_metric_categories"></a> [diagnostic\_metric\_categories](#output\_diagnostic\_metric\_categories) | Diagnostic metric categories configured for the App Service Plan. |
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | ID of the diagnostic setting |
| <a name="output_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#output\_diagnostic\_setting\_name) | Name of the diagnostic setting |
| <a name="output_id"></a> [id](#output\_id) | ID of the App Service Plan |
| <a name="output_location"></a> [location](#output\_location) | Location of the App Service Plan |
| <a name="output_maximum_elastic_worker_count"></a> [maximum\_elastic\_worker\_count](#output\_maximum\_elastic\_worker\_count) | Maximum elastic worker count configured on the App Service Plan. |
| <a name="output_name"></a> [name](#output\_name) | Name of the App Service Plan |
| <a name="output_os_type"></a> [os\_type](#output\_os\_type) | OS type of the App Service Plan |
| <a name="output_per_site_scaling_enabled"></a> [per\_site\_scaling\_enabled](#output\_per\_site\_scaling\_enabled) | Whether per-site scaling is enabled. |
| <a name="output_premium_plan_auto_scale_enabled"></a> [premium\_plan\_auto\_scale\_enabled](#output\_premium\_plan\_auto\_scale\_enabled) | Whether Premium plan automatic scale is enabled. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group name of the App Service Plan |
| <a name="output_sku_name"></a> [sku\_name](#output\_sku\_name) | SKU of the App Service Plan |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to resources. |
| <a name="output_worker_count"></a> [worker\_count](#output\_worker\_count) | Worker count configured on the App Service Plan. |
| <a name="output_zone_balancing_enabled"></a> [zone\_balancing\_enabled](#output\_zone\_balancing\_enabled) | Whether zone balancing is enabled. |
<!-- END_TF_DOCS -->
