variable "name" {
  description = "Optional Front Door profile name. Leave empty to generate a name from the workload and environment."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[A-Za-z0-9-]{1,90}$", trimspace(var.name)))
    error_message = "name must be empty or contain 1-90 letters, numbers, or hyphens."
  }
}

variable "endpoint_name" {
  description = "Optional globally unique Front Door endpoint name. Leave empty to derive it from the profile name."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.endpoint_name) == "" || can(regex("^[a-z0-9][a-z0-9-]{3,48}[a-z0-9]$", trimspace(var.endpoint_name)))
    error_message = "endpoint_name must be 5-50 lowercase letters, numbers, or hyphens and start and end with a letter or number."
  }
}

variable "resource_group_name" {
  description = "Existing resource group where the Front Door profile will be created."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "sku_name" {
  description = "Azure Front Door tier. Premium is required to use Private Link origins and provides managed WAF rule sets."
  type        = string
  default     = "Standard_AzureFrontDoor"

  validation {
    condition     = contains(["Standard_AzureFrontDoor", "Premium_AzureFrontDoor"], var.sku_name)
    error_message = "sku_name must be Standard_AzureFrontDoor or Premium_AzureFrontDoor."
  }
}

variable "origin_hostname" {
  description = "Backend origin host name without a scheme, port, or path."
  type        = string

  validation {
    condition     = length(trimspace(var.origin_hostname)) <= 253 && can(regex("^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$", trimspace(var.origin_hostname)))
    error_message = "origin_hostname must be a DNS-style host name or IP address without a scheme, port, or path."
  }
}

variable "origin_host_header" {
  description = "Optional Host header sent to the origin. Defaults to origin_hostname."
  type        = string
  default     = null

  validation {
    condition     = var.origin_host_header == null ? true : (trimspace(var.origin_host_header) != "" && length(trimspace(var.origin_host_header)) <= 253 && can(regex("^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$", trimspace(var.origin_host_header))))
    error_message = "origin_host_header must be null or a DNS-style host name without a scheme, port, or path."
  }
}

variable "origin_group_name" {
  description = "Optional origin group resource name. Leave empty to generate one from the profile."
  type        = string
  default     = ""
}

variable "origin_name" {
  description = "Optional origin resource name. Leave empty to generate one from the profile."
  type        = string
  default     = ""
}

variable "route_name" {
  description = "Optional route resource name. Leave empty to generate one from the profile."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.route_name) == "" || can(regex("^[A-Za-z0-9]([A-Za-z0-9-]{0,88}[A-Za-z0-9])?$", trimspace(var.route_name)))
    error_message = "route_name must be empty or 1-90 characters, start and end with a letter or number, and contain only letters, numbers, or hyphens."
  }
}

variable "endpoint_enabled" {
  description = "Whether the Front Door endpoint is enabled."
  type        = bool
  default     = true
}

variable "origin_enabled" {
  description = "Whether the origin is enabled."
  type        = bool
  default     = true
}

variable "route_enabled" {
  description = "Whether the route is enabled."
  type        = bool
  default     = true
}

variable "origin_http_port" {
  description = "HTTP port used to reach the origin."
  type        = number
  default     = 80

  validation {
    condition     = var.origin_http_port >= 1 && var.origin_http_port <= 65535 && floor(var.origin_http_port) == var.origin_http_port
    error_message = "origin_http_port must be a whole number between 1 and 65535."
  }
}

variable "origin_https_port" {
  description = "HTTPS port used to reach the origin."
  type        = number
  default     = 443

  validation {
    condition     = var.origin_https_port >= 1 && var.origin_https_port <= 65535 && floor(var.origin_https_port) == var.origin_https_port
    error_message = "origin_https_port must be a whole number between 1 and 65535."
  }
}

variable "certificate_name_check_enabled" {
  description = "Require the TLS certificate presented by the origin to match its configured host name."
  type        = bool
  default     = true

}

variable "origin_priority" {
  description = "Origin priority within its group. Lower values receive traffic before higher values when healthy."
  type        = number
  default     = 1

  validation {
    condition     = var.origin_priority >= 1 && var.origin_priority <= 5 && floor(var.origin_priority) == var.origin_priority
    error_message = "origin_priority must be a whole number from 1 through 5."
  }
}

