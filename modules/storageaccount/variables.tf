variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the storage account will be deployed."

  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  type        = string
  description = "The Azure region where to deploy the resource. If empty, the resource group's location is used."
  default     = ""

  validation {
    condition     = var.location == "" || can(regex("^[a-z0-9-]+$", var.location))
    error_message = "location must be empty or a valid Azure region identifier."
  }
}

variable "name" {
  type        = string
  description = "Storage account name. If empty, the module auto-generates a compliant name."
  default     = ""

  validation {
    condition     = var.name == "" || can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "name must be empty or 3-24 lowercase alphanumeric characters."
  }
}

variable "account_tier" {
  type        = string
  description = "Defines the storage account tier."
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "account_tier must be either Standard or Premium."
  }
}

variable "account_replication_type" {
  type        = string
  description = "Defines the replication type for the storage account."
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "account_replication_type must be one of LRS, GRS, RAGRS, ZRS, GZRS, or RAGZRS."
  }
}

variable "account_kind" {
  type        = string
  description = "Defines the storage account kind."
  default     = "StorageV2"

  validation {
    condition     = contains(["StorageV2", "BlobStorage", "FileStorage", "BlockBlobStorage"], var.account_kind)
    error_message = "account_kind must be one of StorageV2, BlobStorage, FileStorage, or BlockBlobStorage."
  }
}

variable "access_tier" {
  type        = string
  description = "Access tier for Standard StorageV2 or BlobStorage accounts."
  default     = "Hot"

  validation {
    condition     = contains(["Hot", "Cool"], var.access_tier)
    error_message = "access_tier must be either Hot or Cool."
  }
}

variable "min_tls_version" {
  type        = string
  description = "The minimum supported TLS version."
  default     = "TLS1_2"

  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "min_tls_version must be one of TLS1_0, TLS1_1, or TLS1_2."
  }
}

variable "https_traffic_only_enabled" {
  type        = bool
  description = "Whether to require HTTPS traffic only."
  default     = true
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether the storage account public endpoint is reachable."
  default     = false
}

variable "allow_nested_items_to_be_public" {
  type        = bool
  description = "Whether nested blobs and containers can be made public."
  default     = false
}

variable "shared_access_key_enabled" {
  type        = bool
  description = "Whether shared access keys are enabled."
  default     = true
}

variable "default_to_oauth_authentication" {
  type        = bool
  description = "Whether Azure Storage should default requests to Microsoft Entra authorization instead of shared key where supported."
  default     = true
}

variable "cross_tenant_replication_enabled" {
  type        = bool
  description = "Whether cross-tenant replication is enabled."
  default     = false
}

variable "infrastructure_encryption_enabled" {
  type        = bool
  description = "Whether infrastructure encryption is enabled."
  default     = false
}

variable "is_hns_enabled" {
  type        = bool
  description = "Whether hierarchical namespace is enabled."
  default     = false
}

variable "nfsv3_enabled" {
  type        = bool
  description = "Whether NFSv3 is enabled."
  default     = false

  validation {
    condition     = !var.nfsv3_enabled || var.is_hns_enabled
    error_message = "nfsv3_enabled requires is_hns_enabled = true."
  }
}

variable "sftp_enabled" {
  type        = bool
  description = "Whether SFTP is enabled."
  default     = false

  validation {
    condition     = !var.sftp_enabled || (var.is_hns_enabled && var.local_user_enabled)
    error_message = "sftp_enabled requires both is_hns_enabled = true and local_user_enabled = true."
  }
}

variable "local_user_enabled" {
  type        = bool
  description = "Whether local users are enabled for the storage account."
  default     = false
}

variable "system_managed_identity_enabled" {
  type        = bool
  description = "Whether to enable a system-assigned managed identity."
  default     = false
}

variable "blob_properties" {
  type = object({
    versioning_enabled                     = optional(bool)
    change_feed_enabled                    = optional(bool)
    last_access_time_enabled               = optional(bool)
    delete_retention_policy_days           = optional(number)
    container_delete_retention_policy_days = optional(number)
    restore_policy_days                    = optional(number)
  })
  description = "Optional Blob service data protection settings for the storage account, including versioning, change feed, soft delete, container soft delete, last access time tracking, and point-in-time restore."
  default     = null

  validation {
    condition = var.blob_properties == null || (
      (
        try(var.blob_properties.delete_retention_policy_days, null) == null ||
        (
          try(var.blob_properties.delete_retention_policy_days, 0) >= 1 &&
          try(var.blob_properties.delete_retention_policy_days, 0) <= 365
        )
      ) &&
      (
        try(var.blob_properties.container_delete_retention_policy_days, null) == null ||
        (
          try(var.blob_properties.container_delete_retention_policy_days, 0) >= 1 &&
          try(var.blob_properties.container_delete_retention_policy_days, 0) <= 365
        )
      ) &&
      (
        try(var.blob_properties.restore_policy_days, null) == null ||
        (
          try(var.blob_properties.restore_policy_days, 0) >= 1 &&
          try(var.blob_properties.restore_policy_days, 0) <= 365
        )
      )
    )
    error_message = "blob_properties retention and restore day values must be between 1 and 365 when set."
  }
}

