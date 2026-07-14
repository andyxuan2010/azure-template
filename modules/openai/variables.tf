variable "resource_group_name" {
  type        = string
  description = "Resource group where the Azure OpenAI account will be deployed."

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
  description = "Deprecated compatibility input. Supply workload tags explicitly through tags."

  validation {
    condition     = length(trimspace(var.workload)) > 0
    error_message = "workload cannot be empty."
  }
}

variable "location" {
  type        = string
  description = "Optional Azure region for the Azure OpenAI account. Leave empty to use the target resource group's location."
  default     = ""

  validation {
    condition     = trimspace(var.location) == "" || can(regex("^[a-z0-9-]+$", trimspace(var.location)))
    error_message = "location must be empty or a valid Azure region identifier."
  }
}

variable "name" {
  type        = string
  description = "Azure OpenAI account name. Leave empty to auto-generate a standardized name."
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
  description = "Prefix used when the Azure OpenAI account name is generated."
  default     = "oai"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,15}$", var.name_prefix))
    error_message = "name_prefix must be 1-15 characters using lowercase letters, digits, or hyphens."
  }
}

variable "workload_name" {
  type        = string
  description = "Optional workload segment used when the Azure OpenAI account name is generated."
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
  description = "Whether generated Azure OpenAI names include app_env."
  default     = true
}

variable "location_code" {
  type        = string
  description = "Optional short location code used when the Azure OpenAI account name is generated."
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
  description = "Whether generated Azure OpenAI names should include a random suffix."
  default     = true
}

variable "sku_name" {
  type        = string
  description = "SKU name for the Azure OpenAI account."
  default     = "S0"

  validation {
    condition     = contains(["F0", "F1", "S", "S0", "S1", "S2", "S3", "S4", "S5", "S6", "P0", "P1", "P2", "E0", "DC0"], var.sku_name)
    error_message = "sku_name must be one of F0, F1, S, S0, S1, S2, S3, S4, S5, S6, P0, P1, P2, E0, or DC0."
  }
}

variable "custom_subdomain_name" {
  type        = string
  description = "Optional custom subdomain name for the Azure OpenAI account. Defaults to the account name to support Entra ID auth and private endpoints."
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
  description = "Whether local authentication keys are enabled. Prefer Microsoft Entra ID auth for production."
  default     = false
}

variable "dynamic_throttling_enabled" {
  type        = bool
  description = "Whether account-level dynamic throttling is enabled. AzureRM does not send this setting unless true."
  default     = false
}

variable "fqdns" {
  type        = list(string)
  description = "Optional FQDN allow-list for the cognitive account."
  default     = []
}

variable "custom_question_answering_search_service_id" {
  type        = string
  description = "Optional Azure AI Search service ID for custom question answering scenarios."
  default     = ""

  validation {
    condition = (
      trimspace(var.custom_question_answering_search_service_id) == "" &&
      trimspace(var.custom_question_answering_search_service_key) == ""
      ) || (
      trimspace(var.custom_question_answering_search_service_id) != "" &&
      trimspace(var.custom_question_answering_search_service_key) != ""
    )
    error_message = "custom_question_answering_search_service_id and custom_question_answering_search_service_key must be provided together."
  }
}

variable "custom_question_answering_search_service_key" {
  type        = string
  description = "Optional Azure AI Search service key for custom question answering scenarios."
  default     = ""
  sensitive   = true
}

variable "system_assigned_identity_enabled" {
  type        = bool
  description = "Whether to enable a system-assigned managed identity. Ignored when legacy identity is provided."
  default     = true
}

variable "identity_ids" {
  type        = list(string)
  description = "Optional user-assigned managed identity IDs. Ignored when legacy identity is provided."
  default     = []

  validation {
    condition = alltrue([
      for value in var.identity_ids :
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.ManagedIdentity/userAssignedIdentities/.+$", value))
    ])
    error_message = "identity_ids must contain valid user-assigned managed identity resource IDs."
  }
}

variable "identity" {
  description = "Legacy managed identity configuration. Prefer system_assigned_identity_enabled and identity_ids for new deployments."
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
    condition     = var.customer_managed_key == null ? true : trimspace(var.customer_managed_key.key_vault_key_id) != ""
    error_message = "customer_managed_key.key_vault_key_id cannot be empty when customer_managed_key is provided."
  }
}

variable "network_acls" {
  description = "Optional network ACL configuration."
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

variable "enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint for the Azure OpenAI account."
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
    condition = (
      trimspace(var.private_dns_zone_id) == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/privateDnsZones/.+$", var.private_dns_zone_id))
    )
    error_message = "private_dns_zone_id must be empty or a valid Private DNS zone resource ID."
  }
}

