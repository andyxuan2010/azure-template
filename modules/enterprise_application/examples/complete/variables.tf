variable "display_name" {
  description = "Display name for the app registration and Enterprise Application."
  type        = string
  default     = "app-contoso-enterprise-prod"
}

variable "environment" {
  description = "Environment label stored in app registration metadata."
  type        = string
  default     = "prod"
}

variable "homepage_url" {
  description = "HTTPS homepage and login URL."
  type        = string
  default     = "https://app.example.com"
}

variable "notification_email_addresses" {
  description = "Operational notification addresses for the Enterprise Application."
  type        = list(string)
  default     = []
}
