variable "resource_group_name" {
  type        = string
  description = "The name of the resource group containing the virtual network."

  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
    error_message = "resource_group_name cannot be empty."
  }
}

variable "virtual_network_name" {
  type        = string
  description = "The name of the existing virtual network where subnets will be created."

  validation {
    condition     = can(regex("^[a-zA-Z0-9._()-]{2,64}$", trimspace(var.virtual_network_name)))
    error_message = "virtual_network_name must be 2-64 characters and contain only letters, digits, periods, underscores, hyphens, or parentheses."
  }
}

variable "virtual_network_id" {
  type        = string
  description = "Optional virtual network resource ID used as the RBAC scope. When empty, the module looks up the virtual network by name and resource group."
  default     = ""

  validation {
    condition     = var.virtual_network_id == "" || can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+$", var.virtual_network_id))
    error_message = "virtual_network_id must be empty or a valid Azure virtual network resource ID."
  }
}

variable "workload" {
  type        = string
  default     = "project"
  description = "Workload metadata retained for composition compatibility."

  validation {
    condition     = length(trimspace(var.workload)) > 0
    error_message = "workload cannot be empty."
  }
}

variable "app_env" {
  type        = string
  default     = "dev"
  description = "Deployment environment metadata retained for composition compatibility."

  validation {
    condition     = contains(["prod", "staging", "dev", "qa", "sbx", "poc", "test"], var.app_env)
    error_message = "app_env must be one of: prod, staging, dev, qa, sbx, poc, test."
  }
}

variable "subnets" {
  type = map(object({
    address_prefixes                              = list(string)
    service_endpoints                             = optional(list(string), [])
    service_endpoint_policy_ids                   = optional(list(string), [])
    private_endpoint_network_policies             = optional(string, "Enabled")
    private_link_service_network_policies_enabled = optional(bool, true)
    network_security_group_id                     = optional(string, "")
    route_table_id                                = optional(string, "")
    delegations = optional(map(object({
      name                    = string
      service_delegation_name = string
      actions                 = optional(list(string), [])
    })), {})
  }))
  description = "Subnet definitions keyed by subnet name."

  validation {
    condition = length(var.subnets) > 0 && alltrue([
      for name, subnet in var.subnets :
      trimspace(name) != "" && length(subnet.address_prefixes) > 0
    ])
    error_message = "subnets must contain at least one subnet, and each subnet must have a non-empty name and at least one address prefix."
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
    condition = alltrue([
      for _, subnet in var.subnets :
      contains(["Disabled", "Enabled", "NetworkSecurityGroupEnabled", "RouteTableEnabled"], subnet.private_endpoint_network_policies)
    ])
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
    condition = alltrue([
      for _, subnet in var.subnets :
      subnet.network_security_group_id == "" || can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/networkSecurityGroups/[^/]+$", subnet.network_security_group_id))
    ])
    error_message = "network_security_group_id must be empty or a valid Azure network security group resource ID."
  }

  validation {
    condition = alltrue([
      for _, subnet in var.subnets :
      subnet.route_table_id == "" || can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/routeTables/[^/]+$", subnet.route_table_id))
    ])
    error_message = "route_table_id must be empty or a valid Azure route table resource ID."
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
  description = "List of Entra group display names or object IDs that should receive Contributor access to the virtual network scope. Prefer object IDs when display names are not unique."
  default     = null

  validation {
    condition     = var.app_admin_group == null || alltrue([for value in var.app_admin_group : trimspace(value) != ""])
    error_message = "app_admin_group cannot contain empty values."
  }
}

variable "app_user_group" {
  type        = list(string)
  description = "List of Entra group display names or object IDs that should receive Reader access to the virtual network scope. Prefer object IDs when display names are not unique."
  default     = null

  validation {
    condition     = var.app_user_group == null || alltrue([for value in var.app_user_group : trimspace(value) != ""])
    error_message = "app_user_group cannot contain empty values."
  }
}
