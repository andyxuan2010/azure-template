variable "resource_group_name" {
  type        = string
  description = "Resource group where the SQL server and database are deployed."

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into module resources. The module only reads the resource group when this is true or location is empty."
  default     = true
}

variable "inherited_resource_group_tags" {
  type        = map(string)
  description = "Optional already-known resource group tags to use when inherit_resource_group_tags is true. When null, the module reads the target resource group."
  default     = null
}

variable "workload" {
  type        = string
  default     = "project"
  description = "Workload identifier used in tagging."

  validation {
    condition     = length(trimspace(var.workload)) > 0
    error_message = "workload cannot be empty."
  }
}

variable "location" {
  type        = string
  description = "Optional Azure region for SQL resources. Leave empty to use the target resource group's location."
  default     = ""

  validation {
    condition     = trimspace(var.location) == "" || can(regex("^[a-z0-9-]+$", trimspace(var.location)))
    error_message = "location must be empty or a valid Azure region identifier."
  }
}

variable "server_name" {
  type        = string
  description = "Azure SQL logical server name. Leave empty to auto-generate a standardized globally unique name."
  default     = ""

  validation {
    condition = trimspace(var.server_name) == "" || (
      length(trimspace(var.server_name)) >= 1 &&
      length(trimspace(var.server_name)) <= 63 &&
      can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", trimspace(var.server_name)))
    )
    error_message = "When provided, server_name must be 1-63 characters, use lowercase letters, numbers, or hyphens, and start and end with an alphanumeric character."
  }
}

variable "database_name" {
  type        = string
  description = "Azure SQL database name. Leave empty to auto-generate a standardized name."
  default     = ""

  validation {
    condition = trimspace(var.database_name) == "" || (
      length(trimspace(var.database_name)) >= 1 &&
      length(trimspace(var.database_name)) <= 128 &&
      can(regex("^[A-Za-z0-9_-]+$", trimspace(var.database_name)))
    )
    error_message = "When provided, database_name must be 1-128 characters and use letters, numbers, underscores, or hyphens."
  }
}

variable "name_prefix" {
  type        = string
  description = "Prefix used when the SQL server name is generated."
  default     = "sql"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,15}$", var.name_prefix))
    error_message = "name_prefix must be 1-15 characters using lowercase letters, digits, or hyphens."
  }
}

variable "database_name_prefix" {
  type        = string
  description = "Prefix used when the SQL database name is generated."
  default     = "sqldb"

  validation {
    condition     = can(regex("^[A-Za-z0-9_-]{1,20}$", var.database_name_prefix))
    error_message = "database_name_prefix must be 1-20 characters using letters, digits, underscores, or hyphens."
  }
}

variable "workload_name" {
  type        = string
  description = "Optional workload segment used when names are generated."
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
  description = "Whether generated SQL names include app_env."
  default     = true
}

