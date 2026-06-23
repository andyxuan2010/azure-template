variable "resource_group_name" {
  type        = string
  description = "Resource group where the Azure AI Search service will be deployed."

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
  description = "Optional Azure region for the Azure AI Search service. Leave empty to use the target resource group's location."
  default     = ""

  validation {
    condition     = var.location == "" || can(regex("^[a-z0-9-]+$", var.location))
    error_message = "location must be empty or a valid Azure region identifier."
  }
}

variable "name" {
  type        = string
  description = "Azure AI Search service name. Leave empty to auto-generate a unique name."
  default     = ""

  validation {
    condition = trimspace(var.name) == "" || (
      length(trimspace(var.name)) >= 2 &&
      length(trimspace(var.name)) <= 60 &&
      can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", trimspace(var.name)))
    )
    error_message = "When provided, name must be 2-60 characters, use lowercase letters, numbers, or hyphens, and start and end with an alphanumeric character."
  }
}

variable "name_prefix" {
  type        = string
  description = "Prefix used when the Azure AI Search service name is generated."
  default     = "srch"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,15}$", var.name_prefix))
    error_message = "name_prefix must be 1-15 characters using letters, digits, or hyphens."
  }
}

variable "workload_name" {
  type        = string
  description = "Optional workload segment used when the Azure AI Search service name is generated."
  default     = ""

  validation {
    condition     = var.workload_name == "" || can(regex("^[a-zA-Z0-9-]{1,35}$", var.workload_name))
    error_message = "workload_name must be empty or 1-35 characters using letters, digits, or hyphens."
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
  description = "Whether generated Azure AI Search names include app_env."
  default     = true
}

variable "location_code" {
  type        = string
  description = "Optional short location code used when the Azure AI Search service name is generated."
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
    condition     = var.instance == "" || can(regex("^[a-zA-Z0-9-]{1,10}$", var.instance))
    error_message = "instance must be empty or 1-10 characters using letters, digits, or hyphens."
  }
}

variable "use_random_suffix" {
  type        = bool
  description = "Whether generated Azure AI Search names should include a random suffix."
  default     = true
}

variable "sku" {
  type        = string
  description = "SKU for the Azure AI Search service."
  default     = "standard"

  validation {
    condition     = contains(["free", "basic", "standard", "standard2", "standard3", "storage_optimized_l1", "storage_optimized_l2"], lower(trimspace(var.sku)))
    error_message = "sku must be one of free, basic, standard, standard2, standard3, storage_optimized_l1, or storage_optimized_l2."
  }
}

variable "replica_count" {
  type        = number
  description = "Replica count for the Azure AI Search service. Ignored for the free SKU."
  default     = 1

  validation {
    condition     = var.replica_count >= 1 && var.replica_count <= 12
    error_message = "replica_count must be between 1 and 12."
  }
}

variable "partition_count" {
  type        = number
  description = "Partition count for the Azure AI Search service. Ignored for the free SKU."
  default     = 1

  validation {
    condition     = contains([1, 2, 3, 4, 6, 12], var.partition_count)
    error_message = "partition_count must be one of 1, 2, 3, 4, 6, or 12."
  }
}

variable "hosting_mode" {
  type        = string
  description = "Hosting mode for the Azure AI Search service."
  default     = "default"

  validation {
    condition     = contains(["default", "Default", "highDensity", "HighDensity"], trimspace(var.hosting_mode))
    error_message = "hosting_mode must be default or highDensity."
  }
}

variable "semantic_search_sku" {
  type        = string
  description = "Optional semantic ranker SKU for the Azure AI Search service."
  default     = ""

  validation {
    condition     = trimspace(var.semantic_search_sku) == "" || contains(["free", "standard"], lower(trimspace(var.semantic_search_sku)))
    error_message = "semantic_search_sku must be empty, free, or standard."
  }
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled."
  default     = false
}

variable "allowed_ips" {
  type        = list(string)
  description = "Optional list of public IPv4 addresses or CIDR ranges allowed to access the Azure AI Search service when public network access is enabled."
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for value in var.allowed_ips :
      can(cidrhost(contains(value, "/") ? value : "${value}/32", 0))
    ])
    error_message = "allowed_ips entries must be valid IP addresses or CIDR ranges."
  }
}

