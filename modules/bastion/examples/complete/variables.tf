variable "name" {
  description = "Optional Bastion host name override. Leave empty to generate one from the naming convention."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[A-Za-z0-9._-]{2,80}$", trimspace(var.name)))
    error_message = "name must be empty or 2-80 characters using letters, numbers, periods, underscores, or hyphens."
  }
  nullable = false
}

variable "resource_group_name" {
  description = "Resource group where the Bastion host and any module-created public IP will be created."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  description = "Azure region for the Bastion host and any module-created public IP."
  type        = string

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location cannot be empty."
  }
}

variable "subnet_id" {
  description = "Resource ID of the existing dedicated AzureBastionSubnet in the host virtual network."
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/[^/]+/subnets/AzureBastionSubnet$", trimspace(var.subnet_id)))
    error_message = "subnet_id must identify a subnet named AzureBastionSubnet."
  }
}

variable "workload" {
  type        = string
  default     = "project"
  description = "Workload identifier used when name is not provided."

  validation {
    condition     = length(trimspace(var.workload)) > 0
    error_message = "workload cannot be empty."
  }
  nullable = false
}

variable "app_env" {
  type        = string
  default     = "dev"
  description = "Deployment environment used when name is not provided."

  validation {
    condition     = contains(["prod", "staging", "dev", "qa", "sbx", "poc", "test"], var.app_env)
    error_message = "app_env must be one of: prod, staging, dev, qa, sbx, poc, test."
  }
  nullable = false
}

variable "tags" {
  description = "Tags applied to the Bastion host and any module-created public IP."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
  nullable = false
}