variable "location_code" {
  type        = string
  description = "Optional short location code used when SQL names are generated."
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
  description = "Whether generated SQL names should include a random suffix."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags merged with standardized module tags."
  default     = {}

  validation {
    condition = alltrue([
      for key, value in var.tags : trimspace(key) != "" && trimspace(value) != ""
    ])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

variable "server_version" {
  type        = string
  description = "Azure SQL logical server version."
  default     = "12.0"

  validation {
    condition     = contains(["12.0"], var.server_version)
    error_message = "server_version must be 12.0."
  }
}

variable "minimum_tls_version" {
  type        = string
  description = "Minimum TLS version enforced by the SQL server."
  default     = "1.2"

  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "minimum_tls_version must be 1.0, 1.1, or 1.2."
  }
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled on the SQL server. Prefer false with private endpoints for production."
  default     = false
}

variable "connection_policy" {
  type        = string
  description = "SQL server connection policy."
  default     = "Default"

  validation {
    condition     = contains(["Default", "Proxy", "Redirect"], var.connection_policy)
    error_message = "connection_policy must be Default, Proxy, or Redirect."
  }
}

variable "outbound_network_restriction_enabled" {
  type        = bool
  description = "Whether outbound network access from the SQL server is restricted."
  default     = false
}

variable "express_vulnerability_assessment_enabled" {
  type        = bool
  description = "Whether to enable Express Vulnerability Assessment on the SQL server."
  default     = false
}

variable "transparent_data_encryption_key_vault_key_id" {
  type        = string
  description = "Optional Key Vault key ID used as the server-level transparent data encryption protector."
  default     = ""

  validation {
    condition     = trimspace(var.transparent_data_encryption_key_vault_key_id) == "" || can(regex("^https://.+\\.vault\\.azure\\.net/keys/.+", trimspace(var.transparent_data_encryption_key_vault_key_id)))
    error_message = "transparent_data_encryption_key_vault_key_id must be empty or a valid Key Vault key URI."
  }
}

variable "system_assigned_identity_enabled" {
  type        = bool
  description = "Whether to enable a system-assigned managed identity on the SQL server."
  default     = true
}

variable "identity_ids" {
  type        = list(string)
  description = "Optional user-assigned managed identity IDs for the SQL server."
  default     = []

  validation {
    condition = alltrue([
      for value in var.identity_ids :
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.ManagedIdentity/userAssignedIdentities/.+$", value))
    ])
    error_message = "identity_ids must contain valid user-assigned managed identity resource IDs."
  }
}

variable "primary_user_assigned_identity_id" {
  type        = string
  description = "Optional primary user-assigned managed identity ID for server-level customer-managed keys."
  default     = ""

  validation {
    condition     = trimspace(var.primary_user_assigned_identity_id) == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.ManagedIdentity/userAssignedIdentities/.+$", trimspace(var.primary_user_assigned_identity_id)))
    error_message = "primary_user_assigned_identity_id must be empty or a valid user-assigned managed identity resource ID."
  }
}

variable "admin_username" {
  type        = string
  description = "SQL administrator username. Prefer Key Vault-backed values for production."
  default     = null
  nullable    = true
  sensitive   = true

  validation {
    condition     = var.admin_username == null || trimspace(var.admin_username) == "" || can(regex("^[a-zA-Z][a-zA-Z0-9_@.-]{0,127}$", trimspace(var.admin_username)))
    error_message = "admin_username must be null, empty, or start with a letter and be 1-128 characters."
  }
}

variable "admin_password" {
  type        = string
  description = "SQL administrator password. Prefer Key Vault-backed values for production."
  default     = null
  nullable    = true
  sensitive   = true

  validation {
    condition     = var.admin_password == null || trimspace(var.admin_password) == "" || length(trimspace(var.admin_password)) >= 8
    error_message = "admin_password must be null, empty, or at least 8 characters long."
  }
}

variable "admin_credentials_key_vault_id" {
  type        = string
  description = "Optional Key Vault resource ID containing SQL admin username and password secrets."
  default     = ""

  validation {
    condition     = trimspace(var.admin_credentials_key_vault_id) == "" || can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.KeyVault/vaults/[^/]+$", trimspace(var.admin_credentials_key_vault_id)))
    error_message = "admin_credentials_key_vault_id must be empty or a valid Azure Key Vault resource ID."
  }
}

variable "admin_username_secret_name" {
  type        = string
  description = "Key Vault secret name containing the SQL admin username. Used only when admin_username is not set."
  default     = "azure-user"
}

variable "admin_password_secret_name" {
  type        = string
  description = "Key Vault secret name containing the SQL admin password. Used only when admin_password is not set."
  default     = "azure-password"
}

variable "azuread_administrator_enabled" {
  type        = bool
  description = "Whether to configure a Microsoft Entra administrator on the SQL server."
  default     = true
}

variable "ad_admin_login_name" {
  type        = string
  description = "Microsoft Entra administrator display name or login username for the SQL server."
  default     = ""
}

variable "ad_admin_object_id" {
  type        = string
  description = "Microsoft Entra object ID for the SQL server administrator."
  default     = ""

  validation {
    condition     = trimspace(var.ad_admin_object_id) == "" || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", trimspace(var.ad_admin_object_id)))
    error_message = "ad_admin_object_id must be empty or a valid UUID."
  }
}

variable "azuread_admin_tenant_id" {
  type        = string
  description = "Optional Microsoft Entra tenant ID for the SQL server administrator."
  default     = ""

  validation {
    condition     = trimspace(var.azuread_admin_tenant_id) == "" || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", trimspace(var.azuread_admin_tenant_id)))
    error_message = "azuread_admin_tenant_id must be empty or a valid UUID."
  }
}

variable "azuread_authentication_only" {
  type        = bool
  description = "Whether to enable Microsoft Entra-only authentication. Requires a Microsoft Entra administrator."
  default     = false
}

variable "sku_name" {
  type        = string
  description = "SKU for the SQL database, such as Basic, S0, GP_Gen5_2, BC_Gen5_2, or HS_Gen5_2."
  default     = "S0"

  validation {
    condition     = can(regex("^[A-Za-z0-9_]+$", var.sku_name))
    error_message = "sku_name must contain only letters, numbers, and underscores."
  }
}

variable "use_free_limit" {
  type        = bool
  description = "Whether the Azure SQL Database should use Azure SQL free monthly limits. This is intended for eligible General Purpose serverless databases."
  default     = false
}

variable "free_limit_exhaustion_behavior" {
  type        = string
  description = "Behavior when Azure SQL free monthly limits are exhausted. AutoPause pauses the database for the rest of the month; BillOverUsage keeps it online and bills overage."
  default     = "AutoPause"

  validation {
    condition     = contains(["AutoPause", "BillOverUsage"], var.free_limit_exhaustion_behavior)
    error_message = "free_limit_exhaustion_behavior must be AutoPause or BillOverUsage."
  }
}

variable "max_size_gb" {
  type        = number
  description = "Maximum size of the database in GB."
  default     = 32

  validation {
    condition     = var.max_size_gb > 0 && var.max_size_gb <= 1048576
    error_message = "max_size_gb must be greater than 0 and less than or equal to 1048576."
  }
}

variable "collation" {
  type        = string
  description = "Database collation setting."
  default     = "SQL_Latin1_General_CP1_CI_AS"

  validation {
    condition     = can(regex("^[A-Za-z0-9_]+$", var.collation))
    error_message = "collation must be a valid SQL Server collation string."
  }
}

variable "zone_redundant" {
  type        = bool
  description = "Whether the database is zone redundant."
  default     = false
}

variable "backup_storage_redundancy" {
  type        = string
  description = "Backup storage redundancy for the SQL database."
  default     = "Local"

  validation {
    condition     = contains(["Local", "Zone", "Geo", "GeoZone"], var.backup_storage_redundancy)
    error_message = "backup_storage_redundancy must be one of Local, Zone, Geo, or GeoZone."
  }
}

variable "transparent_data_encryption_enabled" {
  type        = bool
  description = "Whether transparent data encryption is enabled on the database."
  default     = true
}

variable "database_transparent_data_encryption_key_vault_key_id" {
  type        = string
  description = "Optional Key Vault key ID used for database-level transparent data encryption."
  default     = ""

  validation {
    condition     = trimspace(var.database_transparent_data_encryption_key_vault_key_id) == "" || can(regex("^https://.+\\.vault\\.azure\\.net/keys/.+", trimspace(var.database_transparent_data_encryption_key_vault_key_id)))
    error_message = "database_transparent_data_encryption_key_vault_key_id must be empty or a valid Key Vault key URI."
  }
}

variable "database_transparent_data_encryption_key_automatic_rotation_enabled" {
  type        = bool
  description = "Whether automatic key rotation is enabled for the database TDE key."
  default     = null
}

variable "geo_backup_enabled" {
  type        = bool
  description = "Whether geo backups are enabled for the database."
  default     = true
}

variable "auto_pause_delay_in_minutes" {
  type        = number
  description = "Serverless auto-pause delay in minutes. Set -1 to disable auto-pause. Only valid for serverless SKUs."
  default     = null
}

variable "min_capacity" {
  type        = number
  description = "Minimum capacity for serverless databases."
  default     = null
}

variable "elastic_pool_id" {
  type        = string
  description = "Optional elastic pool ID for the database."
  default     = ""

  validation {
    condition     = trimspace(var.elastic_pool_id) == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Sql/servers/.+/elasticPools/.+$", trimspace(var.elastic_pool_id)))
    error_message = "elastic_pool_id must be empty or a valid Azure SQL elastic pool resource ID."
  }
}

variable "enclave_type" {
  type        = string
  description = "Optional enclave type for Always Encrypted with secure enclaves."
  default     = ""

  validation {
    condition     = contains(["", "Default", "VBS"], var.enclave_type)
    error_message = "enclave_type must be empty, Default, or VBS."
  }
}

variable "license_type" {
  type        = string
  description = "Optional database license type."
  default     = ""

  validation {
    condition     = contains(["", "LicenseIncluded", "BasePrice"], var.license_type)
    error_message = "license_type must be empty, LicenseIncluded, or BasePrice."
  }
}

variable "maintenance_configuration_name" {
  type        = string
  description = "Optional maintenance configuration name."
  default     = ""
}

variable "ledger_enabled" {
  type        = bool
  description = "Whether ledger is enabled on the database."
  default     = false
}

variable "read_replica_count" {
  type        = number
  description = "Optional read replica count for supported database SKUs."
  default     = null
}

variable "read_scale" {
  type        = bool
  description = "Optional read scale setting for supported database SKUs."
  default     = null
}

variable "create_mode" {
  type        = string
  description = "Database create mode."
  default     = "Default"

  validation {
    condition = contains([
      "Copy",
      "Default",
      "OnlineSecondary",
      "PointInTimeRestore",
      "Recovery",
      "Restore",
      "RestoreExternalBackup",
      "RestoreExternalBackupSecondary",
      "RestoreLongTermRetentionBackup",
      "Secondary"
    ], var.create_mode)
    error_message = "create_mode must be a supported Azure SQL database create mode."
  }
}

variable "creation_source_database_id" {
  type        = string
  description = "Source database ID used by copy and restore create modes."
  default     = ""
}

variable "recover_database_id" {
  type        = string
  description = "Database ID used by Recovery create mode."
  default     = ""
}

variable "restore_dropped_database_id" {
  type        = string
  description = "Dropped database ID used by Restore create mode."
  default     = ""
}

variable "restore_long_term_retention_backup_id" {
  type        = string
  description = "Long-term retention backup ID used by RestoreLongTermRetentionBackup create mode."
  default     = ""
}

variable "restore_point_in_time" {
  type        = string
  description = "Restore point timestamp used by point-in-time restore scenarios."
  default     = ""
}

variable "sample_name" {
  type        = string
  description = "Optional sample database name."
  default     = ""
}

variable "secondary_type" {
  type        = string
  description = "Optional secondary type for replica scenarios."
  default     = ""
}

variable "database_identity_ids" {
  type        = list(string)
  description = "Optional user-assigned managed identity IDs for the SQL database."
  default     = []

  validation {
    condition = alltrue([
      for value in var.database_identity_ids :
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.ManagedIdentity/userAssignedIdentities/.+$", value))
    ])
    error_message = "database_identity_ids must contain valid user-assigned managed identity resource IDs."
  }
}

variable "database_import" {
  description = "Optional import block used to create the database from a BACPAC."
  type = object({
    administrator_login          = string
    administrator_login_password = string
    authentication_type          = string
    storage_account_id           = optional(string)
    storage_key                  = string
    storage_key_type             = string
    storage_uri                  = string
  })
  default   = null
  nullable  = true
  sensitive = true

  validation {
    condition     = var.database_import == null ? true : contains(["ADPassword", "Sql"], var.database_import.authentication_type)
    error_message = "database_import.authentication_type must be ADPassword or Sql."
  }
}

variable "backup_retention_days" {
  type        = number
  description = "Short-term backup retention period in days."
  default     = 7

  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 35
    error_message = "backup_retention_days must be between 1 and 35."
  }
}

