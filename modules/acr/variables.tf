variable "name" {
  type        = string
  description = "Default prefix of the resource name that will be created. Leave empty to auto-generate."
  default     = ""

  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[a-z0-9-]{1,30}$", lower(trimspace(var.name))))
    error_message = "name must be empty or 1-30 lowercase alphanumeric characters and hyphens."
  }
}

variable "app_env" {
  type        = string
  default     = "dev"
  description = "Environment, the environment name such as 'sbx','test', 'prod', 'dev','qa', 'poc'"
  validation {
    condition     = contains(["prod", "dev", "qa", "sbx", "test", "poc"], var.app_env)
    error_message = "Only valid environment names are expected."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Existing resource group name where the Azure Container Registry will be created."

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  type        = string
  description = "Azure region for the Azure Container Registry. If empty, the resource group's location is used."
  default     = ""

  validation {
    condition     = trimspace(var.location) == "" || can(regex("^[a-z0-9-]+$", trimspace(var.location)))
    error_message = "location must be empty or a valid Azure region identifier."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into Azure Container Registry resources."
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

variable "sku" {
  type        = string
  description = "SKU for the Azure Container Registry."
  default     = "Premium"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be one of: Basic, Standard, Premium."
  }
}

variable "admin_enabled" {
  type        = bool
  description = "Whether the admin user is enabled for the registry."
  default     = false
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled for the registry."
  default     = false
}

variable "anonymous_pull_enabled" {
  type        = bool
  description = "Whether anonymous pull access is enabled."
  default     = false

  validation {
    condition     = !var.anonymous_pull_enabled || contains(["Standard", "Premium"], var.sku)
    error_message = "anonymous_pull_enabled is only supported with Standard or Premium SKU."
  }
}

variable "data_endpoint_enabled" {
  type        = bool
  description = "Whether dedicated data endpoints are enabled."
  default     = false

  validation {
    condition     = !var.data_endpoint_enabled || var.sku == "Premium"
    error_message = "data_endpoint_enabled is only supported with Premium SKU."
  }
}

variable "identity_type" {
  description = "Specifies the type of Managed Service Identity that should be configured on this Container Registry. Possible values are SystemAssigned, UserAssigned, SystemAssigned, UserAssigned, or None."
  type        = string
  default     = "None"

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned", "None"], var.identity_type)
    error_message = "identity_type must be one of: SystemAssigned, UserAssigned, SystemAssigned, UserAssigned, or None."
  }
}

variable "identity_ids" {
  description = "Specifies a list of User Assigned Managed Identity IDs to be assigned to this Container Registry. Required if identity_type contains UserAssigned."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for identity_id in var.identity_ids :
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.ManagedIdentity/userAssignedIdentities/.+$", identity_id))
    ])
    error_message = "identity_ids must contain valid user-assigned managed identity resource IDs."
  }
}

