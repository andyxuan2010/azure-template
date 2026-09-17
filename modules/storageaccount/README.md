# Azure Storage Account

Provisions an Azure Storage account with secure authentication defaults, data-service resources, network rules, private endpoints, diagnostics, managed identities, and storage-scoped RBAC.

## Features

- Disables public network access and anonymous nested-item access by default.
- Defaults supported clients to Microsoft Entra authentication and requires TLS 1.2.
- Creates Blob containers, Azure Files shares, queues, and tables.
- Supports storage firewall rules and one private endpoint per selected data-plane subresource.
- Supports system-assigned and user-assigned identities, customer-managed keys, SFTP/NFS options, immutability, and service properties.
- Supports Microsoft Entra group RBAC, arbitrary role assignments, and Log Analytics diagnostics.

## Resources Created

The module always creates one storage account and a random suffix when an explicit name is not supplied. Network rules are created by default. Containers, shares, queues, tables, identities, role assignments, private endpoints, and diagnostics are conditional.

The target resource group, optional private-endpoint subnet, private DNS zones, execution identity, and Microsoft Entra groups may be read but are not managed.

See [architecture](docs/architecture.md) for the resource and trust boundaries.

## Prerequisites and Dependencies

- An existing resource group
- A private-endpoint subnet and the appropriate `privatelink.<service>.core.windows.net` zones when private connectivity is enabled
- A Log Analytics workspace or other supported destination when diagnostics are enabled
- Key Vault/HSM key access and an eligible identity before enabling customer-managed keys
- Microsoft Entra group object IDs or unique display names when group RBAC is requested
- An execution identity that can create storage resources and all requested role assignments

## Provider Configuration

The caller must configure AzureRM 4.x, AzureAD 3.x, and Random 3.x. The required `azurerm.prod` alias is used for private DNS lookup by name and must be passed even when direct zone IDs are used.

```hcl
providers = {
  azurerm      = azurerm
  azurerm.prod = azurerm.prod
}
```

## Basic Usage

```hcl
module "storageaccount" {
  source = "./modules/storageaccount"

  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name = "rg-app-prod"
  location            = "canadacentral"
  name                = "stappprod001"
}
```

The complete executable configuration is in [`examples/basic`](examples/basic/).

## Important Behavior and Secure Defaults

- Public network access is disabled, network rules are enabled with `Deny`, anonymous nested-item access is disabled, and OAuth is preferred by default. Add a private endpoint or explicit network allowance before expecting data-plane access.
- The current Terraform execution identity receives Contributor plus broad Blob, File, Queue, and Table data-plane roles by default. Set `grant_current_terraform_service_principal_storage_roles = false` when access is managed centrally.
- `app_admin_group` receives Contributor plus broad storage data-plane roles. Review this convenience model against least-privilege requirements.
- Account kind, replication, hierarchical namespace, NFS, SFTP, immutability, and encryption changes can be replacement-sensitive, region/SKU constrained, or cost-sensitive.
- Storage data-service resources require the execution path to reach the storage data plane. Private-only accounts can require a private runner with working DNS.

## Networking and Private Connectivity

Private endpoints can be configured with a direct subnet ID or lookup inputs. Private DNS can use direct zone IDs or names resolved through `azurerm.prod`. Keys in `private_dns_zone_ids` and `private_dns_zone_names` must match lowercase requested subresources such as `blob`, `dfs`, or `file`.

Storage firewall subnet rules use subnet IDs and generally require compatible service-endpoint configuration. Private endpoint policies and DNS links belong to the surrounding network composition.

## Identity and RBAC

The module can attach system-assigned and user-assigned identities. Managed-identity role assignments currently target the system-assigned identity and require exactly one role name or role ID per assignment.

Prefer immutable Microsoft Entra object IDs over display names. Separate control-plane roles from storage data-plane roles and disable broad automatic grants when a central RBAC process owns access.

## Naming and Tagging

Supply a globally unique 3–24 character lowercase alphanumeric name or allow the module to generate one from its naming inputs and a random suffix. Caller tags override inherited resource-group tags. See the repository [naming convention](../../docs/NAMING_CONVENTION.md) and [tagging standard](../../docs/TAGGING_STANDARD.md).

## Examples

- [`basic`](examples/basic/): private-by-default account with broad automatic execution-identity grants disabled
- [`complete`](examples/complete/): private endpoints, diagnostics, identity, and common data services
- [`private-dns-lookup`](examples/private-dns-lookup/): subnet and private DNS lookup by name through `azurerm.prod`