variable "backup_interval_in_hours" {
  type        = number
  description = "Short-term backup interval in hours."
  default     = 12

  validation {
    condition     = contains([12, 24], var.backup_interval_in_hours)
    error_message = "backup_interval_in_hours must be 12 or 24."
  }
}

variable "enable_long_term_retention" {
  type        = bool
  description = "Whether to enable long-term retention backups."
  default     = false
}

variable "long_term_retention_policy" {
  description = "Long-term retention policy using week, month, and year counts. Values are converted to ISO 8601 durations."
  type = object({
    weekly_retention          = optional(number, 0)
    monthly_retention         = optional(number, 0)
    yearly_retention          = optional(number, 0)
    week_of_year              = optional(number)
    immutable_backups_enabled = optional(bool)
  })
  default = {}

  validation {
    condition = alltrue([
      var.long_term_retention_policy.weekly_retention >= 0 && var.long_term_retention_policy.weekly_retention <= 520,
      var.long_term_retention_policy.monthly_retention >= 0 && var.long_term_retention_policy.monthly_retention <= 120,
      var.long_term_retention_policy.yearly_retention >= 0 && var.long_term_retention_policy.yearly_retention <= 10,
      coalesce(try(var.long_term_retention_policy.week_of_year, null), 1) >= 1 && coalesce(try(var.long_term_retention_policy.week_of_year, null), 1) <= 52
    ])
    error_message = "LTR values must be weekly 0-520, monthly 0-120, yearly 0-10, and week_of_year 1-52 when set."
  }
}

