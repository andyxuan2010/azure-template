variable "name" {
  description = "Route table name."
  type        = string
  default     = "rt-shared-cc-prod-001"
}

variable "resource_group_name" {
  description = "Existing network resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the route table."
  type        = string
  default     = "canadacentral"
}

variable "disable_bgp_route_propagation" {
  description = "Whether to suppress BGP-learned routes."
  type        = bool
  default     = false
}

variable "routes" {
  description = "User-defined routes keyed by route name."
  type = map(object({
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = {
    firewall_default = {
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4"
    }
    local_services = {
      address_prefix = "10.20.0.0/16"
      next_hop_type  = "VnetLocal"
    }
  }
}

variable "subnet_ids" {
  description = "Existing subnet IDs associated with the route table."
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to the route table."
  type        = map(string)
  default = {
    Environment = "prod"
    ManagedBy   = "Terraform"
    Service     = "SharedNetwork"
  }
}
