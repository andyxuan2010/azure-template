variable "resource_group_name" {
  type        = string
  description = "Resource group where the Cosmos DB account will be deployed."

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
  description = "Optional plan-known resource group tags supplied by the root composition. When null and inherit_resource_group_tags is true, the module falls back to reading the resource group."
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
  description = "Optional Azure region for the Cosmos DB account. Leave empty to use the target resource group's location."
  default     = ""
}

variable "name" {
  type        = string
  description = "Cosmos DB account name. Leave empty to auto-generate a standardized globally unique name."
  default     = ""

  validation {
    condition = trimspace(var.name) == "" || (
      length(trimspace(var.name)) >= 3 &&
      length(trimspace(var.name)) <= 44 &&
      can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", trimspace(var.name)))
    )
    error_message = "When provided, name must be 3-44 characters, use lowercase letters, numbers, or hyphens, and start and end with an alphanumeric character."
  }
}

variable "name_prefix" {
  type        = string
  description = "Prefix used when the Cosmos DB account name is generated."
  default     = "cosmos"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,15}$", var.name_prefix))
    error_message = "name_prefix must be 1-15 characters using lowercase letters, digits, or hyphens."
  }
}

variable "workload_name" {
  type        = string
  description = "Optional workload segment used when the Cosmos DB account name is generated."
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
  description = "Whether generated Cosmos DB names include app_env."
  default     = true
}

variable "location_code" {
  type        = string
  description = "Optional short location code used when the Cosmos DB account name is generated."
  default     = ""
}

variable "instance" {
  type        = string
  description = "Optional instance segment used when generated names do not use a random suffix."
  default     = "001"
}

variable "use_random_suffix" {
  type        = bool
  description = "Whether generated Cosmos DB names should include a random suffix."
  default     = true
}

variable "offer_type" {
  type        = string
  description = "Cosmos DB account offer type."
  default     = "Standard"

  validation {
    condition     = var.offer_type == "Standard"
    error_message = "offer_type must be Standard."
  }
}

variable "kind" {
  type        = string
  description = "Cosmos DB account kind. GlobalDocumentDB is the SQL API default."
  default     = "GlobalDocumentDB"

  validation {
    condition     = contains(["GlobalDocumentDB", "MongoDB", "Parse"], var.kind)
    error_message = "kind must be GlobalDocumentDB, MongoDB, or Parse."
  }
}

variable "minimal_tls_version" {
  type        = string
  description = "Minimum TLS version for the Cosmos DB account."
  default     = "Tls12"
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled."
  default     = false
}

variable "local_authentication_disabled" {
  type        = bool
  description = "Whether key-based local authentication is disabled. Prefer Entra ID RBAC for production."
  default     = true
}

variable "automatic_failover_enabled" {
  type        = bool
  description = "Whether automatic failover is enabled for multi-region accounts."
  default     = true
}

variable "multiple_write_locations_enabled" {
  type        = bool
  description = "Whether writes are enabled in every configured region."
  default     = false
}

variable "free_tier_enabled" {
  type        = bool
  description = "Whether Cosmos DB free tier is enabled."
  default     = false
}

variable "analytical_storage_enabled" {
  type        = bool
  description = "Whether analytical storage is enabled."
  default     = false
}

variable "analytical_storage_schema_type" {
  type        = string
  description = "Analytical storage schema type when analytical storage is enabled."
  default     = "WellDefined"

  validation {
    condition     = contains(["WellDefined", "FullFidelity"], var.analytical_storage_schema_type)
    error_message = "analytical_storage_schema_type must be WellDefined or FullFidelity."
  }
}

variable "zone_redundant" {
  type        = bool
  description = "Zone redundancy for the default geo location when geo_locations is not provided."
  default     = false
}

variable "geo_locations" {
  description = "Geo-replication locations. If omitted, the account is created in location with failover priority 0."
  type = list(object({
    location          = string
    failover_priority = number
    zone_redundant    = optional(bool, false)
  }))
  default  = []
  nullable = false

  validation {
    condition     = length(var.geo_locations) == 0 || contains([for item in var.geo_locations : item.failover_priority], 0)
    error_message = "geo_locations must include one location with failover_priority 0."
  }
}

variable "consistency_policy" {
  description = "Cosmos DB consistency policy."
  type = object({
    consistency_level       = optional(string, "Session")
    max_interval_in_seconds = optional(number)
    max_staleness_prefix    = optional(number)
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["BoundedStaleness", "Eventual", "Session", "Strong", "ConsistentPrefix"], var.consistency_policy.consistency_level)
    error_message = "consistency_policy.consistency_level must be BoundedStaleness, Eventual, Session, Strong, or ConsistentPrefix."
  }
}