variable "managed_identity_role_assignments" {
  type = map(object({
    scope                = string
    role_definition_name = optional(string)
    role_definition_id   = optional(string)
  }))
  description = "Role assignments to apply to the registry's system-assigned managed identity. Each item must set exactly one of role_definition_name or role_definition_id."
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

variable "customer_managed_key_id" {
  description = "Specifies the Key Vault Key ID to use to encrypt the Container Registry."
  type        = string
  default     = null

  validation {
    condition = (
      var.customer_managed_key_id == null ||
      can(regex("^https://.+\\.vault\\.azure\\.net/keys/.+/.+$", var.customer_managed_key_id)) ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.KeyVault/vaults/.+/keys/.+/.+$", var.customer_managed_key_id))
    )
    error_message = "customer_managed_key_id must be null or a valid Key Vault key ID."
  }
}

variable "customer_managed_key_identity_client_id" {
  description = "Specifies the client ID of the user assigned identity to use to encrypt the Container Registry. Requires customer_managed_key_id."
  type        = string
  default     = null

  validation {
    condition = (
      var.customer_managed_key_identity_client_id == null ||
      can(regex("^[0-9a-fA-F-]{36}$", var.customer_managed_key_identity_client_id))
    )
    error_message = "customer_managed_key_identity_client_id must be null or a valid GUID."
  }
}

variable "export_policy_enabled" {
  type        = bool
  description = "Whether export policy is enabled for the registry."
  default     = true
}

variable "quarantine_policy_enabled" {
  type        = bool
  description = "Whether quarantine policy is enabled for the registry."
  default     = false
}

variable "retention_policy_in_days" {
  type        = number
  description = "The number of days to retain untagged manifests before purge. Supported only on Premium SKU."
  default     = null

  validation {
    condition = var.retention_policy_in_days == null ? true : (
      var.retention_policy_in_days >= 0 &&
      floor(var.retention_policy_in_days) == var.retention_policy_in_days
    )
    error_message = "retention_policy_in_days must be null or a whole number greater than or equal to 0."
  }
}

variable "trust_policy_enabled" {
  type        = bool
  description = "Whether trust policy is enabled for the registry."
  default     = false
}

variable "zone_redundancy_enabled" {
  type        = bool
  description = "Whether zone redundancy is enabled for the primary registry. Supported only on Premium SKU."
  default     = false
}

variable "georeplications" {
  description = "A list of georeplication locations for the Container Registry."
  type = list(object({
    location                  = string
    regional_endpoint_enabled = optional(bool, true)
    zone_redundancy_enabled   = optional(bool, false)
    tags                      = optional(map(string), {})
  }))
  default = []

  validation {
    condition = alltrue([
      for rep in var.georeplications : trimspace(rep.location) != ""
    ])
    error_message = "All georeplication locations must be valid non-empty strings."
  }

  validation {
    condition = length(distinct([
      for rep in var.georeplications : lower(trimspace(rep.location))
    ])) == length(var.georeplications)
    error_message = "georeplications locations must be unique."
  }
}

variable "enable_network_rule_set" {
  type        = bool
  description = "Whether to configure ACR network rules."
  default     = false

  validation {
    condition     = !var.enable_network_rule_set || var.sku == "Premium"
    error_message = "enable_network_rule_set is only supported with Premium SKU."
  }
}

variable "network_rule_bypass_option" {
  type        = string
  description = "Bypass option for the ACR network rule set."
  default     = "AzureServices"

  validation {
    condition     = contains(["AzureServices", "None"], var.network_rule_bypass_option)
    error_message = "network_rule_bypass_option must be AzureServices or None."
  }
}

variable "network_rule_default_action" {
  type        = string
  description = "Default action for the ACR network rule set."
  default     = "Deny"

  validation {
    condition     = contains(["Allow", "Deny"], var.network_rule_default_action)
    error_message = "network_rule_default_action must be Allow or Deny."
  }
}

variable "network_rule_ip_rules" {
  type        = list(string)
  description = "Optional list of allowed public IP CIDR ranges for ACR network rules."
  default     = []

  validation {
    condition = alltrue([
      for value in var.network_rule_ip_rules :
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}(/([0-9]|[1-2][0-9]|3[0-2]))?$", trimspace(value))) ||
      can(regex("^[0-9A-Fa-f:]+(/(12[0-8]|1[01][0-9]|[1-9]?[0-9]))?$", trimspace(value)))
    ])
    error_message = "network_rule_ip_rules entries must be valid IPv4/IPv6 addresses or CIDR ranges."
  }
}

variable "app_admin_group" {
  type        = list(string)
  description = "Entra groups that receive Contributor on the registry resource. Values may be display names or object IDs."
  default     = null
}

variable "app_user_group" {
  type        = list(string)
  description = "Entra groups that receive Reader on the registry resource. Values may be display names or object IDs."
  default     = null
}

variable "enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint for the registry."
  default     = false

  validation {
    condition     = !var.enable_private_endpoint || var.sku == "Premium"
    error_message = "enable_private_endpoint is only supported with Premium SKU."
  }

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
  description = "Subnet ID for the private endpoint. Leave empty to resolve it from subnet/vnet/resource group names."
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
  description = "Private endpoint subnet name used when private_endpoint_subnet_id is empty."
  default     = ""
}

variable "private_endpoint_vnet_name" {
  type        = string
  description = "Private endpoint virtual network name used when private_endpoint_subnet_id is empty."
  default     = ""
}

variable "private_endpoint_network_resource_group_name" {
  type        = string
  description = "Resource group containing the private endpoint virtual network when resolving the subnet by name."
  default     = ""

  validation {
    condition = (
      (trimspace(var.private_endpoint_subnet_name) == "" && trimspace(var.private_endpoint_vnet_name) == "" && trimspace(var.private_endpoint_network_resource_group_name) == "") ||
      (trimspace(var.private_endpoint_subnet_name) != "" && trimspace(var.private_endpoint_vnet_name) != "" && trimspace(var.private_endpoint_network_resource_group_name) != "")
    )
    error_message = "private_endpoint_subnet_name, private_endpoint_vnet_name, and private_endpoint_network_resource_group_name must either all be set or all be empty."
  }
}

