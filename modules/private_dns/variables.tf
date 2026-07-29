variable "resource_group_name" {
  description = "Resource group containing the private DNS zones."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into Private DNS resources."
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
  description = "Deployment environment retained for compatibility."

  validation {
    condition     = contains(["prod", "staging", "dev", "qa", "sbx", "poc", "test"], var.app_env)
    error_message = "app_env must be one of: prod, staging, dev, qa, sbx, poc, test."
  }
}

variable "zones" {
  description = "Private DNS zones keyed by zone name."
  type = map(object({
    soa_record = optional(object({
      email        = optional(string)
      expire_time  = optional(number)
      minimum_ttl  = optional(number)
      refresh_time = optional(number)
      retry_time   = optional(number)
      ttl          = optional(number)
      tags         = optional(map(string))
    }))
    vnet_links = optional(map(object({
      virtual_network_id   = string
      registration_enabled = optional(bool, false)
      tags                 = optional(map(string), {})
    })), {})
    a_records = optional(map(object({
      ttl     = number
      records = list(string)
      tags    = optional(map(string), {})
    })), {})
    aaaa_records = optional(map(object({
      ttl     = number
      records = list(string)
      tags    = optional(map(string), {})
    })), {})
    cname_records = optional(map(object({
      ttl    = number
      record = string
      tags   = optional(map(string), {})
    })), {})
    txt_records = optional(map(object({
      ttl     = number
      records = list(string)
      tags    = optional(map(string), {})
    })), {})
  }))

  validation {
    condition     = length(var.zones) > 0 && alltrue([for zone_name in keys(var.zones) : trimspace(zone_name) != "" && can(regex("^[A-Za-z0-9._-]+$", zone_name))])
    error_message = "zones must contain at least one valid private DNS zone name."
  }

  validation {
    condition = alltrue(flatten([
      for zone in values(var.zones) : concat(
        [for record in values(zone.a_records) : record.ttl >= 1 && length(record.records) > 0 && alltrue([for ip in record.records : can(cidrhost("${ip}/32", 0))])],
        [for record in values(zone.aaaa_records) : record.ttl >= 1 && length(record.records) > 0 && alltrue([for ip in record.records : can(cidrhost("${ip}/128", 0))])],
        [for record in values(zone.cname_records) : record.ttl >= 1 && trimspace(record.record) != ""],
        [for record in values(zone.txt_records) : record.ttl >= 1 && length(record.records) > 0]
      )
    ]))
    error_message = "DNS records require positive TTLs, non-empty values, and valid IPv4/IPv6 addresses where applicable."
  }
}

variable "tags" {
  description = "Tags applied to private DNS zones."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}
