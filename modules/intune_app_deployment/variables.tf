variable "resources" {
  description = "Map of named Microsoft Graph request bodies to create at the deviceAppManagement/mobileApps collection."
  type        = map(any)
  default     = {}
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
