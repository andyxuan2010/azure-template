variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the virtual network will be deployed."

  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
    error_message = "resource_group_name cannot be empty."
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

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into virtual network resources."
  default     = true
}

variable "inherited_resource_group_tags" {
  type        = map(string)
  description = "Optional plan-known resource group tags supplied by the root composition. When null and inherit_resource_group_tags is true, the module falls back to reading the resource group."
  default     = null
}

variable "name" {
  type        = string
  description = "Virtual network name. If empty, the module auto-generates a compliant name."
  default     = ""

  validation {
    condition     = var.name == "" || can(regex("^[a-zA-Z0-9._()-]{2,64}$", var.name))
    error_message = "name must be empty or 2-64 characters and contain only letters, digits, periods, underscores, hyphens, or parentheses."
  }
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

variable "app_env" {
  type        = string
  default     = "dev"
  description = "Deployment environment used for the generated Environment tag."

  validation {
    condition     = contains(["prod", "staging", "dev", "qa", "sbx", "poc", "test"], var.app_env)
    error_message = "app_env must be one of: prod, staging, dev, qa, sbx, poc, test."
  }
}

variable "address_space" {
  type        = list(string)
  description = "The address spaces applied to the virtual network."

  validation {
    condition     = length(var.address_space) > 0
    error_message = "address_space must contain at least one CIDR block."
  }

  validation {
    condition = alltrue([
      for cidr in var.address_space :
      can(cidrhost(cidr, 0))
    ])
    error_message = "address_space must contain valid CIDR blocks."
  }

  validation {
    condition = alltrue([
      for cidr in var.address_space :
      try(cidr == cidrsubnet(cidr, 0, 0), false)
    ])
    error_message = "address_space CIDR blocks must use network-aligned prefixes, for example 10.42.0.0/22 instead of 10.42.1.0/22."
  }
}

variable "dns_servers" {
  type        = list(string)
  description = "Optional custom DNS server IP addresses for the virtual network."
  default     = []

  validation {
    condition = alltrue([
      for ip in var.dns_servers :
      can(cidrhost("${ip}/32", 0)) || can(cidrhost("${ip}/128", 0))
    ])
    error_message = "dns_servers must contain valid IPv4 or IPv6 addresses."
  }
}

variable "bgp_community" {
  type        = string
  description = "Optional BGP community value for the virtual network."
  default     = null

  validation {
    condition     = var.bgp_community == null || can(regex("^[0-9]+:[0-9]+$", var.bgp_community))
    error_message = "bgp_community must be null or in ASN:community format."
  }
}

variable "edge_zone" {
  type        = string
  description = "Optional Edge Zone where the virtual network will be deployed."
  default     = null
}

variable "flow_timeout_in_minutes" {
  type        = number
  description = "Optional flow timeout in minutes for the virtual network."
  default     = null

  validation {
    condition     = var.flow_timeout_in_minutes == null ? true : (var.flow_timeout_in_minutes >= 4 && var.flow_timeout_in_minutes <= 30)
    error_message = "flow_timeout_in_minutes must be null or between 4 and 30."
  }
}

variable "ddos_protection_plan_id" {
  type        = string
  description = "Optional DDoS protection plan ID to associate with the virtual network."
  default     = ""

  validation {
    condition     = var.ddos_protection_plan_id == "" || can(regex("^/subscriptions/.+/providers/Microsoft\\.Network/ddosProtectionPlans/.+$", var.ddos_protection_plan_id))
    error_message = "ddos_protection_plan_id must be empty or a valid Azure DDoS protection plan resource ID."
  }
}

variable "subnets" {
  type = map(object({
    address_prefixes                              = list(string)
    service_endpoints                             = optional(list(string), [])
    service_endpoint_policy_ids                   = optional(list(string), [])
    private_endpoint_network_policies             = optional(string, "Enabled")
    private_link_service_network_policies_enabled = optional(bool, true)
    delegations = optional(map(object({
      name                    = string
      service_delegation_name = string
      actions                 = optional(list(string), [])
    })), {})
  }))
  description = "Optional subnet definitions keyed by subnet name."
  default     = {}

  validation {
    condition = alltrue([
      for _, subnet in var.subnets :
      length(subnet.address_prefixes) > 0
    ])
    error_message = "Each subnet must define at least one address prefix."
  }

  validation {
    condition = alltrue(flatten([
      for _, subnet in var.subnets : [
        for cidr in subnet.address_prefixes :
        can(cidrhost(cidr, 0))
      ]
    ]))
    error_message = "Each subnet address_prefixes entry must be a valid CIDR block."
  }

  validation {
    condition = alltrue(flatten([
      for _, subnet in var.subnets : [
        for cidr in subnet.address_prefixes :
        try(cidr == cidrsubnet(cidr, 0, 0), false)
      ]
    ]))
    error_message = "Each subnet address_prefixes entry must use a network-aligned CIDR prefix."
  }

  validation {
    condition = alltrue(flatten([
      for _, subnet in var.subnets : [
        contains(["Disabled", "Enabled", "NetworkSecurityGroupEnabled", "RouteTableEnabled"], subnet.private_endpoint_network_policies)
      ]
    ]))
    error_message = "private_endpoint_network_policies must be Disabled, Enabled, NetworkSecurityGroupEnabled, or RouteTableEnabled."
  }

  validation {
    condition = alltrue(flatten([
      for _, subnet in var.subnets : [
        for policy_id in subnet.service_endpoint_policy_ids :
        can(regex("^/subscriptions/.+", policy_id))
      ]
    ]))
    error_message = "service_endpoint_policy_ids must contain valid Azure resource IDs."
  }

  validation {
    condition = alltrue(flatten([
      for _, subnet in var.subnets : [
        for _, delegation in subnet.delegations :
        trimspace(delegation.name) != "" && trimspace(delegation.service_delegation_name) != ""
      ]
    ]))
    error_message = "Each subnet delegation must set non-empty name and service_delegation_name values."
  }
}

variable "app_admin_group" {
  type        = list(string)
  description = "List of Entra group display names or object IDs that should receive Contributor access to the virtual network. Prefer object IDs when display names are not unique."
  default     = null

  validation {
    condition     = var.app_admin_group == null || alltrue([for value in var.app_admin_group : trimspace(value) != ""])
    error_message = "app_admin_group cannot contain empty values."
  }
}

variable "app_user_group" {
  type        = list(string)
  description = "List of Entra group display names or object IDs that should receive Reader access to the virtual network. Prefer object IDs when display names are not unique."
  default     = null

  validation {
    condition     = var.app_user_group == null || alltrue([for value in var.app_user_group : trimspace(value) != ""])
    error_message = "app_user_group cannot contain empty values."
  }
}

variable "enable_diagnostics" {
  type        = bool
  description = "Enable diagnostic settings for the virtual network."
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
  description = "Diagnostic log categories to enable."
  default     = []

  validation {
    condition     = alltrue([for value in var.diagnostic_log_categories : trimspace(value) != ""])
    error_message = "diagnostic_log_categories cannot contain empty values."
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
    error_message = "diagnostic_metric_categories must contain only supported Virtual Network metric categories."
  }
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

check "vnet_input_consistency" {
  assert {
    condition     = !var.enable_diagnostics || trimspace(var.log_analytics_workspace_id) != ""
    error_message = "log_analytics_workspace_id must be set when enable_diagnostics is true."
  }
}
