variable "resource_group_name" {
  type        = string
  description = "Existing resource group name where the Function App will be created."

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into module resources. The module only reads the resource group when this is true or location is empty."
  default     = false
}

variable "location" {
  type        = string
  description = "Azure region for the Function App. Leave empty to use the resource group location."
  default     = ""

  validation {
    condition     = trimspace(var.location) == "" || can(regex("^[a-z0-9-]+$", trimspace(var.location)))
    error_message = "location must be empty or a valid Azure region identifier."
  }
}

variable "name" {
  type        = string
  description = "Function App name. Leave empty to auto-generate a standardized name."
  default     = ""

  validation {
    condition = trimspace(var.name) == "" || (
      length(trimspace(var.name)) >= 2 &&
      length(trimspace(var.name)) <= 60 &&
      can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", trimspace(var.name)))
    )
    error_message = "name must be empty or 2-60 characters using lowercase letters, numbers, and hyphens, and must start and end with a letter or number."
  }
}

variable "name_prefix" {
  type        = string
  description = "Prefix used when the Function App name is generated."
  default     = "func"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,15}$", var.name_prefix))
    error_message = "name_prefix must be 1-15 characters using lowercase letters, digits, or hyphens."
  }
}

variable "workload_name" {
  type        = string
  description = "Optional workload segment used when the Function App name is generated."
  default     = ""

  validation {
    condition     = var.workload_name == "" || can(regex("^[a-z0-9-]{1,35}$", var.workload_name))
    error_message = "workload_name must be empty or 1-35 characters using lowercase letters, digits, or hyphens."
  }
}

variable "app_env" {
  type        = string
  description = "Deployment environment used for standard tags and generated naming."
  default     = "dev"

  validation {
    condition     = contains(["prod", "staging", "dev", "qa", "sbx", "test", "poc"], var.app_env)
    error_message = "app_env must be one of: prod, staging, dev, qa, sbx, test, poc."
  }
}

variable "include_environment_in_name" {
  type        = bool
  description = "Whether generated Function App names include app_env."
  default     = true
}

variable "location_code" {
  type        = string
  description = "Optional short location code used when the Function App name is generated."
  default     = ""

  validation {
    condition     = var.location_code == "" || can(regex("^[a-z0-9-]{2,20}$", var.location_code))
    error_message = "location_code must be empty or 2-20 lowercase letters, digits, or hyphens."
  }
}

variable "instance" {
  type        = string
  description = "Optional instance segment used when generated names do not use a random suffix."
  default     = "001"

  validation {
    condition     = var.instance == "" || can(regex("^[a-z0-9-]{1,10}$", var.instance))
    error_message = "instance must be empty or 1-10 lowercase letters, digits, or hyphens."
  }
}

variable "use_random_suffix" {
  type        = bool
  description = "Whether generated Function App names should include a random suffix."
  default     = true
}

variable "os_type" {
  type        = string
  description = "Function App operating system. Supported values: Linux or Windows."
  default     = "Linux"

  validation {
    condition     = contains(["linux", "windows"], lower(var.os_type))
    error_message = "os_type must be Linux or Windows."
  }
}

variable "service_plan_id" {
  type        = string
  description = "App Service Plan ID used to host the Function App."

  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Web/server[Ff]arms/.+$", var.service_plan_id))
    error_message = "service_plan_id must be a valid App Service Plan resource ID."
  }
}

variable "storage_account_name" {
  type        = string
  description = "Existing storage account name used by the Function App when access-key or managed-identity storage auth is used."
  default     = ""

  validation {
    condition     = trimspace(var.storage_account_name) == "" || can(regex("^[a-z0-9]{3,24}$", trimspace(var.storage_account_name)))
    error_message = "storage_account_name must be empty or 3-24 lowercase alphanumeric characters."
  }
}

variable "storage_account_resource_group_name" {
  type        = string
  description = "Resource group containing the existing storage account. Leave empty to use resource_group_name."
  default     = ""
}

variable "storage_account_id" {
  type        = string
  description = "Optional storage account resource ID for outputs and documentation when storage lookup is intentionally skipped."
  default     = ""

  validation {
    condition = (
      trimspace(var.storage_account_id) == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Storage/storageAccounts/.+$", var.storage_account_id))
    )
    error_message = "storage_account_id must be empty or a valid storage account resource ID."
  }
}

