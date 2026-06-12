variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the Automation Account will be deployed."

  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
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
  description = "The Azure region where to deploy the resource. If empty, the resource group's location is used."
  default     = ""

  validation {
    condition     = var.location == "" || can(regex("^[a-z0-9-]+$", var.location))
    error_message = "location must be empty or a valid Azure region identifier."
  }
}

variable "name" {
  type        = string
  description = "Automation Account name. If empty, the module auto-generates a compliant name."
  default     = ""

  validation {
    condition     = var.name == "" || can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{1,48}[a-zA-Z0-9]$", var.name))
    error_message = "name must be empty or 3-50 characters using letters, digits, and hyphens, and must start and end with a letter or digit."
  }
}

variable "name_prefix" {
  type        = string
  description = "Prefix used when the Automation Account name is generated."
  default     = "aa"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,10}$", var.name_prefix))
    error_message = "name_prefix must be 1-10 characters using letters, digits, or hyphens."
  }
}

variable "workload_name" {
  type        = string
  description = "Optional workload segment used when the Automation Account name is generated."
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
  description = "Whether generated Automation Account names include app_env."
  default     = true
}

variable "location_code" {
  type        = string
  description = "Optional short location code used when the Automation Account name is generated."
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
  description = "Whether generated Automation Account names should include a random suffix."
  default     = true
}

variable "sku_name" {
  type        = string
  description = "The SKU name of the Automation Account."
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Free"], var.sku_name)
    error_message = "sku_name must be either Basic or Free."
  }
}

variable "local_auth_enabled" {
  type        = bool
  description = "Whether to allow non-Entra local authentication for the Automation Account."
  default     = false
}

variable "public_access_enabled" {
  type        = bool
  description = "Whether the Automation Account public endpoint can be reached from the Internet."
  default     = false
}

variable "system_managed_identity_enabled" {
  type        = bool
  description = "Whether to enable a system-assigned managed identity for the Automation Account."
  default     = true
}

