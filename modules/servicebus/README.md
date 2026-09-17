# Azure Service Bus

Creates an Azure Service Bus namespace with queues, topics, subscriptions, shared-access authorization rules, optional network restrictions, a private endpoint, diagnostics, managed identity, and control-plane RBAC.

## Features

- Basic, Standard, and Premium namespace configuration
- Queues, topics, and subscriptions from keyed maps
- Namespace shared-access authorization rules
- Public endpoint and namespace network-rule controls
- Optional Private Endpoint and Private DNS zone group
- Optional system-assigned managed identity
- Optional diagnostics to Log Analytics
- Microsoft Entra group lookup by object ID or display name
- Resource-group tag inheritance with caller overrides

## Resources Created

The module always creates one Service Bus namespace. It conditionally creates queues, topics, subscriptions, namespace authorization rules, a Private Endpoint, a diagnostic setting, and namespace-scoped Contributor or Reader role assignments.

The module does not create the resource group, subnets, Private DNS zone, VNet links, Log Analytics workspace, application data-plane role assignments, message filters, or application clients.

## Prerequisites and Dependencies

- Existing resource group
- A globally unique namespace name, or permission to use the generated random name
- Existing Private Endpoint subnet and `privatelink.servicebus.windows.net` zone when private connectivity is enabled
- Existing Log Analytics workspace when diagnostics are enabled
- Microsoft Entra directory read permissions when group display names are used
- A reviewed SKU, capacity, partitioning, retention, and disaster-recovery design

## Provider Configuration

The caller supplies `azurerm`, `azuread`, and `random` provider configurations. The execution identity needs Azure resource permissions for the namespace and optional dependencies, plus directory read permission for name-based group lookups.

Prefer immutable Microsoft Entra object IDs. Display-name lookup can fail when names are duplicated.

## Basic Usage

```hcl
module "servicebus" {
  source = "./modules/servicebus"

  resource_group_name = "rg-integration-dev"
  location            = "canadacentral"
  name                = "sb-integration-dev-001"

  local_auth_enabled = false

  queues = {
    orders = {
      dead_lettering_on_message_expiration = true
    }
  }
}
```

See [examples/basic](./examples/basic), [examples/complete](./examples/complete), and [examples/topics-and-subscriptions](./examples/topics-and-subscriptions).

## Important Behavior and Secure Defaults

Compatibility defaults leave public network access and local shared-access signature (SAS) authentication enabled. Hardened callers should explicitly disable local authentication, restrict or disable public access, establish private connectivity where required, and assign Service Bus data-plane roles outside this module.

Basic SKU supports queues only. Capacity and messaging partitions are accepted only for Premium according to the module consistency checks. A subscription must reference a topic declared in the same module call. Authorization rules must grant at least one permission, and `manage` requires both `listen` and `send`.

## Networking and Private Connectivity

The Private Endpoint targets the namespace subresource and can associate one existing Private DNS zone. The caller remains responsible for DNS VNet links, hybrid DNS forwarding, subnet policy, capacity, routing, and connection testing.

Name-based subnet lookup uses the default AzureRM provider, so use a direct subnet ID when the network is produced by another state or subscription.

## Identity and RBAC

`system_managed_identity_enabled` attaches a system-assigned identity to the namespace but does not grant it downstream access.

`app_admin_group` creates Contributor assignments and `app_user_group` creates Reader assignments at namespace scope. These are Azure control-plane roles; they do not grant send, receive, or manage access to messages. Assign Azure Service Bus data roles through the generic `roleassignments` module or the calling composition.

Shared-access authorization rules create SAS credentials that are recorded in Terraform state by the provider even though this module exposes only rule IDs. Prefer Entra authentication where clients support it and protect state accordingly.

## Naming and Tagging

Set an explicit globally unique namespace name for predictable environments. When `name` is empty, the module generates `sb` followed by a random suffix. See the repository [naming convention](../../docs/NAMING_CONVENTION.md) and [tagging standard](../../docs/TAGGING_STANDARD.md).

## Testing

```powershell
terraform init -backend=false
terraform test -filter=tests/unit.tftest.hcl
```

The unit suite mocks all three providers and runs plan-only and expected-failure assertions. It requires no Azure authentication and creates no resources.

## Known Limitations

- The module does not create data-plane RBAC assignments.
- Subscription filters and rules are not managed.
- Only one Private Endpoint and one Private DNS zone ID are supported per module instance.
- Geo-disaster recovery, namespace replicas, and application retry behavior are outside this module.
- Azure validates SKU- and region-specific entity settings at apply time.
- Changing entity settings such as partitioning or duplicate detection may require replacement.

