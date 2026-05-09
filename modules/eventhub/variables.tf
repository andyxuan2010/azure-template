variable "resource_group_name" {
  type        = string
  description = "Resource group where the Event Hub namespace will be deployed."

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  type        = string
  description = "Optional Azure region for the Event Hub namespace. Leave empty to use the target resource group's location."
  default     = ""
}

variable "name" {
  type        = string
  description = "Event Hub namespace name. Leave empty to auto-generate a unique name."
  default     = ""
}

variable "sku" {
  type        = string
  description = "Event Hub namespace SKU."
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be Basic, Standard, or Premium."
  }
}

variable "capacity" {
  type        = number
  description = "Event Hub namespace capacity."
  default     = 1
}

variable "auto_inflate_enabled" {
  type        = bool
  description = "Whether auto-inflate is enabled for the namespace."
  default     = false
}

variable "maximum_throughput_units" {
  type        = number
  description = "Maximum throughput units when auto-inflate is enabled."
  default     = 0

  validation {
    condition     = var.auto_inflate_enabled ? var.maximum_throughput_units >= 1 : var.maximum_throughput_units >= 0
    error_message = "maximum_throughput_units must be at least 1 when auto_inflate_enabled is true."
  }
}

variable "local_authentication_enabled" {
  type        = bool
  description = "Whether SAS/local authentication is enabled."
  default     = true
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether the public endpoint is enabled."
  default     = true
}

variable "minimum_tls_version" {
  type        = string
  description = "Minimum TLS version for the namespace."
  default     = "1.2"

  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "minimum_tls_version must be 1.0, 1.1, or 1.2."
  }
}

variable "system_managed_identity_enabled" {
  type        = bool
  description = "Whether to enable a system-assigned managed identity on the namespace."
  default     = false
}

variable "eventhubs" {
  type = map(object({
    partition_count   = optional(number, 2)
    message_retention = optional(number, 1)
    status            = optional(string, "Active")
  }))
  description = "Map of Event Hubs keyed by Event Hub name."
  default     = {}
}

variable "authorization_rules" {
  type = map(object({
    listen = optional(bool, false)
    send   = optional(bool, false)
    manage = optional(bool, false)
  }))
  description = "Optional namespace authorization rules keyed by rule name."
  default     = {}
}

variable "app_admin_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Contributor access to the namespace."
  default     = []
}

variable "app_user_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Reader access to the namespace."
  default     = []
}

variable "enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint for the Event Hub namespace."
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

variable "private_dns_zone_id" {
  type        = string
  description = "Optional private DNS zone ID to attach to the private endpoint."
  default     = ""
}

variable "enable_diagnostics" {
  type        = bool
  description = "Whether to create diagnostic settings on the Event Hub namespace."
  default     = false
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID used when diagnostics are enabled."
  default     = ""

  validation {
    condition     = var.enable_diagnostics ? trimspace(var.log_analytics_workspace_id) != "" : true
    error_message = "log_analytics_workspace_id must be set when enable_diagnostics is true."
  }
}

variable "diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable."
  default     = ["ArchiveLogs", "OperationalLogs", "AutoScaleLogs", "KafkaCoordinatorLogs", "KafkaUserErrorLogs", "EventHubVNetConnectionEvent", "CustomerManagedKeyUserLogs", "RuntimeAuditLogs", "ApplicationMetricsLogs"]
}

variable "diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable."
  default     = ["AllMetrics"]
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the Event Hub namespace."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}