variable "allow_azure_services" {
  type        = bool
  description = "Whether to add the Azure SQL firewall rule that allows Azure services and resources to access the server public endpoint."
  default     = false
}

variable "firewall_rules" {
  description = "Optional SQL server firewall rules keyed by rule name."
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for name, rule in var.firewall_rules :
      trimspace(name) != "" &&
      can(regex("^((25[0-5]|2[0-4][0-9]|1?[0-9]{1,2})\\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9]{1,2})$", rule.start_ip_address)) &&
      can(regex("^((25[0-5]|2[0-4][0-9]|1?[0-9]{1,2})\\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9]{1,2})$", rule.end_ip_address))
    ])
    error_message = "Each firewall_rules entry must have a non-empty name and valid IPv4 start_ip_address/end_ip_address values."
  }
}

variable "enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint for the SQL server."
  default     = true
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the SQL private endpoint. Alternatively use the subnet lookup inputs."
  default     = ""

  validation {
    condition     = trimspace(var.private_endpoint_subnet_id) == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/.+$", trimspace(var.private_endpoint_subnet_id)))
    error_message = "private_endpoint_subnet_id must be empty or a valid subnet resource ID."
  }
}

variable "private_endpoint_subnet_name" {
  type        = string
  description = "Subnet name used to look up the private endpoint subnet when private_endpoint_subnet_id is empty."
  default     = ""
}

