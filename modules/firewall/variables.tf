variable "name" {
  description = "Azure Firewall name."
  type        = string

  validation {
    condition     = trimspace(var.name) != ""
    error_message = "name cannot be empty."
  }
}

variable "resource_group_name" {
  description = "Resource group where the firewall will be created."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  description = "Azure region for the firewall."
  type        = string

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location cannot be empty."
  }
}

variable "subnet_id" {
  description = "AzureFirewallSubnet ID."
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/AzureFirewallSubnet$", var.subnet_id))
    error_message = "subnet_id must be a valid AzureFirewallSubnet resource ID."
  }
}

variable "sku_tier" {
  description = "Azure Firewall SKU tier."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_tier)
    error_message = "sku_tier must be Basic, Standard, or Premium."
  }
}

variable "sku_name" {
  description = "Azure Firewall SKU name."
  type        = string
  default     = "AZFW_VNet"

  validation {
    condition     = contains(["AZFW_VNet", "AZFW_Hub"], var.sku_name)
    error_message = "sku_name must be AZFW_VNet or AZFW_Hub."
  }
}

variable "zones" {
  description = "Optional availability zones."
  type        = list(string)
  default     = []
}

variable "public_ip_name" {
  description = "Public IP name. Leave empty to derive from the firewall name."
  type        = string
  default     = ""
}

variable "firewall_policy_name" {
  description = "Firewall policy name. Leave empty to derive from the firewall name."
  type        = string
  default     = ""
}

variable "application_rule_collections" {
  description = "Application rule collections keyed by collection name."
  type = map(object({
    priority = number
    action   = string
    rules = map(object({
      source_addresses  = list(string)
      destination_fqdns = list(string)
      protocols = list(object({
        type = string
        port = number
      }))
    }))
  }))
  default = {}
}

variable "network_rule_collections" {
  description = "Network rule collections keyed by collection name."
  type = map(object({
    priority = number
    action   = string
    rules = map(object({
      source_addresses      = list(string)
      destination_addresses = list(string)
      destination_ports     = list(string)
      protocols             = list(string)
    }))
  }))
  default = {}
}

variable "nat_rule_collections" {
  description = "NAT rule collections keyed by collection name."
  type = map(object({
    priority = number
    action   = string
    rules = map(object({
      source_addresses    = list(string)
      destination_address = string
      destination_ports   = list(string)
      translated_address  = string
      translated_port     = string
      protocols           = list(string)
    }))
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to firewall resources."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

check "firewall_input_consistency" {
  assert {
    condition     = var.sku_name != "AZFW_Hub"
    error_message = "This module currently supports only VNet-deployed Azure Firewall. Use sku_name = \"AZFW_VNet\"."
  }
}