variable "storage_account_access_key" {
  type        = string
  description = "Optional storage account access key. Supplying this avoids a storage account data-source lookup for plan-only workflows."
  default     = ""
  sensitive   = true
}

variable "storage_uses_managed_identity" {
  type        = bool
  description = "Whether the Function App should use managed identity for AzureWebJobsStorage instead of an access key."
  default     = false
}

variable "storage_key_vault_secret_id" {
  type        = string
  description = "Optional Key Vault secret ID containing the Function App storage connection string. When set, storage_account_name and storage_account_access_key are not used by the Function App resource."
  default     = ""

  validation {
    condition = (
      try(trimspace(var.storage_key_vault_secret_id), "") == "" ||
      can(regex("^https://.+\\.vault\\.azure\\.net/secrets/.+", var.storage_key_vault_secret_id))
    )
    error_message = "storage_key_vault_secret_id must be empty or a valid Key Vault secret ID URI."
  }
}

variable "functions_extension_version" {
  type        = string
  description = "Functions runtime extension version."
  default     = "~4"

  validation {
    condition     = can(regex("^~?[1-4]$", trimspace(var.functions_extension_version)))
    error_message = "functions_extension_version must be one of 1, 2, 3, 4, ~1, ~2, ~3, or ~4."
  }
}

variable "builtin_logging_enabled" {
  type        = bool
  description = "Whether built-in platform logging is enabled. Prefer diagnostic settings for production observability."
  default     = false
}

variable "enabled" {
  type        = bool
  description = "Whether the Function App is enabled."
  default     = true
}

variable "https_only" {
  type        = bool
  description = "Whether only HTTPS traffic is allowed."
  default     = true
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled."
  default     = false
}

variable "client_certificate_enabled" {
  type        = bool
  description = "Whether client certificates are enabled for inbound requests."
  default     = false
}

variable "client_certificate_mode" {
  type        = string
  description = "Client certificate mode when client certificates are enabled."
  default     = "Optional"

  validation {
    condition     = contains(["Required", "Optional", "OptionalInteractiveUser"], var.client_certificate_mode)
    error_message = "client_certificate_mode must be Required, Optional, or OptionalInteractiveUser."
  }
}

variable "client_certificate_exclusion_paths" {
  type        = string
  description = "Comma-separated request paths excluded from client certificate authentication."
  default     = null
}

variable "content_share_force_disabled" {
  type        = bool
  description = "Whether to disable Function App content share creation."
  default     = false
}

variable "ftp_publish_basic_authentication_enabled" {
  type        = bool
  description = "Whether FTP publishing basic authentication is enabled."
  default     = false
}

variable "webdeploy_publish_basic_authentication_enabled" {
  type        = bool
  description = "Whether WebDeploy publishing basic authentication is enabled."
  default     = false
}

variable "virtual_network_backup_restore_enabled" {
  type        = bool
  description = "Whether backup and restore traffic should use VNet integration."
  default     = false
}

variable "vnet_image_pull_enabled" {
  type        = bool
  description = "Whether container image pulls should use VNet integration."
  default     = false
}

variable "app_settings" {
  type        = map(string)
  description = "Additional application settings for the Function App."
  default     = {}
  nullable    = false
}

variable "app_admin_group" {
  type        = list(string)
  description = "List of Microsoft Entra group display names or object IDs that should receive Contributor access to the Function App."
  default     = []

  validation {
    condition     = alltrue([for value in var.app_admin_group : trimspace(value) != ""])
    error_message = "app_admin_group values must not be empty."
  }
}

variable "app_user_group" {
  type        = list(string)
  description = "List of Microsoft Entra group display names or object IDs that should receive Reader access to the Function App."
  default     = []

  validation {
    condition     = alltrue([for value in var.app_user_group : trimspace(value) != ""])
    error_message = "app_user_group values must not be empty."
  }
}