variable "private_endpoint_vnet_name" {
  type        = string
  description = "Virtual network name used to look up the private endpoint subnet."
  default     = ""
}

variable "private_endpoint_network_resource_group_name" {
  type        = string
  description = "Resource group containing the virtual network used for private endpoint subnet lookup."
  default     = ""
}

variable "private_endpoint_name" {
  type        = string
  description = "Optional private endpoint name. Defaults to pep-<server-name>."
  default     = ""
}

variable "private_service_connection_name" {
  type        = string
  description = "Optional private service connection name. Defaults to psc-<server-name>."
  default     = ""
}

variable "private_endpoint_network_interface_name" {
  type        = string
  description = "Optional custom network interface name for the private endpoint."
  default     = ""
}

variable "private_endpoint_manual_connection" {
  type        = bool
  description = "Whether the private endpoint connection is manually approved."
  default     = false
}

variable "private_endpoint_manual_request_message" {
  type        = string
  description = "Optional request message for manual private endpoint approvals."
  default     = ""
}

variable "private_endpoint_ip_configurations" {
  description = "Optional static IP configurations for the private endpoint."
  type = list(object({
    name               = string
    private_ip_address = string
    member_name        = optional(string, "sqlServer")
    subresource_name   = optional(string, "sqlServer")
  }))
  default = []
}

