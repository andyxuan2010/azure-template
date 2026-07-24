variable "name" {
  description = "Optional Network Security Group name override. Leave empty to generate one from the naming convention."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[A-Za-z0-9._-]{1,80}$", trimspace(var.name)))
    error_message = "name must be empty or 1-80 characters using letters, numbers, periods, underscores, or hyphens."
  }
}

variable "resource_group_name" {
  description = "Resource group where the NSG will be created."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  description = "Azure region for the NSG."
  type        = string

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location cannot be empty."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into NSG resources."
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

variable "app_env" {
  type        = string
  default     = "dev"
  description = "Deployment environment metadata retained for interface compatibility."

  validation {
    condition     = contains(["prod", "staging", "dev", "qa", "sbx", "poc", "test"], var.app_env)
    error_message = "app_env must be one of: prod, staging, dev, qa, sbx, poc, test."
  }
}

variable "instance" {
  description = "Instance identifier used when name is not provided."
  type        = string
  default     = "001"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,12}$", trimspace(var.instance)))
    error_message = "instance must be 1-12 lowercase letters, numbers, or hyphens."
  }
}

variable "security_rules" {
  description = "Map of NSG rules keyed by rule name."
  type = map(object({
    priority                                   = number
    direction                                  = string
    access                                     = string
    protocol                                   = string
    source_port_range                          = optional(string)
    source_port_ranges                         = optional(list(string))
    destination_port_range                     = optional(string)
    destination_port_ranges                    = optional(list(string))
    source_address_prefix                      = optional(string)
    source_address_prefixes                    = optional(list(string))
    destination_address_prefix                 = optional(string)
    destination_address_prefixes               = optional(list(string))
    source_application_security_group_ids      = optional(list(string))
    destination_application_security_group_ids = optional(list(string))
    description                                = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for _, rule in var.security_rules :
      contains(["Inbound", "Outbound"], rule.direction) &&
      contains(["Allow", "Deny"], rule.access) &&
      contains(["Tcp", "Udp", "Icmp", "Esp", "Ah", "*"], rule.protocol) &&
      rule.priority >= 100 &&
      rule.priority <= 4096 &&
      floor(rule.priority) == rule.priority
    ])
    error_message = "Each rule requires a supported direction, access, protocol, and whole-number priority from 100 through 4096."
  }

  validation {
    condition = length(distinct([
      for rule in values(var.security_rules) : "${rule.direction}:${rule.priority}"
    ])) == length(var.security_rules)
    error_message = "Security rule priorities must be unique within each direction."
  }

  validation {
    condition = alltrue([
      for rule in values(var.security_rules) :
      !(try(rule.source_port_range, null) != null && try(rule.source_port_ranges, null) != null) &&
      !(try(rule.destination_port_range, null) != null && try(rule.destination_port_ranges, null) != null) &&
      length(compact([
        try(rule.source_address_prefix, null),
        length(coalesce(try(rule.source_address_prefixes, null), [])) > 0 ? "prefixes" : null,
        length(coalesce(try(rule.source_application_security_group_ids, null), [])) > 0 ? "asgs" : null
      ])) <= 1 &&
      length(compact([
        try(rule.destination_address_prefix, null),
        length(coalesce(try(rule.destination_address_prefixes, null), [])) > 0 ? "prefixes" : null,
        length(coalesce(try(rule.destination_application_security_group_ids, null), [])) > 0 ? "asgs" : null
      ])) <= 1
    ])
    error_message = "Rules cannot mix singular/plural port fields or multiple address source forms."
  }
}

variable "subnet_ids" {
  description = "Subnet IDs to associate to the NSG."
  type        = list(string)
  default     = []

  validation {
    condition = (
      length(distinct(var.subnet_ids)) == length(var.subnet_ids) &&
      alltrue([
        for value in var.subnet_ids :
        can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/.+$", value))
      ])
    )
    error_message = "subnet_ids must contain unique valid Azure subnet resource IDs."
  }
}

variable "subnet_associations" {
  description = "Subnet IDs to associate to the NSG, keyed by stable caller-defined names. Use this when subnet IDs are unknown until apply."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for key, value in var.subnet_associations :
      trimspace(key) != "" &&
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/.+$", value))
    ])
    error_message = "subnet_associations must be keyed by non-empty static names and contain valid Azure subnet resource IDs."
  }
}

variable "network_interface_ids" {
  description = "Network interface IDs to associate to the NSG."
  type        = list(string)
  default     = []

  validation {
    condition = (
      length(distinct(var.network_interface_ids)) == length(var.network_interface_ids) &&
      alltrue([
        for value in var.network_interface_ids :
        can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/networkInterfaces/.+$", value))
      ])
    )
    error_message = "network_interface_ids must contain unique valid Azure network interface resource IDs."
  }
}

variable "network_interface_associations" {
  description = "Network interface IDs to associate to the NSG, keyed by stable caller-defined names. Use this when NIC IDs are unknown until apply."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for key, value in var.network_interface_associations :
      trimspace(key) != "" &&
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/networkInterfaces/.+$", value))
    ])
    error_message = "network_interface_associations must be keyed by non-empty static names and contain valid Azure network interface resource IDs."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the NSG."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}