See [Architecture](./docs/architecture.md).

## Terraform Reference

The content below is generated by `terraform-docs`. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
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
| [azurerm_servicebus_namespace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace) | resource |
| [azurerm_servicebus_namespace_authorization_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace_authorization_rule) | resource |
| [azurerm_servicebus_queue.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue) | resource |
| [azurerm_servicebus_subscription.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_subscription) | resource |
| [azurerm_servicebus_topic.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_topic) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | Optional list of Entra group display names or object IDs that will have Contributor access to the namespace. | `list(string)` | `[]` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment metadata retained for composition compatibility; no tag is generated automatically. | `string` | `"dev"` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | Optional list of Entra group display names or object IDs that will have Reader access to the namespace. | `list(string)` | `[]` | no |
| <a name="input_authorization_rules"></a> [authorization\_rules](#input\_authorization\_rules) | Optional namespace authorization rules keyed by rule name. | <pre>map(object({<br>    listen = optional(bool, false)<br>    send   = optional(bool, false)<br>    manage = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_capacity"></a> [capacity](#input\_capacity) | Service Bus namespace capacity. | `number` | `0` | no |
| <a name="input_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#input\_diagnostic\_log\_categories) | Diagnostic log categories to enable. | `list(string)` | <pre>[<br>  "OperationalLogs",<br>  "VNetAndIPFilteringLogs",<br>  "RuntimeAuditLogs",<br>  "ApplicationMetricsLogs"<br>]</pre> | no |
| <a name="input_diagnostic_metric_categories"></a> [diagnostic\_metric\_categories](#input\_diagnostic\_metric\_categories) | Diagnostic metric categories to enable. | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Whether to create diagnostic settings on the Service Bus namespace. | `bool` | `false` | no |
| <a name="input_enable_network_rule_set"></a> [enable\_network\_rule\_set](#input\_enable\_network\_rule\_set) | Whether to configure network rules on the namespace. | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Whether to create a private endpoint for the Service Bus namespace. | `bool` | `false` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into Service Bus resources. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_local_auth_enabled"></a> [local\_auth\_enabled](#input\_local\_auth\_enabled) | Whether SAS/local authentication is enabled. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | Optional Azure region for the Service Bus namespace. Leave empty to use the target resource group's location. | `string` | `""` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace ID used when diagnostics are enabled. | `string` | `""` | no |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | Minimum TLS version for the namespace. | `string` | `"1.2"` | no |
| <a name="input_name"></a> [name](#input\_name) | Service Bus namespace name. Leave empty to auto-generate a unique name. | `string` | `""` | no |
| <a name="input_network_rule_default_action"></a> [network\_rule\_default\_action](#input\_network\_rule\_default\_action) | Default action for the namespace network rule set. | `string` | `"Allow"` | no |
| <a name="input_network_rule_ip_rules"></a> [network\_rule\_ip\_rules](#input\_network\_rule\_ip\_rules) | Allowed IP rules for the namespace network rule set. | `list(string)` | `[]` | no |
| <a name="input_network_rules"></a> [network\_rules](#input\_network\_rules) | Optional subnet-based network rules. | <pre>list(object({<br>    subnet_id                            = string<br>    ignore_missing_vnet_service_endpoint = optional(bool, false)<br>  }))</pre> | `[]` | no |
| <a name="input_premium_messaging_partitions"></a> [premium\_messaging\_partitions](#input\_premium\_messaging\_partitions) | Premium messaging partitions for Premium SKU. | `number` | `0` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Optional private DNS zone ID to attach to the private endpoint. | `string` | `""` | no |
| <a name="input_private_endpoint_network_resource_group_name"></a> [private\_endpoint\_network\_resource\_group\_name](#input\_private\_endpoint\_network\_resource\_group\_name) | Resource group containing the virtual network used to resolve the private endpoint subnet. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | Subnet ID for the private endpoint. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#input\_private\_endpoint\_subnet\_name) | Subnet name used to resolve the private endpoint subnet when private\_endpoint\_subnet\_id is not set. | `string` | `""` | no |
| <a name="input_private_endpoint_vnet_name"></a> [private\_endpoint\_vnet\_name](#input\_private\_endpoint\_vnet\_name) | Virtual network name used to resolve the private endpoint subnet when private\_endpoint\_subnet\_id is not set. | `string` | `""` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether the public endpoint is enabled. | `bool` | `true` | no |
| <a name="input_queues"></a> [queues](#input\_queues) | Map of Service Bus queues keyed by queue name. | <pre>map(object({<br>    max_size_in_megabytes                   = optional(number, 1024)<br>    max_delivery_count                      = optional(number, 10)<br>    lock_duration                           = optional(string, "PT1M")<br>    default_message_ttl                     = optional(string, "P14D")<br>    auto_delete_on_idle                     = optional(string)<br>    dead_lettering_on_message_expiration    = optional(bool, true)<br>    duplicate_detection_history_time_window = optional(string)<br>    requires_duplicate_detection            = optional(bool, false)<br>    requires_session                        = optional(bool, false)<br>    partitioning_enabled                    = optional(bool, false)<br>    express_enabled                         = optional(bool, false)<br>    batched_operations_enabled              = optional(bool, true)<br>    status                                  = optional(string, "Active")<br>    forward_to                              = optional(string)<br>    forward_dead_lettered_messages_to       = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group where the Service Bus namespace will be deployed. | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | Service Bus namespace SKU. | `string` | `"Standard"` | no |
| <a name="input_subscriptions"></a> [subscriptions](#input\_subscriptions) | Map of Service Bus subscriptions keyed by subscription name. | <pre>map(object({<br>    topic_name                                = string<br>    max_delivery_count                        = optional(number, 10)<br>    lock_duration                             = optional(string, "PT1M")<br>    default_message_ttl                       = optional(string, "P14D")<br>    auto_delete_on_idle                       = optional(string)<br>    dead_lettering_on_message_expiration      = optional(bool, true)<br>    dead_lettering_on_filter_evaluation_error = optional(bool, false)<br>    requires_session                          = optional(bool, false)<br>    batched_operations_enabled                = optional(bool, true)<br>    status                                    = optional(string, "Active")<br>    forward_to                                = optional(string)<br>    forward_dead_lettered_messages_to         = optional(string)<br>    client_scoped_subscription_enabled        = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_system_managed_identity_enabled"></a> [system\_managed\_identity\_enabled](#input\_system\_managed\_identity\_enabled) | Whether to enable a system-assigned managed identity on the namespace. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the Service Bus namespace. | `map(string)` | `{}` | no |
| <a name="input_topics"></a> [topics](#input\_topics) | Map of Service Bus topics keyed by topic name. | <pre>map(object({<br>    max_size_in_megabytes                   = optional(number, 1024)<br>    default_message_ttl                     = optional(string, "P14D")<br>    auto_delete_on_idle                     = optional(string)<br>    duplicate_detection_history_time_window = optional(string)<br>    requires_duplicate_detection            = optional(bool, false)<br>    partitioning_enabled                    = optional(bool, false)<br>    express_enabled                         = optional(bool, false)<br>    batched_operations_enabled              = optional(bool, true)<br>    support_ordering                        = optional(bool, false)<br>    status                                  = optional(string, "Active")<br>  }))</pre> | `{}` | no |
| <a name="input_trusted_services_allowed"></a> [trusted\_services\_allowed](#input\_trusted\_services\_allowed) | Whether trusted Microsoft services are allowed through network rules. | `bool` | `false` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload metadata retained for composition compatibility; tags are supplied explicitly through tags. | `string` | `"project"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_admin_group_role_assignment_ids"></a> [app\_admin\_group\_role\_assignment\_ids](#output\_app\_admin\_group\_role\_assignment\_ids) | Contributor role assignment IDs keyed by principal ID. |
| <a name="output_app_user_group_role_assignment_ids"></a> [app\_user\_group\_role\_assignment\_ids](#output\_app\_user\_group\_role\_assignment\_ids) | Reader role assignment IDs keyed by principal ID. |
| <a name="output_authorization_rule_ids"></a> [authorization\_rule\_ids](#output\_authorization\_rule\_ids) | Namespace authorization rule IDs keyed by rule name. |
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | Diagnostic setting ID when diagnostics are enabled. |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The Service Bus namespace endpoint. |
| <a name="output_id"></a> [id](#output\_id) | The Service Bus namespace resource ID. |
| <a name="output_merged_tags"></a> [merged\_tags](#output\_merged\_tags) | Final merged tags applied to the namespace. |
| <a name="output_name"></a> [name](#output\_name) | The Service Bus namespace name. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint ID when private endpoint is enabled. |
| <a name="output_queue_ids"></a> [queue\_ids](#output\_queue\_ids) | Queue resource IDs keyed by queue name. |
| <a name="output_subscription_ids"></a> [subscription\_ids](#output\_subscription\_ids) | Subscription resource IDs keyed by subscription name. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to the Service Bus namespace. |
| <a name="output_topic_ids"></a> [topic\_ids](#output\_topic\_ids) | Topic resource IDs keyed by topic name. |
<!-- END_TF_DOCS -->
