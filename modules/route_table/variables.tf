variable "name" {
  description = "Optional route table name override. Leave empty to generate one from the naming convention."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[A-Za-z0-9._-]{1,80}$", trimspace(var.name)))
    error_message = "name must be empty or 1-80 characters using letters, numbers, periods, underscores, or hyphens."
  }
}

variable "resource_group_name" {
  description = "Resource group where the route table will be created."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  description = "Azure region for the route table."
  type        = string

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location cannot be empty."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into route table resources."
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

variable "disable_bgp_route_propagation" {
  description = "Whether BGP route propagation is disabled."
  type        = bool
  default     = false
}

variable "routes" {
  description = "Route definitions keyed by route name."
  type = map(object({
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for name, route in var.routes :
      trimspace(name) != "" &&
      trimspace(route.address_prefix) != "" &&
      contains(["VirtualNetworkGateway", "VnetLocal", "Internet", "VirtualAppliance", "None"], route.next_hop_type) &&
      (
        route.next_hop_type == "VirtualAppliance"
        ? try(trimspace(route.next_hop_in_ip_address), "") != ""
        : try(trimspace(route.next_hop_in_ip_address), "") == ""
      )
    ])
    error_message = "Each route must have a non-empty name/address_prefix, a supported next_hop_type, and an IP address only when next_hop_type is VirtualAppliance."
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

variable "subnet_ids" {
  description = "Subnet IDs to associate with the route table."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for subnet_id in var.subnet_ids :
      can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+/subnets/[^/]+$", subnet_id))
    ])
    error_message = "subnet_ids must contain valid Azure subnet resource IDs."
  }
}

variable "tags" {
  description = "Tags applied to the route table."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}
