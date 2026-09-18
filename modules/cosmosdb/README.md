# Azure Cosmos DB

Provisions an Azure Cosmos DB account with secure network and authentication defaults, optional SQL databases and containers, private connectivity, identity, role assignments, diagnostics, backup, and geo-replication.

## Features

- Disables public network access and key-based local authentication by default.
- Enables a system-assigned managed identity by default.
- Supports multi-region placement, automatic failover, zone redundancy, and configurable consistency.
- Supports continuous or periodic backup and account throughput limits.
- Creates optional SQL databases, SQL containers, and Cosmos DB SQL data-plane role definitions and assignments.
- Supports private endpoints, private DNS associations, service-endpoint rules, and IP filters.
- Supports customer-managed keys, Azure RBAC, and Azure Monitor diagnostics.

## Resources Created

The module always creates one `azurerm_cosmosdb_account`. It conditionally creates:

- SQL databases and containers.
- Cosmos DB SQL role definitions and assignments.
- A private endpoint and private DNS zone associations.
- Azure Monitor diagnostic settings.
- Azure RBAC role assignments.
- A random suffix for generated naming.

The resource group, subnet, private DNS zone, identities, Key Vault key, monitoring destinations, and Microsoft Entra groups are existing dependencies and remain caller-owned.

## Prerequisites and Dependencies

- An existing resource group.
- Supported Cosmos DB capacity and features in every selected region.
- An existing subnet and `privatelink.documents.azure.com` private DNS zone for SQL API private endpoints.
- Existing monitoring destinations when diagnostics are enabled.
- Existing identities, Key Vault keys, and permissions for customer-managed encryption.
- Principal IDs and appropriate Cosmos DB data-plane role definitions when using Entra authentication.
- Terraform `>= 1.6.0`; AzureRM `>= 4.0, < 5.0`; AzureAD `>= 3.0, < 4.0`; Random `>= 3.0, < 4.0`.

## Provider Configuration

Configure AzureRM and AzureAD in the calling root module:

```hcl
provider "azurerm" {
  features {}
}

provider "azuread" {}
```

The Terraform identity needs permission to manage Cosmos DB resources, private endpoints, diagnostics, and any configured role assignments.

## Basic Usage

See the executable [basic example](examples/basic/), [complete example](examples/complete/), and [serverless example](examples/serverless/).

```hcl
module "cosmos" {
  source = "../../modules/cosmosdb"

  resource_group_name = azurerm_resource_group.data.name
  location            = azurerm_resource_group.data.location
  workload_name       = "orders"
  app_env             = "prod"

  public_network_access_enabled = false
  local_authentication_disabled = true

  sql_databases = {
    orders = {}
  }

  sql_containers = {
    orders = {
      database_name       = "orders"
      partition_key_paths = ["/tenantId"]
    }
  }
}
```

## Important Behavior and Secure Defaults

- Public network access defaults to disabled, local key authentication defaults to disabled, TLS 1.2 is enforced, and a system-assigned identity is enabled by default.
- The default backup type is continuous and the default consistency level is session.
- A serverless account must have one region and cannot use provisioned database or container throughput or an account total-throughput limit.
- Database and container `throughput` and `autoscale_settings` are mutually exclusive.
- Container entries reference a database by its map key, not only by its Azure name.
- Customer-managed keys require an attached managed identity and preconfigured Key Vault permissions.
- Multi-region capacity, multiple-write regions, analytical storage, provisioned throughput, and diagnostics can materially increase cost.
- Account, database, consistency, and backup changes can be replacement-sensitive or operationally disruptive.

## Networking and Private Connectivity

Private endpoints require a caller-owned subnet and DNS integration. SQL API deployments generally use `privatelink.documents.azure.com`; other APIs require the matching Cosmos DB private-link subresource and DNS design.

Virtual network rules use service endpoints and are distinct from private endpoints. Public IP filters are meaningful only when public network access is enabled. Private DNS, routing, NSGs, and cross-subscription permissions remain caller responsibilities.

## Identity and RBAC

The account supports system-assigned and user-assigned identities. The module can create Azure control-plane role assignments and Cosmos DB SQL data-plane role definitions and assignments.