variable "network_rule_bypass_option" {
  type        = string
  description = "Whether trusted Azure services may bypass network rules."
  default     = "None"

  validation {
    condition     = contains(["None", "AzureServices"], trimspace(var.network_rule_bypass_option))
    error_message = "network_rule_bypass_option must be None or AzureServices."
  }
}

variable "local_authentication_enabled" {
  type        = bool
  description = "Whether API-key based local authentication is enabled."
  default     = false
}

variable "authentication_failure_mode" {
  type        = string
  description = "Optional authentication failure mode when local authentication and Entra authentication are both supported."
  default     = ""

  validation {
    condition     = trimspace(var.authentication_failure_mode) == "" || contains(["http401WithBearerChallenge", "http403"], trimspace(var.authentication_failure_mode))
    error_message = "authentication_failure_mode must be empty, http401WithBearerChallenge, or http403."
  }
}

variable "customer_managed_key_enforcement_enabled" {
  type        = bool
  description = "Whether the Search service enforces customer-managed encryption for non-customer resources. Azure AI Search key wiring is performed outside this resource."
  default     = false
}

variable "system_managed_identity_enabled" {
  type        = bool
  description = "Whether to enable a system-assigned managed identity. Ignored when legacy identity is set."
  default     = false
}

variable "identity_ids" {
  type        = list(string)
  description = "User-assigned managed identity IDs to attach to the Azure AI Search service. Ignored when legacy identity is set."
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

variable "identity" {
  description = "Legacy managed identity configuration. Prefer system_managed_identity_enabled and identity_ids for new usage."
  type = object({
    type         = string
    identity_ids = optional(set(string))
  })
  default = null

  validation {
    condition     = var.identity == null ? true : contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type)
    error_message = "identity.type must be one of SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }

  validation {
    condition = var.identity == null ? true : (
      contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type) ?
      length(try(var.identity.identity_ids, [])) > 0 :
      length(try(var.identity.identity_ids, [])) == 0
    )
    error_message = "identity.identity_ids must be provided for UserAssigned identities and omitted for SystemAssigned-only identities."
  }
}

variable "enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint for the Azure AI Search service."
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

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the private endpoint."
  default     = ""

  validation {
    condition     = trimspace(var.private_endpoint_subnet_id) == "" || can(regex("^/subscriptions/.+", var.private_endpoint_subnet_id))
    error_message = "private_endpoint_subnet_id must be empty or a valid Azure subnet resource ID."
  }
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

variable "private_endpoint_network_interface_name" {
  type        = string
  description = "Optional custom network interface name for the private endpoint."
  default     = ""
}

variable "private_endpoint_manual_connection_enabled" {
  type        = bool
  description = "Whether the private endpoint connection is created as a manual approval request."
  default     = false
}

variable "private_endpoint_request_message" {
  type        = string
  description = "Optional request message used when private_endpoint_manual_connection_enabled is true."
  default     = ""
}

variable "private_dns_zone_id" {
  type        = string
  description = "Optional single private DNS zone ID to attach to the private endpoint. Use private_dns_zone_ids for new configurations."
  default     = ""

  validation {
    condition     = trimspace(var.private_dns_zone_id) == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/privateDnsZones/.+$", var.private_dns_zone_id))
    error_message = "private_dns_zone_id must be empty or a valid Azure Private DNS Zone resource ID."
  }
}

variable "private_dns_zone_ids" {
  type        = list(string)
  description = "Optional list of private DNS zone IDs to attach to the private endpoint."
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for zone_id in var.private_dns_zone_ids :
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/privateDnsZones/.+$", zone_id))
    ])
    error_message = "private_dns_zone_ids values must be valid Azure Private DNS Zone resource IDs."
  }
}

variable "private_dns_zone_names" {
  type        = list(string)
  description = "Optional private DNS zone names to resolve and attach to the private endpoint when IDs are not supplied."
  default     = []
  nullable    = false
}

variable "private_dns_zone_resource_group_name" {
  type        = string
  description = "Resource group containing the private DNS zones referenced by private_dns_zone_names."
  default     = null
}