variable "role_assignments" {
  description = "Additional role assignments scoped to the Function App."
  type = map(object({
    principal_id                           = string
    principal_type                         = optional(string)
    role_definition_name                   = optional(string)
    role_definition_id                     = optional(string)
    name                                   = optional(string)
    description                            = optional(string)
    condition                              = optional(string)
    condition_version                      = optional(string)
    delegated_managed_identity_resource_id = optional(string)
    skip_service_principal_aad_check       = optional(bool, false)
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for _, assignment in var.role_assignments :
      try(trimspace(assignment.role_definition_name), "") != "" || try(trimspace(assignment.role_definition_id), "") != ""
    ])
    error_message = "Each role_assignments item must specify role_definition_name or role_definition_id."
  }
}

variable "connection_strings" {
  description = "Optional Function App connection strings."
  type = list(object({
    name  = string
    value = string
    type  = optional(string, "Custom")
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for connection in var.connection_strings :
      contains(["APIHub", "Custom", "DocDb", "EventHub", "MySql", "NotificationHub", "PostgreSQL", "RedisCache", "ServiceBus", "SQLAzure", "SQLServer"], connection.type)
    ])
    error_message = "connection_strings.type contains an unsupported Function App connection string type."
  }
}

variable "application_stack" {
  description = "Application stack settings for the Function App runtime. Configure exactly one runtime family."
  type = object({
    dotnet_version              = optional(string)
    java_version                = optional(string)
    node_version                = optional(string)
    powershell_core_version     = optional(string)
    python_version              = optional(string)
    use_custom_runtime          = optional(bool)
    use_dotnet_isolated_runtime = optional(bool)
    docker = optional(object({
      image_name        = string
      image_tag         = string
      registry_url      = string
      registry_username = optional(string)
      registry_password = optional(string)
    }))
  })
  default = null

  validation {
    condition     = var.os_type == "Linux" || var.application_stack == null || (try(var.application_stack.python_version, null) == null && try(var.application_stack.docker, null) == null)
    error_message = "application_stack.python_version and application_stack.docker are supported only when os_type is Linux."
  }

  validation {
    condition = var.application_stack == null || try(var.application_stack.dotnet_version, null) == null || (
      lower(var.os_type) == "linux"
      ? can(regex("^\\d+\\.\\d+$", var.application_stack.dotnet_version))
      : can(regex("^v\\d+\\.\\d+$", var.application_stack.dotnet_version))
    )
    error_message = "application_stack.dotnet_version must use '8.0' format for Linux and 'v8.0' format for Windows."
  }

  validation {
    condition = var.application_stack == null || length(compact([
      try(var.application_stack.dotnet_version, null),
      try(var.application_stack.java_version, null),
      try(var.application_stack.node_version, null),
      try(var.application_stack.powershell_core_version, null),
      try(var.application_stack.python_version, null),
      coalesce(try(var.application_stack.use_custom_runtime, null), false) ? "custom" : null,
      try(var.application_stack.docker, null) != null ? "docker" : null
    ])) == 1
    error_message = "application_stack must define exactly one primary runtime option."
  }

  validation {
    condition     = var.application_stack == null || !coalesce(try(var.application_stack.use_dotnet_isolated_runtime, null), false) || try(var.application_stack.dotnet_version, null) != null
    error_message = "application_stack.use_dotnet_isolated_runtime requires application_stack.dotnet_version."
  }
}

variable "system_assigned_identity_enabled" {
  type        = bool
  description = "Whether to enable a system-assigned managed identity."
  default     = false
}

variable "identity_ids" {
  type        = list(string)
  description = "Optional user-assigned managed identity IDs."
  default     = []

  validation {
    condition = alltrue([
      for value in var.identity_ids :
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.ManagedIdentity/userAssignedIdentities/.+$", value))
    ])
    error_message = "identity_ids must contain valid user-assigned managed identity resource IDs."
  }
}

variable "key_vault_reference_identity_id" {
  type        = string
  description = "Managed identity ID used for Key Vault references in app settings."
  default     = ""

  validation {
    condition = (
      try(trimspace(var.key_vault_reference_identity_id), "") == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.ManagedIdentity/userAssignedIdentities/.+$", var.key_vault_reference_identity_id))
    )
    error_message = "key_vault_reference_identity_id must be empty or a valid user-assigned managed identity resource ID."
  }
}

