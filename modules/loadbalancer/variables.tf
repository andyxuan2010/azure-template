variable "name" {
  description = "Name of the Load Balancer."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,80}$", var.name))
    error_message = "name must be between 1 and 80 characters long and can only contain alphanumeric characters and hyphens."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  description = "Azure region."
  type        = string

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location cannot be empty."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into Load Balancer resources."
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

variable "sku" {
  description = "The SKU of the Azure Load Balancer. Accepted values are Basic, Standard and Gateway."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Gateway"], var.sku)
    error_message = "sku must be Basic, Standard or Gateway."
  }
}

variable "sku_tier" {
  description = "The SKU tier of this Load Balancer. Possible values are Global and Regional."
  type        = string
  default     = "Regional"

  validation {
    condition     = contains(["Global", "Regional"], var.sku_tier)
    error_message = "sku_tier must be Global or Regional."
  }
}

variable "frontend_ip_configurations" {
  description = "List of frontend IP configurations."
  type = list(object({
    name                          = string
    public_ip_address_id          = optional(string)
    subnet_id                     = optional(string)
    private_ip_address            = optional(string)
    private_ip_address_allocation = optional(string, "Dynamic")
    zones                         = optional(list(string))
  }))

  validation {
    condition     = length(var.frontend_ip_configurations) > 0
    error_message = "At least one frontend_ip_configuration must be provided."
  }
}

variable "backend_address_pools" {
  description = "List of backend address pools to create."
  type = list(object({
    name = string
  }))
  default = []
}

variable "probes" {
  description = "List of health probes."
  type = list(object({
    name                = string
    protocol            = string
    port                = number
    request_path        = optional(string)
    interval_in_seconds = optional(number, 15)
    number_of_probes    = optional(number, 2)
  }))
  default = []
}

variable "lb_rules" {
  description = "List of load balancing rules."
  type = list(object({
    name                           = string
    protocol                       = string
    frontend_port                  = number
    backend_port                   = number
    frontend_ip_configuration_name = string
    backend_address_pool_name      = optional(string)
    probe_name                     = optional(string)
    enable_floating_ip             = optional(bool, false)
    idle_timeout_in_minutes        = optional(number, 4)
    load_distribution              = optional(string, "Default")
    disable_outbound_snat          = optional(bool, false)
  }))
  default = []
}

variable "app_env" {
  description = "Deployment environment (dev, staging, prod, sbx, test, qa)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod", "sbx", "test", "qa"], var.app_env)
    error_message = "app_env must be one of: dev, staging, prod, sbx, test, qa."
  }
}

variable "tags" {
  description = "Tags for the resources."
  type        = map(string)
  default     = {}
}