variable "shared_private_link_services" {
  description = "Shared private link resources that allow Azure AI Search to privately reach dependency services such as Storage, Key Vault, SQL, Cosmos DB, or OpenAI."
  type = map(object({
    name               = string
    subresource_name   = string
    target_resource_id = string
    request_message    = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for _, item in var.shared_private_link_services :
      trimspace(item.name) != "" &&
      trimspace(item.subresource_name) != "" &&
      can(regex("^/subscriptions/.+", item.target_resource_id))
    ])
    error_message = "Each shared_private_link_services item must include a non-empty name, non-empty subresource_name, and valid target_resource_id."
  }
}

variable "app_admin_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Contributor access to the Azure AI Search service."
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for value in var.app_admin_group : trimspace(value) != ""
    ])
    error_message = "app_admin_group must not contain empty values."
  }

  validation {
    condition = length([
      for value in var.app_admin_group : trimspace(value)
      ]) == length(toset([
        for value in var.app_admin_group : trimspace(value)
    ]))
    error_message = "app_admin_group must not contain duplicate values after trimming whitespace."
  }
}

variable "app_user_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Reader access to the Azure AI Search service."
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for value in var.app_user_group : trimspace(value) != ""
    ])
    error_message = "app_user_group must not contain empty values."
  }

  validation {
    condition = length([
      for value in var.app_user_group : trimspace(value)
      ]) == length(toset([
        for value in var.app_user_group : trimspace(value)
    ]))
    error_message = "app_user_group must not contain duplicate values after trimming whitespace."
  }
}

variable "role_assignments" {
  description = "Additional role assignments to create at the Azure AI Search service scope, keyed by a stable name."
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

  validation {
    condition = alltrue([
      for assignment in var.role_assignments :
      assignment.name == null ? true : can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", assignment.name))
    ])
    error_message = "role_assignments name values must be null or valid GUIDs."
  }
}

variable "enable_diagnostics" {
  type        = bool
  description = "Whether to create diagnostic settings on the Azure AI Search service. Diagnostics are also enabled when at least one diagnostic destination is supplied."
  default     = false
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Optional Log Analytics workspace ID used for diagnostics."
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
  description = "Optional diagnostic setting name. When empty, the module uses <search-service-name>-diagnostic-setting."
  default     = ""
}

variable "diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable. Use diagnostic_log_category_groups for Azure Monitor category groups such as allLogs."
  default     = ["OperationLogs"]
  nullable    = false
}

variable "diagnostic_log_category_groups" {
  type        = list(string)
  description = "Diagnostic log category groups to enable, for example allLogs."
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for value in var.diagnostic_log_category_groups :
      contains(["allLogs", "audit"], value)
    ])
    error_message = "diagnostic_log_category_groups must contain only allLogs or audit."
  }
}

variable "diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable."
  default     = ["AllMetrics"]
  nullable    = false
}

variable "timeouts" {
  description = "Optional timeouts for Search service create, read, update, and delete operations."
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
  description = "A mapping of tags to assign to the Azure AI Search service."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

check "azure_ai_search_input_consistency" {
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
      length(var.private_dns_zone_names) == 0 ||
      try(trimspace(var.private_dns_zone_resource_group_name), "") != ""
    )
    error_message = "private_dns_zone_resource_group_name must be set when private_dns_zone_names is provided."
  }

  assert {
    condition     = var.identity == null || (!var.system_managed_identity_enabled && length(var.identity_ids) == 0)
    error_message = "Use either legacy identity or the newer system_managed_identity_enabled/identity_ids inputs, not both."
  }

  assert {
    condition     = !var.customer_managed_key_enforcement_enabled || (var.identity != null || var.system_managed_identity_enabled || length(var.identity_ids) > 0)
    error_message = "customer_managed_key_enforcement_enabled requires identity, system_managed_identity_enabled, or identity_ids."
  }

  assert {
    condition     = !var.private_endpoint_manual_connection_enabled || trimspace(var.private_endpoint_request_message) != ""
    error_message = "private_endpoint_request_message must be set when private_endpoint_manual_connection_enabled is true."
  }
}