variable "virtual_network_subnet_id" {
  type        = string
  description = "Subnet ID for VNet integration. Leave empty to resolve by subnet/vnet/resource group name."
  default     = ""

  validation {
    condition = (
      trimspace(var.virtual_network_subnet_id) == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/.+$", var.virtual_network_subnet_id))
    )
    error_message = "virtual_network_subnet_id must be empty or a valid subnet resource ID."
  }

  validation {
    condition = (
      trimspace(var.virtual_network_subnet_id) != "" || (
        trimspace(var.vnet_integration_subnet_name) == "" &&
        trimspace(var.vnet_integration_vnet_name) == "" &&
        trimspace(var.vnet_integration_network_resource_group_name) == ""
        ) || (
        trimspace(var.vnet_integration_subnet_name) != "" &&
        trimspace(var.vnet_integration_vnet_name) != "" &&
        trimspace(var.vnet_integration_network_resource_group_name) != ""
      )
    )
    error_message = "For VNet integration, provide virtual_network_subnet_id or all of vnet_integration_subnet_name, vnet_integration_vnet_name, and vnet_integration_network_resource_group_name."
  }
}

variable "vnet_integration_subnet_name" {
  type        = string
  description = "Existing subnet name used for VNet integration when virtual_network_subnet_id is empty."
  default     = ""
}

variable "vnet_integration_vnet_name" {
  type        = string
  description = "Existing virtual network name used for VNet integration subnet lookup."
  default     = ""
}

variable "vnet_integration_network_resource_group_name" {
  type        = string
  description = "Resource group containing the virtual network used for VNet integration subnet lookup."
  default     = ""
}

variable "vnet_route_all_enabled" {
  type        = bool
  description = "Whether all outbound traffic is routed through the VNet integration subnet."
  default     = false
}

variable "always_on" {
  type        = bool
  description = "Whether the Function App should always remain warm. Required for Dedicated and Premium plans; not supported on classic Consumption."
  default     = true
}

variable "api_definition_url" {
  type        = string
  description = "Optional API definition URL."
  default     = null
}

variable "api_management_api_id" {
  type        = string
  description = "Optional API Management API ID linked to the Function App."
  default     = null
}

variable "app_command_line" {
  type        = string
  description = "Optional startup command."
  default     = null
}

variable "app_scale_limit" {
  type        = number
  description = "Optional maximum number of workers for Elastic Premium or Consumption scale-out."
  default     = null

  validation {
    condition     = try(var.app_scale_limit >= 0, true)
    error_message = "app_scale_limit must be null or greater than or equal to 0."
  }
}

variable "application_insights_connection_string" {
  type        = string
  description = "Optional Application Insights connection string."
  default     = null
  sensitive   = true
}

variable "application_insights_key" {
  type        = string
  description = "Optional Application Insights instrumentation key."
  default     = null
  sensitive   = true
}

variable "container_registry_managed_identity_client_id" {
  type        = string
  description = "Optional client ID of the managed identity used to pull container images."
  default     = null
}

variable "container_registry_use_managed_identity" {
  type        = bool
  description = "Whether container image pulls should use managed identity."
  default     = false
}

variable "default_documents" {
  type        = list(string)
  description = "Optional default documents."
  default     = null
}

variable "elastic_instance_minimum" {
  type        = number
  description = "Optional minimum number of elastic instances for Premium plans."
  default     = null

  validation {
    condition     = try(var.elastic_instance_minimum >= 0, true)
    error_message = "elastic_instance_minimum must be null or greater than or equal to 0."
  }
}

variable "ftps_state" {
  type        = string
  description = "FTPS state for the Function App."
  default     = "Disabled"

  validation {
    condition     = contains(["AllAllowed", "FtpsOnly", "Disabled"], var.ftps_state)
    error_message = "ftps_state must be AllAllowed, FtpsOnly, or Disabled."
  }
}

variable "health_check_path" {
  type        = string
  description = "Optional health check path."
  default     = null
}

