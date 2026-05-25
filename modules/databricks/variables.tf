variable "resource_group_name" {
  type        = string
  description = "Resource group where the Databricks workspace will be deployed."

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
  description = "Optional Azure region for the Databricks workspace. Leave empty to use the target resource group's location."
  default     = ""

  validation {
    condition     = var.location == "" || can(regex("^[a-z0-9-]+$", var.location))
    error_message = "location must be empty or a valid Azure region identifier."
  }
}

variable "name" {
  type        = string
  description = "Databricks workspace name. Leave empty to auto-generate a unique name."
  default     = ""

  validation {
    condition = trimspace(var.name) == "" || (
      length(trimspace(var.name)) >= 3 &&
      length(trimspace(var.name)) <= 64 &&
      can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$", trimspace(var.name)))
    )
    error_message = "name must be empty or 3-64 characters using letters, digits, and hyphens, and must start and end with a letter or digit."
  }
}

variable "name_prefix" {
  type        = string
  description = "Prefix used when the Databricks workspace name is generated."
  default     = "dbw"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,15}$", var.name_prefix))
    error_message = "name_prefix must be 1-15 characters using letters, digits, or hyphens."
  }
}

variable "workload_name" {
  type        = string
  description = "Optional workload segment used when the Databricks workspace name is generated."
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
  description = "Whether generated Databricks workspace names include app_env."
  default     = true
}

variable "location_code" {
  type        = string
  description = "Optional short location code used when the Databricks workspace name is generated."
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
  description = "Whether generated Databricks workspace names should include a random suffix."
  default     = true
}

variable "sku" {
  type        = string
  description = "Databricks workspace SKU."
  default     = "premium"

  validation {
    condition     = contains(["standard", "premium", "trial"], lower(var.sku))
    error_message = "sku must be standard, premium, or trial."
  }
}

variable "managed_resource_group_name" {
  type        = string
  description = "Optional managed resource group name for the Databricks workspace."
  default     = ""
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled on the Databricks workspace."
  default     = false
}

variable "network_security_group_rules_required" {
  type        = string
  description = "Network security group rules mode for VNet-injected workspaces."
  default     = "NoAzureDatabricksRules"

  validation {
    condition     = contains(["AllRules", "NoAzureDatabricksRules", "NoAzureServiceRules"], var.network_security_group_rules_required)
    error_message = "network_security_group_rules_required must be AllRules, NoAzureDatabricksRules, or NoAzureServiceRules."
  }
}

variable "customer_managed_key_enabled" {
  type        = bool
  description = "Whether customer-managed keys are enabled. Requires premium SKU."
  default     = false
}

variable "infrastructure_encryption_enabled" {
  type        = bool
  description = "Whether infrastructure encryption is enabled. Requires premium SKU."
  default     = false
}

variable "default_storage_firewall_enabled" {
  type        = bool
  description = "Whether the default storage account firewall is enabled. Requires access_connector_id or create_access_connector."
  default     = false
}

variable "access_connector_id" {
  type        = string
  description = "Optional existing Databricks access connector resource ID. If create_access_connector is true, the created access connector is used instead."
  default     = ""

  validation {
    condition     = trimspace(var.access_connector_id) == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Databricks/accessConnectors/.+$", var.access_connector_id))
    error_message = "access_connector_id must be empty or a valid Databricks access connector resource ID."
  }
}

variable "create_access_connector" {
  type        = bool
  description = "Whether to create a Databricks access connector for Unity Catalog and default storage firewall scenarios."
  default     = false
}

variable "access_connector_name" {
  type        = string
  description = "Optional name for the Databricks access connector. When empty, the module uses dac-<workspace-name>."
  default     = ""
}

variable "access_connector_system_assigned_identity_enabled" {
  type        = bool
  description = "Whether the created access connector gets a system-assigned identity."
  default     = true
}

variable "access_connector_identity_ids" {
  type        = list(string)
  description = "User-assigned managed identity IDs for the created Databricks access connector. Only one user-assigned identity is supported by Azure."
  default     = []
  nullable    = false

  validation {
    condition = length(var.access_connector_identity_ids) <= 1 && alltrue([
      for identity_id in var.access_connector_identity_ids :
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.ManagedIdentity/userAssignedIdentities/.+$", identity_id))
    ])
    error_message = "access_connector_identity_ids must contain at most one valid user-assigned managed identity resource ID."
  }
}

