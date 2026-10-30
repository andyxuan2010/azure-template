variable "name" {
  description = "Optional Bastion host name override. Leave empty to generate one from the naming convention."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[A-Za-z0-9._-]{2,80}$", trimspace(var.name)))
    error_message = "name must be empty or 2-80 characters using letters, numbers, periods, underscores, or hyphens."
  }
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

variable "public_ip_address_id" {
  description = "Optional existing Standard, static public IP resource ID. When empty, the module creates a Standard static public IP."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.public_ip_address_id) == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/publicIPAddresses/.+$", trimspace(var.public_ip_address_id)))
    error_message = "public_ip_address_id must be empty or a valid Azure public IP resource ID."
  }
}

variable "public_ip_name" {
  description = "Optional name for the public IP created by this module. Ignored when public_ip_address_id is supplied."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.public_ip_name) == "" || can(regex("^[A-Za-z0-9._-]{1,80}$", trimspace(var.public_ip_name)))
    error_message = "public_ip_name must be empty or 1-80 characters using letters, numbers, periods, underscores, or hyphens."
  }
}

variable "sku" {
  description = "Public Azure Bastion SKU. Developer and private-only deployments are not supported by this module."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be Basic, Standard, or Premium."
  }
}

variable "copy_paste_enabled" {
  description = "Whether copy and paste is enabled for Bastion sessions."
  type        = bool
  default     = true
}

variable "file_copy_enabled" {
  description = "Whether file transfer is enabled. Azure supports this only for Standard or Premium SKU."
  type        = bool
  default     = false
}

variable "ip_connect_enabled" {
  description = "Whether IP-based connections are enabled. Azure supports this only for Standard or Premium SKU."
  type        = bool
  default     = false
}

variable "kerberos_enabled" {
  description = "Whether Kerberos authentication is enabled. Azure supports this only for Standard or Premium SKU."
  type        = bool
  default     = false
}

variable "scale_units" {
  description = "Bastion scale units. Azure supports values from 2 to 50; Basic remains at 2."
  type        = number
  default     = 2

  validation {
    condition     = var.scale_units >= 2 && var.scale_units <= 50 && floor(var.scale_units) == var.scale_units
    error_message = "scale_units must be a whole number from 2 through 50."
  }
}

variable "shareable_link_enabled" {
  description = "Whether shareable links are enabled. Azure supports this only for Standard or Premium SKU."
  type        = bool
  default     = false
}

variable "tunneling_enabled" {
  description = "Whether native client tunneling is enabled. Azure supports this only for Standard or Premium SKU."
  type        = bool
  default     = false
}

variable "session_recording_enabled" {
  description = "Whether session recording is enabled. Azure supports this only for Premium SKU."
  type        = bool
  default     = false
}

variable "zones" {
  description = "Optional availability zones for the Bastion host and module-created public IP."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for zone in var.zones : contains(["1", "2", "3"], zone)])
    error_message = "zones may contain only Azure availability zone identifiers 1, 2, or 3."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into Bastion resources."
  default     = true
}

variable "inherited_resource_group_tags" {
  type        = map(string)
  description = "Optional plan-known resource group tags supplied by the root composition. When null and inheritance is enabled, the module reads the resource group."
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
  description = "Tags applied to the Bastion host and any module-created public IP."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

check "sku_feature_compatibility" {
  assert {
    condition = var.sku != "Basic" || (
      !var.file_copy_enabled &&
      !var.ip_connect_enabled &&
      !var.kerberos_enabled &&
      !var.shareable_link_enabled &&
      !var.tunneling_enabled &&
      !var.session_recording_enabled &&
      var.scale_units == 2
    )
    error_message = "Basic SKU supports none of the optional Standard/Premium features and uses exactly 2 scale units."
  }

  assert {
    condition     = var.sku == "Premium" || !var.session_recording_enabled
    error_message = "session_recording_enabled requires Premium SKU."
  }
}
