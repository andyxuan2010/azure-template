# Azure Flex Consumption Function App

Provisions one Azure Function App on the Flex Consumption hosting model with normalized naming, resource-group tag inheritance, Flex runtime and blob-container configuration, managed identity, scaling controls, VNet integration, and secure network defaults.

## Features

- Uses the dedicated `azurerm_function_app_flex_consumption` resource.
- Consumes an existing Linux `FC1` App Service Plan and blob deployment container.
- Supports Node.js, .NET isolated, Python, Java, PowerShell, and custom runtime names accepted by AzureRM.
- Supports instance memory, maximum instance count, HTTP concurrency, and always-ready function instances.
- Supports storage access-key or user-assigned identity authentication.
- Supports system-assigned and user-assigned managed identity.
- Supports app settings, ZIP deployment, Application Insights settings, health checks, VNet integration, and tag inheritance.
- Defaults to HTTPS-only traffic and disables public network access.

## Resources Created

The module always creates one `azurerm_function_app_flex_consumption`. The resource group, Flex Consumption App Service Plan, storage account, blob deployment container, package artifact, networking, monitoring destinations, and RBAC assignments are existing or caller-owned dependencies.

See [architecture](docs/architecture.md) for the resource boundary and Flex-specific dependencies.

## Prerequisites and Dependencies

- Terraform 1.6 or newer.
- AzureRM provider 4.x.
- An existing Linux App Service Plan using the `FC1` Flex Consumption SKU.
- An existing private blob container endpoint for deployment content.
- A storage access key or a user-assigned identity configured for storage access.
- Azure permissions to create and manage Function Apps in the resource group.

## Provider Configuration

Configure AzureRM in the calling root module:

```hcl
provider "azurerm" {
  features {}
}
```

## Basic Usage

```hcl
module "functionappflex" {
  source = "./modules/functionappflex"

  name                       = "func-orders-prod"
  resource_group_name        = "rg-orders-prod"
  location                   = "canadacentral"
  service_plan_id            = module.flex_plan.id
  runtime_name               = "python"
  runtime_version            = "3.11"
  storage_container_endpoint = module.function_package_container.resource_id
  storage_access_key         = var.function_storage_access_key
}
```

The executable configurations are in [`examples/basic`](examples/basic/) and [`examples/complete`](examples/complete/).

## Flex Consumption Behavior

This module is separate from the repository's general-purpose Function App module because Flex Consumption has different required inputs and scaling behavior. The caller supplies the Flex-compatible `FC1` plan, runtime metadata, and blob deployment container. Set `instance_memory_in_mb`, `maximum_instance_count`, `http_concurrency`, and `always_ready` only after confirming the target region and workload requirements.

## Storage and Deployment

Set `storage_authentication_type = "StorageAccountConnectionString"` with `storage_access_key`, or set `storage_authentication_type = "UserAssignedIdentity"` with `storage_user_assigned_identity_id` included in the Function App's `identity_ids`. The module rejects incomplete or conflicting storage authentication configuration.

The deployment container is a prerequisite; this module does not upload a package or create a storage account. Keep access keys, app settings, Application Insights credentials, and ZIP artifacts out of source control.

## Networking, Identity, and Secure Defaults

Public network access is disabled and HTTPS-only traffic is enabled by default. Regional VNet integration is optional and requires an existing compatible subnet. Managed identities are opt-in and receive no RBAC assignments from this module; grant permissions in the owning composition using least privilege.

## Naming and Tagging

Provide `name` for a stable explicit name or leave it empty to generate a name from the `func` prefix, workload, location code, environment, and instance. Function App names are limited to 32 characters by the Flex resource's host ID collision guidance. Caller tags override inherited resource-group tags.

Follow the repository [naming convention](../../docs/60-security-governance/naming-convention.md) and [tagging standard](../../docs/60-security-governance/tagging-standard.md).

## Testing

`tests/unit.tftest.hcl` uses a mocked AzureRM provider and plan-only tests. It creates no Azure resources and requires no Azure authentication.

```powershell
terraform init -backend=false
terraform validate
terraform test
```

## Known Limitations

