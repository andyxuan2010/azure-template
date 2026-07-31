# Azure Function App

Provisions one Linux or Windows Azure Function App on an existing App Service Plan, with configurable runtime, storage authentication, identity, networking, authentication, diagnostics, and RBAC.

## Features

- Supports Linux and Windows Function Apps and common language or container stacks.
- Supports storage access keys, managed identity, or a Key Vault secret reference.
- Configures system-assigned and user-assigned identities.
- Supports VNet integration, route-all, private endpoints, and private DNS zone attachment.
- Supports Easy Auth v1 or v2, IP restrictions, CORS, backups, storage mounts, and sticky settings.
- Sends platform logs and metrics to Log Analytics, Storage, or Event Hub.
- Assigns Contributor, Reader, or caller-defined roles at the Function App scope.
- Inherits resource-group tags and lets caller tags take precedence.

## Resources Created

The module creates exactly one Linux or Windows Function App. Depending on inputs, it can also create:

- a random naming suffix;
- a private endpoint and private DNS zone group;
- an Azure Monitor diagnostic setting;
- Microsoft Entra group and caller-defined role assignments.

The resource group, App Service Plan, storage account or Key Vault secret, networking, private DNS zones, and monitoring destinations are existing dependencies.

## Prerequisites and Dependencies

- Terraform 1.6 or newer.
- An existing resource group.
- An App Service Plan whose operating system is compatible with `os_type`.
- A storage account, storage access key, or Key Vault secret that contains the Function storage connection string.
- Optional VNet integration and private endpoint subnets; these must be separate subnets.
- Optional `privatelink.azurewebsites.net` private DNS zone and Log Analytics workspace.

A typical composition is `storageaccount + appserviceplan + networking -> functionapp`. See the repository [module dependency guide](../../docs/MODULE_USAGE_AND_DEPENDENCIES.md).

## Provider Configuration

Configure providers in the calling root module:

```hcl
provider "azurerm" {
  features {}
}

provider "azuread" {}
```

AzureAD is used only when a group is supplied by display name. Prefer immutable group object IDs.

## Basic Usage

```hcl
module "function_app" {
  source = "./modules/functionapp"

  name                 = "func-orders-dev-001"
  resource_group_name  = "rg-orders-dev"
  location             = "canadacentral"
  service_plan_id      = module.appserviceplan.id
  storage_account_name = module.storageaccount.name

  application_stack = {
    python_version = "3.11"
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    WEBSITE_RUN_FROM_PACKAGE = "1"
  }
}
```

Runnable configurations are available in:

- [`examples/basic`](examples/basic/)
- [`examples/complete`](examples/complete/)
- [`examples/windows`](examples/windows/)

## Important Behavior and Secure Defaults

- HTTPS-only, disabled public network access, disabled FTP/WebDeploy basic authentication, TLS 1.2 minimum, and matching main/SCM restrictions are defaults.
- Storage access-key, managed-identity, and Key Vault secret modes are mutually exclusive.
- `auth_settings` and `auth_settings_v2` are mutually exclusive.
- Each IP restriction must select exactly one source: IP/CIDR, service tag, or subnet ID.
- App settings, connection strings, storage keys, authentication secrets, and publishing credentials can enter Terraform state. Protect the backend and prefer managed identity or Key Vault references.
- A generated name can include a random suffix; set `name` explicitly for the most predictable replacement behavior.

## Networking and Private Connectivity

VNet integration controls outbound traffic; a private endpoint controls inbound traffic. Use distinct, correctly delegated subnets and plan DNS, route tables, firewalls, storage access, and name resolution together.

Direct subnet and private DNS resource IDs are preferred. Name-based private DNS lookup uses the default AzureRM provider, so the caller must ensure it targets the correct subscription.

## Identity and RBAC

Managed identity can authenticate to the Function storage account, container registry, Key Vault references, and downstream Azure services, but the module does not grant every downstream permission automatically. Assign least-privilege roles in the root composition.

Optional admin and user groups receive Contributor and Reader at the Function App scope. Generic role assignments support other principals and roles.

## Naming and Tagging

Set `name` explicitly or use the workload, environment, location-code, instance, and optional random-suffix inputs. Caller tags override inherited resource-group tags.

Follow the repository [naming convention](../../docs/NAMING_CONVENTION.md) and [tagging standard](../../docs/TAGGING_STANDARD.md).

## Architecture

See [`docs/architecture.md`](docs/architecture.md) for the runtime-selection, storage-authentication, and network-flow model.

## Testing