variable "health_check_eviction_time_in_min" {
  type        = number
  description = "Optional health check eviction time in minutes."
  default     = null

  validation {
    condition     = var.health_check_eviction_time_in_min == null || try(trimspace(var.health_check_path), "") != ""
    error_message = "health_check_eviction_time_in_min requires health_check_path to be set."
  }
}

variable "http2_enabled" {
  type        = bool
  description = "Whether HTTP/2 is enabled."
  default     = true
}

variable "ip_restriction_default_action" {
  type        = string
  description = "Default action for main-site IP restrictions."
  default     = "Allow"

  validation {
    condition     = contains(["Allow", "Deny"], var.ip_restriction_default_action)
    error_message = "ip_restriction_default_action must be Allow or Deny."
  }
}

variable "load_balancing_mode" {
  type        = string
  description = "Load balancing mode for the Function App."
  default     = "LeastRequests"

  validation {
    condition     = contains(["WeightedRoundRobin", "LeastRequests", "LeastResponseTime", "WeightedTotalTraffic", "RequestHash", "PerSiteRoundRobin"], var.load_balancing_mode)
    error_message = "load_balancing_mode contains an unsupported value."
  }
}

variable "managed_pipeline_mode" {
  type        = string
  description = "Managed pipeline mode."
  default     = "Integrated"

  validation {
    condition     = contains(["Integrated", "Classic"], var.managed_pipeline_mode)
    error_message = "managed_pipeline_mode must be Integrated or Classic."
  }
}

variable "minimum_tls_version" {
  type        = string
  description = "Minimum TLS version for the Function App."
  default     = "1.2"

  validation {
    condition     = contains(["1.0", "1.1", "1.2", "1.3"], var.minimum_tls_version)
    error_message = "minimum_tls_version must be 1.0, 1.1, 1.2, or 1.3."
  }
}

variable "pre_warmed_instance_count" {
  type        = number
  description = "Optional number of pre-warmed instances for Premium plans."
  default     = null

  validation {
    condition     = try(var.pre_warmed_instance_count >= 0, true)
    error_message = "pre_warmed_instance_count must be null or greater than or equal to 0."
  }
}

variable "remote_debugging_enabled" {
  type        = bool
  description = "Whether remote debugging is enabled."
  default     = false
}

variable "remote_debugging_version" {
  type        = string
  description = "Remote debugging Visual Studio version when remote debugging is enabled."
  default     = null
}

variable "runtime_scale_monitoring_enabled" {
  type        = bool
  description = "Whether runtime scale monitoring is enabled."
  default     = false
}

variable "scm_ip_restriction_default_action" {
  type        = string
  description = "Default action for SCM/Kudu IP restrictions."
  default     = "Allow"

  validation {
    condition     = contains(["Allow", "Deny"], var.scm_ip_restriction_default_action)
    error_message = "scm_ip_restriction_default_action must be Allow or Deny."
  }
}

variable "scm_minimum_tls_version" {
  type        = string
  description = "Minimum TLS version for SCM/Kudu."
  default     = "1.2"

  validation {
    condition     = contains(["1.0", "1.1", "1.2", "1.3"], var.scm_minimum_tls_version)
    error_message = "scm_minimum_tls_version must be 1.0, 1.1, 1.2, or 1.3."
  }
}

variable "scm_use_main_ip_restriction" {
  type        = bool
  description = "Whether SCM/Kudu should use the same IP restrictions as the main site."
  default     = true
}

variable "use_32_bit_worker" {
  type        = bool
  description = "Whether to use a 32-bit worker process."
  default     = false
}

variable "websockets_enabled" {
  type        = bool
  description = "Whether WebSockets are enabled."
  default     = false
}

variable "worker_count" {
  type        = number
  description = "Optional number of workers."
  default     = null

  validation {
    condition     = try(var.worker_count >= 1, true)
    error_message = "worker_count must be null or greater than or equal to 1."
  }
}

variable "daily_memory_time_quota" {
  type        = number
  description = "Optional daily memory time quota for Consumption plans."
  default     = null
}

variable "zip_deploy_file" {
  type        = string
  description = "Optional local ZIP package path to deploy."
  default     = null
}

variable "cors" {
  description = "Optional CORS configuration."
  type = object({
    allowed_origins     = optional(list(string), [])
    support_credentials = optional(bool, false)
  })
  default = null
}