- The module does not create the Flex plan, storage account, blob container, package artifact, resource group, custom domains, private endpoints, monitoring destinations, or RBAC assignments.
- Runtime version availability, Flex SKU availability, regional quotas, and Azure Functions limits are validated by Azure and can change independently of the provider.
- Mocked tests cannot prove package deployment, storage reachability, VNet routing, runtime compatibility, or Azure policy effects.

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
| [azurerm_function_app_flex_consumption.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app_flex_consumption) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_always_ready"></a> [always\_ready](#input\_always\_ready) | Map of Flex function names to always-ready instance counts. | `map(number)` | `{}` | no |
| <a name="input_app_command_line"></a> [app\_command\_line](#input\_app\_command\_line) | Optional command line used to launch the application. | `string` | `null` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used when the Function App name is generated. | `string` | `"dev"` | no |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | Application settings for the Flex Consumption Function App. | `map(string)` | `{}` | no |
| <a name="input_application_insights_connection_string"></a> [application\_insights\_connection\_string](#input\_application\_insights\_connection\_string) | Optional Application Insights connection string. | `string` | `null` | no |
| <a name="input_application_insights_key"></a> [application\_insights\_key](#input\_application\_insights\_key) | Optional Application Insights instrumentation key. | `string` | `null` | no |
| <a name="input_client_certificate_enabled"></a> [client\_certificate\_enabled](#input\_client\_certificate\_enabled) | Whether client certificates are enabled for inbound requests. | `bool` | `false` | no |
| <a name="input_client_certificate_exclusion_paths"></a> [client\_certificate\_exclusion\_paths](#input\_client\_certificate\_exclusion\_paths) | Paths excluded from client certificate authentication, separated by semicolons. | `string` | `null` | no |
| <a name="input_client_certificate_mode"></a> [client\_certificate\_mode](#input\_client\_certificate\_mode) | Client certificate mode when client certificates are enabled. | `string` | `"Optional"` | no |
| <a name="input_default_documents"></a> [default\_documents](#input\_default\_documents) | Optional default documents for the Function App site. | `list(string)` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether the Flex Consumption Function App is enabled. | `bool` | `true` | no |
| <a name="input_health_check_eviction_time_in_min"></a> [health\_check\_eviction\_time\_in\_min](#input\_health\_check\_eviction\_time\_in\_min) | Minutes before an unhealthy node is removed from the load balancer when health\_check\_path is set. | `number` | `null` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Optional health check path for the Function App. | `string` | `null` | no |
| <a name="input_http2_enabled"></a> [http2\_enabled](#input\_http2\_enabled) | Whether HTTP/2 is enabled. | `bool` | `false` | no |
| <a name="input_http_concurrency"></a> [http\_concurrency](#input\_http\_concurrency) | Maximum HTTP concurrency per Flex Consumption instance. Leave null for platform assignment. | `number` | `null` | no |
| <a name="input_https_only"></a> [https\_only](#input\_https\_only) | Whether only HTTPS traffic is allowed. | `bool` | `true` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | User-assigned managed identity resource IDs assigned to the Function App. | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | Optional managed identity type for the Function App. | `string` | `null` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into the Function App. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags. When null and inheritance is enabled, the module reads the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance identifier used when the Function App name is generated. | `string` | `"001"` | no |
| <a name="input_instance_memory_in_mb"></a> [instance\_memory\_in\_mb](#input\_instance\_memory\_in\_mb) | Memory allocated to each Flex Consumption instance. Azure currently supports 2048 or 4096 MB. | `number` | `2048` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the Flex Consumption Function App. Leave empty to use the existing resource group's location. | `string` | `""` | no |
| <a name="input_location_code"></a> [location\_code](#input\_location\_code) | Optional short location code used when the Function App name is generated. | `string` | `""` | no |
| <a name="input_maximum_instance_count"></a> [maximum\_instance\_count](#input\_maximum\_instance\_count) | Maximum number of Flex Consumption instances. Leave null to use the platform default. | `number` | `null` | no |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | Minimum TLS version for inbound SSL requests. | `string` | `"1.2"` | no |
| <a name="input_name"></a> [name](#input\_name) | Optional Flex Consumption Function App name override. Leave empty to generate one from the naming convention. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used when the Flex Consumption Function App name is generated. | `string` | `"func"` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is enabled. | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the existing resource group where the Flex Consumption Function App is deployed. | `string` | n/a | yes |
| <a name="input_runtime_name"></a> [runtime\_name](#input\_runtime\_name) | Flex Consumption runtime name. | `string` | n/a | yes |
| <a name="input_runtime_scale_monitoring_enabled"></a> [runtime\_scale\_monitoring\_enabled](#input\_runtime\_scale\_monitoring\_enabled) | Whether Functions runtime scale monitoring is enabled. | `bool` | `false` | no |
| <a name="input_runtime_version"></a> [runtime\_version](#input\_runtime\_version) | Version supported by runtime\_name, such as 20 for Node.js, 3.11 for Python, or 8.0 for .NET isolated. | `string` | n/a | yes |
| <a name="input_scm_minimum_tls_version"></a> [scm\_minimum\_tls\_version](#input\_scm\_minimum\_tls\_version) | Minimum TLS version for the SCM site. | `string` | `"1.2"` | no |
| <a name="input_service_plan_id"></a> [service\_plan\_id](#input\_service\_plan\_id) | Resource ID of an existing Flex Consumption App Service Plan. The plan must use the FC1 SKU and Linux operating system. | `string` | n/a | yes |
| <a name="input_storage_access_key"></a> [storage\_access\_key](#input\_storage\_access\_key) | Storage account access key used when storage\_authentication\_type is StorageAccountConnectionString. | `string` | `null` | no |
| <a name="input_storage_authentication_type"></a> [storage\_authentication\_type](#input\_storage\_authentication\_type) | Authentication method used by the Flex Function App to access deployment storage. | `string` | `"StorageAccountConnectionString"` | no |
| <a name="input_storage_container_endpoint"></a> [storage\_container\_endpoint](#input\_storage\_container\_endpoint) | Endpoint or resource ID of the blob container where the Function App package is hosted. | `string` | n/a | yes |
| <a name="input_storage_container_type"></a> [storage\_container\_type](#input\_storage\_container\_type) | Flex deployment storage container type. Azure currently supports blobContainer. | `string` | `"blobContainer"` | no |
| <a name="input_storage_user_assigned_identity_id"></a> [storage\_user\_assigned\_identity\_id](#input\_storage\_user\_assigned\_identity\_id) | User-assigned managed identity resource ID used when storage\_authentication\_type is UserAssignedIdentity. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the Function App. Caller tags override inherited resource-group tags. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional timeouts for Function App create, read, update, and delete operations. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_use_32_bit_worker"></a> [use\_32\_bit\_worker](#input\_use\_32\_bit\_worker) | Whether the Function App should use a 32-bit worker. | `bool` | `false` | no |
| <a name="input_virtual_network_subnet_id"></a> [virtual\_network\_subnet\_id](#input\_virtual\_network\_subnet\_id) | Optional subnet ID used for regional VNet integration. | `string` | `null` | no |
| <a name="input_vnet_route_all_enabled"></a> [vnet\_route\_all\_enabled](#input\_vnet\_route\_all\_enabled) | Whether all outbound traffic should route through the integrated VNet. | `bool` | `false` | no |
| <a name="input_webdeploy_publish_basic_authentication_enabled"></a> [webdeploy\_publish\_basic\_authentication\_enabled](#input\_webdeploy\_publish\_basic\_authentication\_enabled) | Whether WebDeploy publishing basic authentication is enabled. | `bool` | `false` | no |
| <a name="input_websockets_enabled"></a> [websockets\_enabled](#input\_websockets\_enabled) | Whether WebSockets are enabled. | `bool` | `false` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Compatibility workload segment used when workload\_name is empty. | `string` | `"project"` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Optional workload segment used when the Function App name is generated. | `string` | `""` | no |
| <a name="input_zip_deploy_file"></a> [zip\_deploy\_file](#input\_zip\_deploy\_file) | Optional local ZIP package path for deployment. The caller must set the required package app settings. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_domain_verification_id"></a> [custom\_domain\_verification\_id](#output\_custom\_domain\_verification\_id) | Custom domain verification ID for the Function App. |
| <a name="output_default_hostname"></a> [default\_hostname](#output\_default\_hostname) | Default hostname for the Function App. |
| <a name="output_http_concurrency"></a> [http\_concurrency](#output\_http\_concurrency) | Configured HTTP concurrency per Flex Consumption instance. |
| <a name="output_id"></a> [id](#output\_id) | Function App resource ID. |
| <a name="output_identity_principal_id"></a> [identity\_principal\_id](#output\_identity\_principal\_id) | Principal ID of the managed identity when configured. |
| <a name="output_identity_tenant_id"></a> [identity\_tenant\_id](#output\_identity\_tenant\_id) | Tenant ID of the managed identity when configured. |
| <a name="output_instance_memory_in_mb"></a> [instance\_memory\_in\_mb](#output\_instance\_memory\_in\_mb) | Configured memory per Flex Consumption instance. |
| <a name="output_location"></a> [location](#output\_location) | Azure region used by the Function App. |
| <a name="output_maximum_instance_count"></a> [maximum\_instance\_count](#output\_maximum\_instance\_count) | Configured maximum Flex Consumption instance count. |
| <a name="output_name"></a> [name](#output\_name) | Function App name. |
| <a name="output_outbound_ip_addresses"></a> [outbound\_ip\_addresses](#output\_outbound\_ip\_addresses) | Outbound IP addresses for the Function App. |
| <a name="output_possible_outbound_ip_addresses"></a> [possible\_outbound\_ip\_addresses](#output\_possible\_outbound\_ip\_addresses) | Possible outbound IP addresses for the Function App. |
| <a name="output_public_network_access_enabled"></a> [public\_network\_access\_enabled](#output\_public\_network\_access\_enabled) | Whether public network access is enabled. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group containing the Function App. |
| <a name="output_runtime_name"></a> [runtime\_name](#output\_runtime\_name) | Flex Consumption runtime name. |
| <a name="output_runtime_version"></a> [runtime\_version](#output\_runtime\_version) | Flex Consumption runtime version. |
| <a name="output_service_plan_id"></a> [service\_plan\_id](#output\_service\_plan\_id) | Flex Consumption App Service Plan ID used by the Function App. |
| <a name="output_storage_authentication_type"></a> [storage\_authentication\_type](#output\_storage\_authentication\_type) | Storage authentication type used by the Function App. |
| <a name="output_storage_container_endpoint"></a> [storage\_container\_endpoint](#output\_storage\_container\_endpoint) | Deployment storage container endpoint used by the Function App. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to the Function App. |
<!-- END_TF_DOCS -->
