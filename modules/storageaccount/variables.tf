variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the storage account will be deployed."

  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
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

variable "name_prefix" {
  type        = string
  description = "Prefix used when the storage account name is generated. Non-alphanumeric characters are removed."
  default     = "st"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,10}$", var.name_prefix))
    error_message = "name_prefix must be 1-10 characters using letters, digits, or hyphens."
  }
}

variable "workload_name" {
  type        = string
  description = "Optional workload segment used when the storage account name is generated."
  default     = ""

  validation {
    condition     = var.workload_name == "" || can(regex("^[a-zA-Z0-9-]{1,30}$", var.workload_name))
    error_message = "workload_name must be empty or 1-30 characters using letters, digits, or hyphens."
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
  description = "Whether generated storage account names include app_env."
  default     = true
}

variable "location_code" {
  type        = string
  description = "Optional short location code used when the storage account name is generated."
  default     = ""

  validation {
    condition     = var.location_code == "" || can(regex("^[a-z0-9]{2,10}$", var.location_code))
    error_message = "location_code must be empty or 2-10 lowercase letters or digits."
  }
}

variable "instance" {
  type        = string
  description = "Optional instance segment used when generated names do not use a random suffix."
  default     = "001"

  validation {
    condition     = var.instance == "" || can(regex("^[a-zA-Z0-9]{1,10}$", var.instance))
    error_message = "instance must be empty or 1-10 alphanumeric characters."
  }
}

variable "use_random_suffix" {
  type        = bool
  description = "Whether generated storage account names should include a random suffix."
  default     = true
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

variable "edge_zone" {
  type        = string
  description = "Optional Azure edge zone where the storage account should be created."
  default     = null
}

variable "dns_endpoint_type" {
  type        = string
  description = "DNS endpoint type for the storage account."
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "AzureDnsZone"], var.dns_endpoint_type)
    error_message = "dns_endpoint_type must be Standard or AzureDnsZone."
  }
}

variable "allowed_copy_scope" {
  type        = string
  description = "Restricts permitted copy sources. Valid values are null, AAD, or PrivateLink."
  default     = null

  validation {
    condition     = var.allowed_copy_scope == null ? true : contains(["AAD", "PrivateLink"], var.allowed_copy_scope)
    error_message = "allowed_copy_scope must be null, AAD, or PrivateLink."
  }
}

variable "large_file_share_enabled" {
  type        = bool
  description = "Whether large file shares are enabled for the storage account."
  default     = null
}

variable "queue_encryption_key_type" {
  type        = string
  description = "Encryption key type for Queue service."
  default     = "Service"

  validation {
    condition     = contains(["Service", "Account"], var.queue_encryption_key_type)
    error_message = "queue_encryption_key_type must be Service or Account."
  }
}

variable "table_encryption_key_type" {
  type        = string
  description = "Encryption key type for Table service."
  default     = "Service"

  validation {
    condition     = contains(["Service", "Account"], var.table_encryption_key_type)
    error_message = "table_encryption_key_type must be Service or Account."
  }
}

variable "provisioned_billing_model_version" {
  type        = string
  description = "Optional provisioned billing model version for supported premium storage account types."
  default     = null
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

variable "identity_ids" {
  type        = list(string)
  description = "User-assigned managed identity IDs to attach to the storage account."
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for identity_id in var.identity_ids :
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.ManagedIdentity/userAssignedIdentities/.+$", identity_id))
    ])
    error_message = "identity_ids must contain valid user-assigned managed identity resource IDs."
  }
}

variable "customer_managed_key" {
  description = "Optional customer-managed key configuration. Set one of key_vault_key_id or managed_hsm_key_id. user_assigned_identity_id is required by Azure when using a user-assigned identity for CMK access."
  type = object({
    key_vault_key_id          = optional(string)
    managed_hsm_key_id        = optional(string)
    user_assigned_identity_id = optional(string)
  })
  default = null

  validation {
    condition = var.customer_managed_key == null ? true : (
      (try(trimspace(var.customer_managed_key.key_vault_key_id), "") != "") !=
      (try(trimspace(var.customer_managed_key.managed_hsm_key_id), "") != "")
    )
    error_message = "customer_managed_key must set exactly one of key_vault_key_id or managed_hsm_key_id."
  }
}

variable "custom_domain" {
  description = "Optional custom domain assigned to the storage account."
  type = object({
    name          = string
    use_subdomain = optional(bool, false)
  })
  default = null
}

variable "blob_properties" {
  type = object({
    versioning_enabled                               = optional(bool)
    change_feed_enabled                              = optional(bool)
    change_feed_retention_in_days                    = optional(number)
    default_service_version                          = optional(string)
    last_access_time_enabled                         = optional(bool)
    delete_retention_policy_days                     = optional(number)
    delete_retention_policy_permanent_delete_enabled = optional(bool)
    container_delete_retention_policy_days           = optional(number)
    restore_policy_days                              = optional(number)
    cors_rules = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })), [])
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

