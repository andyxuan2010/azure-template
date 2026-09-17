# Azure SQL Database

Creates an Azure SQL logical server and one database with private connectivity, Microsoft Entra administration, managed identities, encryption controls, auditing, threat detection, diagnostics, backup policies, RBAC, import or restore modes, and an optional failover group.

## Features

- Explicit or generated server and database names
- Microsoft Entra-only or mixed SQL and Entra authentication
- System-assigned and user-assigned server identities
- User-assigned database identity and customer-managed transparent data encryption keys
- Private Endpoint with direct or name-based subnet and Private DNS lookup
- Server and database auditing and threat detection
- Log Analytics, Storage Account, or Event Hub diagnostic destinations
- Short- and long-term backup retention, serverless, elastic-pool, restore, import, ledger, replica, and read-scale options
- Common and custom Azure RBAC assignments
- Optional SQL failover group
- Eligible Azure SQL free-limit configuration through AzAPI

## Resources Created

The module always creates one `azurerm_mssql_server` and one `azurerm_mssql_database`.

Depending on inputs, it also creates firewall rules, server and database auditing policies, a server security alert policy, a diagnostic setting, a Private Endpoint, RBAC assignments, a failover group, and an `azapi_update_resource` for the free-limit setting.

The module looks up but does not create the resource group, subnet, Private DNS zones, Key Vault secrets, Microsoft Entra groups, monitoring destinations, identities, keys, elastic pool, or failover partner.

## Prerequisites and Dependencies

- Existing resource group and a globally unique logical server name
- Microsoft Entra administrator name and object ID when Entra administration is enabled
- SQL administrator credentials or Key Vault secrets unless Entra-only authentication is enabled
- Existing Private Endpoint subnet and SQL Private DNS zone when private access is enabled
- Existing monitoring destinations for diagnostics, auditing, or threat detection
- Existing user-assigned identities and Key Vault keys for customer-managed encryption
- Existing secondary logical server for a failover group
- Regional SKU capacity, feature support, quota, and required Azure permissions

## Provider Configuration

The caller supplies `azurerm`, `azapi`, `azuread`, and `random` provider configurations. No provider blocks are declared inside the module.

The execution identity needs permission to create SQL resources and optional network, monitoring, RBAC, and failover resources. Name-based Microsoft Entra group lookups require directory read access.

## Basic Usage

```hcl
module "sqldb" {
  source = "./modules/sqldb"

  resource_group_name = "rg-data-prod"
  location            = "canadacentral"
  server_name         = "sql-data-prod-001"
  name                = "orders"

  azuread_authentication_only = true
  ad_admin_login_name         = "sql-admins"
  ad_admin_object_id          = var.sql_admin_group_object_id

  public_network_access_enabled = false
  enable_private_endpoint       = true
  private_endpoint_subnet_id    = module.vnet.subnet_ids["private-endpoints"]
  private_dns_zone_ids          = [module.private_dns.zone_ids["privatelink.database.windows.net"]]
}
```

See [examples/basic](./examples/basic), [examples/complete](./examples/complete), and [examples/serverless-free-limit](./examples/serverless-free-limit).

## Important Behavior and Secure Defaults

Public network access is disabled and a Private Endpoint is enabled by default. The caller must provide a subnet ID or the complete subnet lookup inputs. Server auditing and a system-assigned identity are also enabled by default.

Microsoft Entra administration defaults on and therefore requires `ad_admin_login_name` and `ad_admin_object_id`. When Entra-only authentication is false, explicitly supply SQL admin credentials or approved Key Vault secret inputs. Compatibility fallback credential values exist in the implementation and must never be used for a real deployment.

Changing server names, database create modes, identity or encryption configuration, ledger settings, backup redundancy, or networking can replace resources or require migration. Review the plan and Azure feature constraints for the selected SKU.

## Networking and Private Connectivity

Prefer a direct `private_endpoint_subnet_id` and `private_dns_zone_ids` from upstream module outputs. Name-based subnet and zone lookup uses the default AzureRM provider and is intended for resources accessible through that provider context.

Disabling public access does not validate DNS or client routing. The caller owns VNet links, hybrid forwarding, subnet policy, NSGs, routes, approval for manual connections, and end-to-end SQL connectivity tests.

If public access is deliberately enabled, use narrow firewall ranges. `allow_azure_services` creates the broad Azure-services firewall rule and should be used only after a security review.

## Identity, Authentication, and RBAC

Prefer Entra-only authentication. SQL credentials, Key Vault secret values, database import keys, auditing keys, and other sensitive provider values can be present in Terraform state; protect and restrict the state backend.

Customer-managed server encryption requires a server identity with Key Vault key permissions. Database-level customer-managed encryption requires a user-assigned database identity; automatic key rotation requires a database key ID.

`app_admin_group` and `app_user_group` create configurable control-plane role assignments at server scope. `role_assignments` supports server, database, or explicit resource scopes. Azure RBAC does not create contained database users or grant Transact-SQL roles.

## Backup, Resilience, and Operations

