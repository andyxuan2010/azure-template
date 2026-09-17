# Azure Log Analytics Workspace

Provisions an Azure Log Analytics workspace with retention, quota, authentication, network-access, commitment-tier, identity, query-governance, timeout, and tagging controls.

## Features

- Configures workspace SKU, retention, and daily ingestion quota.
- Supports capacity-reservation commitment tiers.
- Controls public ingestion and query access independently.
- Can disable local/shared-key authentication.
- Supports system-assigned or user-assigned managed identity.
- Supports a default Data Collection Rule and resource-context query authorization.
- Supports customer-managed-key enforcement for queries and custom resource timeouts.
- Inherits resource-group tags and lets caller tags take precedence.

## Resources Created

The module creates one Log Analytics workspace. The resource group, Data Collection Rule, Azure Monitor Private Link Scope, data sources, diagnostic settings, and customer-managed key infrastructure are caller-managed dependencies.

## Prerequisites and Dependencies

- Terraform 1.6 or newer.
- Existing resource group.
- Optional existing Data Collection Rule.
- A planned ingestion, query, private-link, retention, and cost-control design.

## Provider Configuration

Configure AzureRM in the calling root module:

```hcl
provider "azurerm" {
  features {}
}
```

## Basic Usage

```hcl
module "log_analytics" {
  source = "./modules/loganalytics"

  name                = "law-orders-prod"
  resource_group_name = "rg-orders-prod"
  location            = "canadacentral"

  retention_in_days             = 90
  local_authentication_disabled = true
}
```

Runnable configurations are available in:

- [`examples/basic`](examples/basic/)
- [`examples/governed`](examples/governed/)

## Important Behavior and Secure Defaults

- Internet ingestion and query access are enabled by default for compatibility. Private deployments should disable them only after Azure Monitor Private Link Scope and data collection paths are ready.
- Local authentication is enabled by default for compatibility. Prefer Microsoft Entra authentication and set `local_authentication_disabled = true` where all clients support it.
- The primary and secondary shared-key outputs are sensitive but still stored in Terraform state. Avoid consuming them unless a legacy integration requires them.
- A daily quota can stop ingestion after the threshold and create monitoring gaps; alert on quota usage.
- Retention, immediate purge, capacity reservation, and customer-managed-key choices can have cost, compliance, or reversibility implications.

## Networking and Data Collection

This module controls whether public ingestion and query endpoints are enabled, but it does not create an Azure Monitor Private Link Scope, private endpoint, DNS records, Data Collection Endpoint, or agent associations.

Disabling public access before private collection and query paths are operational can interrupt telemetry and investigations.

## Identity and Access

Managed identity can support integrations that require a workspace identity. The module does not create RBAC assignments. Grant data readers, contributors, and monitoring publishers outside this module using least privilege.

## Naming and Tagging

Set an explicit Azure-valid workspace name. Caller tags override inherited resource-group tags.

Follow the repository [naming convention](../../docs/NAMING_CONVENTION.md) and [tagging standard](../../docs/TAGGING_STANDARD.md).

## Testing

`tests/unit.tftest.hcl` uses a mocked AzureRM provider with plan-only runs:

```powershell
terraform init -backend=false
terraform validate
terraform test
```

No Azure resources are deployed by these tests.

## Known Limitations

- The module creates only the workspace, not Data Collection Rules, diagnostic settings, solutions, tables, saved searches, alerts, or private-link infrastructure.
- Capacity-reservation values and SKU availability are constrained by Azure and may change by region.
- Plan-only tests cannot verify ingestion, query, private DNS, or Azure Monitor agent behavior.

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
| [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_resource_only_permissions"></a> [allow\_resource\_only\_permissions](#input\_allow\_resource\_only\_permissions) | Whether resource-context queries can be authorized using resource permissions. | `bool` | `true` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment retained for naming and policy compatibility. | `string` | `"dev"` | no |
| <a name="input_cmk_for_query_forced"></a> [cmk\_for\_query\_forced](#input\_cmk\_for\_query\_forced) | Whether queries must use customer-managed keys. | `bool` | `false` | no |
| <a name="input_daily_quota_gb"></a> [daily\_quota\_gb](#input\_daily\_quota\_gb) | Workspace daily ingestion quota in GB. Use -1 for unlimited. | `number` | `-1` | no |
| <a name="input_data_collection_rule_id"></a> [data\_collection\_rule\_id](#input\_data\_collection\_rule\_id) | Optional default Data Collection Rule resource ID. | `string` | `null` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Optional managed identity configuration. | <pre>object({<br>    type         = string<br>    identity_ids = optional(list(string))<br>  })</pre> | `null` | no |
| <a name="input_immediate_data_purge_on_30_days_enabled"></a> [immediate\_data\_purge\_on\_30\_days\_enabled](#input\_immediate\_data\_purge\_on\_30\_days\_enabled) | Whether data is immediately purged after 30 days when retention is 30 days. | `bool` | `false` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into Log Analytics resources. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance identifier used when name is not provided. | `string` | `"001"` | no |
| <a name="input_internet_ingestion_enabled"></a> [internet\_ingestion\_enabled](#input\_internet\_ingestion\_enabled) | Whether public ingestion is enabled. | `bool` | `true` | no |
| <a name="input_internet_query_enabled"></a> [internet\_query\_enabled](#input\_internet\_query\_enabled) | Whether public query is enabled. | `bool` | `true` | no |
| <a name="input_local_authentication_disabled"></a> [local\_authentication\_disabled](#input\_local\_authentication\_disabled) | Whether local auth is disabled. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the workspace. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Optional Log Analytics workspace name override. Leave empty to generate one from the naming convention. | `string` | `""` | no |
| <a name="input_reservation_capacity_in_gb_per_day"></a> [reservation\_capacity\_in\_gb\_per\_day](#input\_reservation\_capacity\_in\_gb\_per\_day) | Optional commitment tier in GB/day. | `number` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group where the workspace will be created. | `string` | n/a | yes |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Workspace retention in days. | `number` | `30` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | Workspace SKU. | `string` | `"PerGB2018"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the workspace. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional create/read/update/delete timeouts. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Deprecated compatibility input. Supply workload tags explicitly through tags. | `string` | `"project"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Log Analytics workspace ID. |
| <a name="output_identity"></a> [identity](#output\_identity) | Managed identity details configured on the workspace. |
| <a name="output_merged_tags"></a> [merged\_tags](#output\_merged\_tags) | Final merged tags applied to the workspace. |
| <a name="output_name"></a> [name](#output\_name) | Log Analytics workspace name. |
| <a name="output_primary_shared_key"></a> [primary\_shared\_key](#output\_primary\_shared\_key) | Workspace primary shared key. |
| <a name="output_secondary_shared_key"></a> [secondary\_shared\_key](#output\_secondary\_shared\_key) | Workspace secondary shared key. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to the workspace. |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | Log Analytics workspace ID value. |
<!-- END_TF_DOCS -->
