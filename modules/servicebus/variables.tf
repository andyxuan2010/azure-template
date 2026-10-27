variable "resource_group_name" {
  type        = string
  description = "Resource group where the Service Bus namespace will be deployed."

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  type        = string
  description = "Optional Azure region for the Service Bus namespace. Leave empty to use the target resource group's location."
  default     = ""
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into Service Bus resources."
  default     = true
}

variable "inherited_resource_group_tags" {
  type        = map(string)
  description = "Optional plan-known resource group tags supplied by the root composition. When null and inherit_resource_group_tags is true, the module falls back to reading the resource group."
  default     = null
}

variable "name" {
  type        = string
  description = "Service Bus namespace name. Leave empty to auto-generate a unique name."
  default     = ""

  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[a-z][a-z0-9-]{4,48}[a-z0-9]$", var.name))
    error_message = "name must be empty or 6-50 lowercase letters, numbers, and hyphens, starting with a letter and ending with a letter or number."
  }
}

variable "workload" {
  type        = string
  default     = "project"
  description = "Workload metadata retained for composition compatibility; tags are supplied explicitly through tags."

  validation {
    condition     = length(trimspace(var.workload)) > 0
    error_message = "workload cannot be empty."
  }
}

variable "app_env" {
  type        = string
  default     = "dev"
  description = "Deployment environment metadata retained for composition compatibility; no tag is generated automatically."

  validation {
    condition     = contains(["prod", "staging", "dev", "qa", "sbx", "poc", "test"], var.app_env)
    error_message = "app_env must be one of: prod, staging, dev, qa, sbx, poc, test."
  }
}

variable "sku" {
  type        = string
  description = "Service Bus namespace SKU."
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be Basic, Standard, or Premium."
  }
}

variable "capacity" {
  type        = number
  description = "Service Bus namespace capacity."
  default     = 0
}

variable "premium_messaging_partitions" {
  type        = number
  description = "Premium messaging partitions for Premium SKU."
  default     = 0
}

variable "local_auth_enabled" {
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

variable "enable_network_rule_set" {
  type        = bool
  description = "Whether to configure network rules on the namespace."
  default     = false
}

variable "network_rule_default_action" {
  type        = string
  description = "Default action for the namespace network rule set."
  default     = "Allow"

  validation {
    condition     = contains(["Allow", "Deny"], var.network_rule_default_action)
    error_message = "network_rule_default_action must be Allow or Deny."
  }
}

variable "network_rule_ip_rules" {
  type        = list(string)
  description = "Allowed IP rules for the namespace network rule set."
  default     = []
}

variable "trusted_services_allowed" {
  type        = bool
  description = "Whether trusted Microsoft services are allowed through network rules."
  default     = false
}

variable "network_rules" {
  type = list(object({
    subnet_id                            = string
    ignore_missing_vnet_service_endpoint = optional(bool, false)
  }))
  description = "Optional subnet-based network rules."
  default     = []
}

variable "queues" {
  type = map(object({
    max_size_in_megabytes                   = optional(number, 1024)
    max_delivery_count                      = optional(number, 10)
    lock_duration                           = optional(string, "PT1M")
    default_message_ttl                     = optional(string, "P14D")
    auto_delete_on_idle                     = optional(string)
    dead_lettering_on_message_expiration    = optional(bool, true)
    duplicate_detection_history_time_window = optional(string)
    requires_duplicate_detection            = optional(bool, false)
    requires_session                        = optional(bool, false)
    partitioning_enabled                    = optional(bool, false)
    express_enabled                         = optional(bool, false)
    batched_operations_enabled              = optional(bool, true)
    status                                  = optional(string, "Active")
    forward_to                              = optional(string)
    forward_dead_lettered_messages_to       = optional(string)
  }))
  description = "Map of Service Bus queues keyed by queue name."
  default     = {}
}

variable "topics" {
  type = map(object({
    max_size_in_megabytes                   = optional(number, 1024)
    default_message_ttl                     = optional(string, "P14D")
    auto_delete_on_idle                     = optional(string)
    duplicate_detection_history_time_window = optional(string)
    requires_duplicate_detection            = optional(bool, false)
    partitioning_enabled                    = optional(bool, false)
    express_enabled                         = optional(bool, false)
    batched_operations_enabled              = optional(bool, true)
    support_ordering                        = optional(bool, false)
    status                                  = optional(string, "Active")
  }))
  description = "Map of Service Bus topics keyed by topic name."
  default     = {}
}

variable "subscriptions" {
  type = map(object({
    topic_name                                = string
    max_delivery_count                        = optional(number, 10)
    lock_duration                             = optional(string, "PT1M")
    default_message_ttl                       = optional(string, "P14D")
    auto_delete_on_idle                       = optional(string)
    dead_lettering_on_message_expiration      = optional(bool, true)
    dead_lettering_on_filter_evaluation_error = optional(bool, false)
    requires_session                          = optional(bool, false)
    batched_operations_enabled                = optional(bool, true)
    status                                    = optional(string, "Active")
    forward_to                                = optional(string)
    forward_dead_lettered_messages_to         = optional(string)
    client_scoped_subscription_enabled        = optional(bool, false)
  }))
  description = "Map of Service Bus subscriptions keyed by subscription name."
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
  description = "Whether to create a private endpoint for the Service Bus namespace."
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
  description = "Whether to create diagnostic settings on the Service Bus namespace."
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
  default     = ["OperationalLogs", "VNetAndIPFilteringLogs", "RuntimeAuditLogs", "ApplicationMetricsLogs"]
}

variable "diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable."
  default     = ["AllMetrics"]
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the Service Bus namespace."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

check "servicebus_input_consistency" {
  assert {
    condition = (
      (var.sku == "Premium" && contains([1, 2, 4, 8, 16], var.capacity)) ||
      (var.sku != "Premium" && var.capacity == 0)
    )
    error_message = "capacity must be 0 for Basic/Standard, or 1, 2, 4, 8, or 16 for Premium."
  }

  assert {
    condition = (
      (var.sku == "Premium" && contains([1, 2, 4], var.premium_messaging_partitions)) ||
      (var.sku != "Premium" && var.premium_messaging_partitions == 0)
    )
    error_message = "premium_messaging_partitions must be 0 for Basic/Standard, or 1, 2, or 4 for Premium."
  }

  assert {
    condition     = var.sku != "Basic" || (length(var.topics) == 0 && length(var.subscriptions) == 0)
    error_message = "Basic SKU supports queues only; topics and subscriptions require Standard or Premium."
  }

  assert {
    condition = alltrue([
      for _, subscription in var.subscriptions : contains(keys(var.topics), subscription.topic_name)
    ])
    error_message = "Every subscription topic_name must reference a topic declared in topics."
  }

  assert {
    condition = alltrue([
      for _, rule in var.authorization_rules :
      (rule.listen || rule.send || rule.manage) &&
      (!rule.manage || (rule.listen && rule.send))
    ])
    error_message = "Authorization rules must grant at least one permission; manage requires both listen and send."
  }
}