variable "identity_ids" {
  type        = list(string)
  description = "User-assigned managed identity IDs to attach to the Automation Account."
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

variable "encryption" {
  description = "Optional customer-managed key configuration for Automation Account encryption."
  type = object({
    key_vault_key_id          = string
    user_assigned_identity_id = optional(string)
  })
  default = null

  validation {
    condition     = var.encryption == null ? true : can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.KeyVault/vaults/.+/keys/.+", var.encryption.key_vault_key_id))
    error_message = "encryption.key_vault_key_id must be a valid Key Vault key resource ID."
  }
}

variable "app_admin_group" {
  type        = list(string)
  description = "Microsoft Entra group display names or object IDs granted Contributor on the Automation Account."
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
  description = "Microsoft Entra group display names or object IDs granted Reader on the Automation Account."
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

variable "managed_identity_role_assignments" {
  type = map(object({
    scope                = string
    role_definition_name = optional(string)
    role_definition_id   = optional(string)
  }))
  description = "Role assignments to apply to the Automation Account system-assigned managed identity. Each entry must include scope and exactly one of role_definition_name or role_definition_id."
  default     = {}

  validation {
    condition = alltrue([
      for _, assignment in var.managed_identity_role_assignments :
      (
        (try(trimspace(assignment.role_definition_name), "") != "") !=
        (try(trimspace(assignment.role_definition_id), "") != "")
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
  description = "Additional role assignments to create at the Automation Account scope, keyed by a stable name."
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

variable "pep_vnet_name" {
  type        = string
  description = "Legacy input: VNet name for private endpoint subnet lookup. Prefer private_endpoint_vnet_name."
  default     = ""

  validation {
    condition = (
      (var.pep_vnet_name == "" && var.pep_vnet_resource_group_name == "") ||
      (var.pep_vnet_name != "" && var.pep_vnet_resource_group_name != "")
    )
    error_message = "pep_vnet_name and pep_vnet_resource_group_name must either both be set or both be empty."
  }
}

variable "pep_vnet_resource_group_name" {
  type        = string
  description = "Legacy input: VNet resource group for private endpoint subnet lookup. Prefer private_endpoint_network_resource_group_name."
  default     = ""
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the private endpoint. If set, subnet name/VNet/RG lookup is skipped."
  default     = ""

  validation {
    condition     = var.private_endpoint_subnet_id == "" || can(regex("^/subscriptions/.+", var.private_endpoint_subnet_id))
    error_message = "private_endpoint_subnet_id must be empty or a valid Azure subnet resource ID."
  }
}

variable "private_endpoint_subnet_name" {
  type        = string
  description = "Name of the existing subnet for private endpoint lookup when private_endpoint_subnet_id is not set."
  default     = null
}

variable "private_endpoint_vnet_name" {
  type        = string
  description = "Name of the VNet containing private_endpoint_subnet_name when private_endpoint_subnet_id is not set."
  default     = null
}

variable "private_endpoint_network_resource_group_name" {
  type        = string
  description = "Resource group name of the VNet containing private_endpoint_subnet_name when private_endpoint_subnet_id is not set."
  default     = null
}

variable "private_endpoint_vnet_exceptions" {
  type        = list(string)
  description = "Legacy behavior only: list of VNet names that should default to PrivateEndpoint2 instead of PrivateEndpoint when private_endpoint_subnet_name is not provided."
  default     = ["dv1vnt001"]
}

variable "private_endpoint_subresource_name" {
  type        = string
  description = "Automation Account private endpoint subresource to connect. Valid values are Webhook or DSCAndHybridWorker. The legacy value DscAndHybridWorker is also accepted and normalized."
  default     = "Webhook"

  validation {
    condition     = contains(["Webhook", "DSCAndHybridWorker", "DscAndHybridWorker"], var.private_endpoint_subresource_name)
    error_message = "private_endpoint_subresource_name must be Webhook or DSCAndHybridWorker."
  }
}

variable "enable_webhook_private_endpoint" {
  type        = bool
  description = "When set, explicitly controls creation of the Webhook private endpoint. Leave null to use the legacy private_endpoint_subresource_name behavior."
  default     = null
}

variable "enable_hrw_private_endpoint" {
  type        = bool
  description = "When set, explicitly controls creation of the DSCAndHybridWorker private endpoint. Leave null to use the legacy private_endpoint_subresource_name behavior."
  default     = null
}

variable "private_dns_zone_id" {
  type        = string
  description = "Optional private DNS zone resource ID to link to created private endpoints."
  default     = ""

  validation {
    condition     = var.private_dns_zone_id == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/privateDnsZones/.+$", var.private_dns_zone_id))
    error_message = "private_dns_zone_id must be empty or a valid Azure Private DNS Zone resource ID."
  }
}

variable "private_dns_zone_name" {
  type        = string
  description = "Optional private DNS zone name to look up and link to created private endpoints when private_dns_zone_id is not set. For Azure Automation, use privatelink.azure-automation.net."
  default     = ""

  validation {
    condition     = trimspace(var.private_dns_zone_name) == "" || can(regex("^[A-Za-z0-9.-]+$", trimspace(var.private_dns_zone_name)))
    error_message = "private_dns_zone_name must be empty or a valid private DNS zone name."
  }
}

variable "private_dns_zone_resource_group_name" {
  type        = string
  description = "Resource group containing private_dns_zone_name when using private DNS zone lookup."
  default     = ""

  validation {
    condition     = trimspace(var.private_dns_zone_resource_group_name) == "" || can(regex("^[A-Za-z0-9._()\\-]{1,90}$", trimspace(var.private_dns_zone_resource_group_name)))
    error_message = "private_dns_zone_resource_group_name must be empty or a valid Azure resource group name."
  }
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
  description = "Enable diagnostic settings for the Automation Account. Diagnostics are also enabled when at least one diagnostic destination is supplied."
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
  description = "Optional diagnostic setting name. When empty, the module uses <automation-account-name>-diagnostic-setting."
  default     = ""
}

variable "diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable. Use diagnostic_log_category_groups for Azure Monitor category groups such as allLogs."
  default     = ["JobLogs", "JobStreams", "AuditEvent"]

  validation {
    condition = alltrue([
      for value in var.diagnostic_log_categories :
      contains(["JobLogs", "JobStreams", "AuditEvent", "DscNodeStatus", "AllLogs", "allLogs"], value)
    ])
    error_message = "diagnostic_log_categories contains unsupported values for Automation Account diagnostics."
  }
}

variable "diagnostic_log_category_groups" {
  type        = list(string)
  description = "Diagnostic log category groups to enable, for example allLogs."
  default     = []

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

  validation {
    condition = alltrue([
      for value in var.diagnostic_metric_categories :
      contains(["AllMetrics"], value)
    ])
    error_message = "diagnostic_metric_categories must contain only AllMetrics."
  }
}

variable "runbooks" {
  description = "Automation Runbooks to create, keyed by a stable name. Use publish_content_link for content hosted externally or content for inline runbook text."
  type = map(object({
    name                     = string
    runbook_type             = string
    log_verbose              = optional(bool, false)
    log_progress             = optional(bool, false)
    description              = optional(string)
    content                  = optional(string)
    runtime_environment_name = optional(string)
    log_activity_trace_level = optional(number)
    tags                     = optional(map(string), {})
    publish_content_link = optional(object({
      uri     = string
      version = optional(string)
      hash = optional(object({
        algorithm = string
        value     = string
      }))
    }))
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for _, runbook in var.runbooks :
      contains(["Graph", "GraphPowerShell", "GraphPowerShellWorkflow", "PowerShellWorkflow", "PowerShell", "PowerShell72", "Python", "Python3", "Python2", "Script"], runbook.runbook_type)
    ])
    error_message = "runbooks runbook_type must be a supported Azure Automation runbook type."
  }

  validation {
    condition = alltrue([
      for _, runbook in var.runbooks :
      try(runbook.log_activity_trace_level, null) == null || contains([0, 9, 15], coalesce(runbook.log_activity_trace_level, 0))
    ])
    error_message = "runbooks log_activity_trace_level must be null, 0, 9, or 15."
  }
}

variable "schedules" {
  description = "Automation schedules to create, keyed by a stable name."
  type = map(object({
    name        = string
    frequency   = string
    description = optional(string)
    interval    = optional(number)
    start_time  = optional(string)
    expiry_time = optional(string)
    timezone    = optional(string)
    week_days   = optional(list(string))
    month_days  = optional(list(number))
    monthly_occurrences = optional(list(object({
      day        = string
      occurrence = number
    })), [])
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for _, schedule in var.schedules :
      contains(["OneTime", "Day", "Hour", "Week", "Month"], schedule.frequency)
    ])
    error_message = "schedules frequency must be OneTime, Day, Hour, Week, or Month."
  }

  validation {
    condition = alltrue(flatten([
      for _, schedule in var.schedules : [
        for day in coalesce(try(schedule.week_days, null), []) :
        contains(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], day)
      ]
    ]))
    error_message = "schedules week_days values must be valid day names."
  }

  validation {
    condition = alltrue(flatten([
      for _, schedule in var.schedules : [
        for day in coalesce(try(schedule.month_days, null), []) :
        day == -1 || (day >= 1 && day <= 31)
      ]
    ]))
    error_message = "schedules month_days values must be -1 or between 1 and 31."
  }

  validation {
    condition = alltrue(flatten([
      for _, schedule in var.schedules : [
        for occurrence in coalesce(try(schedule.monthly_occurrences, null), []) :
        contains(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], occurrence.day) &&
        (occurrence.occurrence == -1 || (occurrence.occurrence >= 1 && occurrence.occurrence <= 5))
      ]
    ]))
    error_message = "schedules monthly_occurrences must use valid day names and occurrence values of -1 or 1 through 5."
  }
}

variable "job_schedules" {
  description = "Links between Automation Runbooks and schedules, keyed by a stable name. runbook_name and schedule_name may reference resources created by this module by map key or by actual name."
  type = map(object({
    runbook_name  = string
    schedule_name = string
    parameters    = optional(map(string), {})
    run_on        = optional(string)
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue(flatten([
      for _, job_schedule in var.job_schedules : [
        for parameter_name in keys(coalesce(try(job_schedule.parameters, null), {})) :
        parameter_name == lower(parameter_name)
      ]
    ]))
    error_message = "job_schedules parameter keys must be lowercase due to Azure Automation parameter normalization."
  }
}

variable "string_variables" {
  description = "String variables to create in the Automation Account. Values are stored in Terraform state even when encrypted in Azure."
  type = map(object({
    name        = string
    value       = string
    description = optional(string)
    encrypted   = optional(bool, false)
  }))
  default  = {}
  nullable = false
}

variable "bool_variables" {
  description = "Boolean variables to create in the Automation Account."
  type = map(object({
    name        = string
    value       = bool
    description = optional(string)
    encrypted   = optional(bool, false)
  }))
  default  = {}
  nullable = false
}

variable "int_variables" {
  description = "Integer variables to create in the Automation Account."
  type = map(object({
    name        = string
    value       = number
    description = optional(string)
    encrypted   = optional(bool, false)
  }))
  default  = {}
  nullable = false
}

variable "datetime_variables" {
  description = "RFC3339 datetime variables to create in the Automation Account."
  type = map(object({
    name        = string
    value       = string
    description = optional(string)
    encrypted   = optional(bool, false)
  }))
  default  = {}
  nullable = false
}

variable "object_variables" {
  description = "Object variables to create in the Automation Account. Value must be a JSON-encoded string, for example jsonencode({ key = \"value\" })."
  type = map(object({
    name        = string
    value       = string
    description = optional(string)
    encrypted   = optional(bool, false)
  }))
  default  = {}
  nullable = false
}

variable "timeouts" {
  description = "Optional timeouts for Automation Account create, read, update, and delete operations."
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
  description = "A mapping of tags to assign to module resources."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

check "automationaccount_input_consistency" {
  assert {
    condition     = var.system_managed_identity_enabled || length(var.managed_identity_role_assignments) == 0
    error_message = "managed_identity_role_assignments requires system_managed_identity_enabled = true."
  }

  assert {
    condition = (
      trimspace(var.private_endpoint_subnet_id) != "" ||
      (
        try(trimspace(var.private_endpoint_subnet_name), "") == "" &&
        try(trimspace(var.private_endpoint_vnet_name), "") == "" &&
        try(trimspace(var.private_endpoint_network_resource_group_name), "") == ""
      ) ||
      (
        try(trimspace(var.private_endpoint_vnet_name), "") != "" &&
        try(trimspace(var.private_endpoint_network_resource_group_name), "") != ""
      )
    )
    error_message = "For private endpoint lookup, set private_endpoint_subnet_id or provide private_endpoint_vnet_name and private_endpoint_network_resource_group_name. private_endpoint_subnet_name is optional because the module can derive the legacy subnet name."
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
      trimspace(var.private_dns_zone_name) == "" ||
      trimspace(var.private_dns_zone_resource_group_name) != ""
    )
    error_message = "private_dns_zone_resource_group_name must be set when private_dns_zone_name is provided."
  }

  assert {
    condition = var.encryption == null || (
      var.system_managed_identity_enabled ||
      length(var.identity_ids) > 0
    )
    error_message = "encryption requires system_managed_identity_enabled = true or at least one user-assigned identity in identity_ids."
  }
}
