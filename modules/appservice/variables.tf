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
  description = "The Azure region to create resources in. If empty, the module uses the resource group's location."
  type        = string
  default     = ""

  validation {
    condition     = var.location == "" || trimspace(var.location) != ""
    error_message = "location must be empty or a non-empty Azure region name."
  }
}

variable "app_service_plan_id" {
  description = "The ID of the App Service plan to host this Web App on."
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Web/serverFarms/.+$", var.app_service_plan_id))
    error_message = "app_service_plan_id must be a valid App Service Plan resource ID that uses the literal serverFarms segment."
  }
}

variable "kind" {
  description = "The kind of Web App to create. Allowed values are \"Linux\" and \"Windows\"."
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["linux", "windows"], lower(var.kind))
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

  validation {
    condition = alltrue([
      for value in var.app_admin_group : trimspace(value) != ""
    ])
    error_message = "app_admin_group values must not be empty."
  }
}

variable "app_user_group" {
  description = "List of Microsoft Entra group display names or object IDs that should receive Reader access to the Web App."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for value in var.app_user_group : trimspace(value) != ""
    ])
    error_message = "app_user_group values must not be empty."
  }
}

variable "application_stack" {
  description = "An object of application stack settings for this Web App. Supports container and code runtimes. Note that application stack settings are often configured outside of Terraform (for example when deploying code), so configuring application stack settings in Terraform may cause conflicts."

  type = object({
    docker_image_name            = optional(string)
    docker_registry_url          = optional(string)
    docker_registry_username     = optional(string)
    docker_registry_password     = optional(string)
    dotnet_version               = optional(string)
    dotnet_core_version          = optional(string)
    go_version                   = optional(string)
    java_container               = optional(string)
    java_container_version       = optional(string)
    java_embedded_server_enabled = optional(bool)
    java_server                  = optional(string)
    java_server_version          = optional(string)
    node_version                 = optional(string)
    python_version               = optional(string)
    python                       = optional(bool)
    php_version                  = optional(string)
    java_version                 = optional(string)
    ruby_version                 = optional(string)
    tomcat_version               = optional(string)
    current_stack                = optional(string)
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

variable "active_directory_allowed_audiences" {
  description = "Optional list of allowed audiences for Microsoft Entra Easy Auth. When null, the module defaults to api://<active_directory_client_id>."
  type        = list(string)
  default     = null
  nullable    = true
}

variable "active_directory_allowed_groups" {
  description = "Optional Microsoft Entra group object IDs allowed by Easy Auth."
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for value in var.active_directory_allowed_groups :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value))
    ])
    error_message = "active_directory_allowed_groups must contain valid GUID object IDs."
  }
}