variable "private_dns_zone_id" {
  type        = string
  description = "Optional private DNS zone ID for the registry private endpoint."
  default     = ""

  validation {
    condition = (
      trimspace(var.private_dns_zone_id) == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/privateDnsZones/.+$", var.private_dns_zone_id))
    )
    error_message = "private_dns_zone_id must be empty or a valid Private DNS zone resource ID."
  }
}

variable "private_dns_zone_name" {
  type        = string
  description = "Optional existing Private DNS zone name used to look up the registry private endpoint DNS zone when private_dns_zone_id is not set."
  default     = ""
}

variable "private_dns_zone_resource_group_name" {
  type        = string
  description = "Resource group containing the Private DNS zone used for ACR private endpoint DNS lookup."
  default     = ""

  validation {
    condition = (
      (trimspace(var.private_dns_zone_name) == "" && trimspace(var.private_dns_zone_resource_group_name) == "") ||
      (trimspace(var.private_dns_zone_name) != "" && trimspace(var.private_dns_zone_resource_group_name) != "")
    )
    error_message = "private_dns_zone_name and private_dns_zone_resource_group_name must either both be set or both be empty."
  }
}

variable "enable_diagnostics" {
  type        = bool
  description = "Whether to create a diagnostic setting for the registry."
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
  default     = ["ContainerRegistryRepositoryEvents", "ContainerRegistryLoginEvents"]

  validation {
    condition = alltrue([
      for value in var.diagnostic_log_categories :
      contains(["ContainerRegistryRepositoryEvents", "ContainerRegistryLoginEvents"], value)
    ])
    error_message = "diagnostic_log_categories must contain only supported ACR log categories."
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
    error_message = "diagnostic_metric_categories must contain only supported ACR metric categories."
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

check "acr_input_consistency" {
  assert {
    condition = !var.enable_private_endpoint || (
      trimspace(var.private_dns_zone_id) != "" || (
        trimspace(var.private_dns_zone_name) == "" &&
        trimspace(var.private_dns_zone_resource_group_name) == ""
        ) || (
        trimspace(var.private_dns_zone_name) != "" &&
        trimspace(var.private_dns_zone_resource_group_name) != ""
      )
    )
    error_message = "When enable_private_endpoint is true, set private_dns_zone_id or provide both private_dns_zone_name and private_dns_zone_resource_group_name."
  }

  assert {
    condition     = !contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type) || length(var.identity_ids) > 0
    error_message = "identity_ids must be provided when identity_type contains UserAssigned."
  }

  assert {
    condition     = length(var.georeplications) == 0 || var.sku == "Premium"
    error_message = "georeplications are only supported with the Premium SKU."
  }

  assert {
    condition = (
      var.customer_managed_key_id == null &&
      var.customer_managed_key_identity_client_id == null
      ) || (
      var.customer_managed_key_id != null &&
      var.customer_managed_key_identity_client_id != null &&
      contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    )
    error_message = "customer_managed_key_id and customer_managed_key_identity_client_id must both be set together, and customer-managed keys require identity_type to include UserAssigned."
  }

  assert {
    condition     = var.export_policy_enabled || !var.public_network_access_enabled
    error_message = "export_policy_enabled can only be set to false when public_network_access_enabled is false."
  }

  assert {
    condition     = !var.zone_redundancy_enabled || var.sku == "Premium"
    error_message = "zone_redundancy_enabled is only supported with the Premium SKU."
  }

  assert {
    condition     = !var.quarantine_policy_enabled || var.sku == "Premium"
    error_message = "quarantine_policy_enabled is only supported with the Premium SKU."
  }

  assert {
    condition     = !var.trust_policy_enabled || var.sku == "Premium"
    error_message = "trust_policy_enabled is only supported with the Premium SKU."
  }

  assert {
    condition     = var.retention_policy_in_days == null || var.sku == "Premium"
    error_message = "retention_policy_in_days is only supported with the Premium SKU."
  }

  assert {
    condition     = length(var.managed_identity_role_assignments) == 0 || contains(["SystemAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "managed_identity_role_assignments requires identity_type to include SystemAssigned."
  }

  assert {
    condition = length(var.georeplications) == 0 || alltrue([
      for rep in var.georeplications : lower(trimspace(rep.location)) != lower(local.location)
    ])
    error_message = "georeplications cannot include the primary registry location."
  }
}