variable "private_dns_zone_ids" {
  type        = list(string)
  description = "Optional list of private DNS zone IDs to attach to the private endpoint."
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
  description = "Existing private DNS zone name used when private DNS zone IDs are not supplied."
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

variable "deployments" {
  description = "Optional Azure OpenAI model deployments keyed by deployment name."
  type = map(object({
    model_format               = string
    model_name                 = string
    model_version              = optional(string)
    sku_name                   = string
    sku_capacity               = optional(number)
    sku_family                 = optional(string)
    sku_size                   = optional(string)
    sku_tier                   = optional(string)
    dynamic_throttling_enabled = optional(bool)
    rai_policy_name            = optional(string)
    version_upgrade_option     = optional(string)
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
      for deployment_name, deployment in var.deployments : (
        trimspace(deployment_name) != "" &&
        trimspace(deployment.model_format) == "OpenAI" &&
        trimspace(deployment.model_name) != "" &&
        trimspace(deployment.sku_name) != "" &&
        (deployment.sku_capacity == null ? true : deployment.sku_capacity >= 1) &&
        (deployment.version_upgrade_option == null ? true : contains(["OnceNewDefaultVersionAvailable", "OnceCurrentVersionExpired", "NoAutoUpgrade"], deployment.version_upgrade_option))
      )
    ])
    error_message = "Each deployment must have a non-empty name, model_format must be OpenAI, model_name and sku_name must be non-empty, sku_capacity must be at least 1 when set, and version_upgrade_option must be OnceNewDefaultVersionAvailable, OnceCurrentVersionExpired, or NoAutoUpgrade when provided."
  }
}

variable "app_admin_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that receive the admin role on the Azure OpenAI account."
  default     = []

  validation {
    condition     = alltrue([for value in var.app_admin_group : trimspace(value) != ""])
    error_message = "app_admin_group values must not be empty."
  }
}

variable "app_user_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that receive the user role on the Azure OpenAI account."
  default     = []

  validation {
    condition     = alltrue([for value in var.app_user_group : trimspace(value) != ""])
    error_message = "app_user_group values must not be empty."
  }
}

variable "app_admin_role_definition_name" {
  type        = string
  description = "Azure role assigned to app_admin_group principals at the Azure OpenAI account scope."
  default     = "Cognitive Services OpenAI Contributor"
}

variable "app_user_role_definition_name" {
  type        = string
  description = "Azure role assigned to app_user_group principals at the Azure OpenAI account scope."
  default     = "Cognitive Services OpenAI User"
}

variable "role_assignments" {
  description = "Additional role assignments scoped to the Azure OpenAI account."
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

variable "enable_diagnostics" {
  type        = bool
  description = "Whether to create diagnostic settings on the Azure OpenAI account. Diagnostics are also enabled automatically when any diagnostic destination ID is supplied."
  default     = false
}

variable "diagnostic_setting_name" {
  type        = string
  description = "Optional diagnostic setting name. Defaults to <account-name>-diagnostic-setting."
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
  default     = ["AllMetrics"]
}

variable "account_timeouts" {
  description = "Optional create/read/update/delete timeouts for the Azure OpenAI account."
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
  description = "A mapping of tags to assign to the Azure OpenAI resources."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

check "openai_input_consistency" {
  assert {
    condition     = var.customer_managed_key == null || local.identity_enabled
    error_message = "customer_managed_key requires identity to be configured on the Azure OpenAI account."
  }

  assert {
    condition = var.customer_managed_key == null || (
      try(trimspace(var.customer_managed_key.identity_client_id), "") == "" ||
      length(local.identity_ids) > 0
    )
    error_message = "customer_managed_key.identity_client_id requires at least one user-assigned identity in identity_ids or legacy identity.identity_ids."
  }

  assert {
    condition = (
      (trimspace(var.custom_question_answering_search_service_id) == "") ==
      (trimspace(var.custom_question_answering_search_service_key) == "")
    )
    error_message = "custom_question_answering_search_service_id and custom_question_answering_search_service_key must be set together."
  }

  assert {
    condition     = !var.enable_diagnostics || local.diagnostic_destination_enabled
    error_message = "enable_diagnostics requires at least one diagnostic destination: log_analytics_workspace_id, diagnostic_storage_account_id, or diagnostic_eventhub_authorization_rule_id."
  }

  assert {
    condition     = !var.enable_private_endpoint || !var.public_network_access_enabled || var.network_acls != null
    error_message = "When private endpoint and public access are both enabled, configure network_acls explicitly."
  }

  assert {
    condition = (
      try(trimspace(var.diagnostic_eventhub_name), "") == "" ||
      trimspace(var.diagnostic_eventhub_authorization_rule_id) != ""
    )
    error_message = "diagnostic_eventhub_authorization_rule_id is required when diagnostic_eventhub_name is set."
  }

  assert {
    condition     = !var.private_endpoint_manual_connection || trimspace(var.private_endpoint_manual_request_message) != ""
    error_message = "private_endpoint_manual_request_message is required for manual private endpoint connections."
  }
}