variable "private_dns_zone_ids" {
  type        = list(string)
  description = "Private DNS zone IDs to associate with the SQL private endpoint."
  default     = []

  validation {
    condition = alltrue([
      for value in var.private_dns_zone_ids :
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/privateDnsZones/.+$", value))
    ])
    error_message = "private_dns_zone_ids must contain valid private DNS zone resource IDs."
  }
}

variable "private_dns_zone_name" {
  type        = string
  description = "Optional private DNS zone name to look up and associate with the private endpoint, for example privatelink.database.windows.net."
  default     = ""
}

variable "private_dns_zone_names" {
  type        = list(string)
  description = "Optional private DNS zone names to look up and associate with the private endpoint."
  default     = []
}

variable "private_dns_zone_resource_group_name" {
  type        = string
  description = "Resource group used for private DNS zone name lookups."
  default     = ""
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
  default  = null
  nullable = true
}

variable "enable_threat_detection" {
  type        = bool
  description = "Whether to enable Microsoft Defender for SQL threat detection for the server."
  default     = false
}

variable "enable_database_threat_detection" {
  type        = bool
  description = "Whether to enable database-level threat detection policy."
  default     = false
}

variable "threat_detection_disabled_alerts" {
  type        = list(string)
  description = "Threat detection alerts to disable."
  default     = []
}

variable "threat_detection_email_account_admins" {
  type        = bool
  description = "Whether threat detection alerts are emailed to subscription/account admins."
  default     = true
}

variable "threat_detection_email_addresses" {
  type        = list(string)
  description = "Email addresses that receive threat detection alerts."
  default     = []
}

variable "threat_detection_retention_days" {
  type        = number
  description = "Threat detection retention days. Defaults to audit_retention_days when null."
  default     = null
}

variable "threat_detection_storage_endpoint" {
  type        = string
  description = "Optional storage endpoint for server threat detection alerts."
  default     = ""
}

variable "threat_detection_storage_account_access_key" {
  type        = string
  description = "Optional storage account access key for server threat detection alerts."
  default     = ""
  sensitive   = true
}

variable "enable_audit" {
  type        = bool
  description = "Whether to enable server-level auditing."
  default     = true
}

variable "enable_database_audit" {
  type        = bool
  description = "Whether to enable database-level auditing."
  default     = false
}

variable "audit_retention_days" {
  type        = number
  description = "Audit retention in days. Set 0 for indefinite retention."
  default     = 30

  validation {
    condition     = var.audit_retention_days == 0 || (var.audit_retention_days >= 1 && var.audit_retention_days <= 2147483647)
    error_message = "audit_retention_days must be 0 or between 1 and 2147483647."
  }
}

variable "audit_log_monitoring_enabled" {
  type        = bool
  description = "Whether server-level auditing sends audit events to Azure Monitor."
  default     = true
}

variable "audit_actions_and_groups" {
  type        = list(string)
  description = "Optional audit action groups for server-level auditing."
  default     = []
}

variable "audit_predicate_expression" {
  type        = string
  description = "Optional predicate expression for server-level auditing."
  default     = ""
}

variable "audit_storage_endpoint" {
  type        = string
  description = "Optional storage endpoint for server-level auditing."
  default     = ""
}

variable "audit_storage_account_access_key" {
  type        = string
  description = "Optional storage account access key for server-level auditing."
  default     = ""
  sensitive   = true
}

variable "audit_storage_account_access_key_is_secondary" {
  type        = bool
  description = "Whether the secondary storage key is used for server-level auditing."
  default     = false
}

variable "audit_storage_account_subscription_id" {
  type        = string
  description = "Optional subscription ID for the server-level audit storage account."
  default     = ""
}

variable "database_audit_retention_days" {
  type        = number
  description = "Database-level audit retention in days. Defaults to audit_retention_days when null."
  default     = null
}

variable "database_audit_log_monitoring_enabled" {
  type        = bool
  description = "Whether database-level auditing sends audit events to Azure Monitor."
  default     = true
}