variable "role_assignments" {
  description = "Additional role assignments to create at the storage account scope, keyed by a stable name."
  type = map(object({
    principal_id                           = string
    role_definition_name                   = optional(string)
    role_definition_id                     = optional(string)
    principal_type                         = optional(string)
    description                            = optional(string)
    name                                   = optional(string)
    condition                              = optional(string)
    condition_version                      = optional(string)
    delegated_managed_identity_resource_id = optional(string)
    skip_service_principal_aad_check       = optional(bool, false)
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for assignment in var.role_assignments :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", assignment.principal_id))
    ])
    error_message = "Each role_assignments principal_id must be a valid GUID."
  }

  validation {
    condition = alltrue([
      for assignment in var.role_assignments :
      (try(trimspace(assignment.role_definition_name), "") != "") != (try(trimspace(assignment.role_definition_id), "") != "")
    ])
    error_message = "Each role_assignments entry must set exactly one of role_definition_name or role_definition_id."
  }

  validation {
    condition = alltrue([
      for assignment in var.role_assignments :
      assignment.principal_type == null ? true : contains(["User", "Group", "ServicePrincipal", "ForeignGroup"], assignment.principal_type)
    ])
    error_message = "role_assignments principal_type must be null, User, Group, ServicePrincipal, or ForeignGroup."
  }
}

variable "grant_current_terraform_service_principal_storage_roles" {
  type        = bool
  description = "Whether to assign Contributor plus full storage data-plane roles for Blob, File, Queue, and Table services to the current Terraform execution identity at the storage account scope."
  default     = true
}

variable "app_admin_group" {
  type        = list(string)
  description = "List of Microsoft Entra group display names or object IDs that should receive Contributor plus Blob, File, Queue, and Table data-plane access to the storage account. Prefer object IDs when display names are not unique."
  default     = []

  validation {
    condition = alltrue([
      for value in var.app_admin_group : trimspace(value) != ""
    ])
    error_message = "app_admin_group must not contain empty values."
  }
}

variable "app_user_group" {
  type        = list(string)
  description = "List of Microsoft Entra group display names or object IDs that should receive Reader access to the storage account. Prefer object IDs when display names are not unique."
  default     = []

  validation {
    condition = alltrue([
      for value in var.app_user_group : trimspace(value) != ""
    ])
    error_message = "app_user_group must not contain empty values."
  }
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

variable "network_rules_private_link_access" {
  type = list(object({
    endpoint_resource_id = string
    endpoint_tenant_id   = optional(string)
  }))
  description = "Private Link resources that are allowed to access the storage account through network rules."
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for item in var.network_rules_private_link_access :
      can(regex("^/subscriptions/.+", item.endpoint_resource_id))
    ])
    error_message = "network_rules_private_link_access endpoint_resource_id values must be valid Azure resource IDs."
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

variable "private_endpoint_name_prefix" {
  type        = string
  description = "Prefix used for generated private endpoint names."
  default     = "pep"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,20}$", var.private_endpoint_name_prefix))
    error_message = "private_endpoint_name_prefix must be 1-20 characters using letters, digits, or hyphens."
  }
}

variable "private_service_connection_name_prefix" {
  type        = string
  description = "Prefix used for generated private service connection names."
  default     = "psc"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,20}$", var.private_service_connection_name_prefix))
    error_message = "private_service_connection_name_prefix must be 1-20 characters using letters, digits, or hyphens."
  }
}

variable "enable_diagnostics" {
  type        = bool
  description = "Enable diagnostic settings for the storage account. Diagnostics are also enabled when at least one diagnostic destination is supplied."
  default     = false
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Optional Log Analytics workspace resource ID for diagnostics."
  default     = ""

  validation {
    condition     = trimspace(var.log_analytics_workspace_id) == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.OperationalInsights/workspaces/.+$", var.log_analytics_workspace_id))
    error_message = "log_analytics_workspace_id must be empty or a valid Log Analytics workspace resource ID."
  }
}

variable "log_analytics_destination_type" {
  type        = string
  description = "Destination type for Log Analytics diagnostics."
  default     = "Dedicated"

  validation {
    condition     = contains(["Dedicated", "AzureDiagnostics"], var.log_analytics_destination_type)
    error_message = "log_analytics_destination_type must be Dedicated or AzureDiagnostics."
  }
}

variable "diagnostic_storage_account_id" {
  type        = string
  description = "Optional Storage Account resource ID for diagnostic archive."
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
  type        = string
  description = "Optional Event Hub authorization rule resource ID for diagnostics."
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
  type        = string
  description = "Optional Event Hub name for diagnostics when using an Event Hub destination."
  default     = null
}

