variable "resource_group_name" {
  type        = string
  description = "Existing resource group name where the Logic App Standard will be created."

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  type        = string
  description = "Azure region for the Logic App Standard. Leave empty to use the resource group location."
  default     = ""

  validation {
    condition     = trimspace(var.location) == "" || can(regex("^[a-z0-9-]+$", trimspace(var.location)))
    error_message = "location must be empty or a valid Azure region identifier."
  }
}

variable "name" {
  type        = string
  description = "Logic App Standard name."

  validation {
    condition     = can(regex("^[a-z0-9-]{2,60}$", trimspace(var.name)))
    error_message = "name must be 2-60 characters and contain only lowercase letters, numbers, or hyphens."
  }
}

variable "service_plan_id" {
  type        = string
  description = "App Service Plan ID used to host the Logic App Standard."

  validation {
    condition     = trimspace(var.service_plan_id) != ""
    error_message = "service_plan_id cannot be empty."
  }

  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Web/server[Ff]arms/.+$", var.service_plan_id))
    error_message = "service_plan_id must be a valid App Service Plan resource ID."
  }
}

variable "storage_account_name" {
  type        = string
  description = "Existing storage account name used by the Logic App Standard."

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", trimspace(var.storage_account_name)))
    error_message = "storage_account_name must be 3-24 lowercase alphanumeric characters."
  }
}

variable "storage_account_resource_group_name" {
  type        = string
  description = "Resource group containing the existing storage account. Leave empty to use resource_group_name."
  default     = ""
}

variable "storage_account_share_name" {
  type        = string
  description = "Optional Azure Files share name used by the Logic App Standard content store. Leave empty to let Azure manage it."
  default     = null

  validation {
    condition     = try(trimspace(var.storage_account_share_name), "") == "" || can(regex("^[a-z0-9](?:[a-z0-9-]{1,61}[a-z0-9])?$", trimspace(var.storage_account_share_name)))
    error_message = "storage_account_share_name must be null, empty, or a valid Azure Files share name."
  }
}

variable "app_settings" {
  type        = map(string)
  description = "Additional application settings for the Logic App Standard."
  default     = {}
  nullable    = false
}

variable "connection_strings" {
  description = "Optional Logic App Standard connection strings."
  type = list(object({
    name  = string
    value = string
    type  = optional(string, "Custom")
  }))
  default  = []
  nullable = false
}

variable "app_admin_group" {
  type        = list(string)
  description = "List of Microsoft Entra group display names or object IDs that should receive Contributor access to the Logic App Standard."
  default     = []
}

