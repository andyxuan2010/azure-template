# Azure App Service Module

Provision an Azure Linux or Windows Web App with secure defaults, optional Application Insights, Azure Monitor diagnostics, Easy Auth, managed identities, storage mounts, private endpoints, custom domains, Deployment Center, and networking controls.

## Highlights

- Supports Linux and Windows Web Apps while preserving stable resource addresses.
- Standardizes Terraform and provider constraints for AzureRM 4.x and AzureAD 3.x.
- Applies environment-aware tags with `ManagedBy`, `module`, `name`, and `app_env` markers.
- Supports Log Analytics, Storage Account, and Event Hub diagnostic destinations.
- Exposes hardened site configuration options including TLS, SCM access, IP restrictions, auto-heal, backup, VNet routing, and container image pull controls.
- Uses plan-based Terraform tests for baseline, hardened Linux, Easy Auth/diagnostics, and Windows private endpoint scenarios.

## Usage

```hcl
module "appservice" {
  source = "./modules/appservice"

  app_name            = "app-contoso-prod-001"
  resource_group_name = "rg-contoso-prod-001"
  location            = "eastus"
  app_service_plan_id = azurerm_service_plan.this.id
  kind                = "Linux"
  app_env             = "prod"

  application_stack = {
    python_version = "3.11"
  }

  always_on                     = true
  ftps_state                    = "Disabled"
  minimum_tls_version           = "1.2"
  scm_minimum_tls_version       = "1.2"
  public_network_access_enabled = false

  enable_diagnostics         = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  tags = {
    Owner = "CCOE"
    IaC   = "Terraform"
  }
}
```

## Operational Notes

