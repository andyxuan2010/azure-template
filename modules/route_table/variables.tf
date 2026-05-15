variable "name" {
  description = "Route table name."
  type        = string

  validation {
    condition     = trimspace(var.name) != ""
    error_message = "name cannot be empty."
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
}

variable "subnet_ids" {
  description = "Subnet IDs to associate with the route table."
  type        = list(string)
  default     = []
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