Primary keys, read-only keys, and connection strings are sensitive outputs. Prefer Entra data-plane RBAC and leave local authentication disabled. Consumers should receive only the least-privileged role at the narrowest practical SQL scope.

## Naming and Tagging

Set `name` for an explicit globally unique account name. Otherwise, the module generates a name with an optional random suffix. Explicit tags override inherited resource-group tags.

## Architecture

See [Architecture](docs/architecture.md) for account, data-plane, networking, identity, resiliency, and monitoring boundaries.

## Testing

The tests mock AzureRM, AzureAD, and Random and do not create an account:

```shell
terraform init -backend=false
terraform test
```

Validate each example independently before use.

## Known Limitations

- SQL database and container resources apply to the Cosmos DB SQL API; other API-specific data-plane resources are outside this module.
- Regional capacity, zone support, failover behavior, quotas, and feature registrations cannot be validated offline.
- Private DNS, network infrastructure, monitoring destinations, Key Vault resources, and runtime role design remain caller-owned.
- Disabling local authentication means applications must be ready to use Microsoft Entra authentication.

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
| [azurerm_cosmosdb_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account) | resource |
| [azurerm_cosmosdb_sql_container.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_container) | resource |
| [azurerm_cosmosdb_sql_database.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_database) | resource |
| [azurerm_cosmosdb_sql_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_role_assignment) | resource |
| [azurerm_cosmosdb_sql_role_definition.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_role_definition) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.app_admin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_user_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_timeouts"></a> [account\_timeouts](#input\_account\_timeouts) | Optional create/read/update/delete timeouts for the Cosmos DB account. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_analytical_storage_enabled"></a> [analytical\_storage\_enabled](#input\_analytical\_storage\_enabled) | Whether analytical storage is enabled. | `bool` | `false` | no |
| <a name="input_analytical_storage_schema_type"></a> [analytical\_storage\_schema\_type](#input\_analytical\_storage\_schema\_type) | Analytical storage schema type when analytical storage is enabled. | `string` | `"WellDefined"` | no |
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | Optional list of Entra group display names or object IDs that receive the admin role on the Cosmos DB account. | `list(string)` | `[]` | no |
| <a name="input_app_admin_role_definition_name"></a> [app\_admin\_role\_definition\_name](#input\_app\_admin\_role\_definition\_name) | Azure role assigned to app\_admin\_group principals at the Cosmos DB account scope. | `string` | `"Cosmos DB Account Contributor"` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used for standard tags and generated naming. | `string` | `"dev"` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | Optional list of Entra group display names or object IDs that receive the reader role on the Cosmos DB account. | `list(string)` | `[]` | no |
| <a name="input_app_user_role_definition_name"></a> [app\_user\_role\_definition\_name](#input\_app\_user\_role\_definition\_name) | Azure role assigned to app\_user\_group principals at the Cosmos DB account scope. | `string` | `"Reader"` | no |
| <a name="input_automatic_failover_enabled"></a> [automatic\_failover\_enabled](#input\_automatic\_failover\_enabled) | Whether automatic failover is enabled for multi-region accounts. | `bool` | `true` | no |
| <a name="input_backup"></a> [backup](#input\_backup) | Cosmos DB backup policy. | <pre>object({<br>    type                = optional(string, "Continuous")<br>    tier                = optional(string)<br>    interval_in_minutes = optional(number)<br>    retention_in_hours  = optional(number)<br>    storage_redundancy  = optional(string)<br>  })</pre> | `{}` | no |
| <a name="input_capabilities"></a> [capabilities](#input\_capabilities) | Optional Cosmos DB capabilities, for example EnableServerless or EnableMongo. | `list(string)` | `[]` | no |
| <a name="input_consistency_policy"></a> [consistency\_policy](#input\_consistency\_policy) | Cosmos DB consistency policy. | <pre>object({<br>    consistency_level       = optional(string, "Session")<br>    max_interval_in_seconds = optional(number)<br>    max_staleness_prefix    = optional(number)<br>  })</pre> | `{}` | no |
| <a name="input_default_identity_type"></a> [default\_identity\_type](#input\_default\_identity\_type) | Optional default identity type used by Cosmos DB when customer-managed keys are configured. | `string` | `""` | no |
| <a name="input_diagnostic_eventhub_authorization_rule_id"></a> [diagnostic\_eventhub\_authorization\_rule\_id](#input\_diagnostic\_eventhub\_authorization\_rule\_id) | Optional Event Hub authorization rule ID used to stream diagnostics. | `string` | `""` | no |
| <a name="input_diagnostic_eventhub_name"></a> [diagnostic\_eventhub\_name](#input\_diagnostic\_eventhub\_name) | Optional Event Hub name used to stream diagnostics. | `string` | `null` | no |
| <a name="input_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#input\_diagnostic\_log\_categories) | Diagnostic log categories to enable. Use AllLogs to emit the provider category group instead of individual categories. | `list(string)` | <pre>[<br>  "AllLogs"<br>]</pre> | no |
| <a name="input_diagnostic_log_category_groups"></a> [diagnostic\_log\_category\_groups](#input\_diagnostic\_log\_category\_groups) | Diagnostic log category groups to enable, for example allLogs or audit. | `list(string)` | `[]` | no |
| <a name="input_diagnostic_metric_categories"></a> [diagnostic\_metric\_categories](#input\_diagnostic\_metric\_categories) | Diagnostic metric categories to enable. | `list(string)` | <pre>[<br>  "Requests"<br>]</pre> | no |
| <a name="input_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#input\_diagnostic\_setting\_name) | Optional diagnostic setting name. Defaults to diag-<account-name>. | `string` | `""` | no |
| <a name="input_diagnostic_storage_account_id"></a> [diagnostic\_storage\_account\_id](#input\_diagnostic\_storage\_account\_id) | Optional Storage Account ID used to archive diagnostics. | `string` | `""` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Whether to create diagnostic settings on the Cosmos DB account. Diagnostics are also enabled automatically when any diagnostic destination ID is supplied. | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Whether to create a private endpoint for the Cosmos DB account. | `bool` | `false` | no |
| <a name="input_free_tier_enabled"></a> [free\_tier\_enabled](#input\_free\_tier\_enabled) | Whether Cosmos DB free tier is enabled. | `bool` | `false` | no |
| <a name="input_geo_locations"></a> [geo\_locations](#input\_geo\_locations) | Geo-replication locations. If omitted, the account is created in location with failover priority 0. | <pre>list(object({<br>    location          = string<br>    failover_priority = number<br>    zone_redundant    = optional(bool, false)<br>  }))</pre> | `[]` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Optional user-assigned managed identity IDs. | `list(string)` | `[]` | no |
| <a name="input_include_environment_in_name"></a> [include\_environment\_in\_name](#input\_include\_environment\_in\_name) | Whether generated Cosmos DB names include app\_env. | `bool` | `true` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into module resources. The module only reads the resource group when this is true or location is empty. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Optional instance segment used when generated names do not use a random suffix. | `string` | `"001"` | no |
| <a name="input_ip_range_filter"></a> [ip\_range\_filter](#input\_ip\_range\_filter) | Optional public IP range filters. | `list(string)` | `[]` | no |
| <a name="input_key_vault_key_id"></a> [key\_vault\_key\_id](#input\_key\_vault\_key\_id) | Optional Key Vault key ID for customer-managed encryption. | `string` | `""` | no |
| <a name="input_kind"></a> [kind](#input\_kind) | Cosmos DB account kind. GlobalDocumentDB is the SQL API default. | `string` | `"GlobalDocumentDB"` | no |
| <a name="input_local_authentication_disabled"></a> [local\_authentication\_disabled](#input\_local\_authentication\_disabled) | Whether key-based local authentication is disabled. Prefer Entra ID RBAC for production. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | Optional Azure region for the Cosmos DB account. Leave empty to use the target resource group's location. | `string` | `""` | no |
| <a name="input_location_code"></a> [location\_code](#input\_location\_code) | Optional short location code used when the Cosmos DB account name is generated. | `string` | `""` | no |
| <a name="input_log_analytics_destination_type"></a> [log\_analytics\_destination\_type](#input\_log\_analytics\_destination\_type) | Diagnostic Log Analytics destination type. | `string` | `null` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace ID used for diagnostics. | `string` | `""` | no |
| <a name="input_minimal_tls_version"></a> [minimal\_tls\_version](#input\_minimal\_tls\_version) | Minimum TLS version for the Cosmos DB account. | `string` | `"Tls12"` | no |
| <a name="input_multiple_write_locations_enabled"></a> [multiple\_write\_locations\_enabled](#input\_multiple\_write\_locations\_enabled) | Whether writes are enabled in every configured region. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Cosmos DB account name. Leave empty to auto-generate a standardized globally unique name. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used when the Cosmos DB account name is generated. | `string` | `"cosmos"` | no |
| <a name="input_network_acl_bypass_for_azure_services"></a> [network\_acl\_bypass\_for\_azure\_services](#input\_network\_acl\_bypass\_for\_azure\_services) | Whether Azure services can bypass network ACLs. | `bool` | `false` | no |
| <a name="input_network_acl_bypass_ids"></a> [network\_acl\_bypass\_ids](#input\_network\_acl\_bypass\_ids) | Optional resource IDs that can bypass network ACLs. | `list(string)` | `[]` | no |
| <a name="input_offer_type"></a> [offer\_type](#input\_offer\_type) | Cosmos DB account offer type. | `string` | `"Standard"` | no |
| <a name="input_private_dns_zone_group_name"></a> [private\_dns\_zone\_group\_name](#input\_private\_dns\_zone\_group\_name) | Private DNS zone group name for the private endpoint. | `string` | `"default"` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Optional single private DNS zone ID to attach to the private endpoint. Use private\_dns\_zone\_ids for new configurations. | `string` | `""` | no |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | Optional list of private DNS zone IDs to attach to the private endpoint. | `list(string)` | `[]` | no |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | Existing private DNS zone name used when private DNS zone IDs are not supplied. SQL API typically uses privatelink.documents.azure.com. | `string` | `""` | no |
| <a name="input_private_dns_zone_names"></a> [private\_dns\_zone\_names](#input\_private\_dns\_zone\_names) | Additional private DNS zone names to look up in private\_dns\_zone\_resource\_group\_name. | `list(string)` | `[]` | no |
| <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name) | Resource group containing existing private DNS zones used when private DNS zone IDs are not supplied. | `string` | `""` | no |
| <a name="input_private_endpoint_ip_configurations"></a> [private\_endpoint\_ip\_configurations](#input\_private\_endpoint\_ip\_configurations) | Optional static private endpoint IP configurations. | <pre>list(object({<br>    name               = string<br>    private_ip_address = string<br>    subresource_name   = optional(string, "Sql")<br>    member_name        = optional(string, "Sql")<br>  }))</pre> | `[]` | no |
| <a name="input_private_endpoint_manual_connection"></a> [private\_endpoint\_manual\_connection](#input\_private\_endpoint\_manual\_connection) | Whether the private endpoint connection should be manually approved. | `bool` | `false` | no |
| <a name="input_private_endpoint_manual_request_message"></a> [private\_endpoint\_manual\_request\_message](#input\_private\_endpoint\_manual\_request\_message) | Optional approval request message for manual private endpoint connections. | `string` | `""` | no |
| <a name="input_private_endpoint_name"></a> [private\_endpoint\_name](#input\_private\_endpoint\_name) | Optional private endpoint name. Defaults to pep-<account-name>. | `string` | `""` | no |
| <a name="input_private_endpoint_network_interface_name"></a> [private\_endpoint\_network\_interface\_name](#input\_private\_endpoint\_network\_interface\_name) | Optional custom network interface name for the private endpoint. | `string` | `""` | no |
| <a name="input_private_endpoint_network_resource_group_name"></a> [private\_endpoint\_network\_resource\_group\_name](#input\_private\_endpoint\_network\_resource\_group\_name) | Resource group containing the virtual network used to resolve the private endpoint subnet. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | Subnet ID for the private endpoint. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#input\_private\_endpoint\_subnet\_name) | Subnet name used to resolve the private endpoint subnet when private\_endpoint\_subnet\_id is not set. | `string` | `""` | no |
| <a name="input_private_endpoint_vnet_name"></a> [private\_endpoint\_vnet\_name](#input\_private\_endpoint\_vnet\_name) | Virtual network name used to resolve the private endpoint subnet when private\_endpoint\_subnet\_id is not set. | `string` | `""` | no |
| <a name="input_private_service_connection_name"></a> [private\_service\_connection\_name](#input\_private\_service\_connection\_name) | Optional private service connection name. | `string` | `""` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is enabled. | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group where the Cosmos DB account will be deployed. | `string` | n/a | yes |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | Additional Azure role assignments scoped to the Cosmos DB account. | <pre>map(object({<br>    principal_id                           = string<br>    principal_type                         = optional(string)<br>    role_definition_name                   = optional(string)<br>    role_definition_id                     = optional(string)<br>    name                                   = optional(string)<br>    description                            = optional(string)<br>    condition                              = optional(string)<br>    condition_version                      = optional(string)<br>    delegated_managed_identity_resource_id = optional(string)<br>    skip_service_principal_aad_check       = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_sql_containers"></a> [sql\_containers](#input\_sql\_containers) | SQL containers keyed by container name. | <pre>map(object({<br>    database_name          = string<br>    partition_key_paths    = list(string)<br>    partition_key_kind     = optional(string, "Hash")<br>    partition_key_version  = optional(number, 2)<br>    throughput             = optional(number)<br>    autoscale_max_ru       = optional(number)<br>    default_ttl            = optional(number)<br>    analytical_storage_ttl = optional(number)<br>    conflict_resolution_policy = optional(object({<br>      mode                          = string<br>      conflict_resolution_path      = optional(string)<br>      conflict_resolution_procedure = optional(string)<br>    }))<br>    indexing_policy = optional(object({<br>      indexing_mode = optional(string, "consistent")<br>      included_paths = optional(list(object({<br>        path = string<br>      })), [])<br>      excluded_paths = optional(list(object({<br>        path = string<br>      })), [])<br>      composite_indexes = optional(list(list(object({<br>        path  = string<br>        order = string<br>      }))), [])<br>      spatial_indexes = optional(list(object({<br>        path  = string<br>        types = optional(list(string))<br>      })), [])<br>    }))<br>    unique_keys = optional(list(object({<br>      paths = list(string)<br>    })), [])<br>  }))</pre> | `{}` | no |
| <a name="input_sql_databases"></a> [sql\_databases](#input\_sql\_databases) | SQL databases keyed by database name. | <pre>map(object({<br>    throughput       = optional(number)<br>    autoscale_max_ru = optional(number)<br>  }))</pre> | `{}` | no |
| <a name="input_sql_role_assignments"></a> [sql\_role\_assignments](#input\_sql\_role\_assignments) | Optional Cosmos DB SQL data-plane role assignments keyed by assignment name. role\_definition\_id may be a built-in or custom role definition resource ID. | <pre>map(object({<br>    principal_id       = string<br>    role_definition_id = string<br>    scope              = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_sql_role_definitions"></a> [sql\_role\_definitions](#input\_sql\_role\_definitions) | Optional custom SQL data-plane role definitions keyed by role name. | <pre>map(object({<br>    assignable_scopes = list(string)<br>    data_actions      = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_system_assigned_identity_enabled"></a> [system\_assigned\_identity\_enabled](#input\_system\_assigned\_identity\_enabled) | Whether to enable a system-assigned managed identity. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to Cosmos DB resources. | `map(string)` | `{}` | no |
| <a name="input_total_throughput_limit"></a> [total\_throughput\_limit](#input\_total\_throughput\_limit) | Optional account-level total throughput limit. Use -1 for no limit. | `number` | `null` | no |
| <a name="input_use_random_suffix"></a> [use\_random\_suffix](#input\_use\_random\_suffix) | Whether generated Cosmos DB names should include a random suffix. | `bool` | `true` | no |
| <a name="input_virtual_network_rules"></a> [virtual\_network\_rules](#input\_virtual\_network\_rules) | Optional subnet rules for service endpoint access. | <pre>list(object({<br>    id                                   = string<br>    ignore_missing_vnet_service_endpoint = optional(bool, false)<br>  }))</pre> | `[]` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Deprecated compatibility input. Supply workload tags explicitly through tags. | `string` | `"project"` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Optional workload segment used when the Cosmos DB account name is generated. | `string` | `""` | no |
| <a name="input_zone_redundant"></a> [zone\_redundant](#input\_zone\_redundant) | Zone redundancy for the default geo location when geo\_locations is not provided. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_admin_group_role_assignment_ids"></a> [app\_admin\_group\_role\_assignment\_ids](#output\_app\_admin\_group\_role\_assignment\_ids) | Admin role assignment IDs keyed by principal key. |
| <a name="output_app_user_group_role_assignment_ids"></a> [app\_user\_group\_role\_assignment\_ids](#output\_app\_user\_group\_role\_assignment\_ids) | Reader role assignment IDs keyed by principal key. |
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | Diagnostic setting ID when diagnostics are enabled. |
| <a name="output_diagnostics_enabled"></a> [diagnostics\_enabled](#output\_diagnostics\_enabled) | Whether diagnostic settings are enabled by this module. |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The Cosmos DB account endpoint. |
| <a name="output_id"></a> [id](#output\_id) | The Cosmos DB account resource ID. |
| <a name="output_identity_type"></a> [identity\_type](#output\_identity\_type) | Configured managed identity type. |
| <a name="output_local_authentication_disabled"></a> [local\_authentication\_disabled](#output\_local\_authentication\_disabled) | Whether key-based local authentication is disabled. |
| <a name="output_merged_tags"></a> [merged\_tags](#output\_merged\_tags) | Final merged tags applied to module resources. |
| <a name="output_name"></a> [name](#output\_name) | The Cosmos DB account name. |
| <a name="output_primary_sql_connection_string"></a> [primary\_sql\_connection\_string](#output\_primary\_sql\_connection\_string) | Primary SQL API connection string. Prefer Entra ID RBAC instead of using this output. |
| <a name="output_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#output\_private\_dns\_zone\_ids) | Private DNS zone IDs attached to the private endpoint. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint ID when private endpoint is enabled. |
| <a name="output_private_endpoint_name"></a> [private\_endpoint\_name](#output\_private\_endpoint\_name) | Private endpoint name when private endpoint is enabled. |
| <a name="output_public_network_access_enabled"></a> [public\_network\_access\_enabled](#output\_public\_network\_access\_enabled) | Whether public network access is enabled. |
| <a name="output_read_endpoints"></a> [read\_endpoints](#output\_read\_endpoints) | Read endpoints for the Cosmos DB account. |
| <a name="output_role_assignment_count"></a> [role\_assignment\_count](#output\_role\_assignment\_count) | Total account-scope Azure role assignment count created by this module. |
| <a name="output_role_assignment_ids"></a> [role\_assignment\_ids](#output\_role\_assignment\_ids) | Additional Azure role assignment IDs keyed by assignment name. |
| <a name="output_sql_container_ids"></a> [sql\_container\_ids](#output\_sql\_container\_ids) | SQL container resource IDs keyed by container name. |
| <a name="output_sql_database_ids"></a> [sql\_database\_ids](#output\_sql\_database\_ids) | SQL database resource IDs keyed by database name. |
| <a name="output_sql_role_assignment_ids"></a> [sql\_role\_assignment\_ids](#output\_sql\_role\_assignment\_ids) | SQL role assignment IDs keyed by assignment name. |
| <a name="output_sql_role_definition_ids"></a> [sql\_role\_definition\_ids](#output\_sql\_role\_definition\_ids) | SQL role definition IDs keyed by role name. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to the Cosmos DB account. |
| <a name="output_write_endpoints"></a> [write\_endpoints](#output\_write\_endpoints) | Write endpoints for the Cosmos DB account. |
<!-- END_TF_DOCS -->
