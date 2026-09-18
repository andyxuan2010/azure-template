variable "name" {
  description = "Optional Private Endpoint name override. Leave empty to generate one from the naming convention."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[A-Za-z0-9._-]{2,80}$", trimspace(var.name)))
    error_message = "name must be empty or 2-80 characters using letters, numbers, periods, underscores, or hyphens."
  }
}

variable "resource_group_name" {
  description = "Resource group where the Private Endpoint will be created."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  description = "Azure region for the Private Endpoint."
  type        = string

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location cannot be empty."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into Private Endpoint resources."
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
  description = "Workload identifier used when name is not provided."

  validation {
    condition     = length(trimspace(var.workload)) > 0
    error_message = "workload cannot be empty."
  }
}

variable "app_env" {
  type        = string
  default     = "dev"
  description = "Deployment environment used when name is not provided."

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

variable "subnet_id" {
  description = "Subnet resource ID where the Private Endpoint NIC will be placed. Preferred over subnet lookup inputs."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.subnet_id) == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/.+$", trimspace(var.subnet_id)))
    error_message = "subnet_id must be empty or a valid Azure subnet resource ID."
  }
}

variable "subnet_name" {
  description = "Subnet name used when subnet_id is not provided."
  type        = string
  default     = ""
}

variable "virtual_network_name" {
  description = "Virtual network name used when subnet_id is not provided."
  type        = string
  default     = ""
}

variable "virtual_network_resource_group_name" {
  description = "Virtual network resource group used when subnet_id is not provided. Defaults to resource_group_name when empty."
  type        = string
  default     = ""
}

variable "private_connection_resource_id" {
  description = "Resource ID of the target service for the Private Endpoint connection."
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/.+$", trimspace(var.private_connection_resource_id)))
    error_message = "private_connection_resource_id must be a valid Azure resource ID."
  }
}

variable "subresource_names" {
  description = "Target service subresource names, such as blob, vault, sites, sqlServer, namespace, or account."
  type        = list(string)

  validation {
    condition     = length(var.subresource_names) > 0 && alltrue([for value in var.subresource_names : trimspace(value) != ""])
    error_message = "subresource_names must contain at least one non-empty value."
  }
}

variable "private_service_connection_name" {
  description = "Optional private service connection name. Defaults to psc-<private-endpoint-name>."
  type        = string
  default     = ""
}

variable "is_manual_connection" {
  description = "Whether the Private Endpoint connection requires manual approval."
  type        = bool
  default     = false
}

variable "request_message" {
  description = "Optional request message for manual Private Endpoint approval."
  type        = string
  default     = ""
}

variable "custom_network_interface_name" {
  description = "Optional custom network interface name for the Private Endpoint NIC."
  type        = string
  default     = ""
}

variable "private_dns_zone_group_name" {
  description = "Private DNS zone group name when private DNS zones are associated."
  type        = string
  default     = "default"

  validation {
    condition     = trimspace(var.private_dns_zone_group_name) != ""
    error_message = "private_dns_zone_group_name cannot be empty."
  }
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs to associate with the Private Endpoint."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for value in var.private_dns_zone_ids :
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/privateDnsZones/.+$", trimspace(value)))
    ])
    error_message = "private_dns_zone_ids must contain valid Private DNS zone resource IDs."
  }
}

variable "private_dns_zone_names" {
  description = "Private DNS zone names to look up and associate with the Private Endpoint when IDs are not supplied."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for value in var.private_dns_zone_names : trimspace(value) != ""])
    error_message = "private_dns_zone_names cannot contain empty values."
  }
}

variable "private_dns_zone_resource_group_name" {
  description = "Resource group containing private_dns_zone_names. Required when private_dns_zone_names is set."
  type        = string
  default     = ""
}

variable "ip_configurations" {
  description = "Optional static IP configurations for the Private Endpoint."
  type = list(object({
    name               = string
    private_ip_address = string
    subresource_name   = string
    member_name        = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for config in var.ip_configurations :
      trimspace(config.name) != "" &&
      can(cidrhost("${config.private_ip_address}/32", 0)) &&
      trimspace(config.subresource_name) != ""
    ])
    error_message = "Each ip_configurations entry must include a name, valid IPv4 private_ip_address, and subresource_name."
  }
}

variable "tags" {
  description = "Tags applied to the Private Endpoint."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

check "private_endpoint_input_consistency" {
  assert {
    condition = trimspace(var.subnet_id) != "" || (
      trimspace(var.subnet_name) != "" &&
      trimspace(var.virtual_network_name) != ""
    )
    error_message = "Provide subnet_id, or provide subnet_name and virtual_network_name for lookup."
  }

  assert {
    condition     = length(var.private_dns_zone_names) == 0 || trimspace(var.private_dns_zone_resource_group_name) != ""
    error_message = "private_dns_zone_resource_group_name is required when private_dns_zone_names is set."
  }
}
