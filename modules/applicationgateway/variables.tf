variable "name" {
  description = "Optional Application Gateway name override. Leave empty to generate one from the naming convention."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[a-zA-Z0-9-]{1,80}$", trimspace(var.name)))
    error_message = "name must be empty or 1-80 characters using letters, numbers, or hyphens."
  }
}

variable "resource_group_name" {
  description = "Resource group where the Application Gateway will be created."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  description = "Azure region for the Application Gateway."
  type        = string

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location cannot be empty."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into Application Gateway resources."
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

variable "app_env" {
  type        = string
  default     = "dev"
  description = "Deployment environment used for policy validation. Supply environment tags explicitly through tags."

  validation {
    condition     = contains(["prod", "staging", "dev", "qa", "sbx", "poc", "test"], var.app_env)
    error_message = "app_env must be one of: prod, staging, dev, qa, sbx, poc, test."
  }
}

variable "subnet_id" {
  description = "Dedicated subnet resource ID used by the Application Gateway gateway IP configuration."
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/.+$", var.subnet_id))
    error_message = "subnet_id must be a valid Azure subnet resource ID."
  }
}

variable "sku_name" {
  description = "Application Gateway SKU name."
  type        = string
  default     = "Standard_v2"

  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.sku_name)
    error_message = "sku_name must be Standard_v2 or WAF_v2."
  }
}

variable "sku_tier" {
  description = "Application Gateway SKU tier."
  type        = string
  default     = "Standard_v2"

  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.sku_tier)
    error_message = "sku_tier must be Standard_v2 or WAF_v2."
  }
}

variable "capacity" {
  description = "Fixed instance capacity when autoscale_configuration is not used."
  type        = number
  default     = 2

  validation {
    condition     = var.capacity >= 1
    error_message = "capacity must be at least 1."
  }
}

variable "autoscale_configuration" {
  description = "Optional autoscale configuration. When set, fixed capacity is not used."
  type = object({
    min_capacity = optional(number, 1)
    max_capacity = optional(number, 2)
  })
  default = null
}

variable "zones" {
  description = "Optional availability zones."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for zone in var.zones : contains(["1", "2", "3"], zone)])
    error_message = "zones may contain only Azure availability zones 1, 2, and 3."
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

variable "enable_http2" {
  description = "Enable HTTP/2 on the Application Gateway."
  type        = bool
  default     = true
}

variable "public_ip_name" {
  description = "Public IP resource name. Leave empty to derive from the gateway name."
  type        = string
  default     = ""
}

variable "private_ip_address" {
  description = "Optional static private IP address for an additional private frontend IP configuration."
  type        = string
  default     = null

  validation {
    condition     = var.private_ip_address == null || can(cidrhost("${var.private_ip_address}/32", 0))
    error_message = "private_ip_address must be null or a valid IPv4 address."
  }
}

variable "ssl_policy" {
  description = "Optional SSL policy configuration for the Application Gateway."
  type = object({
    policy_type          = string
    policy_name          = optional(string)
    min_protocol_version = optional(string)
    cipher_suites        = optional(list(string))
  })
  default = null

  validation {
    condition = var.ssl_policy == null ? true : (
      contains(["Predefined", "Custom", "CustomV2"], var.ssl_policy.policy_type) &&
      (
        var.ssl_policy.policy_type == "Predefined" ?
        try(trimspace(var.ssl_policy.policy_name), "") != "" :
        true
      )
    )
    error_message = "ssl_policy.policy_type must be Predefined, Custom, or CustomV2. When policy_type is Predefined, policy_name must be set."
  }
}

variable "frontend_ports" {
  description = "Frontend ports keyed by port name."
  type        = map(number)
  default = {
    http = 80
  }

  validation {
    condition     = length(var.frontend_ports) > 0 && alltrue([for v in values(var.frontend_ports) : v >= 1 && v <= 65535])
    error_message = "frontend_ports must include at least one entry and every port must be between 1 and 65535."
  }
}

variable "backend_address_pools" {
  description = "Backend address pools keyed by pool name."
  type = map(object({
    fqdns        = optional(list(string), [])
    ip_addresses = optional(list(string), [])
  }))
  default = {}
}

variable "backend_http_settings" {
  description = "Backend HTTP settings keyed by setting name."
  type = map(object({
    port                                = number
    protocol                            = string
    cookie_based_affinity               = optional(string, "Disabled")
    request_timeout                     = optional(number, 30)
    host_name                           = optional(string)
    path                                = optional(string)
    probe_name                          = optional(string)
    pick_host_name_from_backend_address = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for s in values(var.backend_http_settings) :
      contains(["Http", "Https"], s.protocol) &&
      contains(["Enabled", "Disabled"], s.cookie_based_affinity) &&
      s.port >= 1 &&
      s.port <= 65535 &&
      s.request_timeout >= 1 &&
      s.request_timeout <= 86400
    ])
    error_message = "backend_http_settings entries must use protocol Http or Https, cookie_based_affinity Enabled or Disabled, valid ports, and request_timeout between 1 and 86400."
  }
}

