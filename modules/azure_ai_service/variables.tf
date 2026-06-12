variable "resource_group_name" {
  type        = string
  description = "Resource group where the Azure AI Services account will be deployed."

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
  description = "Optional Azure region for the Azure AI Services account. Leave empty to use the target resource group's location."
  default     = ""

  validation {
    condition     = var.location == "" || can(regex("^[a-z0-9-]+$", var.location))
    error_message = "location must be empty or a valid Azure region identifier."
  }
}

variable "name" {
  type        = string
  description = "Azure AI Services account name. Leave empty to auto-generate a unique name."
  default     = ""

  validation {
    condition = trimspace(var.name) == "" || (
      length(trimspace(var.name)) >= 2 &&
      length(trimspace(var.name)) <= 64 &&
      can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", trimspace(var.name)))
    )
    error_message = "When provided, name must be 2-64 characters, use lowercase letters, numbers, or hyphens, and start and end with an alphanumeric character."
  }
}

variable "name_prefix" {
  type        = string
  description = "Prefix used when the Azure AI Services account name is generated."
  default     = "ais"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,15}$", var.name_prefix))
    error_message = "name_prefix must be 1-15 characters using letters, digits, or hyphens."
  }
}

variable "workload_name" {
  type        = string
  description = "Optional workload segment used when the Azure AI Services account name is generated."
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
  description = "Whether generated Azure AI Services names include app_env."
  default     = true
}

variable "location_code" {
  type        = string
  description = "Optional short location code used when the Azure AI Services account name is generated."
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
  description = "Whether generated Azure AI Services names should include a random suffix."
  default     = true
}

variable "kind" {
  type        = string
  description = "Cognitive Services account kind. AIServices is the Azure AI Foundry superset and is the default for this module."
  default     = "AIServices"

  validation {
    condition = contains([
      "Academic", "AIServices", "AnomalyDetector", "Bing.Autosuggest", "Bing.Autosuggest.v7", "Bing.CustomSearch", "Bing.Search", "Bing.Search.v7", "Bing.Speech", "Bing.SpellCheck", "Bing.SpellCheck.v7", "CognitiveServices", "ComputerVision", "ContentModerator", "ContentSafety", "CustomSpeech", "CustomVision.Prediction", "CustomVision.Training", "Emotion", "Face", "FormRecognizer", "ImmersiveReader", "LUIS", "LUIS.Authoring", "MetricsAdvisor", "OpenAI", "Personalizer", "QnAMaker", "Recommendations", "SpeakerRecognition", "Speech", "SpeechServices", "SpeechTranslation", "TextAnalytics", "TextTranslation", "WebLM"
    ], var.kind)
    error_message = "kind must be a supported Cognitive Services account kind."
  }
}

variable "sku_name" {
  type        = string
  description = "SKU name for the Azure AI Services account."
  default     = "S0"

  validation {
    condition     = contains(["C2", "C3", "C4", "D3", "DC0", "E0", "F0", "F1", "P0", "P1", "P2", "S", "S0", "S1", "S2", "S3", "S4", "S5", "S6"], var.sku_name)
    error_message = "sku_name must be a supported Cognitive Services SKU."
  }
}

variable "custom_subdomain_name" {
  type        = string
  description = "Optional custom subdomain name. Required by Azure for private endpoints, network ACLs, and Entra ID token authentication; the module auto-generates it when needed."
  default     = ""

  validation {
    condition = trimspace(var.custom_subdomain_name) == "" || (
      length(trimspace(var.custom_subdomain_name)) >= 2 &&
      length(trimspace(var.custom_subdomain_name)) <= 64 &&
      can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", trimspace(var.custom_subdomain_name)))
    )
    error_message = "When provided, custom_subdomain_name must be 2-64 characters, use lowercase letters, numbers, or hyphens, and start and end with an alphanumeric character."
  }
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled."
  default     = false
}

variable "outbound_network_access_restricted" {
  type        = bool
  description = "Whether outbound network access is restricted."
  default     = false
}

variable "local_auth_enabled" {
  type        = bool
  description = "Whether local authentication keys are enabled."
  default     = false
}