variable "backup" {
  description = "Cosmos DB backup policy."
  type = object({
    type                = optional(string, "Continuous")
    tier                = optional(string)
    interval_in_minutes = optional(number)
    retention_in_hours  = optional(number)
    storage_redundancy  = optional(string)
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["Continuous", "Periodic"], var.backup.type)
    error_message = "backup.type must be Continuous or Periodic."
  }
}

variable "capabilities" {
  type        = list(string)
  description = "Optional Cosmos DB capabilities, for example EnableServerless or EnableMongo."
  default     = []
}

variable "total_throughput_limit" {
  type        = number
  description = "Optional account-level total throughput limit. Use -1 for no limit."
  default     = null
}

variable "ip_range_filter" {
  type        = list(string)
  description = "Optional public IP range filters."
  default     = []
}

variable "network_acl_bypass_for_azure_services" {
  type        = bool
  description = "Whether Azure services can bypass network ACLs."
  default     = false
}

variable "network_acl_bypass_ids" {
  type        = list(string)
  description = "Optional resource IDs that can bypass network ACLs."
  default     = []
}

variable "virtual_network_rules" {
  description = "Optional subnet rules for service endpoint access."
  type = list(object({
    id                                   = string
    ignore_missing_vnet_service_endpoint = optional(bool, false)
  }))
  default  = []
  nullable = false
}

variable "system_assigned_identity_enabled" {
  type        = bool
  description = "Whether to enable a system-assigned managed identity."
  default     = true
}

variable "identity_ids" {
  type        = list(string)
  description = "Optional user-assigned managed identity IDs."
  default     = []
}

variable "default_identity_type" {
  type        = string
  description = "Optional default identity type used by Cosmos DB when customer-managed keys are configured."
  default     = ""
}

variable "key_vault_key_id" {
  type        = string
  description = "Optional Key Vault key ID for customer-managed encryption."
  default     = ""
}

variable "sql_databases" {
  description = "SQL databases keyed by database name."
  type = map(object({
    throughput       = optional(number)
    autoscale_max_ru = optional(number)
  }))
  default  = {}
  nullable = false
}

variable "sql_containers" {
  description = "SQL containers keyed by container name."
  type = map(object({
    database_name          = string
    partition_key_paths    = list(string)
    partition_key_kind     = optional(string, "Hash")
    partition_key_version  = optional(number, 2)
    throughput             = optional(number)
    autoscale_max_ru       = optional(number)
    default_ttl            = optional(number)
    analytical_storage_ttl = optional(number)
    conflict_resolution_policy = optional(object({
      mode                          = string
      conflict_resolution_path      = optional(string)
      conflict_resolution_procedure = optional(string)
    }))
    indexing_policy = optional(object({
      indexing_mode = optional(string, "consistent")
      included_paths = optional(list(object({
        path = string
      })), [])
      excluded_paths = optional(list(object({
        path = string
      })), [])
      composite_indexes = optional(list(list(object({
        path  = string
        order = string
      }))), [])
      spatial_indexes = optional(list(object({
        path  = string
        types = optional(list(string))
      })), [])
    }))
    unique_keys = optional(list(object({
      paths = list(string)
    })), [])
  }))
  default  = {}
  nullable = false
}

variable "sql_role_definitions" {
  description = "Optional custom SQL data-plane role definitions keyed by role name."
  type = map(object({
    assignable_scopes = list(string)
    data_actions      = list(string)
  }))
  default  = {}
  nullable = false
}

variable "sql_role_assignments" {
  description = "Optional Cosmos DB SQL data-plane role assignments keyed by assignment name. role_definition_id may be a built-in or custom role definition resource ID."
  type = map(object({
    principal_id       = string
    role_definition_id = string
    scope              = optional(string)
  }))
  default  = {}
  nullable = false
}

variable "app_admin_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that receive the admin role on the Cosmos DB account."
  default     = []
}

variable "app_user_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that receive the reader role on the Cosmos DB account."
  default     = []
}

variable "app_admin_role_definition_name" {
  type        = string
  description = "Azure role assigned to app_admin_group principals at the Cosmos DB account scope."
  default     = "Cosmos DB Account Contributor"
}

