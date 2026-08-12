# Azure SQL Managed Instance

Creates one Azure SQL Managed Instance in an existing delegated subnet with configurable compute, storage, licensing, identity, Microsoft Entra administration, diagnostics, DNS-zone partnership, and control-plane RBAC.

## Features

- Explicit or deterministic generated managed-instance name
- General Purpose or Business Critical SKU configuration
- SQL administrator and optional Microsoft Entra administrator
- System-assigned, user-assigned, or combined managed identity
- Private-by-default data endpoint configuration
- Optional zone redundancy, maintenance configuration, and DNS-zone partner
- Optional diagnostics to Log Analytics
- Contributor and Reader assignments for Microsoft Entra groups
- Resource-group tag inheritance with caller overrides

## Resources Created

The module always creates one `azurerm_mssql_managed_instance`. It conditionally creates one diagnostic setting and namespace-scoped Contributor or Reader role assignments.

It looks up but does not create the resource group or Microsoft Entra groups. It does not create the delegated subnet, virtual network, NSG, route table, monitoring workspace, user-assigned identities, DNS-zone partner, maintenance configuration, databases, or SQL users.

## Prerequisites and Dependencies

- Existing resource group and supported Azure region
- Dedicated subnet delegated to `Microsoft.Sql/managedInstances`
- Network configuration that satisfies SQL Managed Instance service requirements
- SQL administrator credential stored and supplied securely
- Sufficient regional SQL Managed Instance quota and subnet address capacity
- Existing Log Analytics workspace when diagnostics are enabled
- Existing user-assigned identities when requested
- Directory read permission when group display names are used

SQL Managed Instance deployment and deletion can take several hours. Confirm cost, quota, subnet sizing, and change windows before apply.

## Provider Configuration

The caller supplies `azurerm` and `azuread` provider configurations. The execution identity needs permissions for SQL Managed Instance, monitoring, and role assignments, plus directory read permission for name-based group lookup.

Prefer immutable Microsoft Entra object IDs over display names.

## Basic Usage

```hcl
module "sqlmi" {
  source = "./modules/sqlmi"

  name                         = "sqlmi-data-cc-prod-001"
  resource_group_name          = "rg-data-prod"
  location                     = "canadacentral"
  subnet_id                    = module.vnet.subnet_ids["sql-managed-instance"]
  administrator_login          = "sqladminuser"
  administrator_login_password = var.sqlmi_admin_password
  sku_name                     = "GP_Gen5"
  vcores                       = 8
  storage_size_in_gb           = 512
}
```

See [examples/basic](./examples/basic), [examples/complete](./examples/complete), and [examples/dns-zone-partner](./examples/dns-zone-partner).

## Important Behavior and Secure Defaults

The public data endpoint is disabled and TLS 1.2 is required by default. A system-assigned identity is enabled by default. The administrator password is sensitive but is still stored in Terraform state; use a protected remote backend and an approved secret-delivery workflow.

Storage must be at least 32 GB and use 32-GB increments according to the module validation. Azure applies additional SKU, vCore, storage, zone, maintenance, and regional constraints.

Changes to subnet, DNS-zone partnership, SKU generation, storage, identity, or zone redundancy can be long-running or replacement-sensitive. Review the provider plan and Azure maintenance implications.

## Networking and Private Connectivity

The Managed Instance is deployed directly into the caller's delegated subnet; it does not use a Private Endpoint. The caller owns delegation, address space, NSG rules, route tables, DNS, peering, hybrid connectivity, and management paths.

Enabling the public data endpoint exposes an additional connectivity path and requires a separately reviewed network and authentication design.

## Identity and RBAC

`identity_type` supports system-assigned, user-assigned, or combined identity. When user-assigned identity is selected, at least one `identity_ids` value is required.

The optional Microsoft Entra administrator configures SQL platform administration. Azure RBAC assignments created by `app_admin_group` and `app_user_group` grant resource Contributor or Reader only; they do not create SQL logins, database users, or database roles.

## DNS-Zone Partnership and Resilience

`dns_zone_partner_id` joins the Managed Instance DNS zone to an existing partner instance for supported cross-instance scenarios. The partner must already exist, and callers must evaluate regional, failover, and lifecycle requirements before linking instances.

The module does not create failover groups or managed databases. Use separate compositions and operational runbooks for database replication, failover testing, backup recovery, and client connection handling.

## Naming and Tagging

Set `name` explicitly or allow `sqlmi-<workload>-<location-code>-<environment>-<instance>` generation. See the repository [naming convention](../../docs/NAMING_CONVENTION.md) and [tagging standard](../../docs/TAGGING_STANDARD.md).

## Testing

```powershell
terraform init -backend=false
terraform test -filter=tests/unit.tftest.hcl
```

The unit suite mocks AzureRM and AzureAD and runs plan-only and expected-failure assertions. It requires no cloud authentication and creates no resources.

## Known Limitations

- One managed instance is created per module instance.
- Required subnet infrastructure and service-network policy are caller-owned.
- SQL credentials remain in Terraform state.
- SQL databases, logins, users, backup validation, failover groups, alerts, and maintenance runbooks are outside this module.
- Azure may reject unsupported SKU, storage, zone, or region combinations only during plan or apply.
- Resource creation, updates, and deletion can be exceptionally long-running and expensive.

See [Architecture and Operations](./docs/architecture.md).

## Terraform Reference

