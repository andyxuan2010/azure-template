variable "name" {
  description = "Display name and identifier URI suffix for the application."
  type        = string
  default     = "appreg-orders-prod"
}

variable "app_service_hostnames" {
  description = "App Service hostnames for which Easy Auth and MSAL callback URIs are generated."
  type        = list(string)
  default     = ["app-orders-prod.azurewebsites.net"]
}

variable "additional_web_redirect_uris" {
  description = "Additional approved web redirect URIs."
  type        = list(string)
  default     = ["https://orders.example.com/signin-oidc"]
}

variable "pre_authorized_client_id" {
  description = "Application/client ID of the trusted client pre-authorized for Orders.Read."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.pre_authorized_client_id))
    error_message = "pre_authorized_client_id must be a GUID."
  }
}
