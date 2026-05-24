# Databricks Module

Provision an Azure Databricks workspace with secure defaults, standardized naming and tags, optional VNet injection, enhanced security, customer-managed keys, access connector, private endpoints, diagnostics, and RBAC.

## Features

- Secure baseline with public network access disabled by default.
- Standard generated naming using `name_prefix`, `workload_name`, `app_env`, `location_code`, and optional random suffixes.
- Environment-specific tags plus inherited and caller-provided tags, without module-generated marker tags.
- Premium security options for customer-managed keys, infrastructure encryption, enhanced security monitoring, and compliance security profile.
- VNet injection and no-public-IP support through `custom_parameters`.
- Optional Databricks access connector creation for Unity Catalog and default storage firewall scenarios.
- Optional root DBFS customer-managed key resource.
- Built-in Contributor and Reader assignments for Entra groups, plus generic workspace-scope RBAC assignments.
- Optional role assignments for the created access connector identity.
- Optional private endpoints for `databricks_ui_api` and `browser_authentication`.
- Diagnostics to Log Analytics, Storage Account archive, and Event Hub.

## Basic Usage

```hcl
module "databricks" {
  source = "./modules/databricks"

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  workload_name       = "lakehouse"
  app_env             = "prod"
  sku                 = "premium"

  tags = {
    Owner = "CCOE"
  }
}
```

## Secure VNet-Injected Workspace

```hcl
module "databricks" {
  source = "./modules/databricks"

  resource_group_name           = "rg-example-prod"
  location                      = "eastus"
  name                          = "dbw-lakehouse-prod-eus-001"
  public_network_access_enabled = false
  sku                           = "premium"

  custom_parameters = {
    virtual_network_id                                   = "/subscriptions/<sub>/resourceGroups/<network-rg>/providers/Microsoft.Network/virtualNetworks/<vnet>"
    public_subnet_name                                   = "snet-databricks-public"
    private_subnet_name                                  = "snet-databricks-private"
    public_subnet_network_security_group_association_id  = "/subscriptions/<sub>/resourceGroups/<network-rg>/providers/Microsoft.Network/networkSecurityGroups/<nsg-public>/subnets/snet-databricks-public"
    private_subnet_network_security_group_association_id = "/subscriptions/<sub>/resourceGroups/<network-rg>/providers/Microsoft.Network/networkSecurityGroups/<nsg-private>/subnets/snet-databricks-private"
    no_public_ip                                         = true
  }
}
```

## Unity Catalog Access Connector

```hcl
module "databricks" {
  source = "./modules/databricks"

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  name                = "dbw-lakehouse-prod-eus-001"

  create_access_connector          = true
  default_storage_firewall_enabled = true

  access_connector_role_assignments = {
    external_storage = {
      scope                = "/subscriptions/<sub>/resourceGroups/<data-rg>/providers/Microsoft.Storage/storageAccounts/<lake-storage>"
      role_definition_name = "Storage Blob Data Contributor"
    }
  }
}
```

## Notes

- `customer_managed_key_enabled`, `infrastructure_encryption_enabled`, and `enhanced_security_compliance` require `sku = "premium"`.
- Databricks workspace CMK key inputs and root DBFS CMK key input expect Key Vault key identifier URIs, for example `https://vault.vault.azure.net/keys/key/version`.
- Use `create_access_connector = true` when enabling `default_storage_firewall_enabled` unless you pass an existing `access_connector_id`.
- Private endpoint DNS commonly uses `privatelink.azuredatabricks.net`; browser authentication may require an additional architecture decision in multi-workspace environments.
- Prefer Entra object IDs over display names in `app_admin_group` and `app_user_group` when names are not unique.

## Testing

Run module validation and tests from the module directory:

```powershell
terraform fmt -check -recursive
terraform validate
terraform test
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 3.8.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.73.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_databricks_access_connector.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_access_connector) | resource |
| [azurerm_databricks_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_workspace) | resource |
| [azurerm_databricks_workspace_root_dbfs_customer_managed_key.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_workspace_root_dbfs_customer_managed_key) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.access_connector](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_admin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_user_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azuread_group.app_admin](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azuread_group.app_user](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azurerm_private_dns_zone.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_connector_id"></a> [access\_connector\_id](#input\_access\_connector\_id) | Optional existing Databricks access connector resource ID. If create\_access\_connector is true, the created access connector is used instead. | `string` | `""` | no |
| <a name="input_access_connector_identity_ids"></a> [access\_connector\_identity\_ids](#input\_access\_connector\_identity\_ids) | User-assigned managed identity IDs for the created Databricks access connector. Only one user-assigned identity is supported by Azure. | `list(string)` | `[]` | no |
| <a name="input_access_connector_name"></a> [access\_connector\_name](#input\_access\_connector\_name) | Optional name for the Databricks access connector. When empty, the module uses dac-<workspace-name>. | `string` | `""` | no |
| <a name="input_access_connector_role_assignments"></a> [access\_connector\_role\_assignments](#input\_access\_connector\_role\_assignments) | Role assignments for the created access connector identity, typically Storage Blob Data Contributor on external lakehouse storage scopes. | <pre>map(object({<br>    scope                                  = string<br>    role_definition_name                   = optional(string)<br>    role_definition_id                     = optional(string)<br>    principal_type                         = optional(string)<br>    description                            = optional(string)<br>    name                                   = optional(string)<br>    condition                              = optional(string)<br>    condition_version                      = optional(string)<br>    delegated_managed_identity_resource_id = optional(string)<br>    skip_service_principal_aad_check       = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_access_connector_system_assigned_identity_enabled"></a> [access\_connector\_system\_assigned\_identity\_enabled](#input\_access\_connector\_system\_assigned\_identity\_enabled) | Whether the created access connector gets a system-assigned identity. | `bool` | `true` | no |
| <a name="input_access_connector_timeouts"></a> [access\_connector\_timeouts](#input\_access\_connector\_timeouts) | Optional timeouts for Databricks access connector create, read, update, and delete operations. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | Optional list of Entra group display names or object IDs that will have Contributor access to the Databricks workspace. | `list(string)` | `[]` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used for standard tags and generated naming. | `string` | `"dev"` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | Optional list of Entra group display names or object IDs that will have Reader access to the Databricks workspace. | `list(string)` | `[]` | no |
| <a name="input_create_access_connector"></a> [create\_access\_connector](#input\_create\_access\_connector) | Whether to create a Databricks access connector for Unity Catalog and default storage firewall scenarios. | `bool` | `false` | no |
| <a name="input_custom_parameters"></a> [custom\_parameters](#input\_custom\_parameters) | Optional Databricks custom parameters block for VNet injection, no-public-IP, managed VNet, storage, and ML linkage scenarios. | <pre>object({<br>    machine_learning_workspace_id                        = optional(string)<br>    nat_gateway_name                                     = optional(string)<br>    no_public_ip                                         = optional(bool)<br>    private_subnet_name                                  = optional(string)<br>    private_subnet_network_security_group_association_id = optional(string)<br>    public_ip_name                                       = optional(string)<br>    public_subnet_name                                   = optional(string)<br>    public_subnet_network_security_group_association_id  = optional(string)<br>    storage_account_name                                 = optional(string)<br>    storage_account_sku_name                             = optional(string)<br>    virtual_network_id                                   = optional(string)<br>    vnet_address_prefix                                  = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_customer_managed_key_enabled"></a> [customer\_managed\_key\_enabled](#input\_customer\_managed\_key\_enabled) | Whether customer-managed keys are enabled. Requires premium SKU. | `bool` | `false` | no |
| <a name="input_default_storage_firewall_enabled"></a> [default\_storage\_firewall\_enabled](#input\_default\_storage\_firewall\_enabled) | Whether the default storage account firewall is enabled. Requires access\_connector\_id or create\_access\_connector. | `bool` | `false` | no |
| <a name="input_diagnostic_eventhub_authorization_rule_id"></a> [diagnostic\_eventhub\_authorization\_rule\_id](#input\_diagnostic\_eventhub\_authorization\_rule\_id) | Optional Event Hub authorization rule resource ID for diagnostics. | `string` | `null` | no |
| <a name="input_diagnostic_eventhub_name"></a> [diagnostic\_eventhub\_name](#input\_diagnostic\_eventhub\_name) | Optional Event Hub name for diagnostics when using an Event Hub destination. | `string` | `null` | no |
| <a name="input_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#input\_diagnostic\_log\_categories) | Diagnostic log categories to enable. Use diagnostic\_log\_category\_groups for Azure Monitor category groups such as allLogs. | `list(string)` | <pre>[<br>  "accounts",<br>  "clusters",<br>  "dbfs",<br>  "jobs",<br>  "notebook",<br>  "secrets",<br>  "sqlPermissions",<br>  "workspace"<br>]</pre> | no |
| <a name="input_diagnostic_log_category_groups"></a> [diagnostic\_log\_category\_groups](#input\_diagnostic\_log\_category\_groups) | Diagnostic log category groups to enable, for example allLogs. | `list(string)` | `[]` | no |
| <a name="input_diagnostic_metric_categories"></a> [diagnostic\_metric\_categories](#input\_diagnostic\_metric\_categories) | Diagnostic metric categories to enable. | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| <a name="input_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#input\_diagnostic\_setting\_name) | Optional diagnostic setting name. When empty, the module uses <workspace-name>-diagnostic-setting. | `string` | `""` | no |
| <a name="input_diagnostic_storage_account_id"></a> [diagnostic\_storage\_account\_id](#input\_diagnostic\_storage\_account\_id) | Optional Storage Account resource ID for diagnostic archive. | `string` | `null` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Whether to create diagnostic settings on the Databricks workspace. Diagnostics are also enabled when at least one diagnostic destination is supplied. | `bool` | `false` | no |
| <a name="input_enhanced_security_compliance"></a> [enhanced\_security\_compliance](#input\_enhanced\_security\_compliance) | Optional enhanced security and compliance settings for the Databricks workspace. Requires premium SKU. | <pre>object({<br>    automatic_cluster_update_enabled      = optional(bool)<br>    compliance_security_profile_enabled   = optional(bool)<br>    compliance_security_profile_standards = optional(set(string))<br>    enhanced_security_monitoring_enabled  = optional(bool)<br>  })</pre> | `null` | no |
| <a name="input_include_environment_in_name"></a> [include\_environment\_in\_name](#input\_include\_environment\_in\_name) | Whether generated Databricks workspace names include app\_env. | `bool` | `true` | no |
| <a name="input_infrastructure_encryption_enabled"></a> [infrastructure\_encryption\_enabled](#input\_infrastructure\_encryption\_enabled) | Whether infrastructure encryption is enabled. Requires premium SKU. | `bool` | `false` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into module resources. The module only reads the resource group when this is true or location is empty. | `bool` | `false` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Optional instance segment used when generated names do not use a random suffix. | `string` | `"001"` | no |
| <a name="input_load_balancer_backend_address_pool_id"></a> [load\_balancer\_backend\_address\_pool\_id](#input\_load\_balancer\_backend\_address\_pool\_id) | Optional load balancer backend address pool ID for secure cluster connectivity. | `string` | `""` | no |
| <a name="input_location"></a> [location](#input\_location) | Optional Azure region for the Databricks workspace. Leave empty to use the target resource group's location. | `string` | `""` | no |
| <a name="input_location_code"></a> [location\_code](#input\_location\_code) | Optional short location code used when the Databricks workspace name is generated. | `string` | `""` | no |
| <a name="input_log_analytics_destination_type"></a> [log\_analytics\_destination\_type](#input\_log\_analytics\_destination\_type) | Destination type for Log Analytics diagnostics. | `string` | `"Dedicated"` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Optional Log Analytics workspace ID used for diagnostics. | `string` | `""` | no |
| <a name="input_managed_disk_cmk_key_vault_id"></a> [managed\_disk\_cmk\_key\_vault\_id](#input\_managed\_disk\_cmk\_key\_vault\_id) | Optional Key Vault ID for managed disk CMK. Needed when the key is in a different subscription. | `string` | `""` | no |
| <a name="input_managed_disk_cmk_key_vault_key_id"></a> [managed\_disk\_cmk\_key\_vault\_key\_id](#input\_managed\_disk\_cmk\_key\_vault\_key\_id) | Optional Key Vault key identifier URI for managed disk CMK. | `string` | `""` | no |
| <a name="input_managed_disk_cmk_rotation_to_latest_version_enabled"></a> [managed\_disk\_cmk\_rotation\_to\_latest\_version\_enabled](#input\_managed\_disk\_cmk\_rotation\_to\_latest\_version\_enabled) | Whether managed disk CMK should auto-rotate to the latest key version. | `bool` | `false` | no |
| <a name="input_managed_resource_group_name"></a> [managed\_resource\_group\_name](#input\_managed\_resource\_group\_name) | Optional managed resource group name for the Databricks workspace. | `string` | `""` | no |
| <a name="input_managed_services_cmk_key_vault_id"></a> [managed\_services\_cmk\_key\_vault\_id](#input\_managed\_services\_cmk\_key\_vault\_id) | Optional Key Vault ID for managed services CMK. Needed when the key is in a different subscription. | `string` | `""` | no |
| <a name="input_managed_services_cmk_key_vault_key_id"></a> [managed\_services\_cmk\_key\_vault\_key\_id](#input\_managed\_services\_cmk\_key\_vault\_key\_id) | Optional Key Vault key identifier URI for managed services CMK. | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Databricks workspace name. Leave empty to auto-generate a unique name. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used when the Databricks workspace name is generated. | `string` | `"dbw"` | no |
| <a name="input_network_security_group_rules_required"></a> [network\_security\_group\_rules\_required](#input\_network\_security\_group\_rules\_required) | Network security group rules mode for VNet-injected workspaces. | `string` | `"NoAzureDatabricksRules"` | no |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | Optional private DNS zone IDs attached to each Databricks private endpoint. | `list(string)` | `[]` | no |
| <a name="input_private_dns_zone_names"></a> [private\_dns\_zone\_names](#input\_private\_dns\_zone\_names) | Optional private DNS zone names to resolve and attach to Databricks private endpoints when IDs are not supplied. | `list(string)` | `[]` | no |
| <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name) | Resource group containing the private DNS zones referenced by private\_dns\_zone\_names. | `string` | `null` | no |
| <a name="input_private_endpoint_manual_connection_enabled"></a> [private\_endpoint\_manual\_connection\_enabled](#input\_private\_endpoint\_manual\_connection\_enabled) | Whether private endpoint connections are created as manual approval requests. | `bool` | `false` | no |
| <a name="input_private_endpoint_name_prefix"></a> [private\_endpoint\_name\_prefix](#input\_private\_endpoint\_name\_prefix) | Prefix used for generated private endpoint names. | `string` | `"pep"` | no |
| <a name="input_private_endpoint_network_interface_name"></a> [private\_endpoint\_network\_interface\_name](#input\_private\_endpoint\_network\_interface\_name) | Optional base network interface name for Databricks private endpoints. The subresource name is appended. | `string` | `""` | no |
| <a name="input_private_endpoint_network_resource_group_name"></a> [private\_endpoint\_network\_resource\_group\_name](#input\_private\_endpoint\_network\_resource\_group\_name) | Resource group containing the virtual network used to resolve the private endpoint subnet. | `string` | `""` | no |
| <a name="input_private_endpoint_request_message"></a> [private\_endpoint\_request\_message](#input\_private\_endpoint\_request\_message) | Optional request message used when private\_endpoint\_manual\_connection\_enabled is true. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | Subnet ID for Databricks private endpoints. If set, subnet lookup inputs are ignored. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#input\_private\_endpoint\_subnet\_name) | Subnet name used to resolve private endpoint subnet when private\_endpoint\_subnet\_id is not set. | `string` | `""` | no |
| <a name="input_private_endpoint_subresource_names"></a> [private\_endpoint\_subresource\_names](#input\_private\_endpoint\_subresource\_names) | Databricks private endpoint subresources to create. Common values are databricks\_ui\_api and browser\_authentication. | `list(string)` | `[]` | no |
| <a name="input_private_endpoint_vnet_name"></a> [private\_endpoint\_vnet\_name](#input\_private\_endpoint\_vnet\_name) | Virtual network name used to resolve private endpoint subnet when private\_endpoint\_subnet\_id is not set. | `string` | `""` | no |
| <a name="input_private_service_connection_name_prefix"></a> [private\_service\_connection\_name\_prefix](#input\_private\_service\_connection\_name\_prefix) | Prefix used for generated private service connection names. | `string` | `"psc"` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is enabled on the Databricks workspace. | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group where the Databricks workspace will be deployed. | `string` | n/a | yes |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | Additional role assignments to create at the Databricks workspace scope, keyed by a stable name. | <pre>map(object({<br>    principal_id                           = string<br>    role_definition_name                   = optional(string)<br>    role_definition_id                     = optional(string)<br>    principal_type                         = optional(string)<br>    description                            = optional(string)<br>    name                                   = optional(string)<br>    condition                              = optional(string)<br>    condition_version                      = optional(string)<br>    delegated_managed_identity_resource_id = optional(string)<br>    skip_service_principal_aad_check       = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_root_dbfs_customer_managed_key"></a> [root\_dbfs\_customer\_managed\_key](#input\_root\_dbfs\_customer\_managed\_key) | Optional customer-managed key for the Databricks root DBFS storage account. | <pre>object({<br>    key_vault_key_id = string<br>    key_vault_id     = optional(string)<br>    timeouts = optional(object({<br>      create = optional(string)<br>      read   = optional(string)<br>      update = optional(string)<br>      delete = optional(string)<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | Databricks workspace SKU. | `string` | `"premium"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the Databricks workspace. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional timeouts for Databricks workspace create, read, update, and delete operations. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_use_random_suffix"></a> [use\_random\_suffix](#input\_use\_random\_suffix) | Whether generated Databricks workspace names should include a random suffix. | `bool` | `true` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Optional workload segment used when the Databricks workspace name is generated. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_connector_id"></a> [access\_connector\_id](#output\_access\_connector\_id) | The Databricks access connector ID used by the workspace, if configured. |
| <a name="output_access_connector_identity"></a> [access\_connector\_identity](#output\_access\_connector\_identity) | The created Databricks access connector identity, if created. |
| <a name="output_access_connector_name"></a> [access\_connector\_name](#output\_access\_connector\_name) | The created Databricks access connector name, if created. |
| <a name="output_access_connector_role_assignment_ids"></a> [access\_connector\_role\_assignment\_ids](#output\_access\_connector\_role\_assignment\_ids) | Map of access connector role assignment IDs keyed by assignment name. |
| <a name="output_app_admin_group_principal_ids"></a> [app\_admin\_group\_principal\_ids](#output\_app\_admin\_group\_principal\_ids) | Map of resolved app admin group principal IDs. |
| <a name="output_app_admin_group_role_assignment_ids"></a> [app\_admin\_group\_role\_assignment\_ids](#output\_app\_admin\_group\_role\_assignment\_ids) | Contributor role assignment IDs keyed by principal ID. |
| <a name="output_app_env"></a> [app\_env](#output\_app\_env) | The deployment environment used for tags and generated names. |
| <a name="output_app_user_group_principal_ids"></a> [app\_user\_group\_principal\_ids](#output\_app\_user\_group\_principal\_ids) | Map of resolved app user group principal IDs. |
| <a name="output_app_user_group_role_assignment_ids"></a> [app\_user\_group\_role\_assignment\_ids](#output\_app\_user\_group\_role\_assignment\_ids) | Reader role assignment IDs keyed by principal ID. |
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | Diagnostic setting ID when diagnostics are enabled. |
| <a name="output_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#output\_diagnostic\_setting\_name) | Diagnostic setting name when diagnostics are enabled. |
| <a name="output_diagnostics_enabled"></a> [diagnostics\_enabled](#output\_diagnostics\_enabled) | Boolean flag indicating whether diagnostics are enabled. |
| <a name="output_disk_encryption_set_id"></a> [disk\_encryption\_set\_id](#output\_disk\_encryption\_set\_id) | The disk encryption set resource ID when CMK is enabled. |
| <a name="output_id"></a> [id](#output\_id) | The Databricks workspace resource ID. |
| <a name="output_location"></a> [location](#output\_location) | The Azure region where the Databricks workspace is deployed. |
| <a name="output_location_code"></a> [location\_code](#output\_location\_code) | The short location code used by generated names. |
| <a name="output_managed_disk_identity"></a> [managed\_disk\_identity](#output\_managed\_disk\_identity) | Managed disk identity exposed by Azure Databricks for managed disk CMK scenarios. |
| <a name="output_managed_resource_group_id"></a> [managed\_resource\_group\_id](#output\_managed\_resource\_group\_id) | The managed resource group resource ID. |
| <a name="output_managed_resource_group_name"></a> [managed\_resource\_group\_name](#output\_managed\_resource\_group\_name) | The managed resource group name. |
| <a name="output_merged_tags"></a> [merged\_tags](#output\_merged\_tags) | Final merged tags applied to the Databricks workspace. |
| <a name="output_name"></a> [name](#output\_name) | The Databricks workspace name. |
| <a name="output_private_endpoint_ids"></a> [private\_endpoint\_ids](#output\_private\_endpoint\_ids) | Map of private endpoint IDs keyed by Databricks subresource name. |
| <a name="output_private_endpoint_names"></a> [private\_endpoint\_names](#output\_private\_endpoint\_names) | Map of private endpoint names keyed by Databricks subresource name. |
| <a name="output_public_network_access_enabled"></a> [public\_network\_access\_enabled](#output\_public\_network\_access\_enabled) | Whether public network access is enabled. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name where the Databricks workspace is deployed. |
| <a name="output_role_assignment_count"></a> [role\_assignment\_count](#output\_role\_assignment\_count) | Total number of role assignments created by this module. |
| <a name="output_role_assignment_ids"></a> [role\_assignment\_ids](#output\_role\_assignment\_ids) | Map of additional workspace role assignment IDs keyed by assignment name. |
| <a name="output_root_dbfs_customer_managed_key_id"></a> [root\_dbfs\_customer\_managed\_key\_id](#output\_root\_dbfs\_customer\_managed\_key\_id) | The root DBFS customer-managed key resource ID, if configured. |
| <a name="output_sku"></a> [sku](#output\_sku) | The Databricks workspace SKU. |
| <a name="output_storage_account_identity"></a> [storage\_account\_identity](#output\_storage\_account\_identity) | Storage account identity exposed by Azure Databricks for root DBFS CMK scenarios. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to the Databricks workspace. |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | The Databricks workspace ID. |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | The Databricks workspace URL. |
<!-- END_TF_DOCS -->