`tests/unit.tftest.hcl` uses mocked AzureRM, AzureAD, and Random providers with plan-only runs:

```powershell
terraform init -backend=false
terraform validate
terraform test
```

No Azure resources are deployed by these tests.

## Known Limitations

- The module consumes but does not create the App Service Plan or storage account.
- Private endpoint DNS linkage uses existing private DNS zones.
- Storage networking must allow the Function runtime to reach its content and host storage.
- Runtime stacks, settings, and regional capabilities vary by operating system, plan SKU, Azure region, and provider version.
- The module creates one Function App per invocation; use multiple module instances for multiple apps.

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
| [azurerm_linux_function_app.key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_linux_function_app.managed_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.app_admin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_user_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_windows_function_app.key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_function_app) | resource |
| [azurerm_windows_function_app.managed_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_function_app) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_always_on"></a> [always\_on](#input\_always\_on) | Whether the Function App should always remain warm. Required for Dedicated and Premium plans; not supported on classic Consumption. | `bool` | `true` | no |
| <a name="input_api_definition_url"></a> [api\_definition\_url](#input\_api\_definition\_url) | Optional API definition URL. | `string` | `null` | no |
| <a name="input_api_management_api_id"></a> [api\_management\_api\_id](#input\_api\_management\_api\_id) | Optional API Management API ID linked to the Function App. | `string` | `null` | no |
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | List of Microsoft Entra group display names or object IDs that should receive Contributor access to the Function App. | `list(string)` | `[]` | no |
| <a name="input_app_command_line"></a> [app\_command\_line](#input\_app\_command\_line) | Optional startup command. | `string` | `null` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used for standard tags and generated naming. | `string` | `"dev"` | no |
| <a name="input_app_scale_limit"></a> [app\_scale\_limit](#input\_app\_scale\_limit) | Optional maximum number of workers for Elastic Premium or Consumption scale-out. | `number` | `null` | no |
| <a name="input_app_service_logs"></a> [app\_service\_logs](#input\_app\_service\_logs) | Optional filesystem application log settings. | <pre>object({<br>    disk_quota_mb         = optional(number)<br>    retention_period_days = optional(number)<br>  })</pre> | `null` | no |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | Additional application settings for the Function App. | `map(string)` | `{}` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | List of Microsoft Entra group display names or object IDs that should receive Reader access to the Function App. | `list(string)` | `[]` | no |
| <a name="input_application_insights_connection_string"></a> [application\_insights\_connection\_string](#input\_application\_insights\_connection\_string) | Optional Application Insights connection string. | `string` | `null` | no |
| <a name="input_application_insights_key"></a> [application\_insights\_key](#input\_application\_insights\_key) | Optional Application Insights instrumentation key. | `string` | `null` | no |
| <a name="input_application_stack"></a> [application\_stack](#input\_application\_stack) | Application stack settings for the Function App runtime. Configure exactly one runtime family. | <pre>object({<br>    dotnet_version              = optional(string)<br>    java_version                = optional(string)<br>    node_version                = optional(string)<br>    powershell_core_version     = optional(string)<br>    python_version              = optional(string)<br>    use_custom_runtime          = optional(bool)<br>    use_dotnet_isolated_runtime = optional(bool)<br>    docker = optional(object({<br>      image_name        = string<br>      image_tag         = string<br>      registry_url      = string<br>      registry_username = optional(string)<br>      registry_password = optional(string)<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_auth_settings"></a> [auth\_settings](#input\_auth\_settings) | Legacy App Service authentication settings. Prefer auth\_settings\_v2 for new deployments. | <pre>object({<br>    enabled                        = bool<br>    default_provider               = optional(string)<br>    issuer                         = optional(string)<br>    runtime_version                = optional(string)<br>    token_refresh_extension_hours  = optional(number)<br>    token_store_enabled            = optional(bool)<br>    unauthenticated_client_action  = optional(string)<br>    additional_login_parameters    = optional(map(string), {})<br>    allowed_external_redirect_urls = optional(list(string), [])<br>    active_directory = optional(object({<br>      client_id                  = string<br>      client_secret              = optional(string)<br>      client_secret_setting_name = optional(string)<br>      allowed_audiences          = optional(list(string), [])<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_auth_settings_v2"></a> [auth\_settings\_v2](#input\_auth\_settings\_v2) | App Service Authentication v2 settings with optional Microsoft Entra ID and custom OIDC providers. | <pre>object({<br>    auth_enabled                            = optional(bool, true)<br>    runtime_version                         = optional(string, "~1")<br>    config_file_path                        = optional(string)<br>    default_provider                        = optional(string)<br>    excluded_paths                          = optional(list(string), [])<br>    forward_proxy_convention                = optional(string)<br>    forward_proxy_custom_host_header_name   = optional(string)<br>    forward_proxy_custom_scheme_header_name = optional(string)<br>    http_route_api_prefix                   = optional(string, "/.auth")<br>    require_authentication                  = optional(bool, true)<br>    require_https                           = optional(bool, true)<br>    unauthenticated_action                  = optional(string, "RedirectToLoginPage")<br>    active_directory_v2 = optional(object({<br>      client_id                            = string<br>      tenant_auth_endpoint                 = string<br>      allowed_applications                 = optional(list(string), [])<br>      allowed_audiences                    = optional(list(string), [])<br>      allowed_groups                       = optional(list(string), [])<br>      allowed_identities                   = optional(list(string), [])<br>      client_secret_certificate_thumbprint = optional(string)<br>      client_secret_setting_name           = optional(string)<br>      jwt_allowed_client_applications      = optional(list(string), [])<br>      jwt_allowed_groups                   = optional(list(string), [])<br>      login_parameters                     = optional(map(string), {})<br>      www_authentication_disabled          = optional(bool)<br>    }))<br>    custom_oidc_v2 = optional(list(object({<br>      name                          = string<br>      client_id                     = string<br>      openid_configuration_endpoint = string<br>      name_claim_type               = optional(string)<br>      scopes                        = optional(list(string), [])<br>    })), [])<br>    login = optional(object({<br>      allowed_external_redirect_urls    = optional(list(string), [])<br>      cookie_expiration_convention      = optional(string)<br>      cookie_expiration_time            = optional(string)<br>      logout_endpoint                   = optional(string)<br>      nonce_expiration_time             = optional(string)<br>      preserve_url_fragments_for_logins = optional(bool)<br>      token_refresh_extension_time      = optional(string)<br>      token_store_enabled               = optional(bool, true)<br>      token_store_path                  = optional(string)<br>      token_store_sas_setting_name      = optional(string)<br>      validate_nonce                    = optional(bool, true)<br>    }), {})<br>  })</pre> | `null` | no |
| <a name="input_backup"></a> [backup](#input\_backup) | Optional backup configuration. The storage\_account\_url should include a SAS token. | <pre>object({<br>    name                = string<br>    storage_account_url = string<br>    enabled             = optional(bool, true)<br>    schedule = object({<br>      frequency_interval       = number<br>      frequency_unit           = string<br>      keep_at_least_one_backup = optional(bool)<br>      retention_period_days    = optional(number)<br>      start_time               = optional(string)<br>    })<br>  })</pre> | `null` | no |
| <a name="input_builtin_logging_enabled"></a> [builtin\_logging\_enabled](#input\_builtin\_logging\_enabled) | Whether built-in platform logging is enabled. Prefer diagnostic settings for production observability. | `bool` | `false` | no |
| <a name="input_client_certificate_enabled"></a> [client\_certificate\_enabled](#input\_client\_certificate\_enabled) | Whether client certificates are enabled for inbound requests. | `bool` | `false` | no |
| <a name="input_client_certificate_exclusion_paths"></a> [client\_certificate\_exclusion\_paths](#input\_client\_certificate\_exclusion\_paths) | Comma-separated request paths excluded from client certificate authentication. | `string` | `null` | no |
| <a name="input_client_certificate_mode"></a> [client\_certificate\_mode](#input\_client\_certificate\_mode) | Client certificate mode when client certificates are enabled. | `string` | `"Optional"` | no |
| <a name="input_connection_strings"></a> [connection\_strings](#input\_connection\_strings) | Optional Function App connection strings. | <pre>list(object({<br>    name  = string<br>    value = string<br>    type  = optional(string, "Custom")<br>  }))</pre> | `[]` | no |
| <a name="input_container_registry_managed_identity_client_id"></a> [container\_registry\_managed\_identity\_client\_id](#input\_container\_registry\_managed\_identity\_client\_id) | Optional client ID of the managed identity used to pull container images. | `string` | `null` | no |
| <a name="input_container_registry_use_managed_identity"></a> [container\_registry\_use\_managed\_identity](#input\_container\_registry\_use\_managed\_identity) | Whether container image pulls should use managed identity. | `bool` | `false` | no |
| <a name="input_content_share_force_disabled"></a> [content\_share\_force\_disabled](#input\_content\_share\_force\_disabled) | Whether to disable Function App content share creation. | `bool` | `false` | no |
| <a name="input_cors"></a> [cors](#input\_cors) | Optional CORS configuration. | <pre>object({<br>    allowed_origins     = optional(list(string), [])<br>    support_credentials = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_daily_memory_time_quota"></a> [daily\_memory\_time\_quota](#input\_daily\_memory\_time\_quota) | Optional daily memory time quota for Consumption plans. | `number` | `null` | no |
| <a name="input_default_documents"></a> [default\_documents](#input\_default\_documents) | Optional default documents. | `list(string)` | `null` | no |
| <a name="input_diagnostic_eventhub_authorization_rule_id"></a> [diagnostic\_eventhub\_authorization\_rule\_id](#input\_diagnostic\_eventhub\_authorization\_rule\_id) | Optional Event Hub authorization rule ID used to stream diagnostics. | `string` | `""` | no |
| <a name="input_diagnostic_eventhub_name"></a> [diagnostic\_eventhub\_name](#input\_diagnostic\_eventhub\_name) | Optional Event Hub name used to stream diagnostics. | `string` | `null` | no |
| <a name="input_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#input\_diagnostic\_log\_categories) | Diagnostic log categories to enable. Use AllLogs to emit the provider category group instead of individual categories. | `list(string)` | <pre>[<br>  "AppServiceHTTPLogs",<br>  "AppServiceConsoleLogs",<br>  "AppServiceAppLogs",<br>  "AppServiceAuditLogs",<br>  "AppServiceIPSecAuditLogs",<br>  "AppServicePlatformLogs"<br>]</pre> | no |
| <a name="input_diagnostic_log_category_groups"></a> [diagnostic\_log\_category\_groups](#input\_diagnostic\_log\_category\_groups) | Diagnostic log category groups to enable, for example allLogs or audit. | `list(string)` | `[]` | no |
| <a name="input_diagnostic_metric_categories"></a> [diagnostic\_metric\_categories](#input\_diagnostic\_metric\_categories) | Diagnostic metric categories to enable. | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| <a name="input_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#input\_diagnostic\_setting\_name) | Optional diagnostic setting name. Defaults to <function-app-name>-diagnostic-setting. | `string` | `""` | no |
| <a name="input_diagnostic_storage_account_id"></a> [diagnostic\_storage\_account\_id](#input\_diagnostic\_storage\_account\_id) | Optional Storage Account ID used to archive diagnostics. | `string` | `""` | no |
| <a name="input_elastic_instance_minimum"></a> [elastic\_instance\_minimum](#input\_elastic\_instance\_minimum) | Optional minimum number of elastic instances for Premium plans. | `number` | `null` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Whether to create a diagnostic setting for the Function App. Diagnostics are also enabled automatically when any diagnostic destination ID is supplied. | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Whether to create a private endpoint for the Function App sites endpoint. | `bool` | `false` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether the Function App is enabled. | `bool` | `true` | no |
| <a name="input_ftp_publish_basic_authentication_enabled"></a> [ftp\_publish\_basic\_authentication\_enabled](#input\_ftp\_publish\_basic\_authentication\_enabled) | Whether FTP publishing basic authentication is enabled. | `bool` | `false` | no |
| <a name="input_ftps_state"></a> [ftps\_state](#input\_ftps\_state) | FTPS state for the Function App. | `string` | `"Disabled"` | no |
| <a name="input_functions_extension_version"></a> [functions\_extension\_version](#input\_functions\_extension\_version) | Functions runtime extension version. | `string` | `"~4"` | no |
| <a name="input_health_check_eviction_time_in_min"></a> [health\_check\_eviction\_time\_in\_min](#input\_health\_check\_eviction\_time\_in\_min) | Optional health check eviction time in minutes. | `number` | `null` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Optional health check path. | `string` | `null` | no |
| <a name="input_http2_enabled"></a> [http2\_enabled](#input\_http2\_enabled) | Whether HTTP/2 is enabled. | `bool` | `true` | no |
| <a name="input_https_only"></a> [https\_only](#input\_https\_only) | Whether only HTTPS traffic is allowed. | `bool` | `true` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Optional user-assigned managed identity IDs. | `list(string)` | `[]` | no |
| <a name="input_include_environment_in_name"></a> [include\_environment\_in\_name](#input\_include\_environment\_in\_name) | Whether generated Function App names include app\_env. | `bool` | `true` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into module resources. The module only reads the resource group when this is true or location is empty. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Optional instance segment used when generated names do not use a random suffix. | `string` | `"001"` | no |
| <a name="input_ip_restriction_default_action"></a> [ip\_restriction\_default\_action](#input\_ip\_restriction\_default\_action) | Default action for main-site IP restrictions. | `string` | `"Allow"` | no |
| <a name="input_ip_restrictions"></a> [ip\_restrictions](#input\_ip\_restrictions) | Main-site IP restrictions. | <pre>list(object({<br>    name                      = optional(string)<br>    priority                  = optional(number)<br>    action                    = optional(string, "Allow")<br>    description               = optional(string)<br>    ip_address                = optional(string)<br>    service_tag               = optional(string)<br>    virtual_network_subnet_id = optional(string)<br>    headers = optional(list(object({<br>      x_azure_fdid      = optional(list(string), [])<br>      x_fd_health_probe = optional(list(string), [])<br>      x_forwarded_for   = optional(list(string), [])<br>      x_forwarded_host  = optional(list(string), [])<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_key_vault_reference_identity_id"></a> [key\_vault\_reference\_identity\_id](#input\_key\_vault\_reference\_identity\_id) | Managed identity ID used for Key Vault references in app settings. | `string` | `""` | no |
| <a name="input_load_balancing_mode"></a> [load\_balancing\_mode](#input\_load\_balancing\_mode) | Load balancing mode for the Function App. | `string` | `"LeastRequests"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the Function App. Leave empty to use the resource group location. | `string` | `""` | no |
| <a name="input_location_code"></a> [location\_code](#input\_location\_code) | Optional short location code used when the Function App name is generated. | `string` | `""` | no |
| <a name="input_log_analytics_destination_type"></a> [log\_analytics\_destination\_type](#input\_log\_analytics\_destination\_type) | Diagnostic Log Analytics destination type. | `string` | `null` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace ID used for diagnostics. | `string` | `""` | no |
| <a name="input_managed_pipeline_mode"></a> [managed\_pipeline\_mode](#input\_managed\_pipeline\_mode) | Managed pipeline mode. | `string` | `"Integrated"` | no |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | Minimum TLS version for the Function App. | `string` | `"1.2"` | no |
| <a name="input_name"></a> [name](#input\_name) | Function App name. Leave empty to auto-generate a standardized name. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used when the Function App name is generated. | `string` | `"func"` | no |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | Function App operating system. Supported values: Linux or Windows. | `string` | `"Linux"` | no |
| <a name="input_pre_warmed_instance_count"></a> [pre\_warmed\_instance\_count](#input\_pre\_warmed\_instance\_count) | Optional number of pre-warmed instances for Premium plans. | `number` | `null` | no |
| <a name="input_private_dns_zone_group_name"></a> [private\_dns\_zone\_group\_name](#input\_private\_dns\_zone\_group\_name) | Private DNS zone group name for the private endpoint. | `string` | `"default"` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Private DNS zone ID for the Function App private endpoint. Leave empty to resolve by name and resource group. | `string` | `""` | no |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | Additional private DNS zone IDs associated with the private endpoint. | `list(string)` | `[]` | no |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | Existing private DNS zone name used when private\_dns\_zone\_id is empty. | `string` | `""` | no |
| <a name="input_private_dns_zone_names"></a> [private\_dns\_zone\_names](#input\_private\_dns\_zone\_names) | Additional private DNS zone names to look up in private\_dns\_zone\_resource\_group\_name. | `list(string)` | `[]` | no |
| <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name) | Resource group containing existing private DNS zones used when private DNS zone IDs are not supplied. | `string` | `""` | no |
| <a name="input_private_endpoint_ip_configurations"></a> [private\_endpoint\_ip\_configurations](#input\_private\_endpoint\_ip\_configurations) | Optional static private endpoint IP configurations. | <pre>list(object({<br>    name               = string<br>    private_ip_address = string<br>    subresource_name   = optional(string, "sites")<br>    member_name        = optional(string, "sites")<br>  }))</pre> | `[]` | no |
| <a name="input_private_endpoint_manual_connection"></a> [private\_endpoint\_manual\_connection](#input\_private\_endpoint\_manual\_connection) | Whether the private endpoint connection should be manually approved. | `bool` | `false` | no |
| <a name="input_private_endpoint_manual_request_message"></a> [private\_endpoint\_manual\_request\_message](#input\_private\_endpoint\_manual\_request\_message) | Optional approval request message for manual private endpoint connections. | `string` | `""` | no |
| <a name="input_private_endpoint_name"></a> [private\_endpoint\_name](#input\_private\_endpoint\_name) | Optional private endpoint name. Defaults to pep-<function-app-name>. | `string` | `""` | no |
| <a name="input_private_endpoint_network_interface_name"></a> [private\_endpoint\_network\_interface\_name](#input\_private\_endpoint\_network\_interface\_name) | Optional custom network interface name for the private endpoint. | `string` | `""` | no |
| <a name="input_private_endpoint_network_resource_group_name"></a> [private\_endpoint\_network\_resource\_group\_name](#input\_private\_endpoint\_network\_resource\_group\_name) | Resource group containing the existing virtual network used for private endpoint subnet lookup. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | Subnet ID for the private endpoint. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#input\_private\_endpoint\_subnet\_name) | Existing subnet name used for private endpoint subnet lookup. | `string` | `""` | no |
| <a name="input_private_endpoint_timeouts"></a> [private\_endpoint\_timeouts](#input\_private\_endpoint\_timeouts) | Optional create/read/update/delete timeouts for the private endpoint. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_private_endpoint_vnet_name"></a> [private\_endpoint\_vnet\_name](#input\_private\_endpoint\_vnet\_name) | Existing virtual network name used for private endpoint subnet lookup. | `string` | `""` | no |
| <a name="input_private_service_connection_name"></a> [private\_service\_connection\_name](#input\_private\_service\_connection\_name) | Optional private service connection name. | `string` | `""` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is enabled. | `bool` | `false` | no |
| <a name="input_remote_debugging_enabled"></a> [remote\_debugging\_enabled](#input\_remote\_debugging\_enabled) | Whether remote debugging is enabled. | `bool` | `false` | no |
| <a name="input_remote_debugging_version"></a> [remote\_debugging\_version](#input\_remote\_debugging\_version) | Remote debugging Visual Studio version when remote debugging is enabled. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Existing resource group name where the Function App will be created. | `string` | n/a | yes |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | Additional role assignments scoped to the Function App. | <pre>map(object({<br>    principal_id                           = string<br>    principal_type                         = optional(string)<br>    role_definition_name                   = optional(string)<br>    role_definition_id                     = optional(string)<br>    name                                   = optional(string)<br>    description                            = optional(string)<br>    condition                              = optional(string)<br>    condition_version                      = optional(string)<br>    delegated_managed_identity_resource_id = optional(string)<br>    skip_service_principal_aad_check       = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_runtime_scale_monitoring_enabled"></a> [runtime\_scale\_monitoring\_enabled](#input\_runtime\_scale\_monitoring\_enabled) | Whether runtime scale monitoring is enabled. | `bool` | `false` | no |
| <a name="input_scm_ip_restriction_default_action"></a> [scm\_ip\_restriction\_default\_action](#input\_scm\_ip\_restriction\_default\_action) | Default action for SCM/Kudu IP restrictions. | `string` | `"Allow"` | no |
| <a name="input_scm_ip_restrictions"></a> [scm\_ip\_restrictions](#input\_scm\_ip\_restrictions) | SCM/Kudu IP restrictions. These are ignored by Azure when scm\_use\_main\_ip\_restriction is true. | <pre>list(object({<br>    name                      = optional(string)<br>    priority                  = optional(number)<br>    action                    = optional(string, "Allow")<br>    description               = optional(string)<br>    ip_address                = optional(string)<br>    service_tag               = optional(string)<br>    virtual_network_subnet_id = optional(string)<br>    headers = optional(list(object({<br>      x_azure_fdid      = optional(list(string), [])<br>      x_fd_health_probe = optional(list(string), [])<br>      x_forwarded_for   = optional(list(string), [])<br>      x_forwarded_host  = optional(list(string), [])<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_scm_minimum_tls_version"></a> [scm\_minimum\_tls\_version](#input\_scm\_minimum\_tls\_version) | Minimum TLS version for SCM/Kudu. | `string` | `"1.2"` | no |
| <a name="input_scm_use_main_ip_restriction"></a> [scm\_use\_main\_ip\_restriction](#input\_scm\_use\_main\_ip\_restriction) | Whether SCM/Kudu should use the same IP restrictions as the main site. | `bool` | `true` | no |
| <a name="input_service_plan_id"></a> [service\_plan\_id](#input\_service\_plan\_id) | App Service Plan ID used to host the Function App. | `string` | n/a | yes |
| <a name="input_sticky_settings_app_setting_names"></a> [sticky\_settings\_app\_setting\_names](#input\_sticky\_settings\_app\_setting\_names) | App setting names that should remain sticky across slot swaps. | `list(string)` | `[]` | no |
| <a name="input_sticky_settings_connection_string_names"></a> [sticky\_settings\_connection\_string\_names](#input\_sticky\_settings\_connection\_string\_names) | Connection string names that should remain sticky across slot swaps. | `list(string)` | `[]` | no |
| <a name="input_storage_account_access_key"></a> [storage\_account\_access\_key](#input\_storage\_account\_access\_key) | Optional storage account access key. Supplying this avoids a storage account data-source lookup for plan-only workflows. | `string` | `""` | no |
| <a name="input_storage_account_id"></a> [storage\_account\_id](#input\_storage\_account\_id) | Optional storage account resource ID for outputs and documentation when storage lookup is intentionally skipped. | `string` | `""` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Existing storage account name used by the Function App when access-key or managed-identity storage auth is used. | `string` | `""` | no |
| <a name="input_storage_account_resource_group_name"></a> [storage\_account\_resource\_group\_name](#input\_storage\_account\_resource\_group\_name) | Resource group containing the existing storage account. Leave empty to use resource\_group\_name. | `string` | `""` | no |
| <a name="input_storage_key_vault_secret_id"></a> [storage\_key\_vault\_secret\_id](#input\_storage\_key\_vault\_secret\_id) | Optional Key Vault secret ID containing the Function App storage connection string. When set, storage\_account\_name and storage\_account\_access\_key are not used by the Function App resource. | `string` | `""` | no |
| <a name="input_storage_mounts"></a> [storage\_mounts](#input\_storage\_mounts) | Optional Azure Files mounts exposed to the Function App. | <pre>list(object({<br>    name         = string<br>    account_name = string<br>    access_key   = string<br>    share_name   = string<br>    type         = string<br>    mount_path   = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_storage_uses_managed_identity"></a> [storage\_uses\_managed\_identity](#input\_storage\_uses\_managed\_identity) | Whether the Function App should use managed identity for AzureWebJobsStorage instead of an access key. | `bool` | `false` | no |
| <a name="input_system_assigned_identity_enabled"></a> [system\_assigned\_identity\_enabled](#input\_system\_assigned\_identity\_enabled) | Whether to enable a system-assigned managed identity. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to resources created by this module. | `map(string)` | `{}` | no |
| <a name="input_use_32_bit_worker"></a> [use\_32\_bit\_worker](#input\_use\_32\_bit\_worker) | Whether to use a 32-bit worker process. | `bool` | `false` | no |
| <a name="input_use_random_suffix"></a> [use\_random\_suffix](#input\_use\_random\_suffix) | Whether generated Function App names should include a random suffix. | `bool` | `true` | no |
| <a name="input_virtual_network_backup_restore_enabled"></a> [virtual\_network\_backup\_restore\_enabled](#input\_virtual\_network\_backup\_restore\_enabled) | Whether backup and restore traffic should use VNet integration. | `bool` | `false` | no |
| <a name="input_virtual_network_subnet_id"></a> [virtual\_network\_subnet\_id](#input\_virtual\_network\_subnet\_id) | Subnet ID for VNet integration. Leave empty to resolve by subnet/vnet/resource group name. | `string` | `""` | no |
| <a name="input_vnet_image_pull_enabled"></a> [vnet\_image\_pull\_enabled](#input\_vnet\_image\_pull\_enabled) | Whether container image pulls should use VNet integration. | `bool` | `false` | no |
| <a name="input_vnet_integration_network_resource_group_name"></a> [vnet\_integration\_network\_resource\_group\_name](#input\_vnet\_integration\_network\_resource\_group\_name) | Resource group containing the virtual network used for VNet integration subnet lookup. | `string` | `""` | no |
| <a name="input_vnet_integration_subnet_name"></a> [vnet\_integration\_subnet\_name](#input\_vnet\_integration\_subnet\_name) | Existing subnet name used for VNet integration when virtual\_network\_subnet\_id is empty. | `string` | `""` | no |
| <a name="input_vnet_integration_vnet_name"></a> [vnet\_integration\_vnet\_name](#input\_vnet\_integration\_vnet\_name) | Existing virtual network name used for VNet integration subnet lookup. | `string` | `""` | no |
| <a name="input_vnet_route_all_enabled"></a> [vnet\_route\_all\_enabled](#input\_vnet\_route\_all\_enabled) | Whether all outbound traffic is routed through the VNet integration subnet. | `bool` | `false` | no |
| <a name="input_webdeploy_publish_basic_authentication_enabled"></a> [webdeploy\_publish\_basic\_authentication\_enabled](#input\_webdeploy\_publish\_basic\_authentication\_enabled) | Whether WebDeploy publishing basic authentication is enabled. | `bool` | `false` | no |
| <a name="input_websockets_enabled"></a> [websockets\_enabled](#input\_websockets\_enabled) | Whether WebSockets are enabled. | `bool` | `false` | no |
| <a name="input_worker_count"></a> [worker\_count](#input\_worker\_count) | Optional number of workers. | `number` | `null` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier used in tagging. | `string` | `"project"` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Optional workload segment used when the Function App name is generated. | `string` | `""` | no |
| <a name="input_zip_deploy_file"></a> [zip\_deploy\_file](#input\_zip\_deploy\_file) | Optional local ZIP package path to deploy. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_admin_group_role_assignment_ids"></a> [app\_admin\_group\_role\_assignment\_ids](#output\_app\_admin\_group\_role\_assignment\_ids) | Map of Contributor role assignment IDs keyed by app\_admin\_group principal ID. |
| <a name="output_app_user_group_role_assignment_ids"></a> [app\_user\_group\_role\_assignment\_ids](#output\_app\_user\_group\_role\_assignment\_ids) | Map of Reader role assignment IDs keyed by app\_user\_group principal ID. |
| <a name="output_custom_domain_verification_id"></a> [custom\_domain\_verification\_id](#output\_custom\_domain\_verification\_id) | Custom domain verification ID for the Function App. |
| <a name="output_default_hostname"></a> [default\_hostname](#output\_default\_hostname) | Default hostname for the Function App. |
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | Diagnostic setting resource ID when diagnostics are enabled. |
| <a name="output_diagnostics_enabled"></a> [diagnostics\_enabled](#output\_diagnostics\_enabled) | Whether diagnostic settings are enabled. |
| <a name="output_enabled"></a> [enabled](#output\_enabled) | Whether the Function App is enabled. |
| <a name="output_id"></a> [id](#output\_id) | Function App resource ID. |
| <a name="output_identity_ids"></a> [identity\_ids](#output\_identity\_ids) | User-assigned managed identity IDs configured on the Function App. |
| <a name="output_identity_principal_id"></a> [identity\_principal\_id](#output\_identity\_principal\_id) | Principal ID of the system-assigned managed identity when enabled. |
| <a name="output_identity_tenant_id"></a> [identity\_tenant\_id](#output\_identity\_tenant\_id) | Tenant ID of the system-assigned managed identity when enabled. |
| <a name="output_identity_type"></a> [identity\_type](#output\_identity\_type) | Managed identity type configured on the Function App. |
| <a name="output_kind"></a> [kind](#output\_kind) | Function App operating system. |
| <a name="output_location"></a> [location](#output\_location) | Azure region used by the Function App. |
| <a name="output_location_code"></a> [location\_code](#output\_location\_code) | Short location code used for generated naming. |
| <a name="output_name"></a> [name](#output\_name) | Function App name. |
| <a name="output_os_type"></a> [os\_type](#output\_os\_type) | Function App operating system. |
| <a name="output_outbound_ip_addresses"></a> [outbound\_ip\_addresses](#output\_outbound\_ip\_addresses) | Outbound IP addresses for the Function App. |
| <a name="output_possible_outbound_ip_addresses"></a> [possible\_outbound\_ip\_addresses](#output\_possible\_outbound\_ip\_addresses) | Possible outbound IP addresses for the Function App. |
| <a name="output_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#output\_private\_dns\_zone\_ids) | Private DNS zone IDs associated with the private endpoint. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint resource ID when enabled. |
| <a name="output_private_endpoint_name"></a> [private\_endpoint\_name](#output\_private\_endpoint\_name) | Private endpoint name when enabled. |
| <a name="output_public_network_access_enabled"></a> [public\_network\_access\_enabled](#output\_public\_network\_access\_enabled) | Whether public network access is enabled. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group name where the Function App is deployed. |
| <a name="output_role_assignment_count"></a> [role\_assignment\_count](#output\_role\_assignment\_count) | Total number of Function App role assignments managed by this module. |
| <a name="output_role_assignment_ids"></a> [role\_assignment\_ids](#output\_role\_assignment\_ids) | Map of additional role assignment IDs keyed by input key. |
| <a name="output_service_plan_id"></a> [service\_plan\_id](#output\_service\_plan\_id) | Resolved App Service Plan ID used by the Function App. |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | Resolved or supplied storage account ID used by the Function App. |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | Storage account name used by the Function App when applicable. |
| <a name="output_storage_auth_mode"></a> [storage\_auth\_mode](#output\_storage\_auth\_mode) | Storage authentication mode used by the Function App. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to resources created by this module. |
<!-- END_TF_DOCS -->