variable "dynamic_throttling_enabled" {
  type        = bool
  description = "Whether dynamic throttling is enabled. The provider omits this for OpenAI and AIServices kinds."
  default     = false
}

variable "fqdns" {
  type        = list(string)
  description = "Optional list of outbound FQDNs."
  default     = []
  nullable    = false
}

variable "project_management_enabled" {
  type        = bool
  description = "Whether project management is enabled. Supported when kind is AIServices."
  default     = false
}

variable "qna_runtime_endpoint" {
  type        = string
  description = "Optional QnA Maker runtime endpoint for legacy QnAMaker scenarios."
  default     = ""
}

variable "custom_question_answering" {
  description = "Optional Custom Question Answering search dependency for TextAnalytics accounts."
  type = object({
    search_service_id  = string
    search_service_key = string
  })
  default = null
}

variable "metrics_advisor" {
  description = "Optional Metrics Advisor settings. Only applicable when kind is MetricsAdvisor."
  type = object({
    aad_client_id   = string
    aad_tenant_id   = string
    super_user_name = string
    website_name    = string
  })
  default = null
}

variable "system_managed_identity_enabled" {
  type        = bool
  description = "Whether to enable a system-assigned managed identity. Ignored when legacy identity is set."
  default     = false
}

variable "identity_ids" {
  type        = list(string)
  description = "User-assigned managed identity IDs to attach to the Azure AI Services account. Ignored when legacy identity is set."
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

variable "customer_managed_key" {
  description = "Optional customer-managed key configuration."
  type = object({
    key_vault_key_id   = string
    identity_client_id = optional(string)
  })
  default = null

  validation {
    condition     = var.customer_managed_key == null ? true : can(regex("^https://[a-zA-Z0-9-]+\\.vault\\.azure\\.net/keys/.+", var.customer_managed_key.key_vault_key_id))
    error_message = "customer_managed_key.key_vault_key_id must be a valid Key Vault key identifier URI."
  }
}

variable "storage" {
  description = "Optional storage account attachments for Azure AI Services."
  type = list(object({
    storage_account_id = string
    identity_client_id = optional(string)
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for item in var.storage :
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Storage/storageAccounts/.+$", item.storage_account_id))
    ])
    error_message = "storage.storage_account_id values must be valid Storage Account resource IDs."
  }
}

variable "network_acls" {
  description = "Optional network ACL configuration. When set, Azure requires a custom subdomain."
  type = object({
    default_action = string
    bypass         = optional(string)
    ip_rules       = optional(set(string))
    virtual_network_rules = optional(set(object({
      subnet_id                            = string
      ignore_missing_vnet_service_endpoint = optional(bool)
    })))
  })
  default = null

  validation {
    condition     = var.network_acls == null ? true : contains(["Allow", "Deny"], var.network_acls.default_action)
    error_message = "network_acls.default_action must be either Allow or Deny."
  }

  validation {
    condition     = var.network_acls == null ? true : try(var.network_acls.bypass, null) == null || contains(["AzureServices", "None"], var.network_acls.bypass)
    error_message = "network_acls.bypass must be AzureServices or None when provided."
  }
}

variable "network_injection" {
  description = "Optional network injection configuration for AI Foundry agent networking. Only supported when kind is AIServices."
  type = object({
    scenario  = optional(string, "agent")
    subnet_id = string
  })
  default = null

  validation {
    condition     = var.network_injection == null ? true : var.network_injection.scenario == "agent"
    error_message = "network_injection.scenario must be agent."
  }

  validation {
    condition     = var.network_injection == null ? true : can(regex("^/subscriptions/.+", var.network_injection.subnet_id))
    error_message = "network_injection.subnet_id must be a valid Azure subnet resource ID."
  }
}

variable "deployments" {
  description = "Optional Cognitive Services deployments, commonly used for Azure OpenAI or Azure AI Foundry model deployments."
  type = map(object({
    name                       = string
    dynamic_throttling_enabled = optional(bool)
    rai_policy_name            = optional(string)
    version_upgrade_option     = optional(string)
    model = object({
      format  = string
      name    = string
      version = optional(string)
    })
    sku = object({
      name     = string
      tier     = optional(string)
      size     = optional(string)
      family   = optional(string)
      capacity = optional(number)
    })
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
      for _, deployment in var.deployments :
      deployment.version_upgrade_option == null ? true : contains(["OnceNewDefaultVersionAvailable", "OnceCurrentVersionExpired", "NoAutoUpgrade"], deployment.version_upgrade_option)
    ])
    error_message = "deployments.version_upgrade_option must be null, OnceNewDefaultVersionAvailable, OnceCurrentVersionExpired, or NoAutoUpgrade."
  }
}

variable "rai_policies" {
  description = "Optional Responsible AI policies for Cognitive Services deployments."
  type = map(object({
    name             = string
    base_policy_name = string
    mode             = optional(string)
    tags             = optional(map(string), {})
    content_filters = list(object({
      name               = string
      filter_enabled     = bool
      block_enabled      = bool
      severity_threshold = string
      source             = string
    }))
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
      for _, policy in var.rai_policies :
      policy.mode == null ? true : contains(["Default", "Deferred", "Blocking", "Asynchronous_filter"], policy.mode)
    ])
    error_message = "rai_policies.mode must be null, Default, Deferred, Blocking, or Asynchronous_filter."
  }

  validation {
    condition = alltrue(flatten([
      for _, policy in var.rai_policies : [
        for filter in policy.content_filters :
        contains(["Low", "Medium", "High"], filter.severity_threshold) &&
        contains(["Prompt", "Completion"], filter.source)
      ]
    ]))
    error_message = "rai_policies content_filters must use supported severity_threshold and source values."
  }
}

variable "enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint for the Azure AI Services account."
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

variable "private_endpoint_ip_configurations" {
  description = "Optional static IP configurations for the private endpoint."
  type = list(object({
    name               = string
    private_ip_address = string
    subresource_name   = optional(string, "account")
    member_name        = optional(string, "account")
  }))
  default  = []
  nullable = false
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

variable "app_admin_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Contributor access to the Azure AI Services account."
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
  description = "Optional list of Entra group display names or object IDs that will have Reader access to the Azure AI Services account."
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
  description = "Additional role assignments to create at the Azure AI Services account scope, keyed by a stable name."
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
  description = "Whether to create diagnostic settings on the Azure AI Services account. Diagnostics are also enabled when at least one diagnostic destination is supplied."
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
  description = "Optional diagnostic setting name. When empty, the module uses <account-name>-diagnostic-setting."
  default     = ""
}

variable "diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable. Use diagnostic_log_category_groups for Azure Monitor category groups such as allLogs."
  default     = ["Audit"]
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
  description = "Optional timeouts for Cognitive account create, read, update, and delete operations."
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
  description = "A mapping of tags to assign to the Azure AI Services account."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

check "azure_ai_service_input_consistency" {
  assert {
    condition     = var.identity == null || (!var.system_managed_identity_enabled && length(var.identity_ids) == 0)
    error_message = "Use either legacy identity or the newer system_managed_identity_enabled/identity_ids inputs, not both."
  }

  assert {
    condition     = var.customer_managed_key == null || (var.identity != null || var.system_managed_identity_enabled || length(var.identity_ids) > 0)
    error_message = "customer_managed_key requires identity, system_managed_identity_enabled, or identity_ids."
  }

  assert {
    condition     = !var.project_management_enabled || var.kind == "AIServices"
    error_message = "project_management_enabled can only be true when kind = AIServices."
  }

  assert {
    condition     = !var.project_management_enabled || (var.identity != null || var.system_managed_identity_enabled || length(var.identity_ids) > 0)
    error_message = "project_management_enabled requires identity, system_managed_identity_enabled, or identity_ids."
  }

  assert {
    condition     = var.network_injection == null || var.kind == "AIServices"
    error_message = "network_injection can only be set when kind = AIServices."
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
      length(var.private_dns_zone_names) == 0 ||
      try(trimspace(var.private_dns_zone_resource_group_name), "") != ""
    )
    error_message = "private_dns_zone_resource_group_name must be set when private_dns_zone_names is provided."
  }

  assert {
    condition     = !var.private_endpoint_manual_connection_enabled || trimspace(var.private_endpoint_request_message) != ""
    error_message = "private_endpoint_request_message must be set when private_endpoint_manual_connection_enabled is true."
  }
}