variable "origin_weight" {
  description = "Relative origin traffic weight within its group."
  type        = number
  default     = 500

  validation {
    condition     = var.origin_weight >= 1 && var.origin_weight <= 1000 && floor(var.origin_weight) == var.origin_weight
    error_message = "origin_weight must be a whole number from 1 through 1000."
  }
}

variable "private_link" {
  description = "Optional Premium-only origin Private Link request. The target must be supported by Azure Front Door and the connection requires manual approval."
  type = object({
    private_link_target_id = string
    location               = string
    request_message        = optional(string, "Access request for Azure Front Door Private Link Origin")
    target_type            = optional(string)
  })
  default = null

  validation {
    condition = var.private_link == null ? true : (
      trimspace(var.private_link.private_link_target_id) != "" &&
      trimspace(var.private_link.location) != "" &&
      length(var.private_link.request_message) <= 140 &&
      (var.private_link.target_type == null || contains(["blob", "blob_secondary", "Gateway", "managedEnvironments", "sites", "web", "web_secondary"], var.private_link.target_type))
    )
    error_message = "private_link requires a target ID and location, a request message of at most 140 characters, and an optional supported target_type."
  }
}

variable "health_probe_enabled" {
  description = "Whether the origin group sends health probes."
  type        = bool
  default     = true
}

variable "health_probe_protocol" {
  description = "Protocol used for origin health probes."
  type        = string
  default     = "Https"

  validation {
    condition     = contains(["Http", "Https"], var.health_probe_protocol)
    error_message = "health_probe_protocol must be Http or Https."
  }
}

variable "health_probe_interval_in_seconds" {
  description = "Seconds between origin health probes."
  type        = number
  default     = 60

  validation {
    condition     = var.health_probe_interval_in_seconds >= 1 && var.health_probe_interval_in_seconds <= 255 && floor(var.health_probe_interval_in_seconds) == var.health_probe_interval_in_seconds
    error_message = "health_probe_interval_in_seconds must be a whole number from 1 through 255."
  }
}

variable "health_probe_request_type" {
  description = "HTTP method used for origin health probes."
  type        = string
  default     = "HEAD"

  validation {
    condition     = contains(["GET", "HEAD"], var.health_probe_request_type)
    error_message = "health_probe_request_type must be GET or HEAD."
  }
}

variable "health_probe_path" {
  description = "Origin-relative health probe path."
  type        = string
  default     = "/"

  validation {
    condition     = startswith(var.health_probe_path, "/")
    error_message = "health_probe_path must start with /."
  }
}

variable "additional_latency_in_milliseconds" {
  description = "Latency tolerance used to group healthy origins for routing decisions."
  type        = number
  default     = 50

  validation {
    condition     = var.additional_latency_in_milliseconds >= 0 && var.additional_latency_in_milliseconds <= 1000 && floor(var.additional_latency_in_milliseconds) == var.additional_latency_in_milliseconds
    error_message = "additional_latency_in_milliseconds must be a whole number from 0 through 1000."
  }
}

variable "sample_size" {
  description = "Number of health probe samples used for load-balancing decisions."
  type        = number
  default     = 4

  validation {
    condition     = var.sample_size >= 0 && var.sample_size <= 255 && floor(var.sample_size) == var.sample_size
    error_message = "sample_size must be a whole number from 0 through 255."
  }
}

variable "successful_samples_required" {
  description = "Successful health probe samples required to consider an origin healthy."
  type        = number
  default     = 3

  validation {
    condition     = var.successful_samples_required >= 0 && var.successful_samples_required <= 255 && floor(var.successful_samples_required) == var.successful_samples_required
    error_message = "successful_samples_required must be a whole number from 0 through 255."
  }
}

variable "session_affinity_enabled" {
  description = "Whether Front Door session affinity is enabled for the origin group."
  type        = bool
  default     = false
}

