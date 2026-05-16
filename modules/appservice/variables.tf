variable "app_name" {
  description = "The name of this Web App."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{2,60}$", var.app_name))
    error_message = "app_name must be between 2 and 60 characters long and can only contain alphanumeric characters and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group to create the resources in."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  description = "The location to create the resources in."
  type        = string

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location cannot be empty."
  }
}

variable "app_service_plan_id" {
  description = "The ID of the App Service plan to host this Web App on."
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Web/server[Ff]arms/.+$", var.app_service_plan_id))
    error_message = "app_service_plan_id must be a valid App Service Plan resource ID."
  }
}

variable "kind" {
  description = "The kind of Web App to create. Allowed values are \"Linux\" and \"Windows\"."
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.kind)
    error_message = "Kind must be \"Linux\" or \"Windows\"."
  }
}

variable "app_settings" {
  description = "A map of app settings to be configured for this Web App."
  type        = map(string)
  default     = {}
  nullable    = false

  validation {
    condition     = length(setintersection(["DOCKER_REGISTRY_SERVER_URL", "DOCKER_REGISTRY_SERVER_USERNAME", "DOCKER_REGISTRY_SERVER_PASSWORD"], keys(var.app_settings))) == 0
    error_message = "Docker settings (\"DOCKER_*\") must be configured using \"application_stack\"."
  }

  validation {
    condition     = length(setintersection(["WEBSITE_HTTPLOGGING_ENABLED", "WEBSITE_HTTPLOGGING_RETENTION_DAYS", "WEBSITE_HTTPLOGGING_CONTAINER_URL"], keys(var.app_settings))) == 0
    error_message = "HTTP logging settings (\"WEBSITE_HTTPLOGGING_*\") must be configured using \"http_logs_file_system_retention_in_mb\" and \"http_logs_file_system_retention_in_days\"."
  }
}

variable "connection_strings" {
  description = "A list of connection strings to be configured for this Web App."

  type = list(object({
    name  = string
    value = string
    type  = optional(string, "Custom")
  }))

  default  = []
  nullable = false
}

variable "app_admin_group" {
  description = "List of Microsoft Entra group display names or object IDs that should receive Contributor access to the Web App."
  type        = list(string)
  default     = []
}

variable "app_user_group" {
  description = "List of Microsoft Entra group display names or object IDs that should receive Reader access to the Web App."
  type        = list(string)
  default     = []
}

variable "application_stack" {
  description = "An object of application stack settings for this Web App. Supports container and code runtimes. Note that application stack settings are often configured outside of Terraform (for example when deploying code), so configuring application stack settings in Terraform may cause conflicts."

  type = object({
    docker_image_name        = optional(string)
    docker_registry_url      = optional(string)
    docker_registry_username = optional(string)
    docker_registry_password = optional(string)
    dotnet_version           = optional(string)
    node_version             = optional(string)
    python_version           = optional(string)
    php_version              = optional(string)
    java_version             = optional(string)
    current_stack            = optional(string)
  })

  default = null
}

variable "app_command_line" {
  description = "Optional startup command for Linux Web Apps, for example a gunicorn command for Python apps."
  type        = string
  default     = null
  nullable    = true
}

variable "virtual_applications" {
  description = "A list of virtual applications to configure for this Web App. Only applicable if value of kind is \"Windows\"."

  type = list(object({
    virtual_path  = string
    physical_path = string
    preload       = bool

    virtual_directories = optional(list(object({
      physical_path = optional(string)
      virtual_path  = optional(string)
    })), [])
  }))

  default  = []
  nullable = false
}

variable "active_directory_tenant_auth_endpoint" {
  description = "The authorization endpoint of the Microsoft Entra tenant to use for built-in authentication. If value is set to null, the authorization endpoint of the current tenant will be used."
  type        = string
  nullable    = true
  default     = null
}

variable "active_directory_client_id" {
  description = "The client ID of the Microsoft Entra app registration to use for built-in authentication. If value is set to null, built-in authentication will not be used."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = try(trimspace(var.active_directory_client_id), "") == "" || can(regex("^[0-9a-fA-F-]{36}$", try(trimspace(var.active_directory_client_id), "")))
    error_message = "active_directory_client_id must be null, empty, or a valid GUID."
  }
}