variable "access_connector_role_assignments" {
  description = "Role assignments for the created access connector identity, typically Storage Blob Data Contributor on external lakehouse storage scopes."
  type = map(object({
    scope                                  = string
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
      for assignment in var.access_connector_role_assignments :
      can(regex("^/subscriptions/.+", assignment.scope))
    ])
    error_message = "Each access_connector_role_assignments scope must be a valid Azure resource scope."
  }

  validation {
    condition = alltrue([
      for assignment in var.access_connector_role_assignments :
      (try(trimspace(assignment.role_definition_name), "") != "") != (try(trimspace(assignment.role_definition_id), "") != "")
    ])
    error_message = "Each access_connector_role_assignments entry must set exactly one of role_definition_name or role_definition_id."
  }
}

variable "access_connector_timeouts" {
  description = "Optional timeouts for Databricks access connector create, read, update, and delete operations."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "load_balancer_backend_address_pool_id" {
  type        = string
  description = "Optional load balancer backend address pool ID for secure cluster connectivity."
  default     = ""
}

variable "managed_disk_cmk_key_vault_id" {
  type        = string
  description = "Optional Key Vault ID for managed disk CMK. Needed when the key is in a different subscription."
  default     = ""
}

variable "managed_disk_cmk_key_vault_key_id" {
  type        = string
  description = "Optional Key Vault key identifier URI for managed disk CMK."
  default     = ""

  validation {
    condition     = trimspace(var.managed_disk_cmk_key_vault_key_id) == "" || can(regex("^https://[a-zA-Z0-9-]+\\.(vault\\.azure\\.net|managedhsm\\.azure\\.net)/keys/.+", var.managed_disk_cmk_key_vault_key_id))
    error_message = "managed_disk_cmk_key_vault_key_id must be empty or a valid Key Vault or Managed HSM key identifier URI."
  }
}

variable "managed_disk_cmk_rotation_to_latest_version_enabled" {
  type        = bool
  description = "Whether managed disk CMK should auto-rotate to the latest key version."
  default     = false
}

variable "managed_services_cmk_key_vault_id" {
  type        = string
  description = "Optional Key Vault ID for managed services CMK. Needed when the key is in a different subscription."
  default     = ""
}

variable "managed_services_cmk_key_vault_key_id" {
  type        = string
  description = "Optional Key Vault key identifier URI for managed services CMK."
  default     = ""

  validation {
    condition     = trimspace(var.managed_services_cmk_key_vault_key_id) == "" || can(regex("^https://[a-zA-Z0-9-]+\\.(vault\\.azure\\.net|managedhsm\\.azure\\.net)/keys/.+", var.managed_services_cmk_key_vault_key_id))
    error_message = "managed_services_cmk_key_vault_key_id must be empty or a valid Key Vault or Managed HSM key identifier URI."
  }
}

variable "root_dbfs_customer_managed_key" {
  description = "Optional customer-managed key for the Databricks root DBFS storage account."
  type = object({
    key_vault_key_id = string
    key_vault_id     = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })
  default = null

  validation {
    condition     = var.root_dbfs_customer_managed_key == null ? true : can(regex("^https://[a-zA-Z0-9-]+\\.(vault\\.azure\\.net|managedhsm\\.azure\\.net)/keys/.+", var.root_dbfs_customer_managed_key.key_vault_key_id))
    error_message = "root_dbfs_customer_managed_key.key_vault_key_id must be a valid Key Vault or Managed HSM key identifier URI."
  }
}

variable "custom_parameters" {
  description = "Optional Databricks custom parameters block for VNet injection, no-public-IP, managed VNet, storage, and ML linkage scenarios."
  type = object({
    machine_learning_workspace_id                        = optional(string)
    nat_gateway_name                                     = optional(string)
    no_public_ip                                         = optional(bool)
    private_subnet_name                                  = optional(string)
    private_subnet_network_security_group_association_id = optional(string)
    public_ip_name                                       = optional(string)
    public_subnet_name                                   = optional(string)
    public_subnet_network_security_group_association_id  = optional(string)
    storage_account_name                                 = optional(string)
    storage_account_sku_name                             = optional(string)
    virtual_network_id                                   = optional(string)
    vnet_address_prefix                                  = optional(string)
  })
  default = null

  validation {
    condition = var.custom_parameters == null || try(trimspace(var.custom_parameters.virtual_network_id), "") == "" || (
      try(trimspace(var.custom_parameters.public_subnet_name), "") != "" &&
      try(trimspace(var.custom_parameters.private_subnet_name), "") != "" &&
      try(trimspace(var.custom_parameters.public_subnet_network_security_group_association_id), "") != "" &&
      try(trimspace(var.custom_parameters.private_subnet_network_security_group_association_id), "") != ""
    )
    error_message = "When custom_parameters.virtual_network_id is set, public/private subnet names and NSG association IDs must also be provided."
  }

  validation {
    condition = var.custom_parameters == null || try(trimspace(var.custom_parameters.storage_account_sku_name), "") == "" || contains(
      ["Standard_LRS", "Standard_GRS", "Standard_RAGRS", "Standard_GZRS", "Standard_RAGZRS", "Standard_ZRS", "Premium_LRS", "Premium_ZRS"],
      try(var.custom_parameters.storage_account_sku_name, "")
    )
    error_message = "custom_parameters.storage_account_sku_name must be a supported Storage Account SKU name."
  }
}

variable "enhanced_security_compliance" {
  description = "Optional enhanced security and compliance settings for the Databricks workspace. Requires premium SKU."
  type = object({
    automatic_cluster_update_enabled      = optional(bool)
    compliance_security_profile_enabled   = optional(bool)
    compliance_security_profile_standards = optional(set(string))
    enhanced_security_monitoring_enabled  = optional(bool)
  })
  default = null

  validation {
    condition = var.enhanced_security_compliance == null ? true : (
      !try(var.enhanced_security_compliance.compliance_security_profile_enabled, false) ||
      (
        try(var.enhanced_security_compliance.automatic_cluster_update_enabled, false) &&
        try(var.enhanced_security_compliance.enhanced_security_monitoring_enabled, false)
      )
    )
    error_message = "compliance_security_profile_enabled requires automatic_cluster_update_enabled and enhanced_security_monitoring_enabled to be true."
  }

  validation {
    condition = var.enhanced_security_compliance == null ? true : alltrue([
      for standard in coalesce(try(var.enhanced_security_compliance.compliance_security_profile_standards, null), []) :
      contains(["HIPAA", "PCI_DSS", "FEDRAMP_MODERATE", "IRAP_PROTECTED", "FEDRAMP_HIGH", "FEDRAMP_IL5", "ITAR_EAR", "CYBER_ESSENTIAL_PLUS", "CANADA_PROTECTED_B", "ISMAP", "HITRUST", "K_FSI", "GERMANY_C5", "GERMANY_TISAX"], standard)
    ])
    error_message = "enhanced_security_compliance.compliance_security_profile_standards contains unsupported standards."
  }
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for Databricks private endpoints. If set, subnet lookup inputs are ignored."
  default     = ""

  validation {
    condition     = trimspace(var.private_endpoint_subnet_id) == "" || can(regex("^/subscriptions/.+", var.private_endpoint_subnet_id))
    error_message = "private_endpoint_subnet_id must be empty or a valid Azure subnet resource ID."
  }
}

variable "private_endpoint_subnet_name" {
  type        = string
  description = "Subnet name used to resolve private endpoint subnet when private_endpoint_subnet_id is not set."
  default     = ""
}

variable "private_endpoint_vnet_name" {
  type        = string
  description = "Virtual network name used to resolve private endpoint subnet when private_endpoint_subnet_id is not set."
  default     = ""
}

variable "private_endpoint_network_resource_group_name" {
  type        = string
  description = "Resource group containing the virtual network used to resolve the private endpoint subnet."
  default     = ""
}

variable "private_endpoint_subresource_names" {
  type        = list(string)
  description = "Databricks private endpoint subresources to create. Common values are databricks_ui_api and browser_authentication."
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for name in var.private_endpoint_subresource_names :
      contains(["databricks_ui_api", "browser_authentication"], name)
    ])
    error_message = "private_endpoint_subresource_names must contain only databricks_ui_api or browser_authentication."
  }
}

