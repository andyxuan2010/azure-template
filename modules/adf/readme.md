# Azure Data Factory Module

Provision Azure Data Factory with secure defaults, optional managed networking, private endpoint support, source control integration, diagnostics, managed identity, customer-managed keys, Purview association, and optional SHIR VM wiring.

## Overview

- Providers: `azuread`, `azurerm`
- Nested modules: optional SHIR VM via `../winvm`
- Terraform tests: `tests/live.tftest.hcl`
- Optional dependency lookups only run when the related feature is enabled

## Features

- Creates `azurerm_data_factory` using environment-aware naming and standardized tags.
- Supports `None`, `SystemAssigned`, `UserAssigned`, and mixed managed identity modes.
- Supports customer-managed keys with explicit user-assigned key identity validation.
- Supports GitHub and Azure DevOps repo integration, including `publishing_enabled`.
- Supports managed virtual network, managed private endpoints, optional Azure Integration Runtime, and optional SHIR.
- Supports ADF control-plane private endpoint creation using direct subnet IDs or subnet lookup inputs.
- Supports diagnostics to one or more Log Analytics workspaces with optional category selection.
- Supports resource-level RBAC via explicit permissions and Entra group inputs.
- Supports optional Key Vault Secrets User assignment only when requested or when SHIR is enabled.

## Basic Usage

```hcl
module "adf" {
  source = "./modules/adf"

  name           = "platformdata"
  app_env        = "prod"
  location       = "eastus"
  resource_group = "rg-example-prod"

  public_network_enabled          = false
  managed_virtual_network_enabled = true

  tags = {
    Owner = "CCOE"
  }
}
```

## Hardened Pattern

```hcl
module "adf" {
  source = "./modules/adf"

  name           = "platformdata"
  app_env        = "prod"
  location       = "eastus"
  resource_group = "rg-example-prod"

  identity_type = "SystemAssigned, UserAssigned"
  identity_ids = [
    "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uai-adf-cmk"
  ]

  customer_managed_key_id          = "https://<vault-name>.vault.azure.net/keys/<key-name>/<key-version>"
  customer_managed_key_identity_id = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uai-adf-cmk"
  purview_id                       = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Purview/accounts/<purview-name>"

  enable_private_endpoint    = true
  private_endpoint_subnet_id = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>"
  private_dns_zone_id        = "/subscriptions/<subscription-id>/resourceGroups/<dns-rg>/providers/Microsoft.Network/privateDnsZones/privatelink.datafactory.azure.net"

  managed_private_endpoint = [
    {
      name               = "storage-blob"
      target_resource_id = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/<storage-name>"
      subresource_name   = "blob"
    }
  ]

  enable_diagnostics = true
  log_analytics_workspace = {
    platform = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.OperationalInsights/workspaces/<workspace-name>"
  }
}
```

## SHIR Notes

SHIR remains available, but its required dependencies are now conditional. Set `self_hosted_integration_runtime_enabled = true` and provide `app_vm`, `app_rg`, `app_snet`, `app_vnet`, `app_vnet_rg`, `iac_rg`, `iac_kv`, and `iac_st`.

## Testing

Run module tests from the module directory:

```powershell
terraform test
terraform test -filter="tests\live.tftest.hcl"
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 3.8.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.61.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_shir"></a> [shir](#module\_shir) | ../winvm | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_data_factory.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory) | resource |
| [azurerm_data_factory_integration_runtime_azure.auto_resolve](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_integration_runtime_azure) | resource |
| [azurerm_data_factory_integration_runtime_self_hosted.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_integration_runtime_self_hosted) | resource |
| [azurerm_data_factory_managed_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_managed_private_endpoint) | resource |
| [azurerm_key_vault_secret.default_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.shir_key1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.adf_datafactory](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.app_admin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_user_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.data_factory](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.secret_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azuread_group.app_admin](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azuread_group.app_user](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azurerm_key_vault.iac](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_monitor_diagnostic_categories.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_diagnostic_categories) | data source |
| [azurerm_private_dns_zone.adf_datafactory](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |
| [azurerm_resource_group.adf](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_resource_group.iac](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_storage_account.iac](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) | data source |
| [azurerm_subnet.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_analytics_destination_type"></a> [analytics\_destination\_type](#input\_analytics\_destination\_type) | Log analytics destination type | `string` | `"Dedicated"` | no |
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | The list of groups that will have administrative access to the resources. | `list(string)` | `[]` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Environment, the environment name such as 'sbx','test', 'prod', 'dev','qa' | `string` | `"dev"` | no |
| <a name="input_app_rg"></a> [app\_rg](#input\_app\_rg) | The application resource group name | `string` | `""` | no |
| <a name="input_app_snet"></a> [app\_snet](#input\_app\_snet) | The application subnet name used by SHIR or as the legacy private endpoint subnet lookup input. | `string` | `""` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | The list of groups that will have Reader access to the Azure Data Factory resource and remote access to the SHIR VM. | `list(string)` | `[]` | no |
| <a name="input_app_vm"></a> [app\_vm](#input\_app\_vm) | The VM name used for Self Hosted Integration Runtime | `string` | `""` | no |
| <a name="input_app_vnet"></a> [app\_vnet](#input\_app\_vnet) | The application virtual network name used by SHIR or as the legacy private endpoint virtual network lookup input. | `string` | `""` | no |
| <a name="input_app_vnet_rg"></a> [app\_vnet\_rg](#input\_app\_vnet\_rg) | The application virtual network resource group used by SHIR or as the legacy private endpoint network lookup input. | `string` | `""` | no |
| <a name="input_cleanup_enabled"></a> [cleanup\_enabled](#input\_cleanup\_enabled) | Cluster will not be recycled and it will be used in next data flow activity run until TTL (time to live) is reached if this is set as false | `bool` | `true` | no |
| <a name="input_compute_type"></a> [compute\_type](#input\_compute\_type) | Compute type of the cluster which will execute data flow job: [General\|ComputeOptimized\|MemoryOptimized] | `string` | `"General"` | no |
| <a name="input_core_count"></a> [core\_count](#input\_core\_count) | Core count of the cluster which will execute data flow job: [8\|16\|32\|48\|80\|144\|272] | `number` | `8` | no |
| <a name="input_create_default_azure_integration_runtime"></a> [create\_default\_azure\_integration\_runtime](#input\_create\_default\_azure\_integration\_runtime) | Whether to create a configurable Azure Integration Runtime for Data Factory. | `bool` | `true` | no |
| <a name="input_custom_adf_name"></a> [custom\_adf\_name](#input\_custom\_adf\_name) | Specifies the name of the Data Factory | `string` | `null` | no |
| <a name="input_custom_default_ir_name"></a> [custom\_default\_ir\_name](#input\_custom\_default\_ir\_name) | Specifies the name of the Managed Integration Runtime | `string` | `null` | no |
| <a name="input_custom_diagnostics_name"></a> [custom\_diagnostics\_name](#input\_custom\_diagnostics\_name) | Specifies the name of Diagnostic Settings that monitors ADF | `string` | `null` | no |
| <a name="input_custom_shir_name"></a> [custom\_shir\_name](#input\_custom\_shir\_name) | Specifies the name of Self Hosted Integration runtime | `string` | `null` | no |
| <a name="input_customer_managed_key_id"></a> [customer\_managed\_key\_id](#input\_customer\_managed\_key\_id) | Specifies the Azure Key Vault Key ID to be used as the Customer Managed Key for Double Encryption. | `string` | `null` | no |
| <a name="input_customer_managed_key_identity_id"></a> [customer\_managed\_key\_identity\_id](#input\_customer\_managed\_key\_identity\_id) | User-assigned managed identity resource ID used to access the customer-managed key. | `string` | `null` | no |
| <a name="input_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#input\_diagnostic\_log\_categories) | Diagnostic log categories to enable. Leave empty to enable all categories returned by Azure Monitor. | `list(string)` | `[]` | no |
| <a name="input_diagnostic_metric_categories"></a> [diagnostic\_metric\_categories](#input\_diagnostic\_metric\_categories) | Diagnostic metric categories to enable. Leave empty to enable all metric categories returned by Azure Monitor. | `list(string)` | `[]` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Whether to create diagnostic settings. For backward compatibility, a non-empty log\_analytics\_workspace map also enables diagnostics. | `bool` | `false` | no |
| <a name="input_enable_key_vault_secret_user_role_assignment"></a> [enable\_key\_vault\_secret\_user\_role\_assignment](#input\_enable\_key\_vault\_secret\_user\_role\_assignment) | Whether to grant the Data Factory system-assigned identity Key Vault Secrets User on the IaC Key Vault. | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Whether to create the ADF control-plane private endpoint. | `bool` | `false` | no |
| <a name="input_github_configuration"></a> [github\_configuration](#input\_github\_configuration) | GitHub repo settings for ADF | <pre>object({<br>    account_name         = string<br>    branch_name          = string<br>    git_url              = string<br>    repository_name      = string<br>    root_folder          = string<br>    collaboration_branch = optional(string)<br>    publishing_enabled   = optional(bool, true)<br>  })</pre> | `null` | no |
| <a name="input_global_parameter"></a> [global\_parameter](#input\_global\_parameter) | Configuration of data factory global parameters | <pre>list(object({<br>    name  = string<br>    type  = optional(string, "String")<br>    value = string<br>  }))</pre> | `[]` | no |
| <a name="input_iac_kv"></a> [iac\_kv](#input\_iac\_kv) | The key vault for IaC secrets | `string` | `""` | no |
| <a name="input_iac_rg"></a> [iac\_rg](#input\_iac\_rg) | The resource group containing IaC dependencies (key vault, storage) | `string` | `""` | no |
| <a name="input_iac_st"></a> [iac\_st](#input\_iac\_st) | The storage account for IaC | `string` | `""` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Specifies a list of User Assigned Managed Identity IDs to be assigned to this Data Factory. Required if identity\_type contains UserAssigned. | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | Specifies the type of Managed Service Identity that should be configured on this Data Factory. Possible values are None, SystemAssigned, UserAssigned, SystemAssigned, UserAssigned. | `string` | `"SystemAssigned"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region for Data Factory. If empty, the target resource group's location is used. | `string` | `""` | no |
| <a name="input_log_analytics_workspace"></a> [log\_analytics\_workspace](#input\_log\_analytics\_workspace) | Log Analytics Workspace Name to ID map | `map(string)` | `{}` | no |
| <a name="input_managed_private_endpoint"></a> [managed\_private\_endpoint](#input\_managed\_private\_endpoint) | The ID and sub resource name of the Private Link Enabled Remote Resource | <pre>set(object({<br>    name               = string<br>    target_resource_id = string<br>    subresource_name   = string<br>  }))</pre> | `[]` | no |
| <a name="input_managed_virtual_network_enabled"></a> [managed\_virtual\_network\_enabled](#input\_managed\_virtual\_network\_enabled) | Is Managed Virtual Network enabled? | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Application or workload token used in the generated Data Factory name. | `string` | n/a | yes |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | Additional role assignments to create on the Data Factory resource. | <pre>list(object({<br>    object_id = string<br>    role      = string<br>  }))</pre> | `[]` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Optional existing private DNS zone ID for privatelink.datafactory.azure.net. | `string` | `""` | no |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | Private DNS zone name used when looking up the existing ADF private DNS zone. | `string` | `"privatelink.datafactory.azure.net"` | no |
| <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name) | Resource group containing the existing ADF private DNS zone when private\_dns\_zone\_id is not provided. | `string` | `""` | no |
| <a name="input_private_endpoint_network_resource_group_name"></a> [private\_endpoint\_network\_resource\_group\_name](#input\_private\_endpoint\_network\_resource\_group\_name) | Resource group containing the virtual network used for private endpoint subnet lookup. Falls back to app\_vnet\_rg when empty. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | Optional subnet ID for the ADF private endpoint. If set, subnet lookup inputs are ignored. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#input\_private\_endpoint\_subnet\_name) | Existing subnet name used for private endpoint lookup when private\_endpoint\_subnet\_id is not set. Falls back to app\_snet when empty. | `string` | `""` | no |
| <a name="input_private_endpoint_vnet_name"></a> [private\_endpoint\_vnet\_name](#input\_private\_endpoint\_vnet\_name) | Existing virtual network name used for private endpoint subnet lookup. Falls back to app\_vnet when empty. | `string` | `""` | no |
| <a name="input_public_network_enabled"></a> [public\_network\_enabled](#input\_public\_network\_enabled) | Is the Data Factory visible to the public network? | `bool` | `false` | no |
| <a name="input_purview_id"></a> [purview\_id](#input\_purview\_id) | Specifies the ID of the Purview Account associated with this Data Factory. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | The name of the resource group in which to create the data factory. | `string` | n/a | yes |
| <a name="input_self_hosted_integration_runtime_enabled"></a> [self\_hosted\_integration\_runtime\_enabled](#input\_self\_hosted\_integration\_runtime\_enabled) | Self Hosted Integration runtime | `bool` | `false` | no |
| <a name="input_shir_primary_authorization_key_secret_name"></a> [shir\_primary\_authorization\_key\_secret\_name](#input\_shir\_primary\_authorization\_key\_secret\_name) | Key Vault secret name that receives the SHIR primary authorization key when SHIR is enabled. | `string` | `"adf-ccoe-default-shir-key"` | no |
| <a name="input_shir_secondary_authorization_key_secret_name"></a> [shir\_secondary\_authorization\_key\_secret\_name](#input\_shir\_secondary\_authorization\_key\_secret\_name) | Second Key Vault secret name that receives the SHIR primary authorization key when SHIR is enabled, preserved for backward-compatible consumers. | `string` | `"adf-ccoe-shir-default-key"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | customized tags | `map(string)` | `{}` | no |
| <a name="input_time_to_live_min"></a> [time\_to\_live\_min](#input\_time\_to\_live\_min) | TTL for Integration runtime | `number` | `15` | no |
| <a name="input_virtual_network_enabled"></a> [virtual\_network\_enabled](#input\_virtual\_network\_enabled) | Managed Virtual Network for Integration runtime | `bool` | `true` | no |
| <a name="input_vsts_configuration"></a> [vsts\_configuration](#input\_vsts\_configuration) | Azure DevOps repo settings for ADF | <pre>object({<br>    account_name         = string<br>    project_name         = string<br>    repository_name      = string<br>    branch_name          = string<br>    root_folder          = string<br>    tenant_id            = string<br>    collaboration_branch = optional(string)<br>    publishing_enabled   = optional(bool, true)<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_additional_role_assignment_ids"></a> [additional\_role\_assignment\_ids](#output\_additional\_role\_assignment\_ids) | Map of additional Data Factory role assignment IDs keyed by object ID and role. |
| <a name="output_app_admin_group_role_assignment_ids"></a> [app\_admin\_group\_role\_assignment\_ids](#output\_app\_admin\_group\_role\_assignment\_ids) | Map of Contributor role assignment IDs keyed by app\_admin\_group principal ID or display name. |
| <a name="output_app_user_group_role_assignment_ids"></a> [app\_user\_group\_role\_assignment\_ids](#output\_app\_user\_group\_role\_assignment\_ids) | Map of Reader role assignment IDs keyed by app\_user\_group principal ID or display name. |
| <a name="output_default_integration_runtime_id"></a> [default\_integration\_runtime\_id](#output\_default\_integration\_runtime\_id) | Data Factory Azure Integration Runtime ID when created. |
| <a name="output_default_integration_runtime_name"></a> [default\_integration\_runtime\_name](#output\_default\_integration\_runtime\_name) | Data Factory Azure Integration Runtime name when created. |
| <a name="output_diagnostic_setting_ids"></a> [diagnostic\_setting\_ids](#output\_diagnostic\_setting\_ids) | Diagnostic setting IDs keyed by log analytics workspace map key. |
| <a name="output_diagnostics_enabled"></a> [diagnostics\_enabled](#output\_diagnostics\_enabled) | True when diagnostic settings are enabled. |
| <a name="output_id"></a> [id](#output\_id) | Data Factory resource ID. |
| <a name="output_identity"></a> [identity](#output\_identity) | Data Factory managed identity block. |
| <a name="output_key_vault_secret_user_role_assignment_id"></a> [key\_vault\_secret\_user\_role\_assignment\_id](#output\_key\_vault\_secret\_user\_role\_assignment\_id) | Key Vault Secrets User role assignment ID for the Data Factory managed identity when created. |
| <a name="output_location"></a> [location](#output\_location) | Data Factory Azure region. |
| <a name="output_managed_private_endpoint_fqdns"></a> [managed\_private\_endpoint\_fqdns](#output\_managed\_private\_endpoint\_fqdns) | Managed private endpoint FQDNs keyed by input name. |
| <a name="output_managed_private_endpoint_ids"></a> [managed\_private\_endpoint\_ids](#output\_managed\_private\_endpoint\_ids) | Managed private endpoint IDs keyed by input name. |
| <a name="output_merged_tags"></a> [merged\_tags](#output\_merged\_tags) | Final merged tags applied to resources. |
| <a name="output_name"></a> [name](#output\_name) | Data Factory name. |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | Principal ID for the Data Factory managed identity when present. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | ADF private endpoint ID when created. |
| <a name="output_private_endpoint_ip_address"></a> [private\_endpoint\_ip\_address](#output\_private\_endpoint\_ip\_address) | ADF private endpoint private IP address when created. |
| <a name="output_self_hosted_integration_runtime_id"></a> [self\_hosted\_integration\_runtime\_id](#output\_self\_hosted\_integration\_runtime\_id) | Self-hosted integration runtime ID when created. |
| <a name="output_self_hosted_integration_runtime_key"></a> [self\_hosted\_integration\_runtime\_key](#output\_self\_hosted\_integration\_runtime\_key) | Self-hosted integration runtime primary authorization key. |
| <a name="output_self_hosted_integration_runtime_name"></a> [self\_hosted\_integration\_runtime\_name](#output\_self\_hosted\_integration\_runtime\_name) | Self-hosted integration runtime name when created. |
| <a name="output_shir_authorization_key_secret_ids"></a> [shir\_authorization\_key\_secret\_ids](#output\_shir\_authorization\_key\_secret\_ids) | Key Vault secret IDs created for SHIR authorization keys. |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | Tenant ID for the Data Factory managed identity when present. |
<!-- END_TF_DOCS -->