variable "active_directory_client_secret_setting_name" {
  description = "The name of the app setting containing the client secret of the Microsoft Entra app registration to use for built-in authentication."
  type        = string
  nullable    = false
  default     = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
}

variable "active_directory_login_parameters" {
  description = "A map of key-value pairs to send to the authorization endpoint when a user logs in."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "auth_mode" {
  description = "Authentication mode for the app. Use \"auto\" to preserve existing behavior (Easy Auth when active_directory_client_id is set), \"easy_auth\" for App Service Easy Auth, \"msal\" for app-managed MSAL, \"both\" to support both patterns, or \"none\" to disable platform auth."
  type        = string
  default     = "auto"
  nullable    = false

  validation {
    condition     = contains(["auto", "none", "easy_auth", "msal", "both"], var.auth_mode)
    error_message = "auth_mode must be one of: auto, none, easy_auth, msal, both."
  }

  validation {
    condition = !contains(["easy_auth", "both"], var.auth_mode) || (
      try(trimspace(var.active_directory_client_id), "") != ""
    )
    error_message = "active_directory_client_id must be set when auth_mode is easy_auth or both."
  }
}

variable "allow_anonymous" {
  description = "If true and Easy Auth is enabled, unauthenticated requests are allowed (equivalent to AllowAnonymous)."
  type        = bool
  default     = false
  nullable    = false
}

variable "unauthenticated_action" {
  description = "Optional Easy Auth unauthenticated action override. Allowed values: RedirectToLoginPage, AllowAnonymous, Return401, Return403. If null, computed from allow_anonymous."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition = contains([
      "RedirectToLoginPage",
      "AllowAnonymous",
      "Return401",
      "Return403",
      ""
    ], var.unauthenticated_action == null ? "" : var.unauthenticated_action)
    error_message = "unauthenticated_action must be null or one of: RedirectToLoginPage, AllowAnonymous, Return401, Return403."
  }
}

variable "client_affinity_enabled" {
  description = "Should client affinity be enabled for this Web App?"
  type        = bool
  default     = false
}

variable "key_vault_reference_identity_id" {
  description = "The ID of the managed identity that will be used to fetch app settings sourced from Key Vault."
  type        = string
  default     = null
}

variable "virtual_network_subnet_id" {
  description = "Optional subnet ID for VNet integration. When null, the module uses vnet_integration_subnet_name with vnet_integration_vnet_name and vnet_integration_network_resource_group_name to look up the subnet via data source."
  type        = string
  default     = null

  validation {
    condition     = try(trimspace(var.virtual_network_subnet_id), "") == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/.+$", try(trimspace(var.virtual_network_subnet_id), "")))
    error_message = "virtual_network_subnet_id must be null, empty, or a valid subnet resource ID."
  }
}

variable "vnet_integration_subnet_name" {
  description = "Name of the subnet for VNet integration. The module looks up this subnet (with vnet_integration_vnet_name and vnet_integration_network_resource_group_name) and uses it for integration. Ignored when virtual_network_subnet_id is set."
  type        = string
  default     = null
}

variable "vnet_integration_vnet_name" {
  description = "Name of the virtual network containing the VNet integration subnet. Required for subnet lookup when virtual_network_subnet_id is not set."
  type        = string
  default     = null
}

variable "vnet_integration_network_resource_group_name" {
  description = "Resource group name of the VNet/subnet used for VNet integration. Required for subnet lookup when virtual_network_subnet_id is not set."
  type        = string
  default     = null
}

variable "vnet_route_all_enabled" {
  description = "Should all outbound traffic have NAT Gateways, network security groups and user-defined routes applied?"
  type        = bool
  default     = false
}

variable "websockets_enabled" {
  description = "Should web sockets be enabled for this Web App?"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Optional health check path used by App Service to monitor instance health (for example, /healthz). Set to null to disable."
  type        = string
  default     = null
}

