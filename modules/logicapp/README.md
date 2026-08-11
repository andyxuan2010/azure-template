# Azure Logic App Standard

Provisions an Azure Logic App Standard host on an existing Workflow Standard App Service Plan and storage account, with hardened site settings, identity, networking, private connectivity, diagnostics, and RBAC.

## Features

- Creates a Logic App Standard host with a generated or caller-supplied name.
- Uses an existing App Service Plan and storage account.
- Supports system-assigned and user-assigned managed identities.
- Supports regional VNet integration and route-all behavior.
- Creates an optional private endpoint with an existing private DNS zone.
- Configures application settings and connection strings.
- Sends platform logs and metrics to Log Analytics.
- Assigns Contributor and Reader to Microsoft Entra groups.
- Inherits resource-group tags and lets caller tags take precedence.

## Resources Created

The module creates one Logic App Standard resource. Depending on inputs, it can also create:

- a private endpoint and private DNS zone group;
- an Azure Monitor diagnostic setting;
- Logic App-scoped Contributor and Reader role assignments.

The resource group, Workflow Standard App Service Plan, storage account, VNet subnets, private DNS zone, and Log Analytics workspace are existing dependencies.

## Prerequisites and Dependencies

- Terraform 1.6 or newer.
- Existing resource group.
- Existing Windows Workflow Standard App Service Plan.
- Existing general-purpose storage account and optional Azure Files content share.
- Optional delegated subnet for VNet integration.
- Optional separate private endpoint subnet and `privatelink.azurewebsites.net` private DNS zone.
- Optional Log Analytics workspace and Microsoft Entra groups.

A typical composition is `storageaccount + appserviceplan + networking -> logicapp`. See the repository [module dependency guide](../../docs/MODULE_USAGE_AND_DEPENDENCIES.md).

## Provider Configuration

Configure AzureRM and AzureAD in the calling root module:

```hcl
provider "azurerm" {
  features {}
}

provider "azuread" {}
```

AzureAD is used only for group lookups by display name. Prefer immutable group object IDs.

## Basic Usage

```hcl
module "logic_app" {
  source = "./modules/logicapp"

  name                 = "logic-orders-dev-001"
  resource_group_name  = "rg-orders-dev"
  location             = "canadacentral"
  service_plan_id      = module.appserviceplan.id
  storage_account_name = module.storageaccount.name

  system_assigned_identity_enabled = true
}
```

Runnable configurations are available in:

- [`examples/basic`](examples/basic/)
- [`examples/complete`](examples/complete/)
- [`examples/vnet-integration`](examples/vnet-integration/)

## Important Behavior and Secure Defaults

- HTTPS-only, disabled public network access, disabled FTP/SCM basic publishing, TLS 1.2, required client certificates, disabled FTPS, and Always On are defaults.
- System-assigned identity is disabled by default for compatibility; enable it for normal production integrations.
- The module reads the storage account access key, which is then stored in Terraform state as part of the Logic App configuration. Protect the backend.
- Application settings and connection strings may contain secrets and are also retained in Terraform state. Prefer Key Vault references where supported.
- Connection-string names are case-insensitively unique.
- `vnet_route_all_enabled` requires VNet integration.

## Networking and Private Connectivity

Regional VNet integration controls outbound traffic. A private endpoint controls inbound traffic. Use separate subnets because their delegation and private endpoint policies differ.

The Logic App content share and storage endpoints must remain reachable from the integrated network. Disabling public access without working private DNS and routing can make the host unavailable.

Direct subnet and private DNS resource IDs are preferred. Name-based lookup uses the default AzureRM provider and therefore the caller's active subscription.

## Identity and RBAC

The module can configure system-assigned and user-assigned identities but does not grant them permissions to connectors, Key Vault, storage data, Service Bus, or other downstream services.

Optional admin and user groups receive Contributor and Reader at the Logic App resource scope. Review whether narrower custom roles are more appropriate.

## Workflow Deployment

This module creates the Logic App Standard host only. Workflow definitions, managed API connections, connector authentication, deployment packages, and application release pipelines remain separate concerns.

