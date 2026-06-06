variable "display_name" {
  description = "Display name for the example app registration and Enterprise Application."
  type        = string
  default     = "app-contoso-enterprise-dev"
}

variable "app_env" {
  description = "Deployment environment label for Entra application tags."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["prod", "staging", "dev", "qa", "sbx", "poc", "test"], var.app_env)
    error_message = "app_env must be one of: prod, staging, dev, qa, sbx, poc, test."
  }
}

variable "homepage_url" {
  description = "Homepage and login URL for the example Enterprise Application."
  type        = string
  default     = "https://app.contoso.com"

  validation {
    condition     = can(regex("^https?://", var.homepage_url))
    error_message = "homepage_url must be a valid http/https URL."
  }
}

variable "app_role_assignment_required" {
  description = "Whether assignment is required before users can sign in."
  type        = bool
  default     = false
}

variable "notification_email_addresses" {
  description = "Notification email addresses for the Enterprise Application."
  type        = list(string)
  default     = []
}

variable "create_application_proxy" {
  description = "Whether to configure Microsoft Entra Application Proxy in the example."
  type        = bool
  default     = false
}

variable "application_proxy" {
  description = "Application Proxy settings used when create_application_proxy is true."
  type = object({
    internal_url                 = string
    external_url                 = string
    external_authentication_type = optional(string, "aadPreAuthentication")
  })
  default = {
    internal_url                 = "https://intranet.contoso.local/"
    external_url                 = "https://intranet-contoso.msappproxy.net/"
    external_authentication_type = "aadPreAuthentication"
  }
}