variable "private_dns_zone_ids" {
  type        = list(string)
  description = "Optional private DNS zone IDs attached to each Databricks private endpoint."
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
  description = "Optional private DNS zone names to resolve and attach to Databricks private endpoints when IDs are not supplied."
  default     = []
  nullable    = false
}

variable "private_dns_zone_resource_group_name" {
  type        = string
  description = "Resource group containing the private DNS zones referenced by private_dns_zone_names."
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

variable "private_endpoint_network_interface_name" {
  type        = string
  description = "Optional base network interface name for Databricks private endpoints. The subresource name is appended."
  default     = ""
}

variable "private_endpoint_manual_connection_enabled" {
  type        = bool
  description = "Whether private endpoint connections are created as manual approval requests."
  default     = false
}

variable "private_endpoint_request_message" {
  type        = string
  description = "Optional request message used when private_endpoint_manual_connection_enabled is true."
  default     = ""
}

variable "app_admin_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Contributor access to the Databricks workspace."
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
  description = "Optional list of Entra group display names or object IDs that will have Reader access to the Databricks workspace."
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
  description = "Additional role assignments to create at the Databricks workspace scope, keyed by a stable name."
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
  description = "Whether to create diagnostic settings on the Databricks workspace. Diagnostics are also enabled when at least one diagnostic destination is supplied."
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
  description = "Optional diagnostic setting name. When empty, the module uses <workspace-name>-diagnostic-setting."
  default     = ""
}

