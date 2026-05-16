# Core Configuration Variables
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the Automation Account will be deployed."

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "Resource group name cannot be empty."
  }
}

variable "location" {
  type        = string
  description = "The Azure region where to deploy the resource. If empty, will use the resource group's location."
  default     = ""

  validation {
    condition     = var.location == "" || can(regex("^[a-z0-9-]+$", var.location))
    error_message = "Location must be a valid Azure region identifier."
  }
}

variable "name" {
  type        = string
  description = "Name of the Automation Account. If empty, will auto-generate using naming convention."
  default     = ""

  validation {
    condition     = var.name == "" || (length(var.name) >= 3 && length(var.name) <= 50)
    error_message = "Name must be between 3 and 50 characters if specified."
  }
}

variable "sku_name" {
  type        = string
  description = "The SKU name of the Automation Account. Valid values are 'Basic' or 'Free'."
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Free"], var.sku_name)
    error_message = "SKU name must be either 'Basic' or 'Free'."
  }
}

# Security Configuration
variable "local_auth_enabled" {
  type        = bool
  description = "Whether to enable local authentication (API key) for the Automation Account. When false, only RBAC authentication is used."
  default     = false
}

variable "public_access_enabled" {
  type        = bool
  description = "Whether the Automation Account endpoint can be accessed from the Internet. When true, the endpoint is publicly accessible."
  default     = false
}

variable "system_managed_identity_enabled" {
  type        = bool
  description = "Whether to enable a system-assigned managed identity for the Automation Account."
  default     = true
}

variable "app_admin_group" {
  type        = list(string)
  description = "Microsoft Entra group display names or object IDs granted Contributor on the Automation Account."
  default     = []
}

variable "app_user_group" {
  type        = list(string)
  description = "Microsoft Entra group display names or object IDs granted Reader on the Automation Account."
  default     = []
}

variable "managed_identity_role_assignments" {
  type = map(object({
    scope                = string
    role_definition_name = optional(string)
    role_definition_id   = optional(string)
  }))
  description = "Role assignments to apply to the Automation Account system-assigned managed identity. Each entry must include `scope` and exactly one of `role_definition_name` or `role_definition_id`."
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
}

# Private Endpoint Configuration
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
  description = "Legacy behavior only: list of VNET names that should default to 'PrivateEndpoint2' instead of 'PrivateEndpoint' when private_endpoint_subnet_name is not provided."
  default     = ["dv1vnt001"]
}

variable "private_endpoint_subresource_name" {
  type        = string
  description = "Automation Account private endpoint subresource to connect. Valid values: Webhook, DSCAndHybridWorker. The legacy value DscAndHybridWorker is also accepted and normalized."
  default     = "Webhook"

  validation {
    condition     = contains(["Webhook", "DSCAndHybridWorker", "DscAndHybridWorker"], var.private_endpoint_subresource_name)
    error_message = "private_endpoint_subresource_name must be either 'Webhook' or 'DSCAndHybridWorker'."
  }
}

variable "enable_webhook_private_endpoint" {
  type        = bool
  description = "When set, explicitly control creation of the Webhook private endpoint. Leave null to use the legacy private_endpoint_subresource_name behavior."
  default     = null
}

variable "enable_hrw_private_endpoint" {
  type        = bool
  description = "When set, explicitly control creation of the DSCAndHybridWorker private endpoint. Leave null to use the legacy private_endpoint_subresource_name behavior."
  default     = null
}

variable "private_dns_zone_id" {
  type        = string
  description = "Optional private DNS zone resource ID to link to the private endpoint. Example: /subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.azure-automation.net"
  default     = ""

  validation {
    condition     = var.private_dns_zone_id == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/privateDnsZones/.+$", var.private_dns_zone_id))
    error_message = "private_dns_zone_id must be empty or a valid Azure Private DNS Zone resource ID."
  }
}

# Monitoring & Diagnostics
variable "enable_diagnostics" {
  type        = bool
  description = "Enable diagnostic settings for the Automation Account."
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
  description = "List of diagnostic log categories to enable."
  default     = []

  validation {
    condition = alltrue([
      for value in var.diagnostic_log_categories :
      contains([
        "JobLogs",
        "JobStreams",
        "AuditEvent",
        "DscNodeStatus",
        "AllLogs"
      ], value)
    ])
    error_message = "diagnostic_log_categories contains unsupported values for this module."
  }
}

variable "diagnostic_metric_categories" {
  type        = list(string)
  description = "List of diagnostic metric categories to enable."
  default     = ["AllMetrics"]

  validation {
    condition = alltrue([
      for value in var.diagnostic_metric_categories :
      contains(["AllMetrics"], value)
    ])
    error_message = "diagnostic_metric_categories must contain only supported metric categories."
  }
}

# Tagging
variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

check "automationaccount_input_consistency" {
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
    condition = (
      alltrue([
        for _, assignment in var.managed_identity_role_assignments :
        can(regex("^/subscriptions/.+", assignment.scope))
      ])
    )
    error_message = "Each managed_identity_role_assignments.scope must be a valid Azure resource scope."
  }
}