variable "app_user_group" {
  type        = list(string)
  description = "List of Microsoft Entra group display names or object IDs that should receive Reader access to the Logic App Standard."
  default     = []
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
      try(trimspace(var.virtual_network_subnet_id), "") != "" || (
        try(trimspace(var.vnet_integration_subnet_name), "") == "" &&
        try(trimspace(var.vnet_integration_vnet_name), "") == "" &&
        try(trimspace(var.vnet_integration_network_resource_group_name), "") == ""
        ) || (
        try(trimspace(var.vnet_integration_subnet_name), "") != "" &&
        try(trimspace(var.vnet_integration_vnet_name), "") != "" &&
        try(trimspace(var.vnet_integration_network_resource_group_name), "") != ""
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

variable "enabled" {
  type        = bool
  description = "Whether the Logic App Standard is enabled."
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

variable "client_affinity_enabled" {
  type        = bool
  description = "Whether client affinity is enabled."
  default     = false
}

variable "client_certificate_mode" {
  type        = string
  description = "Client certificate mode. Value must be Required, Optional, or OptionalInteractiveUser."
  default     = "Required"

  validation {
    condition     = contains(["Required", "Optional", "OptionalInteractiveUser"], var.client_certificate_mode)
    error_message = "client_certificate_mode must be Required, Optional, or OptionalInteractiveUser."
  }
}

variable "ftp_publish_basic_authentication_enabled" {
  type        = bool
  description = "Whether basic authentication is enabled for FTP publishing."
  default     = false
}

variable "scm_basic_auth_publishing_credentials_enabled" {
  type        = bool
  description = "Whether SCM/Kudu basic auth publishing credentials are enabled."
  default     = false
}

variable "always_on" {
  type        = bool
  description = "Whether the Logic App Standard should always remain warm."
  default     = true
}

variable "ftps_state" {
  type        = string
  description = "FTPS state for the Logic App Standard."
  default     = "Disabled"

  validation {
    condition     = contains(["AllAllowed", "FtpsOnly", "Disabled"], var.ftps_state)
    error_message = "ftps_state must be AllAllowed, FtpsOnly, or Disabled."
  }
}

variable "http2_enabled" {
  type        = bool
  description = "Whether HTTP/2 is enabled."
  default     = true
}

variable "minimum_tls_version" {
  type        = string
  description = "Minimum TLS version for the Logic App Standard."
  default     = "1.2"

  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "minimum_tls_version must be 1.0, 1.1, or 1.2."
  }
}

variable "use_32_bit_worker_process" {
  type        = bool
  description = "Whether to use a 32-bit worker process."
  default     = false
}

variable "health_check_path" {
  type        = string
  description = "Optional health check path."
  default     = null
}

variable "runtime_scale_monitoring_enabled" {
  type        = bool
  description = "Whether runtime scale monitoring is enabled."
  default     = false
}

variable "websockets_enabled" {
  type        = bool
  description = "Whether websockets are enabled."
  default     = false
}

variable "use_extension_bundle" {
  type        = bool
  description = "Whether to enable extension bundles for the Logic App Standard runtime."
  default     = null
  nullable    = true
}

variable "bundle_version" {
  type        = string
  description = "Optional extension bundle version."
  default     = null
}

variable "logic_app_version" {
  type        = string
  description = "Optional runtime version for the Logic App Standard."
  default     = null
}

variable "enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint for the Logic App Standard sites endpoint."
  default     = false

  validation {
    condition = !var.enable_private_endpoint || (
      try(trimspace(var.private_endpoint_subnet_id), "") != "" || (
        try(trimspace(var.private_endpoint_subnet_name), "") != "" &&
        try(trimspace(var.private_endpoint_vnet_name), "") != "" &&
        try(trimspace(var.private_endpoint_network_resource_group_name), "") != ""
      )
    )
    error_message = "When enable_private_endpoint is true, set private_endpoint_subnet_id or provide private_endpoint_subnet_name, private_endpoint_vnet_name, and private_endpoint_network_resource_group_name."
  }
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

variable "private_dns_zone_id" {
  type        = string
  description = "Private DNS zone ID for the Logic App Standard private endpoint. Leave empty to resolve by name and resource group."
  default     = ""

  validation {
    condition = (
      trimspace(var.private_dns_zone_id) == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/privateDnsZones/.+$", var.private_dns_zone_id))
    )
    error_message = "private_dns_zone_id must be empty or a valid Private DNS zone resource ID."
  }

  validation {
    condition = (
      try(trimspace(var.private_dns_zone_id), "") != "" || (
        try(trimspace(var.private_dns_zone_name), "") == "" &&
        try(trimspace(var.private_dns_zone_resource_group_name), "") == ""
        ) || (
        try(trimspace(var.private_dns_zone_name), "") != "" &&
        try(trimspace(var.private_dns_zone_resource_group_name), "") != ""
      )
    )
    error_message = "For private DNS zone lookup, provide private_dns_zone_id or both private_dns_zone_name and private_dns_zone_resource_group_name."
  }
}

variable "private_dns_zone_name" {
  type        = string
  description = "Existing private DNS zone name used when private_dns_zone_id is empty."
  default     = ""
}

variable "private_dns_zone_resource_group_name" {
  type        = string
  description = "Resource group containing the existing private DNS zone used when private_dns_zone_id is empty."
  default     = ""
}

variable "enable_diagnostics" {
  type        = bool
  description = "Whether to create a diagnostic setting for the Logic App Standard."
  default     = false
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID used when diagnostics are enabled."
  default     = ""

  validation {
    condition     = !var.enable_diagnostics || trimspace(var.log_analytics_workspace_id) != ""
    error_message = "log_analytics_workspace_id must be provided when enable_diagnostics is true."
  }

  validation {
    condition = (
      trimspace(var.log_analytics_workspace_id) == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.OperationalInsights/workspaces/.+$", var.log_analytics_workspace_id))
    )
    error_message = "log_analytics_workspace_id must be empty or a valid Log Analytics workspace resource ID."
  }
}

variable "diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable."
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
      for value in var.diagnostic_log_categories :
      contains([
        "AppServiceHTTPLogs",
        "AppServiceConsoleLogs",
        "AppServiceAppLogs",
        "AppServiceAuditLogs",
        "AppServiceIPSecAuditLogs",
        "AppServicePlatformLogs"
      ], value)
    ])
    error_message = "diagnostic_log_categories contains unsupported values for this module."
  }
}

variable "diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable."
  default     = ["AllMetrics"]

  validation {
    condition = alltrue([
      for value in var.diagnostic_metric_categories :
      contains(["AllMetrics"], value)
    ])
    error_message = "diagnostic_metric_categories must contain only supported metric categories."
  }
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
