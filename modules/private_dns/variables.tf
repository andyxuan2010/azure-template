variable "resource_group_name" {
  description = "Resource group containing the private DNS zones."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
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
  }))
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