variable "database_audit_storage_endpoint" {
  type        = string
  description = "Optional storage endpoint for database-level auditing."
  default     = ""
}

variable "database_audit_storage_account_access_key" {
  type        = string
  description = "Optional storage account access key for database-level auditing."
  default     = ""
  sensitive   = true
}

variable "database_audit_storage_account_access_key_is_secondary" {
  type        = bool
  description = "Whether the secondary storage key is used for database-level auditing."
  default     = false
}

variable "enable_diagnostics" {
  type        = bool
  description = "Whether to create diagnostic settings for the SQL database."
  default     = false
}

variable "diagnostic_setting_name" {
  type        = string
  description = "Optional diagnostic setting name. Defaults to diag-<database-name>."
  default     = ""
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Optional Log Analytics workspace ID for diagnostics."
  default     = ""

  validation {
    condition     = trimspace(var.log_analytics_workspace_id) == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.OperationalInsights/workspaces/.+$", trimspace(var.log_analytics_workspace_id)))
    error_message = "log_analytics_workspace_id must be empty or a valid Log Analytics workspace resource ID."
  }
}

variable "log_analytics_destination_type" {
  type        = string
  description = "Log Analytics destination type for diagnostics."
  default     = "Dedicated"

  validation {
    condition     = contains(["AzureDiagnostics", "Dedicated"], var.log_analytics_destination_type)
    error_message = "log_analytics_destination_type must be AzureDiagnostics or Dedicated."
  }
}

variable "diagnostic_storage_account_id" {
  type        = string
  description = "Optional storage account ID for diagnostics."
  default     = ""
}

variable "diagnostic_eventhub_authorization_rule_id" {
  type        = string
  description = "Optional Event Hub authorization rule ID for diagnostics."
  default     = ""
}

variable "diagnostic_eventhub_name" {
  type        = string
  description = "Optional Event Hub name for diagnostics."
  default     = null
}

variable "diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable for the SQL database. Use AllLogs to enable the provider category group."
  default = [
    "SQLInsights",
    "AutomaticTuning",
    "QueryStoreRuntimeStatistics",
    "QueryStoreWaitStatistics",
    "Errors",
  ]

  validation {
    condition     = alltrue([for value in var.diagnostic_log_categories : trimspace(value) != ""])
    error_message = "diagnostic_log_categories cannot contain empty values."
  }
}

variable "diagnostic_log_category_groups" {
  type        = list(string)
  description = "Diagnostic log category groups to enable for the SQL database."
  default     = []
}

variable "diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable for the SQL database."
  default     = ["AllMetrics"]

  validation {
    condition     = alltrue([for value in var.diagnostic_metric_categories : trimspace(value) != ""])
    error_message = "diagnostic_metric_categories cannot contain empty values."
  }
}

variable "app_admin_group" {
  type        = list(string)
  description = "Microsoft Entra group display names or object IDs that receive the admin Azure RBAC role at SQL server scope."
  default     = []
}

variable "app_user_group" {
  type        = list(string)
  description = "Microsoft Entra group display names or object IDs that receive the user Azure RBAC role at SQL server scope."
  default     = []
}

variable "app_admin_role_definition_name" {
  type        = string
  description = "Azure role assigned to app_admin_group principals at SQL server scope."
  default     = "SQL Server Contributor"
}

variable "app_user_role_definition_name" {
  type        = string
  description = "Azure role assigned to app_user_group principals at SQL server scope."
  default     = "Reader"
}