- Prefer managed identity for Key Vault references, ACR pulls, and downstream access.
- Keep FTP, WebDeploy, and SCM basic publishing credentials disabled unless a deployment workflow explicitly requires them.
- For production, prefer private endpoints, `public_network_access_enabled = false`, `vnet_route_all_enabled = true`, diagnostics, and `always_on = true` on a compatible App Service Plan SKU.
- Use `application_stack` for runtime configuration instead of app settings such as `DOCKER_*`.

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

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_app_service_certificate_binding.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_certificate_binding) | resource |
| [azurerm_app_service_custom_hostname_binding.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_custom_hostname_binding) | resource |
| [azurerm_app_service_managed_certificate.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_managed_certificate) | resource |
| [azurerm_app_service_source_control.deployment_center](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_source_control) | resource |
| [azurerm_application_insights.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_linux_web_app.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.sites](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.app_admin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_user_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_windows_web_app.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_web_app) | resource |
| [azuread_group.app_admin](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azuread_group.app_user](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_monitor_diagnostic_categories.web_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_diagnostic_categories) | data source |
| [azurerm_private_dns_zone.webapp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_subnet.vnet_integration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_active_directory_allowed_applications"></a> [active\_directory\_allowed\_applications](#input\_active\_directory\_allowed\_applications) | Optional Microsoft Entra application client IDs allowed by Easy Auth. | `list(string)` | `[]` | no |
| <a name="input_active_directory_allowed_audiences"></a> [active\_directory\_allowed\_audiences](#input\_active\_directory\_allowed\_audiences) | Optional list of allowed audiences for Microsoft Entra Easy Auth. When null, the module defaults to api://<active\_directory\_client\_id>. | `list(string)` | `null` | no |
| <a name="input_active_directory_allowed_groups"></a> [active\_directory\_allowed\_groups](#input\_active\_directory\_allowed\_groups) | Optional Microsoft Entra group object IDs allowed by Easy Auth. | `list(string)` | `[]` | no |
| <a name="input_active_directory_allowed_identities"></a> [active\_directory\_allowed\_identities](#input\_active\_directory\_allowed\_identities) | Optional Microsoft Entra identity object IDs allowed by Easy Auth. | `list(string)` | `[]` | no |
| <a name="input_active_directory_client_id"></a> [active\_directory\_client\_id](#input\_active\_directory\_client\_id) | The client ID of the Microsoft Entra app registration to use for built-in authentication. If value is set to null, built-in authentication will not be used. | `string` | `null` | no |
| <a name="input_active_directory_client_secret_setting_name"></a> [active\_directory\_client\_secret\_setting\_name](#input\_active\_directory\_client\_secret\_setting\_name) | The name of the app setting containing the client secret of the Microsoft Entra app registration to use for built-in authentication. | `string` | `"MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"` | no |
| <a name="input_active_directory_jwt_allowed_client_applications"></a> [active\_directory\_jwt\_allowed\_client\_applications](#input\_active\_directory\_jwt\_allowed\_client\_applications) | Optional list of JWT client application IDs accepted by Easy Auth. | `list(string)` | `[]` | no |
| <a name="input_active_directory_jwt_allowed_groups"></a> [active\_directory\_jwt\_allowed\_groups](#input\_active\_directory\_jwt\_allowed\_groups) | Optional list of JWT group IDs accepted by Easy Auth. | `list(string)` | `[]` | no |
| <a name="input_active_directory_login_parameters"></a> [active\_directory\_login\_parameters](#input\_active\_directory\_login\_parameters) | A map of key-value pairs to send to the authorization endpoint when a user logs in. | `map(string)` | `{}` | no |
| <a name="input_active_directory_tenant_auth_endpoint"></a> [active\_directory\_tenant\_auth\_endpoint](#input\_active\_directory\_tenant\_auth\_endpoint) | The authorization endpoint of the Microsoft Entra tenant to use for built-in authentication. If value is set to null, the authorization endpoint of the current tenant will be used. | `string` | `null` | no |
| <a name="input_allow_anonymous"></a> [allow\_anonymous](#input\_allow\_anonymous) | If true and Easy Auth is enabled, unauthenticated requests are allowed (equivalent to AllowAnonymous). | `bool` | `false` | no |
| <a name="input_always_on"></a> [always\_on](#input\_always\_on) | Should this Web App be loaded even when there is no traffic? | `bool` | `false` | no |
| <a name="input_api_definition_url"></a> [api\_definition\_url](#input\_api\_definition\_url) | Optional URL to the API definition for the Web App. | `string` | `null` | no |
| <a name="input_api_management_api_id"></a> [api\_management\_api\_id](#input\_api\_management\_api\_id) | Optional API Management API resource ID associated with this Web App. | `string` | `null` | no |
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | List of Microsoft Entra group display names or object IDs that should receive Contributor access to the Web App. | `list(string)` | `[]` | no |
| <a name="input_app_command_line"></a> [app\_command\_line](#input\_app\_command\_line) | Optional startup command for Linux Web Apps, for example a gunicorn command for Python apps. | `string` | `null` | no |
| <a name="input_app_enabled"></a> [app\_enabled](#input\_app\_enabled) | Whether the Web App is enabled. | `bool` | `true` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Optional environment name used for environment tags (prod/staging/dev/sbx/test/qa/poc) | `string` | `"dev"` | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | The name of this Web App. | `string` | n/a | yes |
| <a name="input_app_service_plan_id"></a> [app\_service\_plan\_id](#input\_app\_service\_plan\_id) | The ID of the App Service plan to host this Web App on. | `string` | n/a | yes |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | A map of app settings to be configured for this Web App. | `map(string)` | `{}` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | List of Microsoft Entra group display names or object IDs that should receive Reader access to the Web App. | `list(string)` | `[]` | no |
| <a name="input_application_insights_name"></a> [application\_insights\_name](#input\_application\_insights\_name) | Optional name for the Application Insights resource. When null or empty, the module uses appi-<app\_name>. | `string` | `null` | no |
| <a name="input_application_insights_retention_in_days"></a> [application\_insights\_retention\_in\_days](#input\_application\_insights\_retention\_in\_days) | Retention period in days for the Application Insights resource. | `number` | `90` | no |
| <a name="input_application_insights_workspace_id"></a> [application\_insights\_workspace\_id](#input\_application\_insights\_workspace\_id) | Optional Log Analytics workspace resource ID for the Application Insights resource. When empty, the module falls back to log\_analytics\_workspace\_id. | `string` | `""` | no |
| <a name="input_application_logs_file_system_level"></a> [application\_logs\_file\_system\_level](#input\_application\_logs\_file\_system\_level) | The level of application logs to be enabled. Possible values include "Verbose", "Information", "Warning" and "Error". | `string` | `"Error"` | no |
| <a name="input_application_stack"></a> [application\_stack](#input\_application\_stack) | An object of application stack settings for this Web App. Supports container and code runtimes. Note that application stack settings are often configured outside of Terraform (for example when deploying code), so configuring application stack settings in Terraform may cause conflicts. | <pre>object({<br>    docker_image_name            = optional(string)<br>    docker_registry_url          = optional(string)<br>    docker_registry_username     = optional(string)<br>    docker_registry_password     = optional(string)<br>    dotnet_version               = optional(string)<br>    dotnet_core_version          = optional(string)<br>    go_version                   = optional(string)<br>    java_container               = optional(string)<br>    java_container_version       = optional(string)<br>    java_embedded_server_enabled = optional(bool)<br>    java_server                  = optional(string)<br>    java_server_version          = optional(string)<br>    node_version                 = optional(string)<br>    python_version               = optional(string)<br>    python                       = optional(bool)<br>    php_version                  = optional(string)<br>    java_version                 = optional(string)<br>    ruby_version                 = optional(string)<br>    tomcat_version               = optional(string)<br>    current_stack                = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_auth_allowed_external_redirect_urls"></a> [auth\_allowed\_external\_redirect\_urls](#input\_auth\_allowed\_external\_redirect\_urls) | External redirect URLs allowed by Easy Auth login. | `list(string)` | `[]` | no |
| <a name="input_auth_default_provider"></a> [auth\_default\_provider](#input\_auth\_default\_provider) | Default Easy Auth provider when platform auth is enabled. | `string` | `"azureactivedirectory"` | no |
| <a name="input_auth_excluded_paths"></a> [auth\_excluded\_paths](#input\_auth\_excluded\_paths) | Paths excluded from Easy Auth authentication requirements. | `list(string)` | `[]` | no |
| <a name="input_auth_http_route_api_prefix"></a> [auth\_http\_route\_api\_prefix](#input\_auth\_http\_route\_api\_prefix) | Route prefix used by Easy Auth built-in authentication endpoints. | `string` | `"/.auth"` | no |
| <a name="input_auth_mode"></a> [auth\_mode](#input\_auth\_mode) | Authentication mode for the app. Use "auto" to preserve existing behavior (Easy Auth when active\_directory\_client\_id is set), "easy\_auth" for App Service Easy Auth, "msal" for app-managed MSAL, "both" to support both patterns, or "none" to disable platform auth. | `string` | `"auto"` | no |
| <a name="input_auth_require_https"></a> [auth\_require\_https](#input\_auth\_require\_https) | Whether Easy Auth requires HTTPS for authentication callbacks. | `bool` | `true` | no |
| <a name="input_auth_runtime_version"></a> [auth\_runtime\_version](#input\_auth\_runtime\_version) | Easy Auth runtime version. | `string` | `"~1"` | no |
| <a name="input_auth_token_store_enabled"></a> [auth\_token\_store\_enabled](#input\_auth\_token\_store\_enabled) | Whether App Service Easy Auth token store is enabled. | `bool` | `true` | no |
| <a name="input_auto_heal_setting"></a> [auto\_heal\_setting](#input\_auto\_heal\_setting) | Optional auto-heal rules that recycle the app when request, slow request, or status-code thresholds are reached. | <pre>object({<br>    action = object({<br>      action_type                    = optional(string, "Recycle")<br>      minimum_process_execution_time = optional(string, "00:00:00")<br>    })<br>    trigger = object({<br>      requests = optional(object({<br>        count    = number<br>        interval = string<br>      }))<br>      slow_request = optional(object({<br>        count      = number<br>        interval   = string<br>        time_taken = string<br>      }))<br>      slow_request_with_path = optional(object({<br>        count      = number<br>        interval   = string<br>        path       = string<br>        time_taken = string<br>      }))<br>      status_code = optional(list(object({<br>        count             = number<br>        interval          = string<br>        status_code_range = string<br>        path              = optional(string)<br>        sub_status        = optional(number)<br>        win32_status_code = optional(number)<br>      })), [])<br>    })<br>  })</pre> | `null` | no |
| <a name="input_backup"></a> [backup](#input\_backup) | Optional App Service backup configuration. The storage\_account\_url must be a SAS URL to the backup container. | <pre>object({<br>    name                = string<br>    enabled             = optional(bool, true)<br>    storage_account_url = string<br>    schedule = object({<br>      frequency_interval       = number<br>      frequency_unit           = string<br>      keep_at_least_one_backup = optional(bool, true)<br>      retention_period_days    = optional(number, 30)<br>      start_time               = optional(string)<br>    })<br>  })</pre> | `null` | no |
| <a name="input_client_affinity_enabled"></a> [client\_affinity\_enabled](#input\_client\_affinity\_enabled) | Should client affinity be enabled for this Web App? | `bool` | `false` | no |
| <a name="input_client_certificate_enabled"></a> [client\_certificate\_enabled](#input\_client\_certificate\_enabled) | Should client certificate be enabled for this Web App? | `bool` | `false` | no |
| <a name="input_client_certificate_exclusion_paths"></a> [client\_certificate\_exclusion\_paths](#input\_client\_certificate\_exclusion\_paths) | Paths excluded from client certificate authentication. | `string` | `null` | no |
| <a name="input_client_certificate_mode"></a> [client\_certificate\_mode](#input\_client\_certificate\_mode) | The client cerftificate mode for this Web App. Value must be "Required", "Optional" or "OptionalInteractiveUser". | `string` | `"Required"` | no |
| <a name="input_connection_strings"></a> [connection\_strings](#input\_connection\_strings) | A list of connection strings to be configured for this Web App. | <pre>list(object({<br>    name  = string<br>    value = string<br>    type  = optional(string, "Custom")<br>  }))</pre> | `[]` | no |
| <a name="input_container_registry_managed_identity_client_id"></a> [container\_registry\_managed\_identity\_client\_id](#input\_container\_registry\_managed\_identity\_client\_id) | The client ID of the managed identity that will be used to pull from the Container Registry. | `string` | `null` | no |
| <a name="input_container_registry_use_managed_identity"></a> [container\_registry\_use\_managed\_identity](#input\_container\_registry\_use\_managed\_identity) | Should connections to Container Registry use managed identity? | `bool` | `null` | no |
| <a name="input_cors"></a> [cors](#input\_cors) | CORS configuration for the Web App. | <pre>object({<br>    allowed_origins     = list(string)<br>    support_credentials = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_custom_hostname_bindings"></a> [custom\_hostname\_bindings](#input\_custom\_hostname\_bindings) | A list of custom hostnames to bind to this Web App. | <pre>map(object({<br>    hostname  = string<br>    ssl_state = optional(string, "SniEnabled")<br>  }))</pre> | `{}` | no |
| <a name="input_default_documents"></a> [default\_documents](#input\_default\_documents) | Default documents served by App Service. | `list(string)` | `null` | no |
| <a name="input_deployment_center_azure_repos_branch"></a> [deployment\_center\_azure\_repos\_branch](#input\_deployment\_center\_azure\_repos\_branch) | Branch name in the Azure Repos repository to deploy from via Deployment Center. | `string` | `"main"` | no |
| <a name="input_deployment_center_azure_repos_organization"></a> [deployment\_center\_azure\_repos\_organization](#input\_deployment\_center\_azure\_repos\_organization) | Azure DevOps organization name hosting the Azure Repos repository used by Deployment Center. | `string` | `null` | no |
| <a name="input_deployment_center_azure_repos_project"></a> [deployment\_center\_azure\_repos\_project](#input\_deployment\_center\_azure\_repos\_project) | Azure DevOps project name containing the Azure Repos repository used by Deployment Center. | `string` | `null` | no |
| <a name="input_deployment_center_azure_repos_repository"></a> [deployment\_center\_azure\_repos\_repository](#input\_deployment\_center\_azure\_repos\_repository) | Azure Repos repository name used by Deployment Center. | `string` | `null` | no |
| <a name="input_deployment_center_enabled"></a> [deployment\_center\_enabled](#input\_deployment\_center\_enabled) | Whether to configure Deployment Center for the Web App using an Azure Repos (Azure DevOps) repository. | `bool` | `false` | no |
| <a name="input_deployment_center_use_manual_integration"></a> [deployment\_center\_use\_manual\_integration](#input\_deployment\_center\_use\_manual\_integration) | Whether Deployment Center should use manual integration (true) or continuous integration (false). | `bool` | `true` | no |
| <a name="input_diagnostic_category_discovery_enabled"></a> [diagnostic\_category\_discovery\_enabled](#input\_diagnostic\_category\_discovery\_enabled) | Whether to discover diagnostic categories from Azure when category lists are empty. Keep false for deterministic plan tests. | `bool` | `false` | no |
| <a name="input_diagnostic_eventhub_authorization_rule_id"></a> [diagnostic\_eventhub\_authorization\_rule\_id](#input\_diagnostic\_eventhub\_authorization\_rule\_id) | Optional Event Hub authorization rule resource ID for diagnostic settings. | `string` | `null` | no |
| <a name="input_diagnostic_eventhub_name"></a> [diagnostic\_eventhub\_name](#input\_diagnostic\_eventhub\_name) | Optional Event Hub name for diagnostic settings when using an Event Hub destination. | `string` | `null` | no |
| <a name="input_diagnostic_setting_enabled_log_categories"></a> [diagnostic\_setting\_enabled\_log\_categories](#input\_diagnostic\_setting\_enabled\_log\_categories) | A list of log categories to be enabled for this diagnostic setting. | `list(string)` | <pre>[<br>  "AppServiceHTTPLogs",<br>  "AppServiceConsoleLogs",<br>  "AppServiceAppLogs",<br>  "AppServiceAuditLogs",<br>  "AppServiceIPSecAuditLogs",<br>  "AppServicePlatformLogs"<br>]</pre> | no |
| <a name="input_diagnostic_setting_enabled_metric_categories"></a> [diagnostic\_setting\_enabled\_metric\_categories](#input\_diagnostic\_setting\_enabled\_metric\_categories) | A list of metric categories to be enabled for this diagnostic setting. | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| <a name="input_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#input\_diagnostic\_setting\_name) | The name of the diagnostic setting. | `string` | `"audit-logs"` | no |
| <a name="input_diagnostic_storage_account_id"></a> [diagnostic\_storage\_account\_id](#input\_diagnostic\_storage\_account\_id) | Optional Storage Account resource ID for diagnostic setting archival. | `string` | `null` | no |
| <a name="input_enable_application_insights"></a> [enable\_application\_insights](#input\_enable\_application\_insights) | Whether to create an Application Insights resource for this Web App and inject the standard telemetry app settings. | `bool` | `false` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Whether to create an Azure Monitor diagnostic setting. For backward compatibility, diagnostics are also enabled when any diagnostic destination is supplied. | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Whether to create a private endpoint for the Web App (sites). Requires PremiumV2/PremiumV3 or higher. When enabled, consider setting public\_network\_access\_enabled = false for isolation. | `bool` | `false` | no |
| <a name="input_ftp_publish_basic_authentication_enabled"></a> [ftp\_publish\_basic\_authentication\_enabled](#input\_ftp\_publish\_basic\_authentication\_enabled) | Should basic (username and password) authentication be enabled for the FTP client? | `bool` | `false` | no |
| <a name="input_ftps_state"></a> [ftps\_state](#input\_ftps\_state) | The state of FTP/FTPS service. Possible values include "AllAllowed", "FtpsOnly", and "Disabled". | `string` | `"Disabled"` | no |
| <a name="input_handler_mappings"></a> [handler\_mappings](#input\_handler\_mappings) | Optional Windows handler mappings. Ignored for Linux Web Apps. | <pre>list(object({<br>    extension             = string<br>    script_processor_path = string<br>    arguments             = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_health_check_eviction_time_in_min"></a> [health\_check\_eviction\_time\_in\_min](#input\_health\_check\_eviction\_time\_in\_min) | Optional number of minutes an instance must be unhealthy before App Service evicts it from the load balancer. | `number` | `null` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Optional health check path used by App Service to monitor instance health (for example, /healthz). Set to null to disable. | `string` | `null` | no |
| <a name="input_http2_enabled"></a> [http2\_enabled](#input\_http2\_enabled) | Should the HTTP/2 protocol be enabled for this Web App? | `bool` | `false` | no |
| <a name="input_http_logs_file_system_retention_in_days"></a> [http\_logs\_file\_system\_retention\_in\_days](#input\_http\_logs\_file\_system\_retention\_in\_days) | The retention period in days before HTTP logs are deleted from the file system. | `number` | `0` | no |
| <a name="input_http_logs_file_system_retention_in_mb"></a> [http\_logs\_file\_system\_retention\_in\_mb](#input\_http\_logs\_file\_system\_retention\_in\_mb) | The maximum size in megabytes that HTTP logs can use before being deleted from the file system. | `number` | `35` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | A list of IDs of managed identities to be assigned to this Web App. | `list(string)` | `[]` | no |
| <a name="input_ip_restriction_default_action"></a> [ip\_restriction\_default\_action](#input\_ip\_restriction\_default\_action) | The default action for traffic that does not match any IP restriction rule. Value must be "Allow" or "Deny". | `string` | `"Deny"` | no |
| <a name="input_ip_restrictions"></a> [ip\_restrictions](#input\_ip\_restrictions) | A list of IP restrictions to be configured for this Web App. | <pre>list(object({<br>    action                    = optional(string, "Allow")<br>    description               = optional(string)<br>    ip_address                = optional(string)<br>    name                      = string<br>    priority                  = number<br>    service_tag               = optional(string)<br>    virtual_network_subnet_id = optional(string)<br><br>    headers = optional(object({<br>      x_forwarded_for   = optional(list(string))<br>      x_forwarded_host  = optional(list(string))<br>      x_azure_fdid      = optional(list(string))<br>      x_fd_health_probe = optional(list(string))<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_key_vault_reference_identity_id"></a> [key\_vault\_reference\_identity\_id](#input\_key\_vault\_reference\_identity\_id) | The ID of the managed identity that will be used to fetch app settings sourced from Key Vault. | `string` | `null` | no |
| <a name="input_kind"></a> [kind](#input\_kind) | The kind of Web App to create. Allowed values are "Linux" and "Windows". | `string` | `"Linux"` | no |
| <a name="input_linux_fx_version"></a> [linux\_fx\_version](#input\_linux\_fx\_version) | Optional Linux FX version override. Prefer application\_stack for normal runtime configuration. | `string` | `null` | no |
| <a name="input_load_balancing_mode"></a> [load\_balancing\_mode](#input\_load\_balancing\_mode) | App Service load balancing mode. | `string` | `"LeastRequests"` | no |
| <a name="input_local_mysql_enabled"></a> [local\_mysql\_enabled](#input\_local\_mysql\_enabled) | Whether local MySQL is enabled for the Web App. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region to create resources in. If empty, the module uses the resource group's location. | `string` | `""` | no |
| <a name="input_log_analytics_destination_type"></a> [log\_analytics\_destination\_type](#input\_log\_analytics\_destination\_type) | Destination type for Log Analytics diagnostics. Use Dedicated for resource-specific tables or AzureDiagnostics for the legacy shared table. | `string` | `"Dedicated"` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | The ID of the Log Analytics workspace to send diagnostics to. | `string` | `""` | no |
| <a name="input_logs_detailed_error_messages"></a> [logs\_detailed\_error\_messages](#input\_logs\_detailed\_error\_messages) | Should detailed error messages be enabled for logs? | `bool` | `false` | no |
| <a name="input_logs_failed_request_tracing"></a> [logs\_failed\_request\_tracing](#input\_logs\_failed\_request\_tracing) | Should failed request tracing be enabled for logs? | `bool` | `false` | no |
| <a name="input_managed_pipeline_mode"></a> [managed\_pipeline\_mode](#input\_managed\_pipeline\_mode) | Managed pipeline mode for the Web App. | `string` | `"Integrated"` | no |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | Minimum inbound TLS version for the Web App. | `string` | `"1.2"` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | ID of the Azure Private DNS Zone privatelink.azurewebsites.net used by the app private endpoint. Alternatively use private\_dns\_zone\_name and private\_dns\_zone\_resource\_group\_name to look up an existing zone via data source. | `string` | `null` | no |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | Name of the existing Private DNS Zone (e.g. privatelink.azurewebsites.net). Used with private\_dns\_zone\_resource\_group\_name to look up the zone via data source when private\_dns\_zone\_id is not set. | `string` | `null` | no |
| <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name) | Resource group name of the existing Private DNS Zone. Required for DNS zone lookup when private\_dns\_zone\_id is not set. | `string` | `null` | no |
| <a name="input_private_endpoint_network_resource_group_name"></a> [private\_endpoint\_network\_resource\_group\_name](#input\_private\_endpoint\_network\_resource\_group\_name) | Resource group name of the existing VNet/subnet used for private endpoints. Required for subnet lookup when private\_endpoint\_subnet\_id is not set. | `string` | `null` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | Subnet ID for the private endpoint(s). Use this when you have the subnet ID. When empty and lookup vars are set (subnet name, vnet name, resource group), the module looks up the existing subnet via data source. | `string` | `""` | no |
| <a name="input_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#input\_private\_endpoint\_subnet\_name) | Name of the existing subnet for private endpoints. Used with private\_endpoint\_vnet\_name and private\_endpoint\_network\_resource\_group\_name to look up the subnet via data source when private\_endpoint\_subnet\_id is empty. | `string` | `null` | no |
| <a name="input_private_endpoint_vnet_name"></a> [private\_endpoint\_vnet\_name](#input\_private\_endpoint\_vnet\_name) | Name of the virtual network containing the private endpoint subnet. Required for subnet lookup when private\_endpoint\_subnet\_id is not set. | `string` | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Should public network access be enabled for this Web App? | `bool` | `true` | no |
| <a name="input_remote_debugging_enabled"></a> [remote\_debugging\_enabled](#input\_remote\_debugging\_enabled) | Whether remote debugging is enabled. Keep disabled for production workloads. | `bool` | `false` | no |
| <a name="input_remote_debugging_version"></a> [remote\_debugging\_version](#input\_remote\_debugging\_version) | Remote debugging Visual Studio version. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group to create the resources in. | `string` | n/a | yes |
| <a name="input_scm_basic_auth_publishing_credentials_enabled"></a> [scm\_basic\_auth\_publishing\_credentials\_enabled](#input\_scm\_basic\_auth\_publishing\_credentials\_enabled) | Enable SCM Basic Auth Publishing Credentials (Kudu/SCM endpoint). When set, overrides webdeploy\_publish\_basic\_authentication\_enabled. Used for Local Git, WebDeploy, Visual Studio and other SCM-based deployments. | `bool` | `null` | no |
| <a name="input_scm_ip_restriction_default_action"></a> [scm\_ip\_restriction\_default\_action](#input\_scm\_ip\_restriction\_default\_action) | The default action for Kudu/SCM endpoint traffic that does not match a restriction rule. | `string` | `"Allow"` | no |
| <a name="input_scm_ip_restrictions"></a> [scm\_ip\_restrictions](#input\_scm\_ip\_restrictions) | A list of IP restrictions to configure for the Kudu/SCM endpoint. | <pre>list(object({<br>    action                    = optional(string, "Allow")<br>    description               = optional(string)<br>    ip_address                = optional(string)<br>    name                      = string<br>    priority                  = number<br>    service_tag               = optional(string)<br>    virtual_network_subnet_id = optional(string)<br><br>    headers = optional(object({<br>      x_forwarded_for   = optional(list(string))<br>      x_forwarded_host  = optional(list(string))<br>      x_azure_fdid      = optional(list(string))<br>      x_fd_health_probe = optional(list(string))<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_scm_minimum_tls_version"></a> [scm\_minimum\_tls\_version](#input\_scm\_minimum\_tls\_version) | Minimum TLS version for the Kudu/SCM endpoint. | `string` | `"1.2"` | no |
| <a name="input_scm_type"></a> [scm\_type](#input\_scm\_type) | SCM type for the Web App, such as None, LocalGit, GitHub, BitbucketGit, BitbucketHg, CodePlexGit, CodePlexHg, Dropbox, ExternalGit, Tfs, VSO, or VSTSRM. | `string` | `null` | no |
| <a name="input_scmIpSecurityRestrictionsUseMain"></a> [scmIpSecurityRestrictionsUseMain](#input\_scmIpSecurityRestrictionsUseMain) | Optional App Service property override for scmIpSecurityRestrictionsUseMain. When null, scm\_use\_main\_ip\_restriction is used. | `bool` | `null` | no |
| <a name="input_scm_use_main_ip_restriction"></a> [scm\_use\_main\_ip\_restriction](#input\_scm\_use\_main\_ip\_restriction) | Whether the Kudu/SCM endpoint should reuse the main site IP restrictions. | `bool` | `false` | no |
| <a name="input_sticky_settings_app_setting_names"></a> [sticky\_settings\_app\_setting\_names](#input\_sticky\_settings\_app\_setting\_names) | A list of names of app settings that this Function App will not swap between slots when a swap operation is triggered. | `list(string)` | `[]` | no |
| <a name="input_sticky_settings_connection_string_names"></a> [sticky\_settings\_connection\_string\_names](#input\_sticky\_settings\_connection\_string\_names) | A list of names of connection strings that this Function App will not swap between slots when a swap operation is triggered. | `list(string)` | `[]` | no |
| <a name="input_storage_accounts"></a> [storage\_accounts](#input\_storage\_accounts) | A list of Storage accounts to be mounted for this Web App. | <pre>list(object({<br>    name                    = string<br>    account_name            = string<br>    access_key_setting_name = string<br>    share_name              = string<br>    mount_path              = string<br>    type                    = optional(string, "AzureFiles")<br>  }))</pre> | `[]` | no |
| <a name="input_system_assigned_identity_enabled"></a> [system\_assigned\_identity\_enabled](#input\_system\_assigned\_identity\_enabled) | Should the system-assigned identity be enabled for this Web App? | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resources. | `map(string)` | `{}` | no |
| <a name="input_unauthenticated_action"></a> [unauthenticated\_action](#input\_unauthenticated\_action) | Optional Easy Auth unauthenticated action override. Allowed values: RedirectToLoginPage, AllowAnonymous, Return401, Return403. If null, computed from allow\_anonymous. | `string` | `null` | no |
| <a name="input_use_32_bit_worker"></a> [use\_32\_bit\_worker](#input\_use\_32\_bit\_worker) | Should this Web App use a 32-bit worker? Defaulting to false means 64-bit worker. | `bool` | `false` | no |
| <a name="input_virtual_applications"></a> [virtual\_applications](#input\_virtual\_applications) | A list of virtual applications to configure for this Web App. Only applicable if value of kind is "Windows". | <pre>list(object({<br>    virtual_path  = string<br>    physical_path = string<br>    preload       = bool<br><br>    virtual_directories = optional(list(object({<br>      physical_path = optional(string)<br>      virtual_path  = optional(string)<br>    })), [])<br>  }))</pre> | `[]` | no |
| <a name="input_virtual_network_backup_restore_enabled"></a> [virtual\_network\_backup\_restore\_enabled](#input\_virtual\_network\_backup\_restore\_enabled) | Whether backup and restore traffic should use the integrated virtual network. | `bool` | `false` | no |
| <a name="input_virtual_network_image_pull_enabled"></a> [virtual\_network\_image\_pull\_enabled](#input\_virtual\_network\_image\_pull\_enabled) | Whether Windows container image pulls should use virtual network routing. | `bool` | `false` | no |
| <a name="input_virtual_network_subnet_id"></a> [virtual\_network\_subnet\_id](#input\_virtual\_network\_subnet\_id) | Optional subnet ID for VNet integration. When null, the module uses vnet\_integration\_subnet\_name with vnet\_integration\_vnet\_name and vnet\_integration\_network\_resource\_group\_name to look up the subnet via data source. | `string` | `null` | no |
| <a name="input_vnet_image_pull_enabled"></a> [vnet\_image\_pull\_enabled](#input\_vnet\_image\_pull\_enabled) | Whether Linux container image pulls should use virtual network routing. | `bool` | `false` | no |
| <a name="input_vnet_integration_network_resource_group_name"></a> [vnet\_integration\_network\_resource\_group\_name](#input\_vnet\_integration\_network\_resource\_group\_name) | Resource group name of the VNet/subnet used for VNet integration. Required for subnet lookup when virtual\_network\_subnet\_id is not set. | `string` | `null` | no |
| <a name="input_vnet_integration_subnet_name"></a> [vnet\_integration\_subnet\_name](#input\_vnet\_integration\_subnet\_name) | Name of the subnet for VNet integration. The module looks up this subnet (with vnet\_integration\_vnet\_name and vnet\_integration\_network\_resource\_group\_name) and uses it for integration. Ignored when virtual\_network\_subnet\_id is set. | `string` | `null` | no |
| <a name="input_vnet_integration_vnet_name"></a> [vnet\_integration\_vnet\_name](#input\_vnet\_integration\_vnet\_name) | Name of the virtual network containing the VNet integration subnet. Required for subnet lookup when virtual\_network\_subnet\_id is not set. | `string` | `null` | no |
| <a name="input_vnet_route_all_enabled"></a> [vnet\_route\_all\_enabled](#input\_vnet\_route\_all\_enabled) | Should all outbound traffic have NAT Gateways, network security groups and user-defined routes applied? | `bool` | `false` | no |
| <a name="input_webdeploy_publish_basic_authentication_enabled"></a> [webdeploy\_publish\_basic\_authentication\_enabled](#input\_webdeploy\_publish\_basic\_authentication\_enabled) | Should basic (username and password) authentication be enabled for the WebDeploy client? Prefer scm\_basic\_auth\_publishing\_credentials\_enabled for clarity (same setting). | `bool` | `false` | no |
| <a name="input_websockets_enabled"></a> [websockets\_enabled](#input\_websockets\_enabled) | Should web sockets be enabled for this Web App? | `bool` | `true` | no |
| <a name="input_windows_fx_version"></a> [windows\_fx\_version](#input\_windows\_fx\_version) | Optional Windows FX version override. Prefer application\_stack for normal runtime configuration. | `string` | `null` | no |
| <a name="input_worker_count"></a> [worker\_count](#input\_worker\_count) | Number of workers assigned to the app when supported by the App Service Plan. | `number` | `null` | no |
| <a name="input_zip_deploy_file"></a> [zip\_deploy\_file](#input\_zip\_deploy\_file) | The local path of a ZIP-packaged application to deploy to this Web App. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_admin_group_role_assignment_ids"></a> [app\_admin\_group\_role\_assignment\_ids](#output\_app\_admin\_group\_role\_assignment\_ids) | Map of Contributor role assignment IDs keyed by app\_admin\_group principal ID. |
| <a name="output_app_enabled"></a> [app\_enabled](#output\_app\_enabled) | Whether the Web App is enabled. |
| <a name="output_app_id"></a> [app\_id](#output\_app\_id) | The ID of this Web App. |
| <a name="output_app_kind"></a> [app\_kind](#output\_app\_kind) | The operating system kind of this Web App. |
| <a name="output_app_name"></a> [app\_name](#output\_app\_name) | The name of this Web App. |
| <a name="output_app_user_group_role_assignment_ids"></a> [app\_user\_group\_role\_assignment\_ids](#output\_app\_user\_group\_role\_assignment\_ids) | Map of Reader role assignment IDs keyed by app\_user\_group principal ID. |
| <a name="output_application_insights_connection_string"></a> [application\_insights\_connection\_string](#output\_application\_insights\_connection\_string) | Connection string for the Application Insights resource created for this Web App, if enabled. |
| <a name="output_application_insights_id"></a> [application\_insights\_id](#output\_application\_insights\_id) | Resource ID of the Application Insights resource created for this Web App, if enabled. |
| <a name="output_application_insights_name"></a> [application\_insights\_name](#output\_application\_insights\_name) | Name of the Application Insights resource created for this Web App, if enabled. |
| <a name="output_auth_config"></a> [auth\_config](#output\_auth\_config) | Resolved authentication mode flags for the Web App. |
| <a name="output_custom_domain_verification_id"></a> [custom\_domain\_verification\_id](#output\_custom\_domain\_verification\_id) | The identifier used by App Service to perform domain ownership verification via DNS TXT record. |
| <a name="output_default_hostname"></a> [default\_hostname](#output\_default\_hostname) | The default hostname of this Web App. |
| <a name="output_default_url"></a> [default\_url](#output\_default\_url) | The default HTTPS URL of this Web App. |
| <a name="output_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#output\_diagnostic\_log\_categories) | Effective diagnostic log categories configured by the module. |
| <a name="output_diagnostic_metric_categories"></a> [diagnostic\_metric\_categories](#output\_diagnostic\_metric\_categories) | Effective diagnostic metric categories configured by the module. |
| <a name="output_diagnostics_enabled"></a> [diagnostics\_enabled](#output\_diagnostics\_enabled) | Whether any diagnostic log or metric categories were enabled for the app service. |
| <a name="output_identity_principal_id"></a> [identity\_principal\_id](#output\_identity\_principal\_id) | The principal ID of the system-assigned identity of this Web App. This value will be null if the system-assigned identity is disabled. |
| <a name="output_identity_tenant_id"></a> [identity\_tenant\_id](#output\_identity\_tenant\_id) | The tenant ID of the system-assigned identity of this Web App. This value will be null if the system-assigned identity is disabled. |
| <a name="output_location"></a> [location](#output\_location) | The resolved Azure region used by this Web App. |
| <a name="output_merged_tags"></a> [merged\_tags](#output\_merged\_tags) | Final merged tags applied to resources |
| <a name="output_outbound_ip_addresses"></a> [outbound\_ip\_addresses](#output\_outbound\_ip\_addresses) | Comma-separated outbound IP addresses assigned to the Web App. |
| <a name="output_possible_outbound_ip_addresses"></a> [possible\_outbound\_ip\_addresses](#output\_possible\_outbound\_ip\_addresses) | Comma-separated possible outbound IP addresses for the Web App. |
| <a name="output_private_endpoint_sites_id"></a> [private\_endpoint\_sites\_id](#output\_private\_endpoint\_sites\_id) | Resource ID of the private endpoint for the app (sites), if created. |
| <a name="output_site_credential_name"></a> [site\_credential\_name](#output\_site\_credential\_name) | The Site Credentials Username used for publishing. |
| <a name="output_site_credential_password"></a> [site\_credential\_password](#output\_site\_credential\_password) | The Site Credentials Password used for publishing. |
| <a name="output_vnet_integration_subnet"></a> [vnet\_integration\_subnet](#output\_vnet\_integration\_subnet) | Subnet data structure for VNet integration when looked up by name (id, name, resource\_group\_name, virtual\_network\_name, address\_prefixes). Null when subnet was provided by ID or when no VNet integration is configured. |
| <a name="output_vnet_integration_subnet_id"></a> [vnet\_integration\_subnet\_id](#output\_vnet\_integration\_subnet\_id) | Resolved subnet ID used for VNet integration (from variable or from data source lookup by name). |
<!-- END_TF_DOCS -->