variable "app_service_logs" {
  description = "Optional filesystem application log settings."
  type = object({
    disk_quota_mb         = optional(number)
    retention_period_days = optional(number)
  })
  default = null
}

variable "ip_restrictions" {
  description = "Main-site IP restrictions."
  type = list(object({
    name                      = optional(string)
    priority                  = optional(number)
    action                    = optional(string, "Allow")
    description               = optional(string)
    ip_address                = optional(string)
    service_tag               = optional(string)
    virtual_network_subnet_id = optional(string)
    headers = optional(list(object({
      x_azure_fdid      = optional(list(string), [])
      x_fd_health_probe = optional(list(string), [])
      x_forwarded_for   = optional(list(string), [])
      x_forwarded_host  = optional(list(string), [])
    })))
  }))
  default  = []
  nullable = false
}

variable "scm_ip_restrictions" {
  description = "SCM/Kudu IP restrictions. These are ignored by Azure when scm_use_main_ip_restriction is true."
  type = list(object({
    name                      = optional(string)
    priority                  = optional(number)
    action                    = optional(string, "Allow")
    description               = optional(string)
    ip_address                = optional(string)
    service_tag               = optional(string)
    virtual_network_subnet_id = optional(string)
    headers = optional(list(object({
      x_azure_fdid      = optional(list(string), [])
      x_fd_health_probe = optional(list(string), [])
      x_forwarded_for   = optional(list(string), [])
      x_forwarded_host  = optional(list(string), [])
    })))
  }))
  default  = []
  nullable = false
}

variable "storage_mounts" {
  description = "Optional Azure Files mounts exposed to the Function App."
  type = list(object({
    name         = string
    account_name = string
    access_key   = string
    share_name   = string
    type         = string
    mount_path   = optional(string)
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for mount in var.storage_mounts :
      contains(["AzureFiles"], mount.type)
    ])
    error_message = "storage_mounts.type must be AzureFiles."
  }
}

variable "auth_settings" {
  description = "Legacy App Service authentication settings. Prefer auth_settings_v2 for new deployments."
  type = object({
    enabled                        = bool
    default_provider               = optional(string)
    issuer                         = optional(string)
    runtime_version                = optional(string)
    token_refresh_extension_hours  = optional(number)
    token_store_enabled            = optional(bool)
    unauthenticated_client_action  = optional(string)
    additional_login_parameters    = optional(map(string), {})
    allowed_external_redirect_urls = optional(list(string), [])
    active_directory = optional(object({
      client_id                  = string
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
      allowed_audiences          = optional(list(string), [])
    }))
  })
  default = null
}

variable "auth_settings_v2" {
  description = "App Service Authentication v2 settings with optional Microsoft Entra ID and custom OIDC providers."
  type = object({
    auth_enabled                            = optional(bool, true)
    runtime_version                         = optional(string, "~1")
    config_file_path                        = optional(string)
    default_provider                        = optional(string)
    excluded_paths                          = optional(list(string), [])
    forward_proxy_convention                = optional(string)
    forward_proxy_custom_host_header_name   = optional(string)
    forward_proxy_custom_scheme_header_name = optional(string)
    http_route_api_prefix                   = optional(string, "/.auth")
    require_authentication                  = optional(bool, true)
    require_https                           = optional(bool, true)
    unauthenticated_action                  = optional(string, "RedirectToLoginPage")
    active_directory_v2 = optional(object({
      client_id                            = string
      tenant_auth_endpoint                 = string
      allowed_applications                 = optional(list(string), [])
      allowed_audiences                    = optional(list(string), [])
      allowed_groups                       = optional(list(string), [])
      allowed_identities                   = optional(list(string), [])
      client_secret_certificate_thumbprint = optional(string)
      client_secret_setting_name           = optional(string)
      jwt_allowed_client_applications      = optional(list(string), [])
      jwt_allowed_groups                   = optional(list(string), [])
      login_parameters                     = optional(map(string), {})
      www_authentication_disabled          = optional(bool)
    }))
    custom_oidc_v2 = optional(list(object({
      name                          = string
      client_id                     = string
      openid_configuration_endpoint = string
      name_claim_type               = optional(string)
      scopes                        = optional(list(string), [])
    })), [])
    login = optional(object({
      allowed_external_redirect_urls    = optional(list(string), [])
      cookie_expiration_convention      = optional(string)
      cookie_expiration_time            = optional(string)
      logout_endpoint                   = optional(string)
      nonce_expiration_time             = optional(string)
      preserve_url_fragments_for_logins = optional(bool)
      token_refresh_extension_time      = optional(string)
      token_store_enabled               = optional(bool, true)
      token_store_path                  = optional(string)
      token_store_sas_setting_name      = optional(string)
      validate_nonce                    = optional(bool, true)
    }), {})
  })
  default = null
}