variable "restore_traffic_time_to_healed_or_new_endpoint_in_minutes" {
  description = "Minutes before traffic is restored to a healed or new origin, where supported by the service."
  type        = number
  default     = 10

  validation {
    condition     = var.restore_traffic_time_to_healed_or_new_endpoint_in_minutes >= 0 && var.restore_traffic_time_to_healed_or_new_endpoint_in_minutes <= 50 && floor(var.restore_traffic_time_to_healed_or_new_endpoint_in_minutes) == var.restore_traffic_time_to_healed_or_new_endpoint_in_minutes
    error_message = "restore_traffic_time_to_healed_or_new_endpoint_in_minutes must be a whole number from 0 through 50."
  }
}

variable "patterns_to_match" {
  description = "URL path patterns handled by the route."
  type        = list(string)
  default     = ["/*"]

  validation {
    condition     = length(var.patterns_to_match) > 0 && length(distinct(var.patterns_to_match)) == length(var.patterns_to_match) && alltrue([for pattern in var.patterns_to_match : startswith(pattern, "/")])
    error_message = "patterns_to_match must contain unique URL path patterns that start with /."
  }
}

variable "supported_protocols" {
  description = "Protocols accepted by the route. The default accepts HTTP for redirect and HTTPS for application traffic."
  type        = list(string)
  default     = ["Http", "Https"]

  validation {
    condition     = length(var.supported_protocols) > 0 && length(distinct(var.supported_protocols)) == length(var.supported_protocols) && alltrue([for protocol in var.supported_protocols : contains(["Http", "Https"], protocol)])
    error_message = "supported_protocols must contain unique values from Http and Https."
  }
}

variable "forwarding_protocol" {
  description = "Protocol Front Door uses when forwarding requests to the origin."
  type        = string
  default     = "HttpsOnly"

  validation {
    condition     = contains(["HttpOnly", "HttpsOnly", "MatchRequest"], var.forwarding_protocol)
    error_message = "forwarding_protocol must be HttpOnly, HttpsOnly, or MatchRequest."
  }
}

variable "https_redirect_enabled" {
  description = "Redirect HTTP requests to HTTPS. When enabled, both Http and Https must be in supported_protocols."
  type        = bool
  default     = true

}

variable "link_to_default_domain" {
  description = "Associate the route with the default Azure Front Door endpoint domain. Set false when using only custom domains."
  type        = bool
  default     = true

}

variable "cdn_frontdoor_custom_domain_ids" {
  description = "Optional existing Front Door custom domain IDs to associate with the route. Domain resources and DNS validation remain caller-owned."
  type        = list(string)
  default     = []

  validation {
    condition     = length(distinct(var.cdn_frontdoor_custom_domain_ids)) == length(var.cdn_frontdoor_custom_domain_ids) && alltrue([for id in var.cdn_frontdoor_custom_domain_ids : trimspace(id) != ""])
    error_message = "cdn_frontdoor_custom_domain_ids must contain unique, non-empty resource IDs."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into the Front Door profile and endpoint."
  default     = true
}

variable "inherited_resource_group_tags" {
  type        = map(string)
  description = "Optional plan-known resource group tags supplied by the root composition. When null and tag inheritance is enabled, the module reads the resource group."
  default     = null
}

variable "workload" {
  description = "Workload identifier used when names are generated."
  type        = string
  default     = "project"

  validation {
    condition     = length(trimspace(var.workload)) > 0
    error_message = "workload cannot be empty."
  }
}

variable "app_env" {
  description = "Deployment environment used when names are generated."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["prod", "staging", "dev", "qa", "sbx", "poc", "test"], var.app_env)
    error_message = "app_env must be one of: prod, staging, dev, qa, sbx, poc, test."
  }
}

variable "instance" {
  description = "Instance identifier used when names are generated."
  type        = string
  default     = "001"

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,10}[a-z0-9])?$", trimspace(var.instance)))
    error_message = "instance must be 1-12 lowercase letters, numbers, or hyphens, with an alphanumeric first and last character."
  }
}

variable "tags" {
  description = "Tags applied to the Front Door profile and endpoint."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for key, value in var.tags : trimspace(key) != "" && trimspace(value) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}