variable "health_check_eviction_time_in_min" {
  description = "Optional number of minutes an instance must be unhealthy before App Service evicts it from the load balancer."
  type        = number
  default     = null

  validation {
    condition     = var.health_check_eviction_time_in_min == null || var.health_check_path != null
    error_message = "health_check_path must be set when health_check_eviction_time_in_min is provided."
  }
}

variable "container_registry_use_managed_identity" {
  description = "Should connections to Container Registry use managed identity?"
  type        = bool
  default     = null
}

variable "container_registry_managed_identity_client_id" {
  description = "The client ID of the managed identity that will be used to pull from the Container Registry."
  type        = string
  default     = null
}

variable "always_on" {
  description = "Should this Web App be loaded even when there is no traffic?"
  type        = bool
  default     = false
}

variable "ftps_state" {
  description = "The state of FTP/FTPS service. Possible values include \"AllAllowed\", \"FtpsOnly\", and \"Disabled\"."
  type        = string
  default     = "Disabled"

  validation {
    condition     = contains(["AllAllowed", "FtpsOnly", "Disabled"], var.ftps_state)
    error_message = "ftps_state must be AllAllowed, FtpsOnly, or Disabled."
  }
}

variable "http2_enabled" {
  description = "Should the HTTP/2 protocol be enabled for this Web App?"
  type        = bool
  default     = false
}

variable "ip_restrictions" {
  description = "A list of IP restrictions to be configured for this Web App."

  type = list(object({
    action      = optional(string, "Allow")
    ip_address  = optional(string)
    name        = string
    priority    = number
    service_tag = optional(string)

    headers = optional(object({
      x_forwarded_for   = optional(list(string))
      x_forwarded_host  = optional(list(string))
      x_azure_fdid      = optional(list(string))
      x_fd_health_probe = optional(list(string))
    }))
  }))

  default = []
}

variable "ip_restriction_default_action" {
  description = "The default action for traffic that does not match any IP restriction rule. Value must be \"Allow\" or \"Deny\"."
  type        = string
  default     = "Deny"
  nullable    = false

  validation {
    condition     = contains(["Allow", "Deny"], var.ip_restriction_default_action)
    error_message = "IP restriction default action must be \"Allow\" or \"Deny\"."
  }
}


variable "application_logs_file_system_level" {
  description = "The level of application logs to be enabled. Possible values include \"Verbose\", \"Information\", \"Warning\" and \"Error\"."
  type        = string
  default     = "Error"
}

variable "logs_detailed_error_messages" {
  description = "Should detailed error messages be enabled for logs?"
  type        = bool
  default     = false
}

variable "logs_failed_request_tracing" {
  description = "Should failed request tracing be enabled for logs?"
  type        = bool
  default     = false
}

variable "http_logs_file_system_retention_in_mb" {
  description = "The maximum size in megabytes that HTTP logs can use before being deleted from the file system."
  type        = number
  default     = 35
}

variable "http_logs_file_system_retention_in_days" {
  description = "The retention period in days before HTTP logs are deleted from the file system."
  type        = number
  default     = 0
}

variable "custom_hostname_bindings" {
  description = "A list of custom hostnames to bind to this Web App."

  type = map(object({
    hostname  = string
    ssl_state = optional(string, "SniEnabled")
  }))

  default = {}
}

variable "system_assigned_identity_enabled" {
  description = "Should the system-assigned identity be enabled for this Web App?"
  type        = bool
  default     = false
}

variable "identity_ids" {
  description = "A list of IDs of managed identities to be assigned to this Web App."
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace to send diagnostics to."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.log_analytics_workspace_id) == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.OperationalInsights/workspaces/.+$", var.log_analytics_workspace_id))
    error_message = "log_analytics_workspace_id must be empty or a valid Log Analytics workspace resource ID."
  }
}

variable "enable_application_insights" {
  description = "Whether to create an Application Insights resource for this Web App and inject the standard telemetry app settings."
  type        = bool
  default     = false
}

variable "application_insights_name" {
  description = "Optional name for the Application Insights resource. When null or empty, the module uses appi-<app_name>."
  type        = string
  default     = null
  nullable    = true
}

