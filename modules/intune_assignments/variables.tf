variable "resources" {
  description = "Map of assignments keyed by name. Each entry supplies resource_url and an assign action body."
  type = map(object({
    resource_url = string
    body         = any
  }))
  default = {}
}

variable "api_version" {
  description = "Microsoft Graph API version used for this resource collection."
  type        = string
  default     = "beta"
  validation {
    condition     = contains(["v1.0", "beta"], var.api_version)
    error_message = "api_version must be v1.0 or beta."
  }
}
