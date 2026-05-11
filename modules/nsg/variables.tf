variable "name" {
  description = "Network Security Group name."
  type        = string

  validation {
    condition     = trimspace(var.name) != ""
    error_message = "name cannot be empty."
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
      contains(["Allow", "Deny"], rule.access)
    ])
    error_message = "Each rule must use direction Inbound or Outbound and access Allow or Deny."
  }
}

variable "subnet_ids" {
  description = "Subnet IDs to associate to the NSG."
  type        = list(string)
  default     = []
}

variable "network_interface_ids" {
  description = "Network interface IDs to associate to the NSG."
  type        = list(string)
  default     = []
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