variable "probes" {
  description = "Health probes keyed by probe name."
  type = map(object({
    protocol                                  = string
    path                                      = optional(string, "/")
    host                                      = optional(string, "127.0.0.1")
    interval                                  = optional(number, 30)
    timeout                                   = optional(number, 30)
    unhealthy_threshold                       = optional(number, 3)
    pick_host_name_from_backend_http_settings = optional(bool, false)
    minimum_servers                           = optional(number, 0)
    match_status_codes                        = optional(list(string), ["200-399"])
  }))
  default = {}

  validation {
    condition = alltrue([
      for p in values(var.probes) :
      contains(["Http", "Https"], p.protocol) &&
      p.interval >= 1 &&
      p.timeout >= 1 &&
      p.unhealthy_threshold >= 1 &&
      p.minimum_servers >= 0
    ])
    error_message = "probes entries must use protocol Http or Https and positive interval, timeout, and unhealthy_threshold values."
  }
}

variable "ssl_certificates" {
  description = "SSL certificates keyed by certificate name. Certificate data must be base64-encoded PFX content."
  sensitive   = true
  type = map(object({
    data     = string
    password = string
  }))
  default = {}
}

variable "http_listeners" {
  description = "HTTP listeners keyed by listener name."
  type = map(object({
    frontend_port_name             = string
    protocol                       = string
    host_name                      = optional(string)
    host_names                     = optional(list(string), [])
    ssl_certificate_name           = optional(string)
    require_sni                    = optional(bool, false)
    firewall_policy_id             = optional(string)
    frontend_ip_configuration_name = optional(string, "public")
  }))

  validation {
    condition     = length(var.http_listeners) > 0
    error_message = "http_listeners must contain at least one listener."
  }

  validation {
    condition = alltrue([
      for l in values(var.http_listeners) :
      contains(["Http", "Https"], l.protocol)
    ])
    error_message = "http_listeners protocol must be Http or Https."
  }
}

variable "request_routing_rules" {
  description = "Request routing rules keyed by rule name."
  type = map(object({
    rule_type                  = string
    http_listener_name         = string
    backend_address_pool_name  = optional(string)
    backend_http_settings_name = optional(string)
    url_path_map_name          = optional(string)
    priority                   = optional(number)
  }))

  validation {
    condition     = length(var.request_routing_rules) > 0
    error_message = "request_routing_rules must contain at least one rule."
  }

  validation {
    condition = alltrue([
      for r in values(var.request_routing_rules) :
      contains(["Basic", "PathBasedRouting"], r.rule_type)
    ])
    error_message = "request_routing_rules rule_type must be Basic or PathBasedRouting."
  }
}

variable "url_path_maps" {
  description = "URL path maps keyed by name for PathBasedRouting rules."
  type = map(object({
    default_backend_address_pool_name  = string
    default_backend_http_settings_name = string
    path_rules = map(object({
      paths                      = list(string)
      backend_address_pool_name  = string
      backend_http_settings_name = string
    }))
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for path_map in values(var.url_path_maps) : [
        length(path_map.path_rules) > 0,
        alltrue([
          for path_rule in values(path_map.path_rules) :
          length(path_rule.paths) > 0 &&
          alltrue([for path in path_rule.paths : startswith(path, "/")])
        ])
      ]
    ]))
    error_message = "Each url_path_maps entry must contain at least one path rule, and every path must start with '/'."
  }
}

variable "waf_configuration" {
  description = "Optional WAF configuration. Required when using the WAF_v2 SKU."
  type = object({
    enabled                  = optional(bool, true)
    firewall_mode            = optional(string, "Prevention")
    rule_set_type            = optional(string, "OWASP")
    rule_set_version         = optional(string, "3.2")
    request_body_check       = optional(bool, true)
    file_upload_limit_mb     = optional(number, 100)
    max_request_body_size_kb = optional(number, 128)
  })
  default = null
}

variable "gateway_firewall_policy_id" {
  description = "Optional global Web Application Firewall policy resource ID attached to the Application Gateway."
  type        = string
  default     = null

  validation {
    condition = var.gateway_firewall_policy_id == null || can(
      regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/ApplicationGatewayWebApplicationFirewallPolicies/.+$", var.gateway_firewall_policy_id)
    )
    error_message = "gateway_firewall_policy_id must be null or a valid Application Gateway WAF policy resource ID."
  }
}
variable "identity_ids" {
  description = "Optional user-assigned managed identity IDs attached to the Application Gateway."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for id in var.identity_ids :
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.ManagedIdentity/userAssignedIdentities/.+$", id))
    ])
    error_message = "identity_ids must contain valid user-assigned managed identity resource IDs."
  }
}
variable "log_analytics_workspace_id" {
  description = "Optional Log Analytics workspace resource ID for Application Gateway diagnostics."
  type        = string
  default     = ""

  validation {
    condition = trimspace(var.log_analytics_workspace_id) == "" || can(
      regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.OperationalInsights/workspaces/.+$", trimspace(var.log_analytics_workspace_id))
    )
    error_message = "log_analytics_workspace_id must be empty or a valid Log Analytics workspace resource ID."
  }
}

