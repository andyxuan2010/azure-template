# Azure Event Hubs

Provisions an Azure Event Hubs namespace with secure authentication and network defaults, optional hubs, consumer groups, Capture, schema groups, private connectivity, encryption, diagnostics, RBAC, and Geo-Disaster Recovery pairing.

## Features

- Disables public network access and local SAS authentication by default.
- Supports Basic, Standard, Premium, and Dedicated-backed namespace patterns.
- Creates Event Hubs, consumer groups, retention policies, Capture destinations, and scoped authorization rules.
- Supports Schema Registry groups, auto-inflate, managed identity, and customer-managed keys.
- Supports namespace firewalls, private endpoints, and private DNS association.
- Supports Azure Monitor diagnostics, Azure RBAC, and optional Geo-DR aliasing.
- Supports explicit or generated globally unique namespace naming.

## Resources Created

The module always creates one `azurerm_eventhub_namespace`. It conditionally creates:

- Event Hubs, consumer groups, namespace- and hub-scoped authorization rules.
- Schema Registry groups.
- A namespace customer-managed-key association.
- A Geo-Disaster Recovery configuration.
- Azure RBAC assignments.
- A private endpoint and private DNS zone association.
- An Azure Monitor diagnostic setting.
- A random suffix for generated naming.

Capture storage, secondary namespaces, identities, networks, DNS zones, Key Vault keys, monitoring destinations, and Microsoft Entra groups remain caller-owned.

## Prerequisites and Dependencies

- An existing resource group.
- A supported namespace SKU and sufficient regional capacity.
- An existing private-endpoint subnet and `privatelink.servicebus.windows.net` DNS zone for private access.
- A Storage Account and container for Event Hubs Capture.
- An existing user-assigned identity and storage permissions for identity-based Capture or customer-managed encryption.
- An existing secondary namespace for Geo-Disaster Recovery.
- Existing monitoring destinations for diagnostics.
- Terraform `>= 1.6.0`; AzureRM `>= 4.0, < 5.0`; AzureAD `>= 3.0, < 4.0`; Random `>= 3.0, < 4.0`.

## Provider Configuration

Configure AzureRM and AzureAD in the caller:

```hcl
provider "azurerm" {
  features {}
}

provider "azuread" {}
```

The Terraform identity needs permissions for Event Hubs, private endpoints, diagnostics, and configured role assignments.

## Basic Usage

See the executable [basic example](examples/basic/), [complete example](examples/complete/), and [Geo-DR example](examples/geo-disaster-recovery/).

```hcl
module "event_hubs" {
  source = "../../modules/eventhub"

  name                          = "evhns-streaming-prod-001"
  resource_group_name           = azurerm_resource_group.messaging.name
  location                      = azurerm_resource_group.messaging.location
  public_network_access_enabled = false
  local_authentication_enabled  = false

  eventhubs = {
    telemetry = {
      partition_count   = 4
      message_retention = 3
    }
  }
}
```

## Important Behavior and Secure Defaults

- Public access and local SAS authentication default to disabled, and minimum TLS defaults to 1.2.
- Namespace and Event Hub authorization rules require local authentication to be enabled. Prefer Entra identity and data-plane RBAC.
- Auto-inflate is a Standard SKU feature and requires a nonzero maximum throughput setting.
- Schema Registry, customer-managed encryption, and Geo-DR have SKU restrictions enforced by module checks.
- Manual and autoscale capacity, retention, Capture storage, Premium units, and diagnostics affect cost.
- Geo-DR pairs namespaces but does not replicate event data; applications must implement recovery and checkpoint strategy.

## Networking and Private Connectivity

Private endpoints use the `namespace` subresource and generally associate with `privatelink.servicebus.windows.net` in Azure public cloud. Firewall service endpoints, IP rules, and private endpoints are distinct connectivity models.

Public access remains disabled unless explicitly enabled. Caller-owned DNS, routing, NSGs, service endpoints, and cross-subscription permissions must be in place before deployment.

## Identity and RBAC

Use the current system- and user-assigned identity inputs for new compositions; the legacy `identity` object remains for compatibility. Customer-managed keys and identity-based Capture require appropriate attached identities and external permissions.

Connection-string outputs are sensitive. Prefer Entra roles such as Azure Event Hubs Data Sender or Data Receiver at the narrowest practical scope.

## Naming and Tagging

Set the namespace `name` explicitly or generate it from workload, environment, location, and instance inputs. Explicit tags override inherited resource-group tags.

## Architecture