variable "app_user_role_definition_name" {
  type        = string
  description = "Azure role assigned to app_user_group principals at the Cosmos DB account scope."
  default     = "Reader"
}

variable "role_assignments" {
  description = "Additional Azure role assignments scoped to the Cosmos DB account."
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

variable "enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint for the Cosmos DB account."
  default     = false

  validation {
    condition = !var.enable_private_endpoint || trimspace(var.private_endpoint_subnet_id) != "" || (
      trimspace(var.private_endpoint_subnet_name) != "" &&
      trimspace(var.private_endpoint_vnet_name) != "" &&
      trimspace(var.private_endpoint_network_resource_group_name) != ""
    )
    error_message = "When enable_private_endpoint is true, provide private_endpoint_subnet_id or the subnet, virtual network, and network resource group names."
  }
}

variable "private_endpoint_name" {
  type        = string
  description = "Optional private endpoint name. Defaults to pep-<account-name>."
  default     = ""
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the private endpoint."
  default     = ""
}

variable "private_endpoint_subnet_name" {
  type        = string
  description = "Subnet name used to resolve the private endpoint subnet when private_endpoint_subnet_id is not set."
  default     = ""
}

variable "private_endpoint_vnet_name" {
  type        = string
  description = "Virtual network name used to resolve the private endpoint subnet when private_endpoint_subnet_id is not set."
  default     = ""
}

variable "private_endpoint_network_resource_group_name" {
  type        = string
  description = "Resource group containing the virtual network used to resolve the private endpoint subnet."
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
    subresource_name   = optional(string, "Sql")
    member_name        = optional(string, "Sql")
  }))
  default  = []
  nullable = false
}

variable "private_dns_zone_id" {
  type        = string
  description = "Optional single private DNS zone ID to attach to the private endpoint. Use private_dns_zone_ids for new configurations."
  default     = ""
}

variable "private_dns_zone_ids" {
  type        = list(string)
  description = "Optional list of private DNS zone IDs to attach to the private endpoint."
  default     = []
}

variable "private_dns_zone_name" {
  type        = string
  description = "Existing private DNS zone name used when private DNS zone IDs are not supplied. SQL API typically uses privatelink.documents.azure.com."
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
}

variable "private_dns_zone_group_name" {
  type        = string
  description = "Private DNS zone group name for the private endpoint."
  default     = "default"
}

variable "enable_diagnostics" {
  type        = bool
  description = "Whether to create diagnostic settings on the Cosmos DB account. Diagnostics are also enabled automatically when any diagnostic destination ID is supplied."
  default     = false
}

variable "diagnostic_setting_name" {
  type        = string
  description = "Optional diagnostic setting name. Defaults to diag-<account-name>."
  default     = ""
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID used for diagnostics."
  default     = ""
}

variable "log_analytics_destination_type" {
  type        = string
  description = "Diagnostic Log Analytics destination type."
  default     = null
}

variable "diagnostic_storage_account_id" {
  type        = string
  description = "Optional Storage Account ID used to archive diagnostics."
  default     = ""
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
  default     = ["AllLogs"]
}

variable "diagnostic_log_category_groups" {
  type        = list(string)
  description = "Diagnostic log category groups to enable, for example allLogs or audit."
  default     = []
}

variable "diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable."
  default     = ["Requests"]
}

variable "account_timeouts" {
  description = "Optional create/read/update/delete timeouts for the Cosmos DB account."
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
  description = "A mapping of tags to assign to Cosmos DB resources."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

check "cosmosdb_input_consistency" {
  assert {
    condition     = !var.enable_diagnostics || local.diagnostic_destination_enabled
    error_message = "enable_diagnostics requires at least one diagnostic destination: log_analytics_workspace_id, diagnostic_storage_account_id, or diagnostic_eventhub_authorization_rule_id."
  }

  assert {
    condition     = !(contains(var.capabilities, "EnableServerless") && var.total_throughput_limit != null)
    error_message = "Serverless accounts cannot use total_throughput_limit."
  }

  assert {
    condition = alltrue([
      for _, database in var.sql_databases :
      !(try(database.throughput, null) != null && try(database.autoscale_max_ru, null) != null)
    ])
    error_message = "Each sql_databases item can set throughput or autoscale_max_ru, but not both."
  }

  assert {
    condition = alltrue([
      for _, container in var.sql_containers :
      !(try(container.throughput, null) != null && try(container.autoscale_max_ru, null) != null)
    ])
    error_message = "Each sql_containers item can set throughput or autoscale_max_ru, but not both."
  }
}