## Naming and Tagging

Set `name` explicitly or allow the module to derive it from workload, location, environment, and instance. Dependent private endpoint and diagnostic names use the resolved Logic App name. Caller tags override inherited resource-group tags.

Follow the repository [naming convention](../../docs/NAMING_CONVENTION.md) and [tagging standard](../../docs/TAGGING_STANDARD.md).

## Architecture

See [`docs/architecture.md`](docs/architecture.md) for host, storage, identity, and network flows.

## Testing

`tests/unit.tftest.hcl` uses mocked AzureRM and AzureAD providers with plan-only and expected-failure runs:

```powershell
terraform init -backend=false
terraform validate
terraform test
```

No Azure resources are deployed by these tests.

## Known Limitations

- The module consumes but does not create the App Service Plan or storage account.
- Workflow definitions and API connections are not managed.
- Private DNS zones, VNet links, and storage private endpoints are not created.
- The storage access-key model cannot provide a keyless Logic App Standard host.
- Runtime behavior depends on plan SKU, storage networking, connectors, and regional Azure capabilities.

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
| [azurerm_logic_app_standard.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_standard) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.app_admin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_user_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_always_on"></a> [always\_on](#input\_always\_on) | Whether the Logic App Standard should always remain warm. | `bool` | `true` | no |
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | List of Microsoft Entra group display names or object IDs that should receive Contributor access to the Logic App Standard. | `list(string)` | `[]` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment metadata retained for interface compatibility. | `string` | `"dev"` | no |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | Additional application settings for the Logic App Standard. | `map(string)` | `{}` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | List of Microsoft Entra group display names or object IDs that should receive Reader access to the Logic App Standard. | `list(string)` | `[]` | no |
| <a name="input_bundle_version"></a> [bundle\_version](#input\_bundle\_version) | Optional extension bundle version. | `string` | `null` | no |
| <a name="input_client_affinity_enabled"></a> [client\_affinity\_enabled](#input\_client\_affinity\_enabled) | Whether client affinity is enabled. | `bool` | `false` | no |
| <a name="input_client_certificate_mode"></a> [client\_certificate\_mode](#input\_client\_certificate\_mode) | Client certificate mode. Value must be Required, Optional, or OptionalInteractiveUser. | `string` | `"Required"` | no |
| <a name="input_connection_strings"></a> [connection\_strings](#input\_connection\_strings) | Optional Logic App Standard connection strings. | <pre>list(object({<br>    name  = string<br>    value = string<br>    type  = optional(string, "Custom")<br>  }))</pre> | `[]` | no |
| <a name="input_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#input\_diagnostic\_log\_categories) | Diagnostic log categories to enable. | `list(string)` | <pre>[<br>  "AppServiceHTTPLogs",<br>  "AppServiceConsoleLogs",<br>  "AppServiceAppLogs",<br>  "AppServiceAuditLogs",<br>  "AppServiceIPSecAuditLogs",<br>  "AppServicePlatformLogs"<br>]</pre> | no |
| <a name="input_diagnostic_metric_categories"></a> [diagnostic\_metric\_categories](#input\_diagnostic\_metric\_categories) | Diagnostic metric categories to enable. | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Whether to create a diagnostic setting for the Logic App Standard. | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Whether to create a private endpoint for the Logic App Standard sites endpoint. | `bool` | `false` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether the Logic App Standard is enabled. | `bool` | `true` | no |
| <a name="input_ftp_publish_basic_authentication_enabled"></a> [ftp\_publish\_basic\_authentication\_enabled](#input\_ftp\_publish\_basic\_authentication\_enabled) | Whether basic authentication is enabled for FTP publishing. | `bool` | `false` | no |
| <a name="input_ftps_state"></a> [ftps\_state](#input\_ftps\_state) | FTPS state for the Logic App Standard. | `string` | `"Disabled"` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Optional health check path. | `string` | `null` | no |
| <a name="input_http2_enabled"></a> [http2\_enabled](#input\_http2\_enabled) | Whether HTTP/2 is enabled. | `bool` | `true` | no |
| <a name="input_https_only"></a> [https\_only](#input\_https\_only) | Whether only HTTPS traffic is allowed. | `bool` | `true` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Optional user-assigned managed identity IDs. | `list(string)` | `[]` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into Logic App resources. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance identifier used when name is not provided. | `string` | `"001"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the Logic App Standard. Leave empty to use the resource group location. | `string` | `""` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace ID used when diagnostics are enabled. | `string` | `""` | no |
| <a name="input_logic_app_version"></a> [logic\_app\_version](#input\_logic\_app\_version) | Optional runtime version for the Logic App Standard. | `string` | `null` | no |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | Minimum TLS version for the Logic App Standard. | `string` | `"1.2"` | no |
| <a name="input_name"></a> [name](#input\_name) | Optional Logic App Standard name override. Leave empty to generate one from the naming convention. | `string` | `""` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Private DNS zone ID for the Logic App Standard private endpoint. Leave empty to resolve by name and resource group. | `string` | `""` | no |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | Existing private DNS zone name used when private\_dns\_zone\_id is empty. | `string` | `""` | no |
| <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name) | Resource group containing the existing private DNS zone used when private\_dns\_zone\_id is empty. | `string` | `""` | no |
| <a name="input_private_endpoint_network_resource_group_name"></a> [private\_endpoint\_network\_resource\_group\_name](#input\_private\_endpoint\_network\_resource\_group\_name) | Resource group containing the existing virtual network used for private endpoint subnet lookup. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | Subnet ID for the private endpoint. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#input\_private\_endpoint\_subnet\_name) | Existing subnet name used for private endpoint subnet lookup. | `string` | `""` | no |
| <a name="input_private_endpoint_vnet_name"></a> [private\_endpoint\_vnet\_name](#input\_private\_endpoint\_vnet\_name) | Existing virtual network name used for private endpoint subnet lookup. | `string` | `""` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is enabled. | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Existing resource group name where the Logic App Standard will be created. | `string` | n/a | yes |
| <a name="input_runtime_scale_monitoring_enabled"></a> [runtime\_scale\_monitoring\_enabled](#input\_runtime\_scale\_monitoring\_enabled) | Whether runtime scale monitoring is enabled. | `bool` | `false` | no |
| <a name="input_scm_basic_auth_publishing_credentials_enabled"></a> [scm\_basic\_auth\_publishing\_credentials\_enabled](#input\_scm\_basic\_auth\_publishing\_credentials\_enabled) | Whether SCM/Kudu basic auth publishing credentials are enabled. | `bool` | `false` | no |
| <a name="input_service_plan_id"></a> [service\_plan\_id](#input\_service\_plan\_id) | App Service Plan ID used to host the Logic App Standard. | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Existing storage account name used by the Logic App Standard. | `string` | n/a | yes |
| <a name="input_storage_account_resource_group_name"></a> [storage\_account\_resource\_group\_name](#input\_storage\_account\_resource\_group\_name) | Resource group containing the existing storage account. Leave empty to use resource\_group\_name. | `string` | `""` | no |
| <a name="input_storage_account_share_name"></a> [storage\_account\_share\_name](#input\_storage\_account\_share\_name) | Optional Azure Files share name used by the Logic App Standard content store. Leave empty to let Azure manage it. | `string` | `null` | no |
| <a name="input_system_assigned_identity_enabled"></a> [system\_assigned\_identity\_enabled](#input\_system\_assigned\_identity\_enabled) | Whether to enable a system-assigned managed identity. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to resources created by this module. | `map(string)` | `{}` | no |
| <a name="input_use_32_bit_worker_process"></a> [use\_32\_bit\_worker\_process](#input\_use\_32\_bit\_worker\_process) | Whether to use a 32-bit worker process. | `bool` | `false` | no |
| <a name="input_use_extension_bundle"></a> [use\_extension\_bundle](#input\_use\_extension\_bundle) | Whether to enable extension bundles for the Logic App Standard runtime. | `bool` | `null` | no |
| <a name="input_virtual_network_subnet_id"></a> [virtual\_network\_subnet\_id](#input\_virtual\_network\_subnet\_id) | Subnet ID for VNet integration. Leave empty to resolve by subnet/vnet/resource group name. | `string` | `""` | no |
| <a name="input_vnet_integration_network_resource_group_name"></a> [vnet\_integration\_network\_resource\_group\_name](#input\_vnet\_integration\_network\_resource\_group\_name) | Resource group containing the virtual network used for VNet integration subnet lookup. | `string` | `""` | no |
| <a name="input_vnet_integration_subnet_name"></a> [vnet\_integration\_subnet\_name](#input\_vnet\_integration\_subnet\_name) | Existing subnet name used for VNet integration when virtual\_network\_subnet\_id is empty. | `string` | `""` | no |
| <a name="input_vnet_integration_vnet_name"></a> [vnet\_integration\_vnet\_name](#input\_vnet\_integration\_vnet\_name) | Existing virtual network name used for VNet integration subnet lookup. | `string` | `""` | no |
| <a name="input_vnet_route_all_enabled"></a> [vnet\_route\_all\_enabled](#input\_vnet\_route\_all\_enabled) | Whether all outbound traffic is routed through the VNet integration subnet. | `bool` | `false` | no |
| <a name="input_websockets_enabled"></a> [websockets\_enabled](#input\_websockets\_enabled) | Whether websockets are enabled. | `bool` | `false` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier used in tagging. | `string` | `"project"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_admin_group_role_assignment_ids"></a> [app\_admin\_group\_role\_assignment\_ids](#output\_app\_admin\_group\_role\_assignment\_ids) | Map of Contributor role assignment IDs keyed by app\_admin\_group principal ID. |
| <a name="output_app_user_group_role_assignment_ids"></a> [app\_user\_group\_role\_assignment\_ids](#output\_app\_user\_group\_role\_assignment\_ids) | Map of Reader role assignment IDs keyed by app\_user\_group principal ID. |
| <a name="output_custom_domain_verification_id"></a> [custom\_domain\_verification\_id](#output\_custom\_domain\_verification\_id) | Identifier used for custom domain ownership verification. |
| <a name="output_default_hostname"></a> [default\_hostname](#output\_default\_hostname) | Default hostname for the Logic App Standard. |
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | Diagnostic setting resource ID when diagnostics are enabled. |
| <a name="output_diagnostics_enabled"></a> [diagnostics\_enabled](#output\_diagnostics\_enabled) | Whether Logic App diagnostic settings are enabled. |
| <a name="output_id"></a> [id](#output\_id) | Logic App Standard resource ID. |
| <a name="output_identity_principal_id"></a> [identity\_principal\_id](#output\_identity\_principal\_id) | Principal ID of the system-assigned managed identity when enabled. |
| <a name="output_identity_tenant_id"></a> [identity\_tenant\_id](#output\_identity\_tenant\_id) | Tenant ID of the system-assigned managed identity when enabled. |
| <a name="output_identity_type"></a> [identity\_type](#output\_identity\_type) | Managed identity type configured on the Logic App. |
| <a name="output_kind"></a> [kind](#output\_kind) | Logic App Standard kind reported by Azure. |
| <a name="output_location"></a> [location](#output\_location) | Resolved Azure region for the Logic App Standard. |
| <a name="output_name"></a> [name](#output\_name) | Logic App Standard name. |
| <a name="output_private_endpoint_enabled"></a> [private\_endpoint\_enabled](#output\_private\_endpoint\_enabled) | Whether the Logic App private endpoint is enabled. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint resource ID when enabled. |
| <a name="output_service_plan_id"></a> [service\_plan\_id](#output\_service\_plan\_id) | Resolved App Service Plan ID used by the Logic App Standard. |
| <a name="output_site_credential_name"></a> [site\_credential\_name](#output\_site\_credential\_name) | The site credentials username used for publishing. |
| <a name="output_site_credential_password"></a> [site\_credential\_password](#output\_site\_credential\_password) | The site credentials password used for publishing. |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | Resolved storage account ID used by the Logic App Standard. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to resources created by this module. |
<!-- END_TF_DOCS -->