The content below is generated by `terraform-docs`. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
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
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_mssql_managed_instance.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_managed_instance) | resource |
| [azurerm_role_assignment.app_admin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_user_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_administrator_login"></a> [administrator\_login](#input\_administrator\_login) | SQL administrator login name. | `string` | n/a | yes |
| <a name="input_administrator_login_password"></a> [administrator\_login\_password](#input\_administrator\_login\_password) | SQL administrator login password. | `string` | n/a | yes |
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | List of Microsoft Entra group display names or object IDs that should receive Contributor access to the SQL Managed Instance resource. | `list(string)` | `[]` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment metadata retained for composition compatibility; no tag is generated automatically. | `string` | `"dev"` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | List of Microsoft Entra group display names or object IDs that should receive Reader access to the SQL Managed Instance resource. | `list(string)` | `[]` | no |
| <a name="input_azure_active_directory_administrator"></a> [azure\_active\_directory\_administrator](#input\_azure\_active\_directory\_administrator) | Optional Microsoft Entra administrator configuration. | <pre>object({<br>    login_username                      = string<br>    object_id                           = string<br>    principal_type                      = string<br>    tenant_id                           = optional(string)<br>    azuread_authentication_only_enabled = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_collation"></a> [collation](#input\_collation) | SQL Managed Instance collation. | `string` | `"SQL_Latin1_General_CP1_CI_AS"` | no |
| <a name="input_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#input\_diagnostic\_log\_categories) | Diagnostic log categories to enable for SQL Managed Instance. | `list(string)` | <pre>[<br>  "ResourceUsageStats",<br>  "SQLSecurityAuditEvents",<br>  "DevOpsOperationsAudit"<br>]</pre> | no |
| <a name="input_diagnostic_metric_categories"></a> [diagnostic\_metric\_categories](#input\_diagnostic\_metric\_categories) | Diagnostic metric categories to enable for SQL Managed Instance. | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| <a name="input_dns_zone_partner_id"></a> [dns\_zone\_partner\_id](#input\_dns\_zone\_partner\_id) | Optional partner managed instance ID for DNS zone sharing. | `string` | `null` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Whether to create a diagnostic setting for the SQL Managed Instance. | `bool` | `false` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | User-assigned identity resource IDs. | `set(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | Managed identity type for SQL Managed Instance. | `string` | `"SystemAssigned"` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into SQL Managed Instance resources. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance identifier used when name is not provided. | `string` | `"001"` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | License type for SQL Managed Instance. | `string` | `"BasePrice"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the SQL Managed Instance. If empty, the resource group's location is used. | `string` | `""` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace resource ID for diagnostics. | `string` | `""` | no |
| <a name="input_maintenance_configuration_name"></a> [maintenance\_configuration\_name](#input\_maintenance\_configuration\_name) | Optional maintenance configuration resource name. | `string` | `null` | no |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | Minimum TLS version. | `string` | `"1.2"` | no |
| <a name="input_name"></a> [name](#input\_name) | Optional SQL Managed Instance name override. Leave empty to generate one from the naming convention. | `string` | `""` | no |
| <a name="input_proxy_override"></a> [proxy\_override](#input\_proxy\_override) | Connection type override for SQL Managed Instance. | `string` | `"Proxy"` | no |
| <a name="input_public_data_endpoint_enabled"></a> [public\_data\_endpoint\_enabled](#input\_public\_data\_endpoint\_enabled) | Whether the public data endpoint is enabled. | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group where the SQL Managed Instance will be created. | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SQL Managed Instance SKU name, for example GP\_Gen5 or BC\_Gen5. | `string` | n/a | yes |
| <a name="input_storage_account_type"></a> [storage\_account\_type](#input\_storage\_account\_type) | Underlying storage account type. | `string` | `"GRS"` | no |
| <a name="input_storage_size_in_gb"></a> [storage\_size\_in\_gb](#input\_storage\_size\_in\_gb) | Storage size in GB for the SQL Managed Instance. | `number` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Delegated subnet resource ID for the SQL Managed Instance. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags to apply to the SQL Managed Instance. | `map(string)` | `{}` | no |
| <a name="input_timezone_id"></a> [timezone\_id](#input\_timezone\_id) | Timezone ID for SQL Managed Instance. | `string` | `"UTC"` | no |
| <a name="input_vcores"></a> [vcores](#input\_vcores) | Number of vCores for the SQL Managed Instance. | `number` | n/a | yes |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload metadata retained for composition compatibility; tags are supplied explicitly through tags. | `string` | `"project"` | no |
| <a name="input_zone_redundant_enabled"></a> [zone\_redundant\_enabled](#input\_zone\_redundant\_enabled) | Whether zone redundancy is enabled. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_administrator_login"></a> [administrator\_login](#output\_administrator\_login) | Administrator login name for the SQL Managed Instance. |
| <a name="output_app_admin_group_role_assignment_ids"></a> [app\_admin\_group\_role\_assignment\_ids](#output\_app\_admin\_group\_role\_assignment\_ids) | Map of Contributor role assignment IDs keyed by app\_admin\_group principal ID. |
| <a name="output_app_user_group_role_assignment_ids"></a> [app\_user\_group\_role\_assignment\_ids](#output\_app\_user\_group\_role\_assignment\_ids) | Map of Reader role assignment IDs keyed by app\_user\_group principal ID. |
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | Diagnostic setting ID, if diagnostics are enabled. |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | Fully qualified domain name of the SQL Managed Instance. |
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the SQL Managed Instance. |
| <a name="output_location"></a> [location](#output\_location) | Azure region of the SQL Managed Instance. |
| <a name="output_name"></a> [name](#output\_name) | Name of the SQL Managed Instance. |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | Managed identity principal ID, if enabled. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group containing the SQL Managed Instance. |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | Delegated subnet resource ID used by the SQL Managed Instance. |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the SQL Managed Instance. |
<!-- END_TF_DOCS -->