variable "application_insights_workspace_id" {
  description = "Optional Log Analytics workspace resource ID for the Application Insights resource. When empty, the module falls back to log_analytics_workspace_id."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.application_insights_workspace_id) == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.OperationalInsights/workspaces/.+$", var.application_insights_workspace_id))
    error_message = "application_insights_workspace_id must be empty or a valid Log Analytics workspace resource ID."
  }
}

variable "application_insights_retention_in_days" {
  description = "Retention period in days for the Application Insights resource."
  type        = number
  default     = 90

  validation {
    condition     = var.application_insights_retention_in_days >= 30 && var.application_insights_retention_in_days <= 730
    error_message = "application_insights_retention_in_days must be between 30 and 730 days."
  }
}

variable "diagnostic_setting_enabled_log_categories" {
  description = "A list of log categories to be enabled for this diagnostic setting."
  type        = list(string)

  default = [
    "AppServiceHTTPLogs",
    "AppServiceConsoleLogs",
    "AppServiceAppLogs",
    "AppServiceAuditLogs",
    "AppServiceIPSecAuditLogs",
    "AppServicePlatformLogs"
  ]
}

variable "diagnostic_setting_enabled_metric_categories" {
  description = "A list of metric categories to be enabled for this diagnostic setting."
  type        = list(string)
  default     = []
}

variable "diagnostic_setting_name" {
  description = "The name of the diagnostic setting."
  type        = string
  default     = "audit-logs"
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}

  validation {
    condition     = length(setintersection(["hidden-link: /app-insights-conn-string", "hidden-link: /app-insights-instrumentation-key", "hidden-link: /app-insights-resource-id"], keys(var.tags))) == 0
    error_message = "Hidden tags (\"hidden-link: *\") are managed by Azure."
  }
}

variable "app_env" {
  description = "Optional environment name used for environment tags (prod/staging/dev/sbx/test/qa)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["prod", "staging", "dev", "qa", "sbx", "test"], var.app_env)
    error_message = "app_env must be one of: prod, staging, dev, qa, sbx, test."
  }
}

variable "storage_accounts" {
  description = "A list of Storage accounts to be mounted for this Web App."

  type = list(object({
    name                    = string
    account_name            = string
    access_key_setting_name = string
    share_name              = string
    mount_path              = string
    type                    = optional(string, "AzureFiles")
  }))

  default = []

  validation {
    condition     = alltrue([for storage_account in var.storage_accounts : storage_account.mount_path != "" && storage_account.mount_path != null])
    error_message = "Storage account mount point can not be empty or null."
  }

  # Ref: https://learn.microsoft.com/en-us/azure/app-service/configure-connect-to-azure-storage#limitations
  validation {
    condition     = alltrue([for storage_account in var.storage_accounts : storage_account.mount_path != "/" && storage_account.mount_path != "/home"])
    error_message = "Storage account mount point can not be \"/\" or \"/home\"."
  }

  validation {
    condition     = alltrue([for storage_account in var.storage_accounts : storage_account.type == "AzureFiles" || storage_account.type == "AzureBlob"])
    error_message = "Storage account type must be either \"AzureFiles\" or \"AzureBlob\"."
  }
}

variable "public_network_access_enabled" {
  description = "Should public network access be enabled for this Web App?"
  type        = bool
  default     = true
}


variable "client_certificate_mode" {
  description = "The client cerftificate mode for this Web App. Value must be \"Required\", \"Optional\" or \"OptionalInteractiveUser\"."
  type        = string
  default     = "Required"

  validation {
    condition     = contains(["Required", "Optional", "OptionalInteractiveUser"], var.client_certificate_mode)
    error_message = "client_certificate_mode must be Required, Optional, or OptionalInteractiveUser."
  }
}

variable "client_certificate_enabled" {
  description = "Should client certificate be enabled for this Web App?"
  type        = bool
  default     = false
}

variable "zip_deploy_file" {
  description = "The local path of a ZIP-packaged application to deploy to this Web App."
  type        = string
  default     = null
}

variable "ftp_publish_basic_authentication_enabled" {
  description = "Should basic (username and password) authentication be enabled for the FTP client?"
  type        = bool
  default     = false
  nullable    = false
}