variable "role_assignments" {
  description = "Additional role assignments scoped to the SQL server, SQL database, or an explicit Azure resource ID."
  type = map(object({
    principal_id                           = string
    principal_type                         = optional(string)
    role_definition_id                     = optional(string)
    role_definition_name                   = optional(string)
    name                                   = optional(string)
    description                            = optional(string)
    condition                              = optional(string)
    condition_version                      = optional(string)
    delegated_managed_identity_resource_id = optional(string)
    skip_service_principal_aad_check       = optional(bool, false)
    scope                                  = optional(string, "server")
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

variable "failover_group" {
  description = "Optional SQL failover group configuration. Provide a partner server ID to enable."
  type = object({
    partner_server_id                         = string
    name                                      = optional(string)
    database_ids                              = optional(list(string), [])
    readonly_endpoint_failover_policy_enabled = optional(bool)
    partner_server_location                   = optional(string)
    partner_server_role                       = optional(string)
    read_write_endpoint_failover_policy = optional(object({
      mode          = optional(string, "Automatic")
      grace_minutes = optional(number, 60)
    }), {})
    tags = optional(map(string), {})
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })
  default  = null
  nullable = true
}

variable "server_timeouts" {
  description = "Optional create/read/update/delete timeouts for the SQL server."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default  = null
  nullable = true
}

variable "database_timeouts" {
  description = "Optional create/read/update/delete timeouts for the SQL database."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default  = null
  nullable = true
}

check "sqldb_input_consistency" {
  assert {
    condition     = !local.diagnostics_enabled || local.diagnostic_destination_enabled
    error_message = "At least one diagnostic destination must be set when diagnostics are enabled."
  }

  assert {
    condition     = !var.enable_private_endpoint || try(trimspace(local.private_endpoint_subnet_id_resolved), "") != ""
    error_message = "private_endpoint_subnet_id or the private endpoint subnet lookup inputs must be set when enable_private_endpoint is true."
  }

  assert {
    condition     = length(local.private_dns_zone_names_effective) == 0 || trimspace(var.private_dns_zone_resource_group_name) != ""
    error_message = "private_dns_zone_resource_group_name must be set when private DNS zone names are supplied."
  }

  assert {
    condition     = !local.azuread_admin_enabled || (trimspace(var.ad_admin_login_name) != "" && trimspace(var.ad_admin_object_id) != "")
    error_message = "ad_admin_login_name and ad_admin_object_id are required when the Microsoft Entra administrator is enabled."
  }

  assert {
    condition     = !var.azuread_authentication_only || local.azuread_admin_enabled
    error_message = "azuread_authentication_only requires the Microsoft Entra administrator to be enabled."
  }

  assert {
    condition     = var.azuread_authentication_only || (local.admin_username_effective != "" && local.admin_password_effective != "")
    error_message = "SQL administrator credentials are required unless azuread_authentication_only is true."
  }

  assert {
    condition     = var.sku_name != "Basic" || var.max_size_gb <= 2
    error_message = "Basic tier supports a maximum database size of 2 GB."
  }

  assert {
    condition     = !contains(["prod"], var.app_env) || !var.enable_long_term_retention || local.diagnostics_enabled
    error_message = "Production long-term retention requires diagnostics to be enabled."
  }

  assert {
    condition = !var.enable_long_term_retention || (
      try(var.long_term_retention_policy.weekly_retention, 0) > 0 ||
      try(var.long_term_retention_policy.monthly_retention, 0) > 0 ||
      try(var.long_term_retention_policy.yearly_retention, 0) > 0
    )
    error_message = "When enable_long_term_retention is true, set at least one non-zero long_term_retention_policy value."
  }

  assert {
    condition     = !var.allow_azure_services || var.public_network_access_enabled
    error_message = "allow_azure_services requires public_network_access_enabled to be true."
  }

  assert {
    condition     = !var.enable_audit || var.audit_log_monitoring_enabled || local.audit_storage_endpoint != null
    error_message = "Server auditing requires audit_log_monitoring_enabled or audit_storage_endpoint."
  }

  assert {
    condition     = !var.enable_database_audit || var.database_audit_log_monitoring_enabled || local.database_audit_storage_endpoint != null
    error_message = "Database auditing requires database_audit_log_monitoring_enabled or database_audit_storage_endpoint."
  }

  assert {
    condition     = var.database_transparent_data_encryption_key_automatic_rotation_enabled != true || local.database_tde_key_vault_key_id != null
    error_message = "database_transparent_data_encryption_key_automatic_rotation_enabled requires database_transparent_data_encryption_key_vault_key_id."
  }
}