## Testing

`tests/unit.tftest.hcl` uses mocked AzureRM, AzureAD, and Random providers. Its two plan-only tests require no Azure authentication, create no resources, and incur no cost.

```powershell
terraform -chdir=modules/storageaccount init -backend=false
terraform -chdir=modules/storageaccount test
```

## Known Limitations

- The module does not create resource groups, VNets, subnets, private DNS zones, DNS links, Key Vault keys, or monitoring destinations.
- Private-only data-service provisioning may fail from a runner without private network and DNS access even when the control-plane plan succeeds.
- Broad default execution-identity and administrator grants may not meet strict separation-of-duties requirements unless explicitly disabled or replaced.
- Mocked tests cannot prove data-plane reachability, DNS resolution, Microsoft Entra lookup uniqueness, key permissions, or Azure Policy effects.

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
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.app_admin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_admin_group_data_plane](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_user_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.managed_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.terraform_execution_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_network_rules.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_container.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_queue.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_queue) | resource |
| [azurerm_storage_share.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) | resource |
| [azurerm_storage_table.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_table) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tier"></a> [access\_tier](#input\_access\_tier) | Access tier for Standard StorageV2 or BlobStorage accounts. | `string` | `"Hot"` | no |
| <a name="input_account_kind"></a> [account\_kind](#input\_account\_kind) | Defines the storage account kind. | `string` | `"StorageV2"` | no |
| <a name="input_account_replication_type"></a> [account\_replication\_type](#input\_account\_replication\_type) | Defines the replication type for the storage account. | `string` | `"LRS"` | no |
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | Defines the storage account tier. | `string` | `"Standard"` | no |
| <a name="input_allow_nested_items_to_be_public"></a> [allow\_nested\_items\_to\_be\_public](#input\_allow\_nested\_items\_to\_be\_public) | Whether nested blobs and containers can be made public. | `bool` | `false` | no |
| <a name="input_allowed_copy_scope"></a> [allowed\_copy\_scope](#input\_allowed\_copy\_scope) | Restricts permitted copy sources. Valid values are null, AAD, or PrivateLink. | `string` | `null` | no |
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | List of Microsoft Entra group display names or object IDs that should receive Contributor plus Blob, File, Queue, and Table data-plane access to the storage account. Prefer object IDs when display names are not unique. | `list(string)` | `[]` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used for standard tags and generated naming. | `string` | `"dev"` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | List of Microsoft Entra group display names or object IDs that should receive Reader access to the storage account. Prefer object IDs when display names are not unique. | `list(string)` | `[]` | no |
| <a name="input_azure_files_authentication"></a> [azure\_files\_authentication](#input\_azure\_files\_authentication) | Optional Azure Files authentication configuration. | <pre>object({<br>    directory_type                 = string<br>    default_share_level_permission = optional(string)<br>    active_directory = optional(object({<br>      domain_guid         = string<br>      domain_name         = string<br>      domain_sid          = string<br>      forest_name         = string<br>      netbios_domain_name = string<br>      storage_sid         = string<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_blob_properties"></a> [blob\_properties](#input\_blob\_properties) | Optional Blob service data protection settings for the storage account, including versioning, change feed, soft delete, container soft delete, last access time tracking, and point-in-time restore. | <pre>object({<br>    versioning_enabled                               = optional(bool)<br>    change_feed_enabled                              = optional(bool)<br>    change_feed_retention_in_days                    = optional(number)<br>    default_service_version                          = optional(string)<br>    last_access_time_enabled                         = optional(bool)<br>    delete_retention_policy_days                     = optional(number)<br>    delete_retention_policy_permanent_delete_enabled = optional(bool)<br>    container_delete_retention_policy_days           = optional(number)<br>    restore_policy_days                              = optional(number)<br>    cors_rules = optional(list(object({<br>      allowed_headers    = list(string)<br>      allowed_methods    = list(string)<br>      allowed_origins    = list(string)<br>      exposed_headers    = list(string)<br>      max_age_in_seconds = number<br>    })), [])<br>  })</pre> | `null` | no |
| <a name="input_containers"></a> [containers](#input\_containers) | Storage containers to create, keyed by container name. | <pre>map(object({<br>    container_access_type             = optional(string, "private")<br>    default_encryption_scope          = optional(string)<br>    encryption_scope_override_enabled = optional(bool)<br>    metadata                          = optional(map(string), {})<br>  }))</pre> | `{}` | no |
| <a name="input_cross_tenant_replication_enabled"></a> [cross\_tenant\_replication\_enabled](#input\_cross\_tenant\_replication\_enabled) | Whether cross-tenant replication is enabled. | `bool` | `false` | no |
| <a name="input_custom_domain"></a> [custom\_domain](#input\_custom\_domain) | Optional custom domain assigned to the storage account. | <pre>object({<br>    name          = string<br>    use_subdomain = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | Optional customer-managed key configuration. Set one of key\_vault\_key\_id or managed\_hsm\_key\_id. user\_assigned\_identity\_id is required by Azure when using a user-assigned identity for CMK access. | <pre>object({<br>    key_vault_key_id          = optional(string)<br>    managed_hsm_key_id        = optional(string)<br>    user_assigned_identity_id = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_default_to_oauth_authentication"></a> [default\_to\_oauth\_authentication](#input\_default\_to\_oauth\_authentication) | Whether Azure Storage should default requests to Microsoft Entra authorization instead of shared key where supported. | `bool` | `true` | no |
| <a name="input_diagnostic_eventhub_authorization_rule_id"></a> [diagnostic\_eventhub\_authorization\_rule\_id](#input\_diagnostic\_eventhub\_authorization\_rule\_id) | Optional Event Hub authorization rule resource ID for diagnostics. | `string` | `null` | no |
| <a name="input_diagnostic_eventhub_name"></a> [diagnostic\_eventhub\_name](#input\_diagnostic\_eventhub\_name) | Optional Event Hub name for diagnostics when using an Event Hub destination. | `string` | `null` | no |
| <a name="input_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#input\_diagnostic\_log\_categories) | Diagnostic log categories to enable. | `list(string)` | <pre>[<br>  "StorageRead",<br>  "StorageWrite",<br>  "StorageDelete"<br>]</pre> | no |
| <a name="input_diagnostic_metric_categories"></a> [diagnostic\_metric\_categories](#input\_diagnostic\_metric\_categories) | Diagnostic metric categories to enable. | `list(string)` | <pre>[<br>  "Transaction"<br>]</pre> | no |
| <a name="input_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#input\_diagnostic\_setting\_name) | Optional diagnostic setting name. When empty, the module uses <storage-account-name>-diagnostic-setting. | `string` | `""` | no |
| <a name="input_diagnostic_storage_account_id"></a> [diagnostic\_storage\_account\_id](#input\_diagnostic\_storage\_account\_id) | Optional Storage Account resource ID for diagnostic archive. | `string` | `null` | no |
| <a name="input_dns_endpoint_type"></a> [dns\_endpoint\_type](#input\_dns\_endpoint\_type) | DNS endpoint type for the storage account. | `string` | `"Standard"` | no |
| <a name="input_edge_zone"></a> [edge\_zone](#input\_edge\_zone) | Optional Azure edge zone where the storage account should be created. | `string` | `null` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Enable diagnostic settings for the storage account. Diagnostics are also enabled when at least one diagnostic destination is supplied. | `bool` | `false` | no |
| <a name="input_enable_network_rules"></a> [enable\_network\_rules](#input\_enable\_network\_rules) | Whether to manage storage account network rules. | `bool` | `true` | no |
| <a name="input_file_shares"></a> [file\_shares](#input\_file\_shares) | Azure Files shares to create, keyed by share name. | <pre>map(object({<br>    quota            = optional(number, 100)<br>    access_tier      = optional(string)<br>    enabled_protocol = optional(string, "SMB")<br>    metadata         = optional(map(string), {})<br>  }))</pre> | `{}` | no |
| <a name="input_grant_current_terraform_service_principal_storage_roles"></a> [grant\_current\_terraform\_service\_principal\_storage\_roles](#input\_grant\_current\_terraform\_service\_principal\_storage\_roles) | Whether to assign Contributor plus full storage data-plane roles for Blob, File, Queue, and Table services to the current Terraform execution identity at the storage account scope. | `bool` | `true` | no |
| <a name="input_https_traffic_only_enabled"></a> [https\_traffic\_only\_enabled](#input\_https\_traffic\_only\_enabled) | Whether to require HTTPS traffic only. | `bool` | `true` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | User-assigned managed identity IDs to attach to the storage account. | `list(string)` | `[]` | no |
| <a name="input_immutability_policy"></a> [immutability\_policy](#input\_immutability\_policy) | Optional account-level immutability policy. | <pre>object({<br>    allow_protected_append_writes = optional(bool, false)<br>    period_since_creation_in_days = number<br>    state                         = optional(string, "Unlocked")<br>  })</pre> | `null` | no |
| <a name="input_include_environment_in_name"></a> [include\_environment\_in\_name](#input\_include\_environment\_in\_name) | Whether generated storage account names include app\_env. | `bool` | `true` | no |
| <a name="input_infrastructure_encryption_enabled"></a> [infrastructure\_encryption\_enabled](#input\_infrastructure\_encryption\_enabled) | Whether infrastructure encryption is enabled. | `bool` | `false` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into module resources. The module only reads the resource group when this is true or location is empty. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Optional instance segment used when generated names do not use a random suffix. | `string` | `"001"` | no |
| <a name="input_is_hns_enabled"></a> [is\_hns\_enabled](#input\_is\_hns\_enabled) | Whether hierarchical namespace is enabled. | `bool` | `false` | no |
| <a name="input_large_file_share_enabled"></a> [large\_file\_share\_enabled](#input\_large\_file\_share\_enabled) | Whether large file shares are enabled for the storage account. | `bool` | `null` | no |
| <a name="input_local_user_enabled"></a> [local\_user\_enabled](#input\_local\_user\_enabled) | Whether local users are enabled for the storage account. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where to deploy the resource. If empty, the resource group's location is used. | `string` | `""` | no |
| <a name="input_location_code"></a> [location\_code](#input\_location\_code) | Optional short location code used when the storage account name is generated. | `string` | `""` | no |
| <a name="input_log_analytics_destination_type"></a> [log\_analytics\_destination\_type](#input\_log\_analytics\_destination\_type) | Destination type for Log Analytics diagnostics. | `string` | `"Dedicated"` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Optional Log Analytics workspace resource ID for diagnostics. | `string` | `""` | no |
| <a name="input_managed_identity_role_assignments"></a> [managed\_identity\_role\_assignments](#input\_managed\_identity\_role\_assignments) | Role assignments to apply to the system-assigned managed identity. Each item must set exactly one of role\_definition\_name or role\_definition\_id. | <pre>map(object({<br>    scope                = string<br>    role_definition_name = optional(string)<br>    role_definition_id   = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_min_tls_version"></a> [min\_tls\_version](#input\_min\_tls\_version) | The minimum supported TLS version. | `string` | `"TLS1_2"` | no |
| <a name="input_name"></a> [name](#input\_name) | Storage account name. If empty, the module auto-generates a compliant name. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used when the storage account name is generated. Non-alphanumeric characters are removed. | `string` | `"st"` | no |
| <a name="input_network_rules_bypass"></a> [network\_rules\_bypass](#input\_network\_rules\_bypass) | Traffic classes to bypass the network rules. | `list(string)` | <pre>[<br>  "AzureServices"<br>]</pre> | no |
| <a name="input_network_rules_default_action"></a> [network\_rules\_default\_action](#input\_network\_rules\_default\_action) | Default action for storage account network rules. | `string` | `"Deny"` | no |
| <a name="input_network_rules_ip_rules"></a> [network\_rules\_ip\_rules](#input\_network\_rules\_ip\_rules) | IPv4 addresses or CIDR ranges allowed by network rules. | `list(string)` | `[]` | no |
| <a name="input_network_rules_private_link_access"></a> [network\_rules\_private\_link\_access](#input\_network\_rules\_private\_link\_access) | Private Link resources that are allowed to access the storage account through network rules. | <pre>list(object({<br>    endpoint_resource_id = string<br>    endpoint_tenant_id   = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_network_rules_virtual_network_subnet_ids"></a> [network\_rules\_virtual\_network\_subnet\_ids](#input\_network\_rules\_virtual\_network\_subnet\_ids) | Subnet resource IDs allowed by network rules. | `list(string)` | `[]` | no |
| <a name="input_nfsv3_enabled"></a> [nfsv3\_enabled](#input\_nfsv3\_enabled) | Whether NFSv3 is enabled. | `bool` | `false` | no |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | Optional private DNS zone IDs keyed by private endpoint subresource name. | `map(string)` | `{}` | no |
| <a name="input_private_dns_zone_names"></a> [private\_dns\_zone\_names](#input\_private\_dns\_zone\_names) | Optional private DNS zone names keyed by private endpoint subresource name. Used with private\_dns\_zone\_resource\_group\_name when private\_dns\_zone\_ids are not supplied for those keys. | `map(string)` | `{}` | no |
| <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name) | Resource group containing the private DNS zones used for storage account private endpoints. | `string` | `null` | no |
| <a name="input_private_endpoint_name_prefix"></a> [private\_endpoint\_name\_prefix](#input\_private\_endpoint\_name\_prefix) | Prefix used for generated private endpoint names. | `string` | `"pep"` | no |
| <a name="input_private_endpoint_network_resource_group_name"></a> [private\_endpoint\_network\_resource\_group\_name](#input\_private\_endpoint\_network\_resource\_group\_name) | Resource group containing the virtual network used for private endpoint subnet lookup. | `string` | `null` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | Subnet ID for the private endpoint. If set, subnet lookup inputs are ignored. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#input\_private\_endpoint\_subnet\_name) | Existing subnet name used for private endpoint lookup when private\_endpoint\_subnet\_id is not set. | `string` | `null` | no |
| <a name="input_private_endpoint_subresource_names"></a> [private\_endpoint\_subresource\_names](#input\_private\_endpoint\_subresource\_names) | Storage private endpoint subresources to create. Valid values: blob, dfs, file, queue, table, web. | `list(string)` | `[]` | no |
| <a name="input_private_endpoint_vnet_name"></a> [private\_endpoint\_vnet\_name](#input\_private\_endpoint\_vnet\_name) | Existing virtual network name used for private endpoint subnet lookup. | `string` | `null` | no |
| <a name="input_private_service_connection_name_prefix"></a> [private\_service\_connection\_name\_prefix](#input\_private\_service\_connection\_name\_prefix) | Prefix used for generated private service connection names. | `string` | `"psc"` | no |
| <a name="input_provisioned_billing_model_version"></a> [provisioned\_billing\_model\_version](#input\_provisioned\_billing\_model\_version) | Optional provisioned billing model version for supported premium storage account types. | `string` | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether the storage account public endpoint is reachable. | `bool` | `false` | no |
| <a name="input_queue_encryption_key_type"></a> [queue\_encryption\_key\_type](#input\_queue\_encryption\_key\_type) | Encryption key type for Queue service. | `string` | `"Service"` | no |
| <a name="input_queue_properties"></a> [queue\_properties](#input\_queue\_properties) | Optional Queue service properties. | <pre>object({<br>    cors_rules = optional(list(object({<br>      allowed_headers    = list(string)<br>      allowed_methods    = list(string)<br>      allowed_origins    = list(string)<br>      exposed_headers    = list(string)<br>      max_age_in_seconds = number<br>    })), [])<br>    logging = optional(object({<br>      delete                = bool<br>      read                  = bool<br>      write                 = bool<br>      version               = string<br>      retention_policy_days = optional(number)<br>    }))<br>    hour_metrics = optional(object({<br>      enabled               = bool<br>      version               = string<br>      include_apis          = optional(bool)<br>      retention_policy_days = optional(number)<br>    }))<br>    minute_metrics = optional(object({<br>      enabled               = bool<br>      version               = string<br>      include_apis          = optional(bool)<br>      retention_policy_days = optional(number)<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_queues"></a> [queues](#input\_queues) | Storage queues to create, keyed by queue name. | <pre>map(object({<br>    metadata = optional(map(string), {})<br>  }))</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the storage account will be deployed. | `string` | n/a | yes |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | Additional role assignments to create at the storage account scope, keyed by a stable name. | <pre>map(object({<br>    principal_id                           = string<br>    role_definition_name                   = optional(string)<br>    role_definition_id                     = optional(string)<br>    principal_type                         = optional(string)<br>    description                            = optional(string)<br>    name                                   = optional(string)<br>    condition                              = optional(string)<br>    condition_version                      = optional(string)<br>    delegated_managed_identity_resource_id = optional(string)<br>    skip_service_principal_aad_check       = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_routing"></a> [routing](#input\_routing) | Optional routing configuration for Microsoft and internet endpoint publishing. | <pre>object({<br>    choice                      = optional(string, "MicrosoftRouting")<br>    publish_internet_endpoints  = optional(bool, false)<br>    publish_microsoft_endpoints = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_sas_policy"></a> [sas\_policy](#input\_sas\_policy) | Optional shared access signature expiration policy. | <pre>object({<br>    expiration_action = optional(string, "Log")<br>    expiration_period = string<br>  })</pre> | `null` | no |
| <a name="input_sftp_enabled"></a> [sftp\_enabled](#input\_sftp\_enabled) | Whether SFTP is enabled. | `bool` | `false` | no |
| <a name="input_share_properties"></a> [share\_properties](#input\_share\_properties) | Optional Azure Files service properties. | <pre>object({<br>    cors_rules = optional(list(object({<br>      allowed_headers    = list(string)<br>      allowed_methods    = list(string)<br>      allowed_origins    = list(string)<br>      exposed_headers    = list(string)<br>      max_age_in_seconds = number<br>    })), [])<br>    retention_policy_days = optional(number)<br>    smb = optional(object({<br>      authentication_types            = optional(list(string))<br>      channel_encryption_type         = optional(list(string))<br>      kerberos_ticket_encryption_type = optional(list(string))<br>      multichannel_enabled            = optional(bool)<br>      versions                        = optional(list(string))<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_shared_access_key_enabled"></a> [shared\_access\_key\_enabled](#input\_shared\_access\_key\_enabled) | Whether shared access keys are enabled. | `bool` | `true` | no |
| <a name="input_static_website"></a> [static\_website](#input\_static\_website) | Optional static website configuration. | <pre>object({<br>    index_document     = optional(string)<br>    error_404_document = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_system_managed_identity_enabled"></a> [system\_managed\_identity\_enabled](#input\_system\_managed\_identity\_enabled) | Whether to enable a system-assigned managed identity. | `bool` | `false` | no |
| <a name="input_table_encryption_key_type"></a> [table\_encryption\_key\_type](#input\_table\_encryption\_key\_type) | Encryption key type for Table service. | `string` | `"Service"` | no |
| <a name="input_tables"></a> [tables](#input\_tables) | Storage tables to create, keyed by table name. | `map(object({}))` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resources. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional timeouts for storage account create, read, update, and delete operations. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_use_random_suffix"></a> [use\_random\_suffix](#input\_use\_random\_suffix) | Whether generated storage account names should include a random suffix. | `bool` | `true` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier used in tagging. | `string` | `"project"` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Optional workload segment used when the storage account name is generated. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_kind"></a> [account\_kind](#output\_account\_kind) | The storage account kind. |
| <a name="output_account_replication_type"></a> [account\_replication\_type](#output\_account\_replication\_type) | The storage account replication type. |
| <a name="output_account_tier"></a> [account\_tier](#output\_account\_tier) | The storage account tier. |
| <a name="output_app_admin_group_data_plane_role_assignment_ids"></a> [app\_admin\_group\_data\_plane\_role\_assignment\_ids](#output\_app\_admin\_group\_data\_plane\_role\_assignment\_ids) | Map of storage data-plane role assignment IDs keyed by app\_admin\_group input and role. |
| <a name="output_app_admin_group_principal_ids"></a> [app\_admin\_group\_principal\_ids](#output\_app\_admin\_group\_principal\_ids) | Map of resolved admin group principal IDs keyed by app\_admin\_group input. |
| <a name="output_app_admin_group_role_assignment_ids"></a> [app\_admin\_group\_role\_assignment\_ids](#output\_app\_admin\_group\_role\_assignment\_ids) | Map of Contributor role assignment IDs keyed by app\_admin\_group input. |
| <a name="output_app_env"></a> [app\_env](#output\_app\_env) | The deployment environment used by the module. |
| <a name="output_app_user_group_principal_ids"></a> [app\_user\_group\_principal\_ids](#output\_app\_user\_group\_principal\_ids) | Map of resolved Reader group principal IDs keyed by app\_user\_group input. |
| <a name="output_app_user_group_role_assignment_ids"></a> [app\_user\_group\_role\_assignment\_ids](#output\_app\_user\_group\_role\_assignment\_ids) | Map of Reader role assignment IDs keyed by app\_user\_group display name. |
| <a name="output_container_ids"></a> [container\_ids](#output\_container\_ids) | Map of storage container IDs keyed by container name. |
| <a name="output_default_to_oauth_authentication"></a> [default\_to\_oauth\_authentication](#output\_default\_to\_oauth\_authentication) | Whether the storage account defaults requests to Microsoft Entra authorization where supported. |
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | The ID of the diagnostic setting, if created. |
| <a name="output_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#output\_diagnostic\_setting\_name) | The effective diagnostic setting name. |
| <a name="output_diagnostics_enabled"></a> [diagnostics\_enabled](#output\_diagnostics\_enabled) | Whether diagnostics are enabled by this module. |
| <a name="output_file_share_ids"></a> [file\_share\_ids](#output\_file\_share\_ids) | Map of Azure Files share IDs keyed by share name. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the storage account. |
| <a name="output_identity"></a> [identity](#output\_identity) | The identity block of the storage account. |
| <a name="output_identity_type"></a> [identity\_type](#output\_identity\_type) | The resolved managed identity type assigned to the storage account. |
| <a name="output_location"></a> [location](#output\_location) | The location of the storage account. |
| <a name="output_location_code"></a> [location\_code](#output\_location\_code) | The resolved location code used for generated naming. |
| <a name="output_managed_identity_role_assignment_ids"></a> [managed\_identity\_role\_assignment\_ids](#output\_managed\_identity\_role\_assignment\_ids) | Map of managed identity role assignment IDs keyed by assignment name. |
| <a name="output_name"></a> [name](#output\_name) | The name of the storage account. |
| <a name="output_network_rules_config"></a> [network\_rules\_config](#output\_network\_rules\_config) | Effective storage account network rule configuration. |
| <a name="output_network_rules_id"></a> [network\_rules\_id](#output\_network\_rules\_id) | The ID of the storage account network rules resource, if created. |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | The primary blob endpoint. |
| <a name="output_primary_dfs_endpoint"></a> [primary\_dfs\_endpoint](#output\_primary\_dfs\_endpoint) | The primary Data Lake endpoint. |
| <a name="output_primary_file_endpoint"></a> [primary\_file\_endpoint](#output\_primary\_file\_endpoint) | The primary file endpoint. |
| <a name="output_primary_queue_endpoint"></a> [primary\_queue\_endpoint](#output\_primary\_queue\_endpoint) | The primary queue endpoint. |
| <a name="output_primary_table_endpoint"></a> [primary\_table\_endpoint](#output\_primary\_table\_endpoint) | The primary table endpoint. |
| <a name="output_primary_web_endpoint"></a> [primary\_web\_endpoint](#output\_primary\_web\_endpoint) | The primary static website endpoint. |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | The principal ID of the system-assigned managed identity, if enabled. |
| <a name="output_private_endpoint_fqdns"></a> [private\_endpoint\_fqdns](#output\_private\_endpoint\_fqdns) | Map of private endpoint FQDN lists keyed by storage subresource. |
| <a name="output_private_endpoint_ids"></a> [private\_endpoint\_ids](#output\_private\_endpoint\_ids) | Map of private endpoint IDs keyed by storage subresource. |
| <a name="output_private_endpoint_ip_addresses"></a> [private\_endpoint\_ip\_addresses](#output\_private\_endpoint\_ip\_addresses) | Map of private endpoint IP address lists keyed by storage subresource. |
| <a name="output_private_endpoint_names"></a> [private\_endpoint\_names](#output\_private\_endpoint\_names) | Map of private endpoint names keyed by storage subresource. |
| <a name="output_queue_ids"></a> [queue\_ids](#output\_queue\_ids) | Map of storage queue IDs keyed by queue name. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group containing the storage account. |
| <a name="output_role_assignment_count"></a> [role\_assignment\_count](#output\_role\_assignment\_count) | Total number of role assignments requested by this module. |
| <a name="output_role_assignment_ids"></a> [role\_assignment\_ids](#output\_role\_assignment\_ids) | Map of additional role assignment IDs keyed by role\_assignments input. |
| <a name="output_table_ids"></a> [table\_ids](#output\_table\_ids) | Map of storage table IDs keyed by table name. |
| <a name="output_tags"></a> [tags](#output\_tags) | The effective tags assigned to the storage account. |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | The tenant ID of the system-assigned managed identity, if enabled. |
| <a name="output_terraform_execution_identity_role_assignment_ids"></a> [terraform\_execution\_identity\_role\_assignment\_ids](#output\_terraform\_execution\_identity\_role\_assignment\_ids) | Map of role assignment IDs created for the current Terraform execution identity. |
<!-- END_TF_DOCS -->