variable "diagnostic_setting_name" {
  description = "Name of the Application Gateway diagnostic setting."
  type        = string
  default     = "application-gateway-diagnostics"

  validation {
    condition     = trimspace(var.diagnostic_setting_name) != ""
    error_message = "diagnostic_setting_name cannot be empty."
  }
}

variable "diagnostic_setting_enabled_log_categories" {
  description = "Optional diagnostic log categories to enable for Application Gateway."
  type        = list(string)
  default     = []
}

variable "diagnostic_setting_enabled_metric_categories" {
  description = "Optional diagnostic metric categories to enable for Application Gateway."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to Application Gateway resources."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

check "applicationgateway_sku_consistency" {
  assert {
    condition     = var.sku_name == var.sku_tier
    error_message = "sku_name and sku_tier must match."
  }
}

check "applicationgateway_capacity_mode" {
  assert {
    condition     = var.autoscale_configuration == null || var.capacity >= 1
    error_message = "capacity must remain a positive value even when autoscale_configuration is set."
  }
}

check "applicationgateway_autoscale_bounds" {
  assert {
    condition = var.autoscale_configuration == null ? true : (
      var.autoscale_configuration.min_capacity >= 0 &&
      var.autoscale_configuration.max_capacity >= var.autoscale_configuration.min_capacity
    )
    error_message = "autoscale_configuration must satisfy min_capacity >= 0 and max_capacity >= min_capacity."
  }
}

check "applicationgateway_waf_requirement" {
  assert {
    condition = var.sku_tier != "WAF_v2" || (
      var.waf_configuration != null ||
      try(trimspace(var.gateway_firewall_policy_id), "") != ""
    )
    error_message = "WAF_v2 requires either waf_configuration or gateway_firewall_policy_id."
  }
}

check "applicationgateway_listener_frontend_ports_exist" {
  assert {
    condition = alltrue([
      for l in values(var.http_listeners) :
      contains(local.frontend_port_names, l.frontend_port_name)
    ])
    error_message = "Each http_listener.frontend_port_name must reference a defined frontend_ports key."
  }
}

check "applicationgateway_https_listener_certificates_exist" {
  assert {
    condition = alltrue([
      for l in values(var.http_listeners) :
      l.protocol != "Https" ? true : (
        (l.ssl_certificate_name != null ? l.ssl_certificate_name : "") != "" &&
        contains(local.ssl_certificate_names, l.ssl_certificate_name != null ? l.ssl_certificate_name : "")
      )
    ])
    error_message = "Each HTTPS listener must reference a defined ssl_certificates key."
  }
}

check "applicationgateway_backend_http_settings_probes_exist" {
  assert {
    condition = alltrue([
      for s in values(var.backend_http_settings) :
      (s.probe_name != null ? s.probe_name : "") == "" ? true : contains(local.probe_names, s.probe_name != null ? s.probe_name : "")
    ])
    error_message = "Each backend_http_settings.probe_name must reference a defined probes key."
  }
}

check "applicationgateway_request_routing_rule_references_exist" {
  assert {
    condition = alltrue([
      for r in values(var.request_routing_rules) :
      contains(local.http_listener_names, r.http_listener_name) &&
      (
        r.rule_type == "Basic" ?
        contains(local.backend_address_pool_names, try(r.backend_address_pool_name, "")) &&
        contains(local.backend_http_settings_names, try(r.backend_http_settings_name, "")) &&
        try(r.url_path_map_name, null) == null :
        contains(local.url_path_map_names, try(r.url_path_map_name, "")) &&
        try(r.backend_address_pool_name, null) == null &&
        try(r.backend_http_settings_name, null) == null
      )
    ])
    error_message = "Basic rules must reference an existing listener, backend pool, and backend HTTP setting. PathBasedRouting rules must reference an existing url_path_map_name and omit direct backend references."
  }
}

check "applicationgateway_url_path_map_references_exist" {
  assert {
    condition = alltrue(flatten([
      for path_map in values(var.url_path_maps) : concat(
        [
          contains(local.backend_address_pool_names, path_map.default_backend_address_pool_name),
          contains(local.backend_http_settings_names, path_map.default_backend_http_settings_name)
        ],
        flatten([
          for path_rule in values(path_map.path_rules) : [
            contains(local.backend_address_pool_names, path_rule.backend_address_pool_name),
            contains(local.backend_http_settings_names, path_rule.backend_http_settings_name)
          ]
        ])
      )
    ]))
    error_message = "Every URL path map default and path-rule backend must reference defined backend_address_pools and backend_http_settings keys."
  }
}

check "applicationgateway_diagnostics_consistency" {
  assert {
    condition = trimspace(var.log_analytics_workspace_id) != "" || (
      length(var.diagnostic_setting_enabled_log_categories) == 0 &&
      length(var.diagnostic_setting_enabled_metric_categories) == 0
    )
    error_message = "log_analytics_workspace_id is required when diagnostic log or metric categories are configured."
  }
}