variable "active_directory_allowed_applications" {
  description = "Optional Microsoft Entra application client IDs allowed by Easy Auth."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "active_directory_allowed_identities" {
  description = "Optional Microsoft Entra identity object IDs allowed by Easy Auth."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "active_directory_jwt_allowed_client_applications" {
  description = "Optional list of JWT client application IDs accepted by Easy Auth."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "active_directory_jwt_allowed_groups" {
  description = "Optional list of JWT group IDs accepted by Easy Auth."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "auth_default_provider" {
  description = "Default Easy Auth provider when platform auth is enabled."
  type        = string
  default     = "azureactivedirectory"
  nullable    = false

  validation {
    condition     = contains(["azureactivedirectory"], var.auth_default_provider)
    error_message = "auth_default_provider currently supports azureactivedirectory."
  }
}

variable "auth_excluded_paths" {
  description = "Paths excluded from Easy Auth authentication requirements."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "auth_token_store_enabled" {
  description = "Whether App Service Easy Auth token store is enabled."
  type        = bool
  default     = true
  nullable    = false
}

variable "auth_allowed_external_redirect_urls" {
  description = "External redirect URLs allowed by Easy Auth login."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "auth_require_https" {
  description = "Whether Easy Auth requires HTTPS for authentication callbacks."
  type        = bool
  default     = true
  nullable    = false
}

variable "auth_runtime_version" {
  description = "Easy Auth runtime version."
  type        = string
  default     = "~1"
  nullable    = false
}

variable "auth_http_route_api_prefix" {
  description = "Route prefix used by Easy Auth built-in authentication endpoints."
  type        = string
  default     = "/.auth"
  nullable    = false
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

variable "app_enabled" {
  description = "Whether the Web App is enabled."
  type        = bool
  default     = true
  nullable    = false
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

variable "virtual_network_backup_restore_enabled" {
  description = "Whether backup and restore traffic should use the integrated virtual network."
  type        = bool
  default     = false
  nullable    = false
}

variable "vnet_image_pull_enabled" {
  description = "Whether Linux container image pulls should use virtual network routing."
  type        = bool
  default     = false
  nullable    = false
}

variable "virtual_network_image_pull_enabled" {
  description = "Whether Windows container image pulls should use virtual network routing."
  type        = bool
  default     = false
  nullable    = false
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

variable "minimum_tls_version" {
  description = "Minimum inbound TLS version for the Web App."
  type        = string
  default     = "1.2"
  nullable    = false

  validation {
    condition     = contains(["1.0", "1.1", "1.2", "1.3"], var.minimum_tls_version)
    error_message = "minimum_tls_version must be one of: 1.0, 1.1, 1.2, 1.3."
  }
}

variable "scm_minimum_tls_version" {
  description = "Minimum TLS version for the Kudu/SCM endpoint."
  type        = string
  default     = "1.2"
  nullable    = false

  validation {
    condition     = contains(["1.0", "1.1", "1.2", "1.3"], var.scm_minimum_tls_version)
    error_message = "scm_minimum_tls_version must be one of: 1.0, 1.1, 1.2, 1.3."
  }
}

variable "api_definition_url" {
  description = "Optional URL to the API definition for the Web App."
  type        = string
  default     = null
}

variable "api_management_api_id" {
  description = "Optional API Management API resource ID associated with this Web App."
  type        = string
  default     = null
}

variable "default_documents" {
  description = "Default documents served by App Service."
  type        = list(string)
  default     = null
}

variable "load_balancing_mode" {
  description = "App Service load balancing mode."
  type        = string
  default     = "LeastRequests"
  nullable    = false

  validation {
    condition     = contains(["WeightedRoundRobin", "LeastRequests", "LeastResponseTime", "WeightedTotalTraffic", "RequestHash", "PerSiteRoundRobin"], var.load_balancing_mode)
    error_message = "load_balancing_mode must be one of: WeightedRoundRobin, LeastRequests, LeastResponseTime, WeightedTotalTraffic, RequestHash, PerSiteRoundRobin."
  }
}

variable "local_mysql_enabled" {
  description = "Whether local MySQL is enabled for the Web App."
  type        = bool
  default     = false
  nullable    = false
}

variable "managed_pipeline_mode" {
  description = "Managed pipeline mode for the Web App."
  type        = string
  default     = "Integrated"
  nullable    = false

  validation {
    condition     = contains(["Integrated", "Classic"], var.managed_pipeline_mode)
    error_message = "managed_pipeline_mode must be Integrated or Classic."
  }
}

variable "remote_debugging_enabled" {
  description = "Whether remote debugging is enabled. Keep disabled for production workloads."
  type        = bool
  default     = false
  nullable    = false
}

variable "remote_debugging_version" {
  description = "Remote debugging Visual Studio version."
  type        = string
  default     = null
}

variable "scm_type" {
  description = "SCM type for the Web App, such as None, LocalGit, GitHub, BitbucketGit, BitbucketHg, CodePlexGit, CodePlexHg, Dropbox, ExternalGit, Tfs, VSO, or VSTSRM."
  type        = string
  default     = null
}

variable "worker_count" {
  description = "Number of workers assigned to the app when supported by the App Service Plan."
  type        = number
  default     = null

  validation {
    condition     = var.worker_count == null ? true : var.worker_count >= 1
    error_message = "worker_count must be null or greater than or equal to 1."
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
    action                    = optional(string, "Allow")
    description               = optional(string)
    ip_address                = optional(string)
    name                      = string
    priority                  = number
    service_tag               = optional(string)
    virtual_network_subnet_id = optional(string)

    headers = optional(object({
      x_forwarded_for   = optional(list(string))
      x_forwarded_host  = optional(list(string))
      x_azure_fdid      = optional(list(string))
      x_fd_health_probe = optional(list(string))
    }))
  }))

  default = []

  validation {
    condition = alltrue([
      for rule in var.ip_restrictions :
      contains(["Allow", "Deny"], rule.action)
    ])
    error_message = "Each ip_restrictions action must be Allow or Deny."
  }
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

variable "scm_ip_restrictions" {
  description = "A list of IP restrictions to configure for the Kudu/SCM endpoint."

  type = list(object({
    action                    = optional(string, "Allow")
    description               = optional(string)
    ip_address                = optional(string)
    name                      = string
    priority                  = number
    service_tag               = optional(string)
    virtual_network_subnet_id = optional(string)

    headers = optional(object({
      x_forwarded_for   = optional(list(string))
      x_forwarded_host  = optional(list(string))
      x_azure_fdid      = optional(list(string))
      x_fd_health_probe = optional(list(string))
    }))
  }))

  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for rule in var.scm_ip_restrictions :
      contains(["Allow", "Deny"], rule.action)
    ])
    error_message = "Each scm_ip_restrictions action must be Allow or Deny."
  }
}

variable "scm_ip_restriction_default_action" {
  description = "The default action for Kudu/SCM endpoint traffic that does not match a restriction rule."
  type        = string
  default     = "Allow"
  nullable    = false

  validation {
    condition     = contains(["Allow", "Deny"], var.scm_ip_restriction_default_action)
    error_message = "scm_ip_restriction_default_action must be Allow or Deny."
  }
}

variable "scm_use_main_ip_restriction" {
  description = "Whether the Kudu/SCM endpoint should reuse the main site IP restrictions."
  type        = bool
  default     = false
  nullable    = false
}

variable "scmIpSecurityRestrictionsUseMain" {
  description = "Optional App Service property override for scmIpSecurityRestrictionsUseMain. When null, scm_use_main_ip_restriction is used."
  type        = bool
  default     = null
  nullable    = true
}

variable "application_logs_file_system_level" {
  description = "The level of application logs to be enabled. Possible values include \"Verbose\", \"Information\", \"Warning\" and \"Error\"."
  type        = string
  default     = "Error"

  validation {
    condition     = contains(["Off", "Verbose", "Information", "Warning", "Error"], var.application_logs_file_system_level)
    error_message = "application_logs_file_system_level must be Off, Verbose, Information, Warning, or Error."
  }
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

  validation {
    condition     = var.http_logs_file_system_retention_in_mb >= 25 && var.http_logs_file_system_retention_in_mb <= 100
    error_message = "http_logs_file_system_retention_in_mb must be between 25 and 100."
  }
}

variable "http_logs_file_system_retention_in_days" {
  description = "The retention period in days before HTTP logs are deleted from the file system."
  type        = number
  default     = 0

  validation {
    condition     = var.http_logs_file_system_retention_in_days >= 0 && var.http_logs_file_system_retention_in_days <= 365
    error_message = "http_logs_file_system_retention_in_days must be between 0 and 365."
  }
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

variable "enable_diagnostics" {
  description = "Whether to create an Azure Monitor diagnostic setting. For backward compatibility, diagnostics are also enabled when any diagnostic destination is supplied."
  type        = bool
  default     = false
  nullable    = false
}

variable "log_analytics_destination_type" {
  description = "Destination type for Log Analytics diagnostics. Use Dedicated for resource-specific tables or AzureDiagnostics for the legacy shared table."
  type        = string
  default     = "Dedicated"
  nullable    = false

  validation {
    condition     = contains(["Dedicated", "AzureDiagnostics"], var.log_analytics_destination_type)
    error_message = "log_analytics_destination_type must be Dedicated or AzureDiagnostics."
  }
}

variable "diagnostic_storage_account_id" {
  description = "Optional Storage Account resource ID for diagnostic setting archival."
  type        = string
  default     = null

  validation {
    condition = (
      var.diagnostic_storage_account_id == null ||
      try(trimspace(var.diagnostic_storage_account_id), "") == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Storage/storageAccounts/.+$", var.diagnostic_storage_account_id))
    )
    error_message = "diagnostic_storage_account_id must be null, empty, or a valid Storage Account resource ID."
  }
}

variable "diagnostic_eventhub_authorization_rule_id" {
  description = "Optional Event Hub authorization rule resource ID for diagnostic settings."
  type        = string
  default     = null

  validation {
    condition = (
      var.diagnostic_eventhub_authorization_rule_id == null ||
      try(trimspace(var.diagnostic_eventhub_authorization_rule_id), "") == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.EventHub/namespaces/.+/authorizationRules/.+$", var.diagnostic_eventhub_authorization_rule_id)) ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.EventHub/namespaces/.+/eventhubs/.+/authorizationRules/.+$", var.diagnostic_eventhub_authorization_rule_id))
    )
    error_message = "diagnostic_eventhub_authorization_rule_id must be null, empty, or a valid Event Hub authorization rule resource ID."
  }
}

variable "diagnostic_eventhub_name" {
  description = "Optional Event Hub name for diagnostic settings when using an Event Hub destination."
  type        = string
  default     = null
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

  validation {
    condition = alltrue([
      for value in var.diagnostic_setting_enabled_log_categories :
      trimspace(value) != ""
    ])
    error_message = "diagnostic_setting_enabled_log_categories must contain only non-empty category names."
  }
}

variable "diagnostic_setting_enabled_metric_categories" {
  description = "A list of metric categories to be enabled for this diagnostic setting."
  type        = list(string)
  default     = ["AllMetrics"]

  validation {
    condition = alltrue([
      for value in var.diagnostic_setting_enabled_metric_categories :
      contains(["AllMetrics"], value)
    ])
    error_message = "diagnostic_setting_enabled_metric_categories must contain only supported metric categories."
  }
}

variable "diagnostic_setting_name" {
  description = "The name of the diagnostic setting."
  type        = string
  default     = "audit-logs"
}

variable "diagnostic_category_discovery_enabled" {
  description = "Whether to discover diagnostic categories from Azure when category lists are empty. Keep false for deterministic plan tests."
  type        = bool
  default     = false
  nullable    = false
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
  description = "Optional environment name used for environment tags (prod/staging/dev/sbx/test/qa/poc)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["prod", "staging", "dev", "qa", "sbx", "test", "poc"], var.app_env)
    error_message = "app_env must be one of: prod, staging, dev, qa, sbx, test, poc."
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

variable "client_certificate_exclusion_paths" {
  description = "Paths excluded from client certificate authentication."
  type        = string
  default     = null
}

variable "zip_deploy_file" {
  description = "The local path of a ZIP-packaged application to deploy to this Web App."
  type        = string
  default     = null
}

variable "linux_fx_version" {
  description = "Optional Linux FX version override. Prefer application_stack for normal runtime configuration."
  type        = string
  default     = null
}

variable "windows_fx_version" {
  description = "Optional Windows FX version override. Prefer application_stack for normal runtime configuration."
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

variable "backup" {
  description = "Optional App Service backup configuration. The storage_account_url must be a SAS URL to the backup container."
  type = object({
    name                = string
    enabled             = optional(bool, true)
    storage_account_url = string
    schedule = object({
      frequency_interval       = number
      frequency_unit           = string
      keep_at_least_one_backup = optional(bool, true)
      retention_period_days    = optional(number, 30)
      start_time               = optional(string)
    })
  })
  default = null

  validation {
    condition     = var.backup == null ? true : contains(["Day", "Hour"], var.backup.schedule.frequency_unit)
    error_message = "backup.schedule.frequency_unit must be Day or Hour."
  }
}

variable "auto_heal_setting" {
  description = "Optional auto-heal rules that recycle the app when request, slow request, or status-code thresholds are reached."
  type = object({
    action = object({
      action_type                    = optional(string, "Recycle")
      minimum_process_execution_time = optional(string, "00:00:00")
    })
    trigger = object({
      requests = optional(object({
        count    = number
        interval = string
      }))
      slow_request = optional(object({
        count      = number
        interval   = string
        time_taken = string
      }))
      slow_request_with_path = optional(object({
        count      = number
        interval   = string
        path       = string
        time_taken = string
      }))
      status_code = optional(list(object({
        count             = number
        interval          = string
        status_code_range = string
        path              = optional(string)
        sub_status        = optional(number)
        win32_status_code = optional(number)
      })), [])
    })
  })
  default = null

  validation {
    condition     = var.auto_heal_setting == null ? true : contains(["Recycle", "LogEvent", "CustomAction"], var.auto_heal_setting.action.action_type)
    error_message = "auto_heal_setting.action.action_type must be Recycle, LogEvent, or CustomAction."
  }
}

variable "handler_mappings" {
  description = "Optional Windows handler mappings. Ignored for Linux Web Apps."
  type = list(object({
    extension             = string
    script_processor_path = string
    arguments             = optional(string)
  }))
  default  = []
  nullable = false
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
    condition = !var.enable_diagnostics || (
      trimspace(var.log_analytics_workspace_id) != "" ||
      try(trimspace(var.diagnostic_storage_account_id), "") != "" ||
      try(trimspace(var.diagnostic_eventhub_authorization_rule_id), "") != ""
    )
    error_message = "When enable_diagnostics is true, set at least one destination: log_analytics_workspace_id, diagnostic_storage_account_id, or diagnostic_eventhub_authorization_rule_id."
  }

  assert {
    condition = (
      try(trimspace(var.diagnostic_eventhub_name), "") == "" ||
      try(trimspace(var.diagnostic_eventhub_authorization_rule_id), "") != ""
    )
    error_message = "diagnostic_eventhub_authorization_rule_id must be set when diagnostic_eventhub_name is provided."
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
    condition = !var.enable_private_endpoint || (
      (var.private_dns_zone_id == null ? "" : trimspace(var.private_dns_zone_id)) != "" ||
      (
        (var.private_dns_zone_name == null ? "" : trimspace(var.private_dns_zone_name)) != "" &&
        (var.private_dns_zone_resource_group_name == null ? "" : trimspace(var.private_dns_zone_resource_group_name)) != ""
      )
    )
    error_message = "When enable_private_endpoint is true, set private_dns_zone_id or provide private_dns_zone_name and private_dns_zone_resource_group_name together."
  }

  assert {
    condition     = !local.scm_ip_security_restrictions_use_main || length(var.scm_ip_restrictions) == 0
    error_message = "When scmIpSecurityRestrictionsUseMain or scm_use_main_ip_restriction is true, leave scm_ip_restrictions empty."
  }

  assert {
    condition     = !var.remote_debugging_enabled || var.app_env != "prod"
    error_message = "remote_debugging_enabled must stay false for prod."
  }

  assert {
    condition     = length(var.handler_mappings) == 0 || lower(var.kind) == "windows"
    error_message = "handler_mappings are only supported for Windows Web Apps."
  }

  assert {
    condition     = var.linux_fx_version == null || lower(var.kind) == "linux"
    error_message = "linux_fx_version is only supported for Linux Web Apps."
  }

  assert {
    condition     = var.windows_fx_version == null || lower(var.kind) == "windows"
    error_message = "windows_fx_version is only supported for Windows Web Apps."
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

  validation {
    condition     = var.cors == null ? true : (!try(var.cors.support_credentials, false) || !contains(var.cors.allowed_origins, "*"))
    error_message = "CORS support_credentials cannot be true when allowed_origins contains '*'."
  }
}