variable "diagnostic_setting_name" {
  type        = string
  description = "Optional diagnostic setting name. When empty, the module uses <storage-account-name>-diagnostic-setting."
  default     = ""
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

variable "static_website" {
  description = "Optional static website configuration."
  type = object({
    index_document     = optional(string)
    error_404_document = optional(string)
  })
  default = null
}

variable "routing" {
  description = "Optional routing configuration for Microsoft and internet endpoint publishing."
  type = object({
    choice                      = optional(string, "MicrosoftRouting")
    publish_internet_endpoints  = optional(bool, false)
    publish_microsoft_endpoints = optional(bool, false)
  })
  default = null

  validation {
    condition     = var.routing == null ? true : contains(["MicrosoftRouting", "InternetRouting"], var.routing.choice)
    error_message = "routing.choice must be MicrosoftRouting or InternetRouting."
  }
}

variable "sas_policy" {
  description = "Optional shared access signature expiration policy."
  type = object({
    expiration_action = optional(string, "Log")
    expiration_period = string
  })
  default = null

  validation {
    condition     = var.sas_policy == null ? true : contains(["Log", "Block"], var.sas_policy.expiration_action)
    error_message = "sas_policy.expiration_action must be Log or Block."
  }
}

variable "immutability_policy" {
  description = "Optional account-level immutability policy."
  type = object({
    allow_protected_append_writes = optional(bool, false)
    period_since_creation_in_days = number
    state                         = optional(string, "Unlocked")
  })
  default = null

  validation {
    condition     = var.immutability_policy == null ? true : contains(["Disabled", "Unlocked", "Locked"], var.immutability_policy.state)
    error_message = "immutability_policy.state must be Disabled, Unlocked, or Locked."
  }
}

variable "azure_files_authentication" {
  description = "Optional Azure Files authentication configuration."
  type = object({
    directory_type                 = string
    default_share_level_permission = optional(string)
    active_directory = optional(object({
      domain_guid         = string
      domain_name         = string
      domain_sid          = string
      forest_name         = string
      netbios_domain_name = string
      storage_sid         = string
    }))
  })
  default = null

  validation {
    condition     = var.azure_files_authentication == null ? true : contains(["AADDS", "AD", "AADKERB"], var.azure_files_authentication.directory_type)
    error_message = "azure_files_authentication.directory_type must be AADDS, AD, or AADKERB."
  }
}

variable "queue_properties" {
  description = "Optional Queue service properties."
  type = object({
    cors_rules = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })), [])
    logging = optional(object({
      delete                = bool
      read                  = bool
      write                 = bool
      version               = string
      retention_policy_days = optional(number)
    }))
    hour_metrics = optional(object({
      enabled               = bool
      version               = string
      include_apis          = optional(bool)
      retention_policy_days = optional(number)
    }))
    minute_metrics = optional(object({
      enabled               = bool
      version               = string
      include_apis          = optional(bool)
      retention_policy_days = optional(number)
    }))
  })
  default = null
}

variable "share_properties" {
  description = "Optional Azure Files service properties."
  type = object({
    cors_rules = optional(list(object({
      allowed_headers    = list(string)
      allowed_methods    = list(string)
      allowed_origins    = list(string)
      exposed_headers    = list(string)
      max_age_in_seconds = number
    })), [])
    retention_policy_days = optional(number)
    smb = optional(object({
      authentication_types            = optional(list(string))
      channel_encryption_type         = optional(list(string))
      kerberos_ticket_encryption_type = optional(list(string))
      multichannel_enabled            = optional(bool)
      versions                        = optional(list(string))
    }))
  })
  default = null
}

variable "containers" {
  description = "Storage containers to create, keyed by container name."
  type = map(object({
    container_access_type             = optional(string, "private")
    default_encryption_scope          = optional(string)
    encryption_scope_override_enabled = optional(bool)
    metadata                          = optional(map(string), {})
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for name, container in var.containers :
      can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", name)) &&
      contains(["private", "blob", "container"], container.container_access_type)
    ])
    error_message = "containers keys must be valid container names and container_access_type must be private, blob, or container."
  }
}

variable "file_shares" {
  description = "Azure Files shares to create, keyed by share name."
  type = map(object({
    quota            = optional(number, 100)
    access_tier      = optional(string)
    enabled_protocol = optional(string, "SMB")
    metadata         = optional(map(string), {})
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for name, share in var.file_shares :
      can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", name)) &&
      share.quota >= 1 &&
      contains(["SMB", "NFS"], share.enabled_protocol)
    ])
    error_message = "file_shares keys must be valid share names, quota must be at least 1, and enabled_protocol must be SMB or NFS."
  }
}

variable "queues" {
  description = "Storage queues to create, keyed by queue name."
  type = map(object({
    metadata = optional(map(string), {})
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for name, queue in var.queues :
      can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", name))
    ])
    error_message = "queues keys must be valid queue names."
  }
}

variable "tables" {
  description = "Storage tables to create, keyed by table name."
  type        = map(object({}))
  default     = {}
  nullable    = false

  validation {
    condition = alltrue([
      for name, table in var.tables :
      can(regex("^[A-Za-z][A-Za-z0-9]{2,62}$", name))
    ])
    error_message = "tables keys must be valid table names."
  }
}

variable "timeouts" {
  description = "Optional timeouts for storage account create, read, update, and delete operations."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
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
    condition = var.customer_managed_key == null || (
      var.system_managed_identity_enabled ||
      length(var.identity_ids) > 0
    )
    error_message = "customer_managed_key requires system_managed_identity_enabled = true or at least one user-assigned identity in identity_ids."
  }
}