variable "webdeploy_publish_basic_authentication_enabled" {
  description = "Should basic (username and password) authentication be enabled for the WebDeploy client? Prefer scm_basic_auth_publishing_credentials_enabled for clarity (same setting)."
  type        = bool
  default     = false
  nullable    = false
}

variable "scm_basic_auth_publishing_credentials_enabled" {
  description = "Enable SCM Basic Auth Publishing Credentials (Kudu/SCM endpoint). When set, overrides webdeploy_publish_basic_authentication_enabled. Used for Local Git, WebDeploy, Visual Studio and other SCM-based deployments."
  type        = bool
  default     = null
  nullable    = true
}

variable "use_32_bit_worker" {
  description = "Should this Web App use a 32-bit worker? Defaulting to false means 64-bit worker."
  type        = bool
  default     = false
  nullable    = false
}

variable "sticky_settings_app_setting_names" {
  description = "A list of names of app settings that this Function App will not swap between slots when a swap operation is triggered."
  type        = list(string)
  default     = []
}

variable "sticky_settings_connection_string_names" {
  description = "A list of names of connection strings that this Function App will not swap between slots when a swap operation is triggered."
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Private endpoint
# -----------------------------------------------------------------------------

variable "enable_private_endpoint" {
  description = "Whether to create a private endpoint for the Web App (sites). Requires PremiumV2/PremiumV3 or higher. When enabled, consider setting public_network_access_enabled = false for isolation."
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for the private endpoint(s). Use this when you have the subnet ID. When empty and lookup vars are set (subnet name, vnet name, resource group), the module looks up the existing subnet via data source."
  type        = string
  default     = ""

  validation {
    condition     = var.private_endpoint_subnet_id == "" || can(regex("^/subscriptions/", var.private_endpoint_subnet_id))
    error_message = "private_endpoint_subnet_id must be empty or a valid Azure resource ID."
  }
}

variable "private_endpoint_subnet_name" {
  description = "Name of the existing subnet for private endpoints. Used with private_endpoint_vnet_name and private_endpoint_network_resource_group_name to look up the subnet via data source when private_endpoint_subnet_id is empty."
  type        = string
  default     = null
}

variable "private_endpoint_vnet_name" {
  description = "Name of the virtual network containing the private endpoint subnet. Required for subnet lookup when private_endpoint_subnet_id is not set."
  type        = string
  default     = null
}

variable "private_endpoint_network_resource_group_name" {
  description = "Resource group name of the existing VNet/subnet used for private endpoints. Required for subnet lookup when private_endpoint_subnet_id is not set."
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "ID of the Azure Private DNS Zone privatelink.azurewebsites.net used by the app private endpoint. Alternatively use private_dns_zone_name and private_dns_zone_resource_group_name to look up an existing zone via data source."
  type        = string
  default     = null
}

variable "private_dns_zone_name" {
  description = "Name of the existing Private DNS Zone (e.g. privatelink.azurewebsites.net). Used with private_dns_zone_resource_group_name to look up the zone via data source when private_dns_zone_id is not set."
  type        = string
  default     = null
}

variable "private_dns_zone_resource_group_name" {
  description = "Resource group name of the existing Private DNS Zone. Required for DNS zone lookup when private_dns_zone_id is not set."
  type        = string
  default     = null
}

check "appservice_input_consistency" {
  assert {
    condition = !var.enable_application_insights || (
      trimspace(var.application_insights_workspace_id) != "" ||
      trimspace(var.log_analytics_workspace_id) != ""
    )
    error_message = "When enable_application_insights is true, set application_insights_workspace_id or log_analytics_workspace_id."
  }

  assert {
    condition = (
      (var.virtual_network_subnet_id == null ? "" : trimspace(var.virtual_network_subnet_id)) != "" ||
      (
        (var.vnet_integration_subnet_name == null ? "" : trimspace(var.vnet_integration_subnet_name)) == "" &&
        (var.vnet_integration_vnet_name == null ? "" : trimspace(var.vnet_integration_vnet_name)) == "" &&
        (var.vnet_integration_network_resource_group_name == null ? "" : trimspace(var.vnet_integration_network_resource_group_name)) == ""
      ) ||
      (
        (var.vnet_integration_subnet_name == null ? "" : trimspace(var.vnet_integration_subnet_name)) != "" &&
        (var.vnet_integration_vnet_name == null ? "" : trimspace(var.vnet_integration_vnet_name)) != "" &&
        (var.vnet_integration_network_resource_group_name == null ? "" : trimspace(var.vnet_integration_network_resource_group_name)) != ""
      )
    )
    error_message = "For VNet integration, set virtual_network_subnet_id or provide vnet_integration_subnet_name, vnet_integration_vnet_name, and vnet_integration_network_resource_group_name together."
  }

  assert {
    condition = !var.enable_private_endpoint || (
      (var.private_endpoint_subnet_id == null ? "" : trimspace(var.private_endpoint_subnet_id)) != "" ||
      (
        (var.private_endpoint_subnet_name == null ? "" : trimspace(var.private_endpoint_subnet_name)) != "" &&
        (var.private_endpoint_vnet_name == null ? "" : trimspace(var.private_endpoint_vnet_name)) != "" &&
        (var.private_endpoint_network_resource_group_name == null ? "" : trimspace(var.private_endpoint_network_resource_group_name)) != ""
      )
    )
    error_message = "When enable_private_endpoint is true, set private_endpoint_subnet_id or provide private_endpoint_subnet_name, private_endpoint_vnet_name, and private_endpoint_network_resource_group_name."
  }

  assert {
    condition = (
      (var.private_dns_zone_id == null ? "" : trimspace(var.private_dns_zone_id)) != "" ||
      (
        (var.private_dns_zone_name == null ? "" : trimspace(var.private_dns_zone_name)) == "" &&
        (var.private_dns_zone_resource_group_name == null ? "" : trimspace(var.private_dns_zone_resource_group_name)) == ""
      ) ||
      (
        (var.private_dns_zone_name == null ? "" : trimspace(var.private_dns_zone_name)) != "" &&
        (var.private_dns_zone_resource_group_name == null ? "" : trimspace(var.private_dns_zone_resource_group_name)) != ""
      )
    )
    error_message = "For private DNS, set private_dns_zone_id or provide private_dns_zone_name and private_dns_zone_resource_group_name together."
  }
}

# -----------------------------------------------------------------------------
# Deployment Center (Azure Repos)
# -----------------------------------------------------------------------------

variable "deployment_center_enabled" {
  description = "Whether to configure Deployment Center for the Web App using an Azure Repos (Azure DevOps) repository."
  type        = bool
  default     = false
}

variable "deployment_center_azure_repos_organization" {
  description = "Azure DevOps organization name hosting the Azure Repos repository used by Deployment Center."
  type        = string
  default     = null
}

variable "deployment_center_azure_repos_project" {
  description = "Azure DevOps project name containing the Azure Repos repository used by Deployment Center."
  type        = string
  default     = null
}

variable "deployment_center_azure_repos_repository" {
  description = "Azure Repos repository name used by Deployment Center."
  type        = string
  default     = null
}

variable "deployment_center_azure_repos_branch" {
  description = "Branch name in the Azure Repos repository to deploy from via Deployment Center."
  type        = string
  default     = "main"

  validation {
    condition = !var.deployment_center_enabled || (
      var.deployment_center_azure_repos_organization != null &&
      var.deployment_center_azure_repos_project != null &&
      var.deployment_center_azure_repos_repository != null &&
      var.deployment_center_azure_repos_branch != null
    )

    error_message = "When deployment_center_enabled is true, deployment_center_azure_repos_organization, deployment_center_azure_repos_project, deployment_center_azure_repos_repository and deployment_center_azure_repos_branch must all be set."
  }
}

variable "deployment_center_use_manual_integration" {
  description = "Whether Deployment Center should use manual integration (true) or continuous integration (false)."
  type        = bool
  default     = true
}

variable "cors" {
  description = "CORS configuration for the Web App."
  type = object({
    allowed_origins     = list(string)
    support_credentials = optional(bool, false)
  })
  default = null
}