variable "diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable. Use diagnostic_log_category_groups for Azure Monitor category groups such as allLogs."
  default     = ["accounts", "clusters", "dbfs", "jobs", "notebook", "secrets", "sqlPermissions", "workspace"]
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
  description = "Optional timeouts for Databricks workspace create, read, update, and delete operations."
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
  description = "A mapping of tags to assign to the Databricks workspace."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

check "databricks_input_consistency" {
  assert {
    condition     = !var.default_storage_firewall_enabled || trimspace(var.access_connector_id) != "" || var.create_access_connector
    error_message = "default_storage_firewall_enabled requires access_connector_id or create_access_connector = true."
  }

  assert {
    condition     = !var.create_access_connector || trimspace(var.access_connector_id) == ""
    error_message = "Set either create_access_connector or access_connector_id, not both."
  }

  assert {
    condition     = !var.customer_managed_key_enabled || lower(var.sku) == "premium"
    error_message = "customer_managed_key_enabled requires sku = premium."
  }

  assert {
    condition     = !var.infrastructure_encryption_enabled || lower(var.sku) == "premium"
    error_message = "infrastructure_encryption_enabled requires sku = premium."
  }

  assert {
    condition     = var.enhanced_security_compliance == null || lower(var.sku) == "premium"
    error_message = "enhanced_security_compliance requires sku = premium."
  }

  assert {
    condition = (
      trimspace(var.managed_disk_cmk_key_vault_key_id) == "" ||
      var.customer_managed_key_enabled
    )
    error_message = "managed_disk_cmk_key_vault_key_id requires customer_managed_key_enabled = true."
  }

  assert {
    condition = (
      trimspace(var.managed_services_cmk_key_vault_key_id) == "" ||
      var.customer_managed_key_enabled
    )
    error_message = "managed_services_cmk_key_vault_key_id requires customer_managed_key_enabled = true."
  }

  assert {
    condition = (
      var.root_dbfs_customer_managed_key == null ||
      var.customer_managed_key_enabled
    )
    error_message = "root_dbfs_customer_managed_key requires customer_managed_key_enabled = true."
  }

  assert {
    condition = length(var.private_endpoint_subresource_names) == 0 || (
      trimspace(var.private_endpoint_subnet_id) != "" ||
      (
        trimspace(var.private_endpoint_subnet_name) != "" &&
        trimspace(var.private_endpoint_vnet_name) != "" &&
        trimspace(var.private_endpoint_network_resource_group_name) != ""
      )
    )
    error_message = "When private endpoints are requested, set private_endpoint_subnet_id or provide private_endpoint_subnet_name, private_endpoint_vnet_name, and private_endpoint_network_resource_group_name."
  }

  assert {
    condition = (
      length(var.private_dns_zone_names) == 0 ||
      try(trimspace(var.private_dns_zone_resource_group_name), "") != ""
    )
    error_message = "private_dns_zone_resource_group_name must be set when private_dns_zone_names is provided."
  }

  assert {
    condition     = !var.private_endpoint_manual_connection_enabled || trimspace(var.private_endpoint_request_message) != ""
    error_message = "private_endpoint_request_message must be set when private_endpoint_manual_connection_enabled is true."
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
}