Short-term retention is always configured. Long-term retention is optional and requires at least one non-zero weekly, monthly, or yearly period. Production long-term retention is guarded by the module's diagnostics consistency check.

A failover group requires an existing partner server. Replica database creation, application connection-string failover behavior, planned failover procedures, recovery testing, and data residency review remain operational responsibilities.

The free-limit option is intended only for eligible General Purpose serverless databases. Eligibility, included usage, and exhaustion behavior are enforced by Azure, not inferred by this module.

## Naming and Tagging

Use `name` for the database name; `database_name` remains a deprecated compatibility alias. Server and database generators combine prefixes, workload, optional environment, location code, and instance or random suffix. See the repository [naming convention](../../docs/NAMING_CONVENTION.md) and [tagging standard](../../docs/TAGGING_STANDARD.md).

## Testing

```powershell
terraform init -backend=false
terraform test -filter=tests/unit.tftest.hcl
```

The unit suite mocks AzureRM, AzAPI, AzureAD, and Random and runs plan-only and expected-failure assertions. It requires no cloud authentication and creates no resources.

## Known Limitations

- One logical server and one primary database are managed per module instance.
- Private networking, DNS links, identities, keys, monitoring destinations, and failover partners must already exist.
- Microsoft Entra directory roles and SQL contained users are not managed.
- Some SKU and feature combinations are validated only by Azure during plan or apply.
- Database import and restore settings are mutually constrained by the provider and may be create-time only.
- Existing resources and matching RBAC assignments must be imported before this module can own them.

See [Architecture and Security Boundaries](./docs/architecture.md).

## Terraform Reference

The content below is generated by `terraform-docs`. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 2.0, < 3.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 3.0, < 4.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | >= 2.0, < 3.0 |
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >= 3.0, < 4.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, < 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0, < 4.0 |

## Resources