variable "backup" {
  description = "Optional backup configuration. The storage_account_url should include a SAS token."
  type = object({
    name                = string
    storage_account_url = string
    enabled             = optional(bool, true)
    schedule = object({
      frequency_interval       = number
      frequency_unit           = string
      keep_at_least_one_backup = optional(bool)
      retention_period_days    = optional(number)
      start_time               = optional(string)
    })
  })
  default = null

  validation {
    condition     = try(contains(["Day", "Hour"], var.backup.schedule.frequency_unit), true)
    error_message = "backup.schedule.frequency_unit must be Day or Hour."
  }
}

variable "sticky_settings_app_setting_names" {
  type        = list(string)
  description = "App setting names that should remain sticky across slot swaps."
  default     = []
}

variable "sticky_settings_connection_string_names" {
  type        = list(string)
  description = "Connection string names that should remain sticky across slot swaps."
  default     = []
}

variable "enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint for the Function App sites endpoint."
  default     = false

  validation {
    condition = !var.enable_private_endpoint || (
      trimspace(var.private_endpoint_subnet_id) != "" || (
        trimspace(var.private_endpoint_subnet_name) != "" &&
        trimspace(var.private_endpoint_vnet_name) != "" &&
        trimspace(var.private_endpoint_network_resource_group_name) != ""
      )
    )
    error_message = "When enable_private_endpoint is true, set private_endpoint_subnet_id or provide private_endpoint_subnet_name, private_endpoint_vnet_name, and private_endpoint_network_resource_group_name."
  }
}

variable "private_endpoint_name" {
  type        = string
  description = "Optional private endpoint name. Defaults to pep-<function-app-name>."
  default     = ""
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the private endpoint."
  default     = ""

  validation {
    condition = (
      trimspace(var.private_endpoint_subnet_id) == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/.+$", var.private_endpoint_subnet_id))
    )
    error_message = "private_endpoint_subnet_id must be empty or a valid subnet resource ID."
  }
}

variable "private_endpoint_subnet_name" {
  type        = string
  description = "Existing subnet name used for private endpoint subnet lookup."
  default     = ""
}

variable "private_endpoint_vnet_name" {
  type        = string
  description = "Existing virtual network name used for private endpoint subnet lookup."
  default     = ""
}

variable "private_endpoint_network_resource_group_name" {
  type        = string
  description = "Resource group containing the existing virtual network used for private endpoint subnet lookup."
  default     = ""
}

variable "private_endpoint_network_interface_name" {
  type        = string
  description = "Optional custom network interface name for the private endpoint."
  default     = ""
}

variable "private_service_connection_name" {
  type        = string
  description = "Optional private service connection name."
  default     = ""
}

variable "private_endpoint_manual_connection" {
  type        = bool
  description = "Whether the private endpoint connection should be manually approved."
  default     = false
}

variable "private_endpoint_manual_request_message" {
  type        = string
  description = "Optional approval request message for manual private endpoint connections."
  default     = ""
}

variable "private_endpoint_ip_configurations" {
  description = "Optional static private endpoint IP configurations."
  type = list(object({
    name               = string
    private_ip_address = string
    subresource_name   = optional(string, "sites")
    member_name        = optional(string, "sites")
  }))
  default  = []
  nullable = false
}

