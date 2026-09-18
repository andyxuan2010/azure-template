variable "name" {
  description = "Optional Load Balancer name override. Leave empty to generate one from the naming convention."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[a-zA-Z0-9-]{1,80}$", trimspace(var.name)))
    error_message = "name must be empty or between 1 and 80 characters long and can only contain alphanumeric characters and hyphens."
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
  description = "Deprecated compatibility input. Supply workload tags explicitly through tags."

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

  validation {
    condition = alltrue([
      for frontend in var.frontend_ip_configurations :
      (try(frontend.public_ip_address_id, null) != null) != (try(frontend.subnet_id, null) != null)
    ])
    error_message = "Each frontend IP configuration must set exactly one of public_ip_address_id or subnet_id."
  }

  validation {
    condition = alltrue([
      for frontend in var.frontend_ip_configurations :
      contains(["Dynamic", "Static"], frontend.private_ip_address_allocation) &&
      (frontend.private_ip_address_allocation != "Static" || try(frontend.private_ip_address, null) != null)
    ])
    error_message = "private_ip_address_allocation must be Dynamic or Static, and Static requires private_ip_address."
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

  validation {
    condition = alltrue([
      for probe in var.probes :
      contains(["Http", "Https", "Tcp"], probe.protocol) &&
      probe.port >= 1 && probe.port <= 65535 &&
      probe.interval_in_seconds >= 5 && probe.interval_in_seconds <= 120 &&
      probe.number_of_probes >= 1
    ])
    error_message = "Probes must use Http, Https, or Tcp; valid ports; interval 5-120 seconds; and at least one probe."
  }

  validation {
    condition = alltrue([
      for probe in var.probes :
      !contains(["Http", "Https"], probe.protocol) || try(startswith(probe.request_path, "/"), false)
    ])
    error_message = "HTTP and HTTPS probes require request_path beginning with '/'."
  }
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
    enable_tcp_reset               = optional(bool, false)
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.lb_rules :
      contains(["All", "Tcp", "Udp"], rule.protocol) &&
      rule.frontend_port >= 0 && rule.frontend_port <= 65535 &&
      rule.backend_port >= 0 && rule.backend_port <= 65535 &&
      rule.idle_timeout_in_minutes >= 4 && rule.idle_timeout_in_minutes <= 100 &&
      contains(["Default", "SourceIP", "SourceIPProtocol"], rule.load_distribution)
    ])
    error_message = "Load-balancing rules must use supported protocol, port, timeout, and distribution values."
  }
}

variable "outbound_rules" {
  description = "Standard Load Balancer outbound rules."
  type = list(object({
    name                           = string
    protocol                       = optional(string, "All")
    backend_address_pool_name      = string
    frontend_ip_configuration_name = string
    allocated_outbound_ports       = optional(number, 0)
    enable_tcp_reset               = optional(bool, true)
    idle_timeout_in_minutes        = optional(number, 4)
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.outbound_rules :
      contains(["All", "Tcp", "Udp"], rule.protocol) &&
      rule.allocated_outbound_ports >= 0 &&
      rule.idle_timeout_in_minutes >= 4 &&
      rule.idle_timeout_in_minutes <= 120
    ])
    error_message = "Outbound rules must use protocol All, Tcp, or Udp, non-negative allocated ports, and timeout 4-120 minutes."
  }
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
  description = "Tags for the resources."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

check "loadbalancer_input_consistency" {
  assert {
    condition = (
      length(distinct(local.frontend_names)) == length(local.frontend_names) &&
      length(distinct(local.backend_pool_names)) == length(local.backend_pool_names) &&
      length(distinct(local.probe_names)) == length(local.probe_names)
    )
    error_message = "Frontend IP configuration, backend pool, and probe names must be unique."
  }

  assert {
    condition     = length(distinct([for rule in var.lb_rules : rule.name])) == length(var.lb_rules) && length(distinct([for rule in var.outbound_rules : rule.name])) == length(var.outbound_rules)
    error_message = "Load-balancing rule and outbound rule names must be unique within their collections."
  }

  assert {
    condition = alltrue([
      for rule in var.lb_rules :
      contains(local.frontend_names, rule.frontend_ip_configuration_name) &&
      (try(rule.backend_address_pool_name, null) == null || contains(local.backend_pool_names, rule.backend_address_pool_name)) &&
      (try(rule.probe_name, null) == null || contains(local.probe_names, rule.probe_name))
    ])
    error_message = "Every load-balancing rule must reference defined frontend, backend pool, and probe names."
  }

  assert {
    condition = alltrue([
      for rule in var.outbound_rules :
      contains(local.frontend_names, rule.frontend_ip_configuration_name) &&
      contains(local.backend_pool_names, rule.backend_address_pool_name)
    ])
    error_message = "Every outbound rule must reference a defined frontend and backend pool."
  }

  assert {
    condition     = length(var.outbound_rules) == 0 || var.sku == "Standard"
    error_message = "Outbound rules require sku = Standard."
  }
}
