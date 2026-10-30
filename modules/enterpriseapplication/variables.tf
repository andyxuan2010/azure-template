variable "application_id" {
  description = "Application (client) ID of the app registration this Enterprise Application/service principal connects to."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.application_id))
    error_message = "application_id must be an application/client ID GUID."
  }
}

variable "account_enabled" {
  description = "Whether the Enterprise Application service principal account is enabled."
  type        = bool
  default     = true
}

variable "app_role_assignment_required" {
  description = "Whether users or groups must be assigned an app role before signing in through the Enterprise Application."
  type        = bool
  default     = false
}

variable "description" {
  description = "Optional description for the Enterprise Application."
  type        = string
  default     = null
}

variable "notes" {
  description = "Optional notes for the Enterprise Application."
  type        = string
  default     = null
}

variable "login_url" {
  description = "Optional URL Azure AD uses to launch the application from Microsoft 365 or My Apps."
  type        = string
  default     = null

  validation {
    condition     = var.login_url == null || can(regex("^https?://", var.login_url))
    error_message = "login_url must be null or a valid http/https URL."
  }
}

variable "preferred_single_sign_on_mode" {
  description = "Preferred single sign-on mode for the Enterprise Application. Use null to leave unset."
  type        = string
  default     = null

  validation {
    condition     = var.preferred_single_sign_on_mode == null ? true : contains(["oidc", "password", "saml", "notSupported"], var.preferred_single_sign_on_mode)
    error_message = "preferred_single_sign_on_mode must be one of: oidc, password, saml, notSupported, or null."
  }
}

variable "saml_relay_state" {
  description = "Optional SAML relay state. Applies only when preferred_single_sign_on_mode is saml."
  type        = string
  default     = null
}

variable "owners" {
  description = "List of Entra object IDs to set as Enterprise Application owners."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for value in var.owners :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value))
    ])
    error_message = "owners must contain only Microsoft Entra object IDs."
  }
}

variable "add_current_caller_as_owner" {
  description = "When true, the current Terraform caller object ID is added as an owner."
  type        = bool
  default     = true
}

variable "notification_email_addresses" {
  description = "Notification email addresses for the Enterprise Application."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for value in var.notification_email_addresses :
      can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", value))
    ])
    error_message = "notification_email_addresses entries must be valid email addresses."
  }
}

variable "feature_tags" {
  description = "Feature tags to classify the service principal as an Enterprise Application, gallery app, custom SSO app, or hidden app."
  type = object({
    custom_single_sign_on = optional(bool, false)
    enterprise            = optional(bool, true)
    gallery               = optional(bool, false)
    hide                  = optional(bool, false)
  })
  default = {
    enterprise = true
  }
}

variable "use_existing" {
  description = "When true, the AzureAD provider attempts to use an existing service principal for application_id."
  type        = bool
  default     = true
}

variable "app_role_assignments" {
  description = "App role assignments for users, groups, or service principals, keyed by logical name."
  type = map(object({
    principal_object_id = string
    app_role_id         = optional(string, "00000000-0000-0000-0000-000000000000")
  }))
  default = {}

  validation {
    condition = alltrue([
      for _, assignment in var.app_role_assignments :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", assignment.principal_object_id)) &&
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", assignment.app_role_id))
    ])
    error_message = "app_role_assignments entries must include principal_object_id and app_role_id GUIDs."
  }
}

variable "create_application_proxy" {
  description = "When true, configures Microsoft Entra Application Proxy on the connected app registration."
  type        = bool
  default     = false
}

variable "application_proxy" {
  description = "Application Proxy settings applied to the connected app registration when create_application_proxy is true."
  type = object({
    internal_url                                   = string
    external_url                                   = string
    external_authentication_type                   = optional(string, "aadPreAuthentication")
    application_server_timeout                     = optional(string, "Default")
    is_backend_certificate_validation_enabled      = optional(bool, true)
    is_http_only_cookie_enabled                    = optional(bool, true)
    is_persistent_cookie_enabled                   = optional(bool, false)
    is_secure_cookie_enabled                       = optional(bool, true)
    is_state_session_enabled                       = optional(bool, true)
    is_translate_host_header_enabled               = optional(bool, true)
    is_translate_links_in_body_enabled             = optional(bool, false)
    is_continuous_access_evaluation_enabled        = optional(bool, true)
    traffic_routing_method                         = optional(string, "none")
    use_alternate_url_for_translation_and_redirect = optional(bool, false)
    alternate_url                                  = optional(string)
    verified_custom_domain_key_credential          = optional(any)
    verified_custom_domain_password_credential     = optional(any)
    single_sign_on_settings                        = optional(any)
  })
  default = null

  validation {
    condition = var.application_proxy == null ? true : (
      can(regex("^https?://", var.application_proxy.internal_url)) &&
      can(regex("^https?://", var.application_proxy.external_url)) &&
      contains(["passthru", "aadPreAuthentication"], var.application_proxy.external_authentication_type) &&
      contains(["Default", "Long"], var.application_proxy.application_server_timeout) &&
      contains(["none", "random", "sessionPersistence", "performance", "unknownFutureValue"], var.application_proxy.traffic_routing_method)
    )
    error_message = "application_proxy requires valid internal/external URLs, external_authentication_type, application_server_timeout, and traffic_routing_method values."
  }
}

check "enterpriseapplication_input_consistency" {
  assert {
    condition     = !var.create_application_proxy || var.application_proxy != null
    error_message = "application_proxy must be set when create_application_proxy is true."
  }

  assert {
    condition     = var.create_application_proxy || var.application_proxy == null
    error_message = "Set create_application_proxy = true when application_proxy is provided."
  }

  assert {
    condition     = var.saml_relay_state == null || var.preferred_single_sign_on_mode == "saml"
    error_message = "saml_relay_state can only be set when preferred_single_sign_on_mode is saml."
  }
}