variable "private_dns_zone_id" {
  type        = string
  description = "Private DNS zone ID for the Function App private endpoint. Leave empty to resolve by name and resource group."
  default     = ""

  validation {
    condition = (
      trimspace(var.private_dns_zone_id) == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/privateDnsZones/.+$", var.private_dns_zone_id))
    )
    error_message = "private_dns_zone_id must be empty or a valid Private DNS zone resource ID."
  }
}

variable "private_dns_zone_ids" {
  type        = list(string)
  description = "Additional private DNS zone IDs associated with the private endpoint."
  default     = []

  validation {
    condition = alltrue([
      for value in var.private_dns_zone_ids :
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/privateDnsZones/.+$", value))
    ])
    error_message = "private_dns_zone_ids must contain valid Private DNS zone resource IDs."
  }
}

variable "private_dns_zone_name" {
  type        = string
  description = "Existing private DNS zone name used when private_dns_zone_id is empty."
  default     = ""
}

variable "private_dns_zone_names" {
  type        = list(string)
  description = "Additional private DNS zone names to look up in private_dns_zone_resource_group_name."
  default     = []
}

variable "private_dns_zone_resource_group_name" {
  type        = string
  description = "Resource group containing existing private DNS zones used when private DNS zone IDs are not supplied."
  default     = ""

  validation {
    condition = (
      length(compact(concat(
        trimspace(var.private_dns_zone_name) != "" ? [var.private_dns_zone_name] : [],
        var.private_dns_zone_names
      ))) == 0 ||
      trimspace(var.private_dns_zone_resource_group_name) != ""
    )
    error_message = "private_dns_zone_resource_group_name is required when private_dns_zone_name or private_dns_zone_names are supplied."
  }
}

variable "private_dns_zone_group_name" {
  type        = string
  description = "Private DNS zone group name for the private endpoint."
  default     = "default"
}

variable "private_endpoint_timeouts" {
  description = "Optional create/read/update/delete timeouts for the private endpoint."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "enable_diagnostics" {
  type        = bool
  description = "Whether to create a diagnostic setting for the Function App. Diagnostics are also enabled automatically when any diagnostic destination ID is supplied."
  default     = false
}

variable "diagnostic_setting_name" {
  type        = string
  description = "Optional diagnostic setting name. Defaults to <function-app-name>-diagnostic-setting."
  default     = ""
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID used for diagnostics."
  default     = ""

  validation {
    condition = (
      trimspace(var.log_analytics_workspace_id) == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.OperationalInsights/workspaces/.+$", var.log_analytics_workspace_id))
    )
    error_message = "log_analytics_workspace_id must be empty or a valid Log Analytics workspace resource ID."
  }
}

variable "log_analytics_destination_type" {
  type        = string
  description = "Diagnostic Log Analytics destination type."
  default     = null

  validation {
    condition     = try(contains(["AzureDiagnostics", "Dedicated"], var.log_analytics_destination_type), true)
    error_message = "log_analytics_destination_type must be null, AzureDiagnostics, or Dedicated."
  }
}

variable "diagnostic_storage_account_id" {
  type        = string
  description = "Optional Storage Account ID used to archive diagnostics."
  default     = ""

  validation {
    condition = (
      trimspace(var.diagnostic_storage_account_id) == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Storage/storageAccounts/.+$", var.diagnostic_storage_account_id))
    )
    error_message = "diagnostic_storage_account_id must be empty or a valid storage account resource ID."
  }
}

variable "diagnostic_eventhub_authorization_rule_id" {
  type        = string
  description = "Optional Event Hub authorization rule ID used to stream diagnostics."
  default     = ""
}

variable "diagnostic_eventhub_name" {
  type        = string
  description = "Optional Event Hub name used to stream diagnostics."
  default     = null
}

variable "diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable. Use AllLogs to emit the provider category group instead of individual categories."
  default = [
    "AppServiceHTTPLogs",
    "AppServiceConsoleLogs",
    "AppServiceAppLogs",
    "AppServiceAuditLogs",
    "AppServiceIPSecAuditLogs",
    "AppServicePlatformLogs"
  ]
}

variable "diagnostic_log_category_groups" {
  type        = list(string)
  description = "Diagnostic log category groups to enable, for example allLogs or audit."
  default     = []
}

variable "diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable."
  default     = ["AllMetrics"]
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources created by this module."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}