| Name | Type |
|------|------|
| [azapi_update_resource.free_limit](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/update_resource) | resource |
| [azurerm_monitor_diagnostic_setting.sql_diagnostics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_mssql_database.sql_db](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) | resource |
| [azurerm_mssql_database_extended_auditing_policy.audit](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database_extended_auditing_policy) | resource |
| [azurerm_mssql_failover_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_failover_group) | resource |
| [azurerm_mssql_firewall_rule.azure_services](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_firewall_rule) | resource |
| [azurerm_mssql_firewall_rule.sql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_firewall_rule) | resource |
| [azurerm_mssql_server.sql_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server) | resource |
| [azurerm_mssql_server_extended_auditing_policy.audit](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_extended_auditing_policy) | resource |
| [azurerm_mssql_server_security_alert_policy.threat_detection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_security_alert_policy) | resource |
| [azurerm_private_endpoint.sql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.app_admin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_user_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ad_admin_login_name"></a> [ad\_admin\_login\_name](#input\_ad\_admin\_login\_name) | Microsoft Entra administrator display name or login username for the SQL server. | `string` | `""` | no |
| <a name="input_ad_admin_object_id"></a> [ad\_admin\_object\_id](#input\_ad\_admin\_object\_id) | Microsoft Entra object ID for the SQL server administrator. | `string` | `""` | no |
| <a name="input_admin_credentials_key_vault_id"></a> [admin\_credentials\_key\_vault\_id](#input\_admin\_credentials\_key\_vault\_id) | Optional Key Vault resource ID containing SQL admin username and password secrets. | `string` | `""` | no |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | SQL administrator password. Prefer Key Vault-backed values for production. | `string` | `null` | no |
| <a name="input_admin_password_secret_name"></a> [admin\_password\_secret\_name](#input\_admin\_password\_secret\_name) | Key Vault secret name containing the SQL admin password. Used only when admin\_password is not set. | `string` | `"azure-password"` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | SQL administrator username. Prefer Key Vault-backed values for production. | `string` | `null` | no |
| <a name="input_admin_username_secret_name"></a> [admin\_username\_secret\_name](#input\_admin\_username\_secret\_name) | Key Vault secret name containing the SQL admin username. Used only when admin\_username is not set. | `string` | `"azure-user"` | no |
| <a name="input_allow_azure_services"></a> [allow\_azure\_services](#input\_allow\_azure\_services) | Whether to add the Azure SQL firewall rule that allows Azure services and resources to access the server public endpoint. | `bool` | `false` | no |
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | Microsoft Entra group display names or object IDs that receive the admin Azure RBAC role at SQL server scope. | `list(string)` | `[]` | no |
| <a name="input_app_admin_role_definition_name"></a> [app\_admin\_role\_definition\_name](#input\_app\_admin\_role\_definition\_name) | Azure role assigned to app\_admin\_group principals at SQL server scope. | `string` | `"SQL Server Contributor"` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used for standard tags and generated naming. | `string` | `"dev"` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | Microsoft Entra group display names or object IDs that receive the user Azure RBAC role at SQL server scope. | `list(string)` | `[]` | no |
| <a name="input_app_user_role_definition_name"></a> [app\_user\_role\_definition\_name](#input\_app\_user\_role\_definition\_name) | Azure role assigned to app\_user\_group principals at SQL server scope. | `string` | `"Reader"` | no |
| <a name="input_audit_actions_and_groups"></a> [audit\_actions\_and\_groups](#input\_audit\_actions\_and\_groups) | Optional audit action groups for server-level auditing. | `list(string)` | `[]` | no |
| <a name="input_audit_log_monitoring_enabled"></a> [audit\_log\_monitoring\_enabled](#input\_audit\_log\_monitoring\_enabled) | Whether server-level auditing sends audit events to Azure Monitor. | `bool` | `true` | no |
| <a name="input_audit_predicate_expression"></a> [audit\_predicate\_expression](#input\_audit\_predicate\_expression) | Optional predicate expression for server-level auditing. | `string` | `""` | no |
| <a name="input_audit_retention_days"></a> [audit\_retention\_days](#input\_audit\_retention\_days) | Audit retention in days. Set 0 for indefinite retention. | `number` | `30` | no |
| <a name="input_audit_storage_account_access_key"></a> [audit\_storage\_account\_access\_key](#input\_audit\_storage\_account\_access\_key) | Optional storage account access key for server-level auditing. | `string` | `""` | no |
| <a name="input_audit_storage_account_access_key_is_secondary"></a> [audit\_storage\_account\_access\_key\_is\_secondary](#input\_audit\_storage\_account\_access\_key\_is\_secondary) | Whether the secondary storage key is used for server-level auditing. | `bool` | `false` | no |
| <a name="input_audit_storage_account_subscription_id"></a> [audit\_storage\_account\_subscription\_id](#input\_audit\_storage\_account\_subscription\_id) | Optional subscription ID for the server-level audit storage account. | `string` | `""` | no |
| <a name="input_audit_storage_endpoint"></a> [audit\_storage\_endpoint](#input\_audit\_storage\_endpoint) | Optional storage endpoint for server-level auditing. | `string` | `""` | no |
| <a name="input_auto_pause_delay_in_minutes"></a> [auto\_pause\_delay\_in\_minutes](#input\_auto\_pause\_delay\_in\_minutes) | Serverless auto-pause delay in minutes. Set -1 to disable auto-pause. Only valid for serverless SKUs. | `number` | `null` | no |
| <a name="input_azuread_admin_tenant_id"></a> [azuread\_admin\_tenant\_id](#input\_azuread\_admin\_tenant\_id) | Optional Microsoft Entra tenant ID for the SQL server administrator. | `string` | `""` | no |
| <a name="input_azuread_administrator_enabled"></a> [azuread\_administrator\_enabled](#input\_azuread\_administrator\_enabled) | Whether to configure a Microsoft Entra administrator on the SQL server. | `bool` | `true` | no |
| <a name="input_azuread_authentication_only"></a> [azuread\_authentication\_only](#input\_azuread\_authentication\_only) | Whether to enable Microsoft Entra-only authentication. Requires a Microsoft Entra administrator. | `bool` | `false` | no |
| <a name="input_backup_interval_in_hours"></a> [backup\_interval\_in\_hours](#input\_backup\_interval\_in\_hours) | Short-term backup interval in hours. | `number` | `12` | no |
| <a name="input_backup_retention_days"></a> [backup\_retention\_days](#input\_backup\_retention\_days) | Short-term backup retention period in days. | `number` | `7` | no |
| <a name="input_backup_storage_redundancy"></a> [backup\_storage\_redundancy](#input\_backup\_storage\_redundancy) | Backup storage redundancy for the SQL database. | `string` | `"Local"` | no |
| <a name="input_collation"></a> [collation](#input\_collation) | Database collation setting. | `string` | `"SQL_Latin1_General_CP1_CI_AS"` | no |
| <a name="input_connection_policy"></a> [connection\_policy](#input\_connection\_policy) | SQL server connection policy. | `string` | `"Default"` | no |
| <a name="input_create_mode"></a> [create\_mode](#input\_create\_mode) | Database create mode. | `string` | `"Default"` | no |
| <a name="input_creation_source_database_id"></a> [creation\_source\_database\_id](#input\_creation\_source\_database\_id) | Source database ID used by copy and restore create modes. | `string` | `""` | no |
| <a name="input_database_audit_log_monitoring_enabled"></a> [database\_audit\_log\_monitoring\_enabled](#input\_database\_audit\_log\_monitoring\_enabled) | Whether database-level auditing sends audit events to Azure Monitor. | `bool` | `true` | no |
| <a name="input_database_audit_retention_days"></a> [database\_audit\_retention\_days](#input\_database\_audit\_retention\_days) | Database-level audit retention in days. Defaults to audit\_retention\_days when null. | `number` | `null` | no |
| <a name="input_database_audit_storage_account_access_key"></a> [database\_audit\_storage\_account\_access\_key](#input\_database\_audit\_storage\_account\_access\_key) | Optional storage account access key for database-level auditing. | `string` | `""` | no |
| <a name="input_database_audit_storage_account_access_key_is_secondary"></a> [database\_audit\_storage\_account\_access\_key\_is\_secondary](#input\_database\_audit\_storage\_account\_access\_key\_is\_secondary) | Whether the secondary storage key is used for database-level auditing. | `bool` | `false` | no |
| <a name="input_database_audit_storage_endpoint"></a> [database\_audit\_storage\_endpoint](#input\_database\_audit\_storage\_endpoint) | Optional storage endpoint for database-level auditing. | `string` | `""` | no |
| <a name="input_database_identity_ids"></a> [database\_identity\_ids](#input\_database\_identity\_ids) | Optional user-assigned managed identity IDs for the SQL database. | `list(string)` | `[]` | no |
| <a name="input_database_import"></a> [database\_import](#input\_database\_import) | Optional import block used to create the database from a BACPAC. | <pre>object({<br>    administrator_login          = string<br>    administrator_login_password = string<br>    authentication_type          = string<br>    storage_account_id           = optional(string)<br>    storage_key                  = string<br>    storage_key_type             = string<br>    storage_uri                  = string<br>  })</pre> | `null` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Deprecated alias for name. Use name for the Azure SQL database name override. | `string` | `""` | no |
| <a name="input_database_name_prefix"></a> [database\_name\_prefix](#input\_database\_name\_prefix) | Prefix used when the SQL database name is generated. | `string` | `"sqldb"` | no |
| <a name="input_database_timeouts"></a> [database\_timeouts](#input\_database\_timeouts) | Optional create/read/update/delete timeouts for the SQL database. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_database_transparent_data_encryption_key_automatic_rotation_enabled"></a> [database\_transparent\_data\_encryption\_key\_automatic\_rotation\_enabled](#input\_database\_transparent\_data\_encryption\_key\_automatic\_rotation\_enabled) | Whether automatic key rotation is enabled for the database TDE key. | `bool` | `null` | no |
| <a name="input_database_transparent_data_encryption_key_vault_key_id"></a> [database\_transparent\_data\_encryption\_key\_vault\_key\_id](#input\_database\_transparent\_data\_encryption\_key\_vault\_key\_id) | Optional Key Vault key ID used for database-level transparent data encryption. | `string` | `""` | no |
| <a name="input_diagnostic_eventhub_authorization_rule_id"></a> [diagnostic\_eventhub\_authorization\_rule\_id](#input\_diagnostic\_eventhub\_authorization\_rule\_id) | Optional Event Hub authorization rule ID for diagnostics. | `string` | `""` | no |
| <a name="input_diagnostic_eventhub_name"></a> [diagnostic\_eventhub\_name](#input\_diagnostic\_eventhub\_name) | Optional Event Hub name for diagnostics. | `string` | `null` | no |
| <a name="input_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#input\_diagnostic\_log\_categories) | Diagnostic log categories to enable for the SQL database. Use AllLogs to enable the provider category group. | `list(string)` | <pre>[<br>  "SQLInsights",<br>  "AutomaticTuning",<br>  "QueryStoreRuntimeStatistics",<br>  "QueryStoreWaitStatistics",<br>  "Errors"<br>]</pre> | no |
| <a name="input_diagnostic_log_category_groups"></a> [diagnostic\_log\_category\_groups](#input\_diagnostic\_log\_category\_groups) | Diagnostic log category groups to enable for the SQL database. | `list(string)` | `[]` | no |
| <a name="input_diagnostic_metric_categories"></a> [diagnostic\_metric\_categories](#input\_diagnostic\_metric\_categories) | Diagnostic metric categories to enable for the SQL database. | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| <a name="input_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#input\_diagnostic\_setting\_name) | Optional diagnostic setting name. Defaults to diag-<database-name>. | `string` | `""` | no |
| <a name="input_diagnostic_storage_account_id"></a> [diagnostic\_storage\_account\_id](#input\_diagnostic\_storage\_account\_id) | Optional storage account ID for diagnostics. | `string` | `""` | no |
| <a name="input_elastic_pool_id"></a> [elastic\_pool\_id](#input\_elastic\_pool\_id) | Optional elastic pool ID for the database. | `string` | `""` | no |
| <a name="input_enable_audit"></a> [enable\_audit](#input\_enable\_audit) | Whether to enable server-level auditing. | `bool` | `true` | no |
| <a name="input_enable_database_audit"></a> [enable\_database\_audit](#input\_enable\_database\_audit) | Whether to enable database-level auditing. | `bool` | `false` | no |
| <a name="input_enable_database_threat_detection"></a> [enable\_database\_threat\_detection](#input\_enable\_database\_threat\_detection) | Whether to enable database-level threat detection policy. | `bool` | `false` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Whether to create diagnostic settings for the SQL database. | `bool` | `false` | no |
| <a name="input_enable_long_term_retention"></a> [enable\_long\_term\_retention](#input\_enable\_long\_term\_retention) | Whether to enable long-term retention backups. | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Whether to create a private endpoint for the SQL server. | `bool` | `true` | no |
| <a name="input_enable_threat_detection"></a> [enable\_threat\_detection](#input\_enable\_threat\_detection) | Whether to enable Microsoft Defender for SQL threat detection for the server. | `bool` | `false` | no |
| <a name="input_enclave_type"></a> [enclave\_type](#input\_enclave\_type) | Optional enclave type for Always Encrypted with secure enclaves. | `string` | `""` | no |
| <a name="input_express_vulnerability_assessment_enabled"></a> [express\_vulnerability\_assessment\_enabled](#input\_express\_vulnerability\_assessment\_enabled) | Whether to enable Express Vulnerability Assessment on the SQL server. | `bool` | `false` | no |
| <a name="input_failover_group"></a> [failover\_group](#input\_failover\_group) | Optional SQL failover group configuration. Provide a partner server ID to enable. | <pre>object({<br>    partner_server_id                         = string<br>    name                                      = optional(string)<br>    database_ids                              = optional(list(string), [])<br>    readonly_endpoint_failover_policy_enabled = optional(bool)<br>    partner_server_location                   = optional(string)<br>    partner_server_role                       = optional(string)<br>    read_write_endpoint_failover_policy = optional(object({<br>      mode          = optional(string, "Automatic")<br>      grace_minutes = optional(number, 60)<br>    }), {})<br>    tags = optional(map(string), {})<br>    timeouts = optional(object({<br>      create = optional(string)<br>      read   = optional(string)<br>      update = optional(string)<br>      delete = optional(string)<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | Optional SQL server firewall rules keyed by rule name. | <pre>map(object({<br>    start_ip_address = string<br>    end_ip_address   = string<br>    timeouts = optional(object({<br>      create = optional(string)<br>      read   = optional(string)<br>      update = optional(string)<br>      delete = optional(string)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_free_limit_exhaustion_behavior"></a> [free\_limit\_exhaustion\_behavior](#input\_free\_limit\_exhaustion\_behavior) | Behavior when Azure SQL free monthly limits are exhausted. AutoPause pauses the database for the rest of the month; BillOverUsage keeps it online and bills overage. | `string` | `"AutoPause"` | no |
| <a name="input_geo_backup_enabled"></a> [geo\_backup\_enabled](#input\_geo\_backup\_enabled) | Whether geo backups are enabled for the database. | `bool` | `true` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Optional user-assigned managed identity IDs for the SQL server. | `list(string)` | `[]` | no |
| <a name="input_include_environment_in_name"></a> [include\_environment\_in\_name](#input\_include\_environment\_in\_name) | Whether generated SQL names include app\_env. | `bool` | `true` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into module resources. The module only reads the resource group when this is true or location is empty. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional already-known resource group tags to use when inherit\_resource\_group\_tags is true. When null, the module reads the target resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Optional instance segment used when generated names do not use a random suffix. | `string` | `"001"` | no |
| <a name="input_ledger_enabled"></a> [ledger\_enabled](#input\_ledger\_enabled) | Whether ledger is enabled on the database. | `bool` | `false` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | Optional database license type. | `string` | `""` | no |
| <a name="input_location"></a> [location](#input\_location) | Optional Azure region for SQL resources. Leave empty to use the target resource group's location. | `string` | `""` | no |
| <a name="input_location_code"></a> [location\_code](#input\_location\_code) | Optional short location code used when SQL names are generated. | `string` | `""` | no |
| <a name="input_log_analytics_destination_type"></a> [log\_analytics\_destination\_type](#input\_log\_analytics\_destination\_type) | Log Analytics destination type for diagnostics. | `string` | `"Dedicated"` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Optional Log Analytics workspace ID for diagnostics. | `string` | `""` | no |
| <a name="input_long_term_retention_policy"></a> [long\_term\_retention\_policy](#input\_long\_term\_retention\_policy) | Long-term retention policy using week, month, and year counts. Values are converted to ISO 8601 durations. | <pre>object({<br>    weekly_retention          = optional(number, 0)<br>    monthly_retention         = optional(number, 0)<br>    yearly_retention          = optional(number, 0)<br>    week_of_year              = optional(number)<br>    immutable_backups_enabled = optional(bool)<br>  })</pre> | `{}` | no |
| <a name="input_maintenance_configuration_name"></a> [maintenance\_configuration\_name](#input\_maintenance\_configuration\_name) | Optional maintenance configuration name. | `string` | `""` | no |
| <a name="input_max_size_gb"></a> [max\_size\_gb](#input\_max\_size\_gb) | Maximum size of the database in GB. | `number` | `32` | no |
| <a name="input_min_capacity"></a> [min\_capacity](#input\_min\_capacity) | Minimum capacity for serverless databases. | `number` | `null` | no |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | Minimum TLS version enforced by the SQL server. | `string` | `"1.2"` | no |
| <a name="input_name"></a> [name](#input\_name) | Optional Azure SQL database name override. Leave empty to auto-generate a standardized name. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used when the SQL server name is generated. | `string` | `"sql"` | no |
| <a name="input_outbound_network_restriction_enabled"></a> [outbound\_network\_restriction\_enabled](#input\_outbound\_network\_restriction\_enabled) | Whether outbound network access from the SQL server is restricted. | `bool` | `false` | no |
| <a name="input_primary_user_assigned_identity_id"></a> [primary\_user\_assigned\_identity\_id](#input\_primary\_user\_assigned\_identity\_id) | Optional primary user-assigned managed identity ID for server-level customer-managed keys. | `string` | `""` | no |
| <a name="input_private_dns_zone_group_name"></a> [private\_dns\_zone\_group\_name](#input\_private\_dns\_zone\_group\_name) | Private DNS zone group name for the private endpoint. | `string` | `"default"` | no |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | Private DNS zone IDs to associate with the SQL private endpoint. | `list(string)` | `[]` | no |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | Optional private DNS zone name to look up and associate with the private endpoint, for example privatelink.database.windows.net. | `string` | `""` | no |
| <a name="input_private_dns_zone_names"></a> [private\_dns\_zone\_names](#input\_private\_dns\_zone\_names) | Optional private DNS zone names to look up and associate with the private endpoint. | `list(string)` | `[]` | no |
| <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name) | Resource group used for private DNS zone name lookups. | `string` | `""` | no |
| <a name="input_private_endpoint_ip_configurations"></a> [private\_endpoint\_ip\_configurations](#input\_private\_endpoint\_ip\_configurations) | Optional static IP configurations for the private endpoint. | <pre>list(object({<br>    name               = string<br>    private_ip_address = string<br>    member_name        = optional(string, "sqlServer")<br>    subresource_name   = optional(string, "sqlServer")<br>  }))</pre> | `[]` | no |
| <a name="input_private_endpoint_manual_connection"></a> [private\_endpoint\_manual\_connection](#input\_private\_endpoint\_manual\_connection) | Whether the private endpoint connection is manually approved. | `bool` | `false` | no |
| <a name="input_private_endpoint_manual_request_message"></a> [private\_endpoint\_manual\_request\_message](#input\_private\_endpoint\_manual\_request\_message) | Optional request message for manual private endpoint approvals. | `string` | `""` | no |
| <a name="input_private_endpoint_name"></a> [private\_endpoint\_name](#input\_private\_endpoint\_name) | Optional private endpoint name. Defaults to pep-<server-name>. | `string` | `""` | no |
| <a name="input_private_endpoint_network_interface_name"></a> [private\_endpoint\_network\_interface\_name](#input\_private\_endpoint\_network\_interface\_name) | Optional custom network interface name for the private endpoint. | `string` | `""` | no |
| <a name="input_private_endpoint_network_resource_group_name"></a> [private\_endpoint\_network\_resource\_group\_name](#input\_private\_endpoint\_network\_resource\_group\_name) | Resource group containing the virtual network used for private endpoint subnet lookup. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | Subnet ID for the SQL private endpoint. Alternatively use the subnet lookup inputs. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#input\_private\_endpoint\_subnet\_name) | Subnet name used to look up the private endpoint subnet when private\_endpoint\_subnet\_id is empty. | `string` | `""` | no |
| <a name="input_private_endpoint_timeouts"></a> [private\_endpoint\_timeouts](#input\_private\_endpoint\_timeouts) | Optional create/read/update/delete timeouts for the private endpoint. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_private_endpoint_vnet_name"></a> [private\_endpoint\_vnet\_name](#input\_private\_endpoint\_vnet\_name) | Virtual network name used to look up the private endpoint subnet. | `string` | `""` | no |
| <a name="input_private_service_connection_name"></a> [private\_service\_connection\_name](#input\_private\_service\_connection\_name) | Optional private service connection name. Defaults to psc-<server-name>. | `string` | `""` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is enabled on the SQL server. Prefer false with private endpoints for production. | `bool` | `false` | no |
| <a name="input_read_replica_count"></a> [read\_replica\_count](#input\_read\_replica\_count) | Optional read replica count for supported database SKUs. | `number` | `null` | no |
| <a name="input_read_scale"></a> [read\_scale](#input\_read\_scale) | Optional read scale setting for supported database SKUs. | `bool` | `null` | no |
| <a name="input_recover_database_id"></a> [recover\_database\_id](#input\_recover\_database\_id) | Database ID used by Recovery create mode. | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group where the SQL server and database are deployed. | `string` | n/a | yes |
| <a name="input_restore_dropped_database_id"></a> [restore\_dropped\_database\_id](#input\_restore\_dropped\_database\_id) | Dropped database ID used by Restore create mode. | `string` | `""` | no |
| <a name="input_restore_long_term_retention_backup_id"></a> [restore\_long\_term\_retention\_backup\_id](#input\_restore\_long\_term\_retention\_backup\_id) | Long-term retention backup ID used by RestoreLongTermRetentionBackup create mode. | `string` | `""` | no |
| <a name="input_restore_point_in_time"></a> [restore\_point\_in\_time](#input\_restore\_point\_in\_time) | Restore point timestamp used by point-in-time restore scenarios. | `string` | `""` | no |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | Additional role assignments scoped to the SQL server, SQL database, or an explicit Azure resource ID. | <pre>map(object({<br>    principal_id                           = string<br>    principal_type                         = optional(string)<br>    role_definition_id                     = optional(string)<br>    role_definition_name                   = optional(string)<br>    name                                   = optional(string)<br>    description                            = optional(string)<br>    condition                              = optional(string)<br>    condition_version                      = optional(string)<br>    delegated_managed_identity_resource_id = optional(string)<br>    skip_service_principal_aad_check       = optional(bool, false)<br>    scope                                  = optional(string, "server")<br>  }))</pre> | `{}` | no |
| <a name="input_sample_name"></a> [sample\_name](#input\_sample\_name) | Optional sample database name. | `string` | `""` | no |
| <a name="input_secondary_type"></a> [secondary\_type](#input\_secondary\_type) | Optional secondary type for replica scenarios. | `string` | `""` | no |
| <a name="input_server_name"></a> [server\_name](#input\_server\_name) | Azure SQL logical server name. Leave empty to auto-generate a standardized globally unique name. | `string` | `""` | no |
| <a name="input_server_timeouts"></a> [server\_timeouts](#input\_server\_timeouts) | Optional create/read/update/delete timeouts for the SQL server. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_server_version"></a> [server\_version](#input\_server\_version) | Azure SQL logical server version. | `string` | `"12.0"` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU for the SQL database, such as Basic, S0, GP\_Gen5\_2, BC\_Gen5\_2, or HS\_Gen5\_2. | `string` | `"S0"` | no |
| <a name="input_system_assigned_identity_enabled"></a> [system\_assigned\_identity\_enabled](#input\_system\_assigned\_identity\_enabled) | Whether to enable a system-assigned managed identity on the SQL server. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags merged with standardized module tags. | `map(string)` | `{}` | no |
| <a name="input_threat_detection_disabled_alerts"></a> [threat\_detection\_disabled\_alerts](#input\_threat\_detection\_disabled\_alerts) | Threat detection alerts to disable. | `list(string)` | `[]` | no |
| <a name="input_threat_detection_email_account_admins"></a> [threat\_detection\_email\_account\_admins](#input\_threat\_detection\_email\_account\_admins) | Whether threat detection alerts are emailed to subscription/account admins. | `bool` | `true` | no |
| <a name="input_threat_detection_email_addresses"></a> [threat\_detection\_email\_addresses](#input\_threat\_detection\_email\_addresses) | Email addresses that receive threat detection alerts. | `list(string)` | `[]` | no |
| <a name="input_threat_detection_retention_days"></a> [threat\_detection\_retention\_days](#input\_threat\_detection\_retention\_days) | Threat detection retention days. Defaults to audit\_retention\_days when null. | `number` | `null` | no |
| <a name="input_threat_detection_storage_account_access_key"></a> [threat\_detection\_storage\_account\_access\_key](#input\_threat\_detection\_storage\_account\_access\_key) | Optional storage account access key for server threat detection alerts. | `string` | `""` | no |
| <a name="input_threat_detection_storage_endpoint"></a> [threat\_detection\_storage\_endpoint](#input\_threat\_detection\_storage\_endpoint) | Optional storage endpoint for server threat detection alerts. | `string` | `""` | no |
| <a name="input_transparent_data_encryption_enabled"></a> [transparent\_data\_encryption\_enabled](#input\_transparent\_data\_encryption\_enabled) | Whether transparent data encryption is enabled on the database. | `bool` | `true` | no |
| <a name="input_transparent_data_encryption_key_vault_key_id"></a> [transparent\_data\_encryption\_key\_vault\_key\_id](#input\_transparent\_data\_encryption\_key\_vault\_key\_id) | Optional Key Vault key ID used as the server-level transparent data encryption protector. | `string` | `""` | no |
| <a name="input_use_free_limit"></a> [use\_free\_limit](#input\_use\_free\_limit) | Whether the Azure SQL Database should use Azure SQL free monthly limits. This is intended for eligible General Purpose serverless databases. | `bool` | `false` | no |
| <a name="input_use_random_suffix"></a> [use\_random\_suffix](#input\_use\_random\_suffix) | Whether generated SQL names should include a random suffix. | `bool` | `true` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier used in tagging. | `string` | `"project"` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Optional workload segment used when names are generated. | `string` | `""` | no |
| <a name="input_zone_redundant"></a> [zone\_redundant](#input\_zone\_redundant) | Whether the database is zone redundant. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_admin_group_role_assignment_ids"></a> [app\_admin\_group\_role\_assignment\_ids](#output\_app\_admin\_group\_role\_assignment\_ids) | Admin role assignment IDs keyed by principal ID. |
| <a name="output_app_user_group_role_assignment_ids"></a> [app\_user\_group\_role\_assignment\_ids](#output\_app\_user\_group\_role\_assignment\_ids) | User role assignment IDs keyed by principal ID. |
| <a name="output_azuread_administrator_enabled"></a> [azuread\_administrator\_enabled](#output\_azuread\_administrator\_enabled) | Whether a Microsoft Entra administrator is configured. |
| <a name="output_azuread_authentication_only"></a> [azuread\_authentication\_only](#output\_azuread\_authentication\_only) | Whether Microsoft Entra-only authentication is enabled. |
| <a name="output_backup_configuration"></a> [backup\_configuration](#output\_backup\_configuration) | Database backup and resiliency configuration summary. |
| <a name="output_database_audit_policy_id"></a> [database\_audit\_policy\_id](#output\_database\_audit\_policy\_id) | Database audit policy resource ID when enabled. |
| <a name="output_database_id"></a> [database\_id](#output\_database\_id) | Resource ID of the Azure SQL database. |
| <a name="output_database_identity_ids"></a> [database\_identity\_ids](#output\_database\_identity\_ids) | User-assigned managed identity IDs configured on the SQL database. |
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | The Azure SQL database name. |
| <a name="output_database_tags"></a> [database\_tags](#output\_database\_tags) | Tags applied to the SQL database. |
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | Diagnostic setting resource ID when diagnostics are enabled. |
| <a name="output_diagnostics_enabled"></a> [diagnostics\_enabled](#output\_diagnostics\_enabled) | Whether diagnostic settings are enabled. |
| <a name="output_failover_group_id"></a> [failover\_group\_id](#output\_failover\_group\_id) | Failover group resource ID when configured. |
| <a name="output_failover_group_name"></a> [failover\_group\_name](#output\_failover\_group\_name) | Failover group name when configured. |
| <a name="output_free_limit_configuration"></a> [free\_limit\_configuration](#output\_free\_limit\_configuration) | Azure SQL free monthly limit configuration summary. |
| <a name="output_location"></a> [location](#output\_location) | Azure region where SQL resources are deployed. |
| <a name="output_location_code"></a> [location\_code](#output\_location\_code) | Short location code used for generated naming. |
| <a name="output_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#output\_private\_dns\_zone\_ids) | Private DNS zone IDs associated with the private endpoint. |
| <a name="output_private_endpoint_fqdns"></a> [private\_endpoint\_fqdns](#output\_private\_endpoint\_fqdns) | Private endpoint FQDNs when private endpoint is enabled. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint resource ID when private endpoint is enabled. |
| <a name="output_private_endpoint_ip_addresses"></a> [private\_endpoint\_ip\_addresses](#output\_private\_endpoint\_ip\_addresses) | Private endpoint IP addresses when private endpoint is enabled. |
| <a name="output_private_endpoint_name"></a> [private\_endpoint\_name](#output\_private\_endpoint\_name) | Private endpoint name when private endpoint is enabled. |
| <a name="output_private_endpoint_nic_id"></a> [private\_endpoint\_nic\_id](#output\_private\_endpoint\_nic\_id) | Private endpoint network interface ID when private endpoint is enabled. |
| <a name="output_public_endpoint"></a> [public\_endpoint](#output\_public\_endpoint) | Public SQL endpoint details when public access is enabled. Azure SQL exposes a public FQDN rather than a dedicated static IP. |
| <a name="output_public_network_access_enabled"></a> [public\_network\_access\_enabled](#output\_public\_network\_access\_enabled) | Whether public network access is enabled on the SQL server. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group where SQL resources are deployed. |
| <a name="output_role_assignment_count"></a> [role\_assignment\_count](#output\_role\_assignment\_count) | Total number of role assignments managed by this module. |
| <a name="output_role_assignment_ids"></a> [role\_assignment\_ids](#output\_role\_assignment\_ids) | Additional role assignment IDs keyed by input key. |
| <a name="output_security_configuration"></a> [security\_configuration](#output\_security\_configuration) | Database security and monitoring configuration summary. |
| <a name="output_server_audit_policy_id"></a> [server\_audit\_policy\_id](#output\_server\_audit\_policy\_id) | Server audit policy resource ID when enabled. |
| <a name="output_server_fqdn"></a> [server\_fqdn](#output\_server\_fqdn) | Fully qualified domain name of the Azure SQL logical server. |
| <a name="output_server_id"></a> [server\_id](#output\_server\_id) | Resource ID of the Azure SQL logical server. |
| <a name="output_server_identity"></a> [server\_identity](#output\_server\_identity) | Managed identity details for the SQL server. |
| <a name="output_server_identity_ids"></a> [server\_identity\_ids](#output\_server\_identity\_ids) | User-assigned managed identity IDs configured on the SQL server. |
| <a name="output_server_identity_type"></a> [server\_identity\_type](#output\_server\_identity\_type) | Managed identity type configured on the SQL server. |
| <a name="output_server_name"></a> [server\_name](#output\_server\_name) | The Azure SQL logical server name. |
| <a name="output_server_principal_id"></a> [server\_principal\_id](#output\_server\_principal\_id) | Principal ID of the SQL server system-assigned managed identity. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to SQL resources. |
| <a name="output_threat_detection_policy_id"></a> [threat\_detection\_policy\_id](#output\_threat\_detection\_policy\_id) | Server threat detection policy resource ID when enabled. |
<!-- END_TF_DOCS -->