See [Architecture](docs/architecture.md) for namespace, entity, Capture, network, identity, monitoring, and Geo-DR boundaries.

## Testing

The unit tests mock AzureRM, AzureAD, and Random:

```shell
terraform init -backend=false
terraform test
```

## Known Limitations

- The module does not create Capture storage, private DNS zones, identities, Key Vault keys, or the secondary Geo-DR namespace.
- Event data, consumer checkpoints, schema definitions, application retries, and failover orchestration are outside Terraform's scope.
- Regional quota, feature availability, private routing, and target permissions cannot be proven by offline tests.
- Enabling SAS exposes sensitive connection-string outputs and requires an explicit credential lifecycle.

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
| [azurerm_eventhub.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub_authorization_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_authorization_rule) | resource |
| [azurerm_eventhub_consumer_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_consumer_group) | resource |
| [azurerm_eventhub_namespace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace) | resource |
| [azurerm_eventhub_namespace_authorization_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace_authorization_rule) | resource |
| [azurerm_eventhub_namespace_customer_managed_key.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace_customer_managed_key) | resource |
| [azurerm_eventhub_namespace_disaster_recovery_config.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace_disaster_recovery_config) | resource |
| [azurerm_eventhub_namespace_schema_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace_schema_group) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.app_admin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_user_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | Optional list of Entra group display names or object IDs that will have Contributor access to the namespace. | `list(string)` | `[]` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used for standard tags and generated naming. | `string` | `"dev"` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | Optional list of Entra group display names or object IDs that will have Reader access to the namespace. | `list(string)` | `[]` | no |
| <a name="input_authorization_rules"></a> [authorization\_rules](#input\_authorization\_rules) | Optional namespace-level authorization rules keyed by stable name. Requires local\_authentication\_enabled = true. | <pre>map(object({<br>    name   = optional(string)<br>    listen = optional(bool, false)<br>    send   = optional(bool, false)<br>    manage = optional(bool, false)<br>    timeouts = optional(object({<br>      create = optional(string)<br>      read   = optional(string)<br>      update = optional(string)<br>      delete = optional(string)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_auto_inflate_enabled"></a> [auto\_inflate\_enabled](#input\_auto\_inflate\_enabled) | Whether auto-inflate is enabled for Standard Event Hubs namespaces. | `bool` | `false` | no |
| <a name="input_capacity"></a> [capacity](#input\_capacity) | Event Hubs namespace capacity or throughput units. | `number` | `1` | no |
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | Optional Event Hubs namespace customer-managed key configuration. | <pre>object({<br>    key_vault_key_ids                 = list(string)<br>    infrastructure_encryption_enabled = optional(bool, false)<br>    user_assigned_identity_id         = optional(string)<br>    timeouts = optional(object({<br>      create = optional(string)<br>      read   = optional(string)<br>      update = optional(string)<br>      delete = optional(string)<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_dedicated_cluster_id"></a> [dedicated\_cluster\_id](#input\_dedicated\_cluster\_id) | Optional Event Hubs Dedicated Cluster resource ID where this namespace should be created. | `string` | `""` | no |
| <a name="input_diagnostic_eventhub_authorization_rule_id"></a> [diagnostic\_eventhub\_authorization\_rule\_id](#input\_diagnostic\_eventhub\_authorization\_rule\_id) | Optional Event Hubs namespace authorization rule resource ID for diagnostics. | `string` | `null` | no |
| <a name="input_diagnostic_eventhub_name"></a> [diagnostic\_eventhub\_name](#input\_diagnostic\_eventhub\_name) | Optional Event Hub name for diagnostics when using an Event Hub destination. | `string` | `null` | no |
| <a name="input_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#input\_diagnostic\_log\_categories) | Diagnostic log categories to enable. Use diagnostic\_log\_category\_groups for Azure Monitor category groups such as allLogs. | `list(string)` | <pre>[<br>  "ArchiveLogs",<br>  "OperationalLogs",<br>  "AutoScaleLogs",<br>  "KafkaCoordinatorLogs",<br>  "KafkaUserErrorLogs",<br>  "EventHubVNetConnectionEvent",<br>  "CustomerManagedKeyUserLogs",<br>  "RuntimeAuditLogs",<br>  "ApplicationMetricsLogs"<br>]</pre> | no |
| <a name="input_diagnostic_log_category_groups"></a> [diagnostic\_log\_category\_groups](#input\_diagnostic\_log\_category\_groups) | Diagnostic log category groups to enable, for example allLogs. | `list(string)` | `[]` | no |
| <a name="input_diagnostic_metric_categories"></a> [diagnostic\_metric\_categories](#input\_diagnostic\_metric\_categories) | Diagnostic metric categories to enable. | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| <a name="input_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#input\_diagnostic\_setting\_name) | Optional diagnostic setting name. When empty, the module uses <namespace-name>-diagnostic-setting. | `string` | `""` | no |
| <a name="input_diagnostic_storage_account_id"></a> [diagnostic\_storage\_account\_id](#input\_diagnostic\_storage\_account\_id) | Optional Storage Account resource ID for diagnostic archive. | `string` | `null` | no |
| <a name="input_diagnostic_timeouts"></a> [diagnostic\_timeouts](#input\_diagnostic\_timeouts) | Optional timeouts for diagnostic setting create, read, update, and delete operations. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_disaster_recovery_config"></a> [disaster\_recovery\_config](#input\_disaster\_recovery\_config) | Optional Geo-Disaster Recovery alias configuration for a paired secondary Event Hubs namespace. | <pre>object({<br>    name                 = string<br>    partner_namespace_id = string<br>    timeouts = optional(object({<br>      create = optional(string)<br>      read   = optional(string)<br>      update = optional(string)<br>      delete = optional(string)<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Whether to create diagnostic settings on the Event Hubs namespace. Diagnostics are also enabled when at least one diagnostic destination is supplied. | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Whether to create a private endpoint for the Event Hubs namespace. | `bool` | `false` | no |
| <a name="input_eventhubs"></a> [eventhubs](#input\_eventhubs) | Map of Event Hubs keyed by stable name. Each Event Hub can define capture, retention, consumer groups, and scoped SAS rules. | <pre>map(object({<br>    name              = optional(string)<br>    partition_count   = optional(number, 2)<br>    message_retention = optional(number, 1)<br>    status            = optional(string, "Active")<br>    retention_description = optional(object({<br>      cleanup_policy                    = string<br>      retention_time_in_hours           = optional(number)<br>      tombstone_retention_time_in_hours = optional(number)<br>    }))<br>    capture_description = optional(object({<br>      enabled             = bool<br>      encoding            = optional(string, "Avro")<br>      interval_in_seconds = optional(number)<br>      size_limit_in_bytes = optional(number)<br>      skip_empty_archives = optional(bool)<br>      destination = object({<br>        name                        = optional(string, "EventHubArchive.AzureBlockBlob")<br>        archive_name_format         = string<br>        blob_container_name         = string<br>        storage_account_id          = string<br>        storage_authentication_type = optional(string, "StorageSAS")<br>        storage_authentication_id   = optional(string)<br>      })<br>    }))<br>    consumer_groups = optional(map(object({<br>      name          = optional(string)<br>      user_metadata = optional(string)<br>      timeouts = optional(object({<br>        create = optional(string)<br>        read   = optional(string)<br>        update = optional(string)<br>        delete = optional(string)<br>      }))<br>    })), {})<br>    authorization_rules = optional(map(object({<br>      name   = optional(string)<br>      listen = optional(bool, false)<br>      send   = optional(bool, false)<br>      manage = optional(bool, false)<br>      timeouts = optional(object({<br>        create = optional(string)<br>        read   = optional(string)<br>        update = optional(string)<br>        delete = optional(string)<br>      }))<br>    })), {})<br>    timeouts = optional(object({<br>      create = optional(string)<br>      read   = optional(string)<br>      update = optional(string)<br>      delete = optional(string)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Legacy managed identity configuration. Prefer system\_managed\_identity\_enabled and identity\_ids for new usage. | <pre>object({<br>    type         = string<br>    identity_ids = optional(set(string))<br>  })</pre> | `null` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | User-assigned managed identity IDs to attach to the Event Hubs namespace. Ignored when legacy identity is set. | `list(string)` | `[]` | no |
| <a name="input_include_environment_in_name"></a> [include\_environment\_in\_name](#input\_include\_environment\_in\_name) | Whether generated Event Hubs namespace names include app\_env. | `bool` | `true` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into module resources. The module only reads the resource group when this is true or location is empty. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Optional instance segment used when generated names do not use a random suffix. | `string` | `"001"` | no |
| <a name="input_local_authentication_enabled"></a> [local\_authentication\_enabled](#input\_local\_authentication\_enabled) | Whether SAS/local authentication is enabled. Disable for Entra ID-only access. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Optional Azure region for the Event Hubs namespace. Leave empty to use the target resource group's location. | `string` | `""` | no |
| <a name="input_location_code"></a> [location\_code](#input\_location\_code) | Optional short location code used when the Event Hubs namespace name is generated. | `string` | `""` | no |
| <a name="input_log_analytics_destination_type"></a> [log\_analytics\_destination\_type](#input\_log\_analytics\_destination\_type) | Destination type for Log Analytics diagnostics. | `string` | `"Dedicated"` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Optional Log Analytics workspace ID used for diagnostics. | `string` | `""` | no |
| <a name="input_maximum_throughput_units"></a> [maximum\_throughput\_units](#input\_maximum\_throughput\_units) | Maximum throughput units when auto-inflate is enabled. | `number` | `0` | no |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | Minimum TLS version for the namespace. | `string` | `"1.2"` | no |
| <a name="input_name"></a> [name](#input\_name) | Event Hubs namespace name. Leave empty to auto-generate a unique name. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used when the Event Hubs namespace name is generated. | `string` | `"evhns"` | no |
| <a name="input_network_rulesets"></a> [network\_rulesets](#input\_network\_rulesets) | Optional namespace firewall configuration using Event Hubs network rule sets. | <pre>object({<br>    default_action                 = optional(string, "Deny")<br>    trusted_service_access_enabled = optional(bool, false)<br>    ip_rules = optional(list(object({<br>      ip_mask = string<br>      action  = optional(string, "Allow")<br>    })), [])<br>    virtual_network_rules = optional(list(object({<br>      subnet_id                                       = string<br>      ignore_missing_virtual_network_service_endpoint = optional(bool, false)<br>    })), [])<br>  })</pre> | `null` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Optional single private DNS zone ID to attach to the private endpoint. Use private\_dns\_zone\_ids for new configurations. | `string` | `""` | no |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | Optional list of private DNS zone IDs to attach to the private endpoint. | `list(string)` | `[]` | no |
| <a name="input_private_dns_zone_names"></a> [private\_dns\_zone\_names](#input\_private\_dns\_zone\_names) | Optional private DNS zone names to resolve and attach to the private endpoint when IDs are not supplied. Event Hubs commonly uses privatelink.servicebus.windows.net in Azure public cloud. | `list(string)` | `[]` | no |
| <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name) | Resource group used to resolve private\_dns\_zone\_names. | `string` | `""` | no |
| <a name="input_private_endpoint_ip_configurations"></a> [private\_endpoint\_ip\_configurations](#input\_private\_endpoint\_ip\_configurations) | Optional static IP configurations for the private endpoint. | <pre>list(object({<br>    name               = string<br>    private_ip_address = string<br>    subresource_name   = optional(string, "namespace")<br>    member_name        = optional(string, "namespace")<br>  }))</pre> | `[]` | no |
| <a name="input_private_endpoint_manual_connection_enabled"></a> [private\_endpoint\_manual\_connection\_enabled](#input\_private\_endpoint\_manual\_connection\_enabled) | Whether the private endpoint connection is created as a manual approval request. | `bool` | `false` | no |
| <a name="input_private_endpoint_name_prefix"></a> [private\_endpoint\_name\_prefix](#input\_private\_endpoint\_name\_prefix) | Prefix used for generated private endpoint names. | `string` | `"pep"` | no |
| <a name="input_private_endpoint_network_interface_name"></a> [private\_endpoint\_network\_interface\_name](#input\_private\_endpoint\_network\_interface\_name) | Optional custom network interface name for the private endpoint. | `string` | `""` | no |
| <a name="input_private_endpoint_network_resource_group_name"></a> [private\_endpoint\_network\_resource\_group\_name](#input\_private\_endpoint\_network\_resource\_group\_name) | Resource group containing the virtual network used to resolve the private endpoint subnet. | `string` | `""` | no |
| <a name="input_private_endpoint_request_message"></a> [private\_endpoint\_request\_message](#input\_private\_endpoint\_request\_message) | Optional request message used when private\_endpoint\_manual\_connection\_enabled is true. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | Subnet ID for the private endpoint. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#input\_private\_endpoint\_subnet\_name) | Subnet name used to resolve the private endpoint subnet when private\_endpoint\_subnet\_id is not set. | `string` | `""` | no |
| <a name="input_private_endpoint_timeouts"></a> [private\_endpoint\_timeouts](#input\_private\_endpoint\_timeouts) | Optional timeouts for private endpoint create, read, update, and delete operations. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_private_endpoint_vnet_name"></a> [private\_endpoint\_vnet\_name](#input\_private\_endpoint\_vnet\_name) | Virtual network name used to resolve the private endpoint subnet when private\_endpoint\_subnet\_id is not set. | `string` | `""` | no |
| <a name="input_private_service_connection_name_prefix"></a> [private\_service\_connection\_name\_prefix](#input\_private\_service\_connection\_name\_prefix) | Prefix used for generated private service connection names. | `string` | `"psc"` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether the Event Hubs namespace public endpoint is reachable. | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group where the Event Hubs namespace will be deployed. | `string` | n/a | yes |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | Additional role assignments to create at the Event Hubs namespace scope, keyed by a stable name. | <pre>map(object({<br>    principal_id                           = string<br>    role_definition_name                   = optional(string)<br>    role_definition_id                     = optional(string)<br>    principal_type                         = optional(string)<br>    description                            = optional(string)<br>    name                                   = optional(string)<br>    condition                              = optional(string)<br>    condition_version                      = optional(string)<br>    delegated_managed_identity_resource_id = optional(string)<br>    skip_service_principal_aad_check       = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_schema_groups"></a> [schema\_groups](#input\_schema\_groups) | Optional Event Hubs schema registry groups keyed by stable name. | <pre>map(object({<br>    name                 = optional(string)<br>    schema_compatibility = string<br>    schema_type          = string<br>    timeouts = optional(object({<br>      create = optional(string)<br>      read   = optional(string)<br>      delete = optional(string)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | Event Hubs namespace SKU. | `string` | `"Standard"` | no |
| <a name="input_system_managed_identity_enabled"></a> [system\_managed\_identity\_enabled](#input\_system\_managed\_identity\_enabled) | Whether to enable a system-assigned managed identity on the namespace. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the Event Hubs namespace and related resources. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional timeouts for Event Hubs namespace create, read, update, and delete operations. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_use_random_suffix"></a> [use\_random\_suffix](#input\_use\_random\_suffix) | Whether generated Event Hubs namespace names should include a random suffix. | `bool` | `true` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Deprecated compatibility input. Supply workload tags explicitly through tags. | `string` | `"project"` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Optional workload segment used when the Event Hubs namespace name is generated. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_admin_group_principal_ids"></a> [app\_admin\_group\_principal\_ids](#output\_app\_admin\_group\_principal\_ids) | Map of resolved app admin group principal IDs. |
| <a name="output_app_admin_group_role_assignment_ids"></a> [app\_admin\_group\_role\_assignment\_ids](#output\_app\_admin\_group\_role\_assignment\_ids) | Contributor role assignment IDs keyed by principal ID. |
| <a name="output_app_env"></a> [app\_env](#output\_app\_env) | The deployment environment used for tags and generated names. |
| <a name="output_app_user_group_principal_ids"></a> [app\_user\_group\_principal\_ids](#output\_app\_user\_group\_principal\_ids) | Map of resolved app user group principal IDs. |
| <a name="output_app_user_group_role_assignment_ids"></a> [app\_user\_group\_role\_assignment\_ids](#output\_app\_user\_group\_role\_assignment\_ids) | Reader role assignment IDs keyed by principal ID. |
| <a name="output_authorization_rule_ids"></a> [authorization\_rule\_ids](#output\_authorization\_rule\_ids) | Backward-compatible alias for namespace authorization rule IDs keyed by rule name. |
| <a name="output_capacity"></a> [capacity](#output\_capacity) | The Event Hubs namespace capacity. |
| <a name="output_consumer_group_ids"></a> [consumer\_group\_ids](#output\_consumer\_group\_ids) | Consumer group IDs keyed by <eventhub-key>.<consumer-group-key>. |
| <a name="output_customer_managed_key_id"></a> [customer\_managed\_key\_id](#output\_customer\_managed\_key\_id) | Customer-managed key resource ID when configured. |
| <a name="output_default_primary_connection_string"></a> [default\_primary\_connection\_string](#output\_default\_primary\_connection\_string) | The default primary connection string for the Event Hubs namespace when local authentication is enabled. |
| <a name="output_default_secondary_connection_string"></a> [default\_secondary\_connection\_string](#output\_default\_secondary\_connection\_string) | The default secondary connection string for the Event Hubs namespace when local authentication is enabled. |
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | Diagnostic setting ID when diagnostics are enabled. |
| <a name="output_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#output\_diagnostic\_setting\_name) | Diagnostic setting name when diagnostics are enabled. |
| <a name="output_diagnostics_enabled"></a> [diagnostics\_enabled](#output\_diagnostics\_enabled) | Boolean flag indicating whether diagnostics are enabled. |
| <a name="output_disaster_recovery_config_id"></a> [disaster\_recovery\_config\_id](#output\_disaster\_recovery\_config\_id) | Geo-disaster recovery config ID when configured. |
| <a name="output_eventhub_authorization_rule_ids"></a> [eventhub\_authorization\_rule\_ids](#output\_eventhub\_authorization\_rule\_ids) | Event Hub authorization rule IDs keyed by <eventhub-key>.<rule-key>. |
| <a name="output_eventhub_authorization_rule_primary_connection_strings"></a> [eventhub\_authorization\_rule\_primary\_connection\_strings](#output\_eventhub\_authorization\_rule\_primary\_connection\_strings) | Event Hub authorization rule primary connection strings keyed by <eventhub-key>.<rule-key>. |
| <a name="output_eventhub_ids"></a> [eventhub\_ids](#output\_eventhub\_ids) | Event Hub resource IDs keyed by input key. |
| <a name="output_eventhub_names"></a> [eventhub\_names](#output\_eventhub\_names) | Event Hub names keyed by input key. |
| <a name="output_eventhub_partition_ids"></a> [eventhub\_partition\_ids](#output\_eventhub\_partition\_ids) | Event Hub partition IDs keyed by input key. |
| <a name="output_id"></a> [id](#output\_id) | The Event Hubs namespace resource ID. |
| <a name="output_identity"></a> [identity](#output\_identity) | Managed identity details for the Event Hubs namespace. |
| <a name="output_identity_type"></a> [identity\_type](#output\_identity\_type) | The managed identity type enabled on the Event Hubs namespace. |
| <a name="output_local_authentication_enabled"></a> [local\_authentication\_enabled](#output\_local\_authentication\_enabled) | Whether SAS/local authentication is enabled. |
| <a name="output_location"></a> [location](#output\_location) | The Azure region where the Event Hubs namespace is deployed. |
| <a name="output_location_code"></a> [location\_code](#output\_location\_code) | The short location code used by generated names. |
| <a name="output_merged_tags"></a> [merged\_tags](#output\_merged\_tags) | Final merged tags applied to the Event Hubs namespace. |
| <a name="output_name"></a> [name](#output\_name) | The Event Hubs namespace name. |
| <a name="output_namespace_authorization_rule_ids"></a> [namespace\_authorization\_rule\_ids](#output\_namespace\_authorization\_rule\_ids) | Namespace authorization rule IDs keyed by rule name. |
| <a name="output_namespace_authorization_rule_primary_connection_strings"></a> [namespace\_authorization\_rule\_primary\_connection\_strings](#output\_namespace\_authorization\_rule\_primary\_connection\_strings) | Namespace authorization rule primary connection strings keyed by rule name. |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | The principal ID of the system-assigned managed identity, when enabled. |
| <a name="output_private_endpoint_fqdns"></a> [private\_endpoint\_fqdns](#output\_private\_endpoint\_fqdns) | Private endpoint FQDNs when private endpoint is enabled. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint ID when private endpoint is enabled. |
| <a name="output_private_endpoint_ip_addresses"></a> [private\_endpoint\_ip\_addresses](#output\_private\_endpoint\_ip\_addresses) | Private endpoint IP addresses when private endpoint is enabled. |
| <a name="output_private_endpoint_name"></a> [private\_endpoint\_name](#output\_private\_endpoint\_name) | Private endpoint name when private endpoint is enabled. |
| <a name="output_public_network_access_enabled"></a> [public\_network\_access\_enabled](#output\_public\_network\_access\_enabled) | Whether public network access is enabled. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name where the Event Hubs namespace is deployed. |
| <a name="output_role_assignment_count"></a> [role\_assignment\_count](#output\_role\_assignment\_count) | Total number of role assignments created by this module. |
| <a name="output_role_assignment_ids"></a> [role\_assignment\_ids](#output\_role\_assignment\_ids) | Map of additional role assignment IDs keyed by assignment name. |
| <a name="output_schema_group_ids"></a> [schema\_group\_ids](#output\_schema\_group\_ids) | Schema group IDs keyed by input key. |
| <a name="output_sku"></a> [sku](#output\_sku) | The Event Hubs namespace SKU. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to the Event Hubs namespace. |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | The tenant ID of the system-assigned managed identity, when enabled. |
<!-- END_TF_DOCS -->