variable "managed_identity_role_assignments" {
  type = map(object({
    scope                = string
    role_definition_name = optional(string)
    role_definition_id   = optional(string)
  }))
  description = "Role assignments to apply to the system-assigned managed identity. Each item must set exactly one of role_definition_name or role_definition_id."
  default     = {}

  validation {
    condition = alltrue([
      for _, assignment in var.managed_identity_role_assignments :
      (
        (try(assignment.role_definition_name, null) != null && try(assignment.role_definition_id, null) == null) ||
        (try(assignment.role_definition_name, null) == null && try(assignment.role_definition_id, null) != null)
      )
    ])
    error_message = "Each managed_identity_role_assignments item must set exactly one of role_definition_name or role_definition_id."
  }

  validation {
    condition = alltrue([
      for _, assignment in var.managed_identity_role_assignments :
      can(regex("^/subscriptions/.+", assignment.scope))
    ])
    error_message = "Each managed_identity_role_assignments.scope must be a valid Azure resource scope."
  }
}

variable "app_admin_group" {
  type        = list(string)
  description = "List of Microsoft Entra group display names or object IDs that should receive Contributor access to the storage account. Prefer object IDs when display names are not unique."
  default     = null
}

variable "app_user_group" {
  type        = list(string)
  description = "List of Microsoft Entra group display names or object IDs that should receive Reader access to the storage account. Prefer object IDs when display names are not unique."
  default     = null
}

variable "enable_network_rules" {
  type        = bool
  description = "Whether to manage storage account network rules."
  default     = true
}

variable "network_rules_default_action" {
  type        = string
  description = "Default action for storage account network rules."
  default     = "Deny"

  validation {
    condition     = contains(["Allow", "Deny"], var.network_rules_default_action)
    error_message = "network_rules_default_action must be either Allow or Deny."
  }
}

variable "network_rules_bypass" {
  type        = list(string)
  description = "Traffic classes to bypass the network rules."
  default     = ["AzureServices"]

  validation {
    condition = alltrue([
      for value in var.network_rules_bypass :
      contains(["AzureServices", "Logging", "Metrics", "None"], value)
    ])
    error_message = "network_rules_bypass entries must be AzureServices, Logging, Metrics, or None."
  }
}

variable "network_rules_ip_rules" {
  type        = list(string)
  description = "IPv4 addresses or CIDR ranges allowed by network rules."
  default     = []

  validation {
    condition = alltrue([
      for value in var.network_rules_ip_rules :
      can(cidrhost(contains(value, "/") ? value : "${value}/32", 0))
    ])
    error_message = "network_rules_ip_rules entries must be valid IPv4 or IPv6 addresses or CIDR ranges."
  }
}

variable "network_rules_virtual_network_subnet_ids" {
  type        = list(string)
  description = "Subnet resource IDs allowed by network rules."
  default     = []

  validation {
    condition = alltrue([
      for subnet_id in var.network_rules_virtual_network_subnet_ids :
      can(regex("^/subscriptions/.+", subnet_id))
    ])
    error_message = "network_rules_virtual_network_subnet_ids must contain valid Azure subnet resource IDs."
  }
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the private endpoint. If set, subnet lookup inputs are ignored."
  default     = ""

  validation {
    condition     = var.private_endpoint_subnet_id == "" || can(regex("^/subscriptions/.+", var.private_endpoint_subnet_id))
    error_message = "private_endpoint_subnet_id must be empty or a valid Azure subnet resource ID."
  }
}

variable "private_endpoint_subnet_name" {
  type        = string
  description = "Existing subnet name used for private endpoint lookup when private_endpoint_subnet_id is not set."
  default     = null
}

variable "private_endpoint_vnet_name" {
  type        = string
  description = "Existing virtual network name used for private endpoint subnet lookup."
  default     = null
}

variable "private_endpoint_network_resource_group_name" {
  type        = string
  description = "Resource group containing the virtual network used for private endpoint subnet lookup."
  default     = null
}

variable "private_endpoint_subresource_names" {
  type        = list(string)
  description = "Storage private endpoint subresources to create. Valid values: blob, dfs, file, queue, table, web."
  default     = []

  validation {
    condition = alltrue([
      for name in var.private_endpoint_subresource_names :
      contains(["blob", "dfs", "file", "queue", "table", "web"], lower(name))
    ])
    error_message = "private_endpoint_subresource_names must contain only blob, dfs, file, queue, table, or web."
  }
}

