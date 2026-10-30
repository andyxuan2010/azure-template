variable "name" {
  description = "Optional NAT Gateway name override. Leave empty to generate one from the naming convention."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[A-Za-z0-9._-]{1,80}$", trimspace(var.name)))
    error_message = "name must be empty or 1-80 characters using letters, numbers, periods, underscores, or hyphens."
  }
}

variable "resource_group_name" {
  description = "Resource group where the NAT Gateway and any module-created public IPs will be created."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  description = "Azure region for the NAT Gateway and any module-created public IPs."
  type        = string

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location cannot be empty."
  }
}

variable "sku_name" {
  description = "NAT Gateway SKU. Standard is zonal or no-zone; StandardV2 is zone-redundant and requires StandardV2 public IPs."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "StandardV2"], var.sku_name)
    error_message = "sku_name must be Standard or StandardV2."
  }
}

variable "idle_timeout_in_minutes" {
  description = "Outbound flow idle timeout in minutes."
  type        = number
  default     = 4

  validation {
    condition     = var.idle_timeout_in_minutes >= 4 && var.idle_timeout_in_minutes <= 120 && floor(var.idle_timeout_in_minutes) == var.idle_timeout_in_minutes
    error_message = "idle_timeout_in_minutes must be a whole number from 4 through 120."
  }
}

variable "zones" {
  description = "Optional single availability zone for a Standard NAT Gateway. Must be empty for StandardV2."
  type        = list(string)
  default     = []

  validation {
    condition = var.sku_name == "StandardV2" ? length(var.zones) == 0 : (
      length(var.zones) <= 1 && alltrue([for zone in var.zones : contains(["1", "2", "3"], zone)])
    )
    error_message = "Standard supports zero or one zone from 1, 2, or 3; StandardV2 requires zones to be empty."
  }
}

variable "subnet_ids" {
  description = "One or more existing subnet IDs to associate with the NAT Gateway. All subnets must be in the same virtual network."
  type        = list(string)

  validation {
    condition = (
      length(var.subnet_ids) > 0 &&
      length(distinct(var.subnet_ids)) == length(var.subnet_ids) &&
      length(distinct([for subnet_id in var.subnet_ids : split("/subnets/", trimspace(subnet_id))[0]])) == 1 &&
      alltrue([
        for subnet_id in var.subnet_ids :
        can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+/subnets/[^/]+$", trimspace(subnet_id)))
      ])
    )
    error_message = "subnet_ids must contain unique, valid Azure subnet resource IDs from one virtual network, with at least one subnet."
  }
}

variable "public_ip_address_ids" {
  description = "Optional existing public IP resource IDs. If empty, the module creates public_ip_count addresses using the selected NAT Gateway SKU."
  type        = list(string)
  default     = []

  validation {
    condition = length(var.public_ip_address_ids) <= 16 && length(distinct(var.public_ip_address_ids)) == length(var.public_ip_address_ids) && alltrue([
      for public_ip_id in var.public_ip_address_ids :
      can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/publicIPAddresses/[^/]+$", trimspace(public_ip_id)))
    ])
    error_message = "public_ip_address_ids must contain up to 16 unique, valid Azure public IP resource IDs."
  }
}

variable "public_ip_count" {
  description = "Number of Standard or StandardV2 static public IP addresses created when public_ip_address_ids is empty."
  type        = number
  default     = 1

  validation {
    condition     = var.public_ip_count >= 1 && var.public_ip_count <= 16 && floor(var.public_ip_count) == var.public_ip_count
    error_message = "public_ip_count must be a whole number from 1 through 16."
  }
}

variable "public_ip_name_prefix" {
  description = "Optional prefix for module-created public IP names. A numeric suffix is appended to each name."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.public_ip_name_prefix) == "" || can(regex("^[A-Za-z0-9._-]{1,75}$", trimspace(var.public_ip_name_prefix)))
    error_message = "public_ip_name_prefix must be empty or 1-75 characters using letters, numbers, periods, underscores, or hyphens."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into the NAT Gateway and module-created public IPs."
  default     = true
}

variable "inherited_resource_group_tags" {
  type        = map(string)
  description = "Optional plan-known resource group tags supplied by the root composition. When null and tag inheritance is enabled, the module reads the resource group."
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

variable "tags" {
  description = "Tags applied to the NAT Gateway and any module-created public IPs."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}