variable "private_dns_zone_ids" {
  type        = map(string)
  description = "Optional private DNS zone IDs keyed by private endpoint subresource name."
  default     = {}

  validation {
    condition = alltrue([
      for _, zone_id in var.private_dns_zone_ids :
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/privateDnsZones/.+$", zone_id))
    ])
    error_message = "private_dns_zone_ids values must be valid Azure Private DNS Zone resource IDs."
  }
}

variable "private_dns_zone_names" {
  type        = map(string)
  description = "Optional private DNS zone names keyed by private endpoint subresource name. Used with private_dns_zone_resource_group_name when private_dns_zone_ids are not supplied for those keys."
  default     = {}
}

variable "private_dns_zone_resource_group_name" {
  type        = string
  description = "Resource group containing the private DNS zones used for storage account private endpoints."
  default     = null
}

variable "enable_diagnostics" {
  type        = bool
  description = "Enable diagnostic settings for the storage account."
  default     = false
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace resource ID for diagnostics. Required when enable_diagnostics is true."
  default     = ""

  validation {
    condition     = !var.enable_diagnostics || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.OperationalInsights/workspaces/.+$", var.log_analytics_workspace_id))
    error_message = "log_analytics_workspace_id must be a valid workspace resource ID when enable_diagnostics is true."
  }
}

variable "diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable."
  default     = ["StorageRead", "StorageWrite", "StorageDelete"]

  validation {
    condition = alltrue([
      for value in var.diagnostic_log_categories :
      contains(["StorageRead", "StorageWrite", "StorageDelete"], value)
    ])
    error_message = "diagnostic_log_categories must contain only supported Storage Account log categories."
  }
}

variable "diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable."
  default     = ["Transaction"]

  validation {
    condition = alltrue([
      for value in var.diagnostic_metric_categories :
      contains(["Transaction"], value)
    ])
    error_message = "diagnostic_metric_categories must contain only supported Storage Account metric categories."
  }
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

check "storageaccount_input_consistency" {
  assert {
    condition     = var.system_managed_identity_enabled || length(var.managed_identity_role_assignments) == 0
    error_message = "managed_identity_role_assignments requires system_managed_identity_enabled = true."
  }

  assert {
    condition = (
      var.blob_properties == null ||
      try(var.blob_properties.restore_policy_days, null) == null ||
      (
        try(var.blob_properties.versioning_enabled, false) &&
        try(var.blob_properties.change_feed_enabled, false) &&
        try(var.blob_properties.delete_retention_policy_days, 0) > try(var.blob_properties.restore_policy_days, 0)
      )
    )
    error_message = "blob_properties.restore_policy_days requires versioning_enabled = true, change_feed_enabled = true, and delete_retention_policy_days greater than restore_policy_days."
  }

  assert {
    condition = length(var.private_endpoint_subresource_names) == 0 || (
      trimspace(var.private_endpoint_subnet_id) != "" || (
        try(trimspace(var.private_endpoint_subnet_name), "") != "" &&
        try(trimspace(var.private_endpoint_vnet_name), "") != "" &&
        try(trimspace(var.private_endpoint_network_resource_group_name), "") != ""
      )
    )
    error_message = "When private endpoints are requested, set private_endpoint_subnet_id or provide private_endpoint_subnet_name, private_endpoint_vnet_name, and private_endpoint_network_resource_group_name."
  }

  assert {
    condition = (
      length(var.private_endpoint_subresource_names) == 0 ||
      length(var.private_dns_zone_ids) == 0 ||
      alltrue([
        for name in var.private_endpoint_subresource_names :
        lookup(var.private_dns_zone_ids, lower(name), null) == null || trimspace(lookup(var.private_dns_zone_ids, lower(name), "")) != ""
      ])
    )
    error_message = "private_dns_zone_ids keys must match the lowercase private endpoint subresource names when provided."
  }

  assert {
    condition = (
      length(var.private_dns_zone_names) == 0 ||
      alltrue([
        for name in var.private_endpoint_subresource_names :
        lookup(var.private_dns_zone_names, lower(name), null) == null || trimspace(lookup(var.private_dns_zone_names, lower(name), "")) != ""
      ])
    )
    error_message = "private_dns_zone_names keys must match the lowercase private endpoint subresource names when provided."
  }

  assert {
    condition = (
      length(var.private_dns_zone_names) == 0 ||
      try(trimspace(var.private_dns_zone_resource_group_name), "") != ""
    )
    error_message = "private_dns_zone_resource_group_name must be set when private_dns_zone_names is provided."
  }

  assert {
    condition     = !var.sftp_enabled || var.shared_access_key_enabled
    error_message = "sftp_enabled requires shared_access_key_enabled = true."
  }

  assert {
    condition     = !var.enable_diagnostics || trimspace(var.log_analytics_workspace_id) != ""
    error_message = "log_analytics_workspace_id must be set when enable_diagnostics is true."
  }
}
