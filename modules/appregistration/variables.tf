variable "display_name" {
  description = "Display name of the Microsoft Entra app registration."
  type        = string

  validation {
    condition     = trimspace(var.display_name) != ""
    error_message = "display_name cannot be empty."
  }
}

variable "description" {
  description = "Optional description for the Microsoft Entra app registration."
  type        = string
  default     = null
}

variable "notes" {
  description = "Optional notes for the Microsoft Entra app registration."
  type        = string
  default     = null
}

variable "sign_in_audience" {
  description = "Intended audience for the app registration."
  type        = string
  default     = "AzureADMyOrg"

  validation {
    condition     = contains(["AzureADMyOrg", "AzureADMultipleOrgs", "AzureADandPersonalMicrosoftAccount", "PersonalMicrosoftAccount"], var.sign_in_audience)
    error_message = "sign_in_audience must be one of AzureADMyOrg, AzureADMultipleOrgs, AzureADandPersonalMicrosoftAccount, PersonalMicrosoftAccount."
  }
}

variable "owners" {
  description = "List of Entra object IDs to set as app owners."
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

variable "prevent_duplicate_names" {
  description = "Whether AzureAD provider should prevent creating an application when another app with the same display name exists."
  type        = bool
  default     = false
}

variable "fallback_public_client_enabled" {
  description = "Whether the application can use public client flows when no redirect URI is specified."
  type        = bool
  default     = false
}

variable "device_only_auth_enabled" {
  description = "Whether device-only authentication is enabled for the application."
  type        = bool
  default     = false
}

variable "add_current_caller_as_owner" {
  description = "When true, the current Terraform caller object ID is added as an owner."
  type        = bool
  default     = true
}

variable "web_redirect_uris" {
  description = "Optional redirect URIs for web applications. These are merged with any App Service callback URIs generated from app_service_redirect_hostnames."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for value in var.web_redirect_uris :
      can(regex("^https?://", value))
    ])
    error_message = "web_redirect_uris must contain valid http or https URLs."
  }
}

variable "web_homepage_url" {
  description = "Optional home page URL for the web application."
  type        = string
  default     = null

  validation {
    condition     = var.web_homepage_url == null || can(regex("^https?://", var.web_homepage_url))
    error_message = "web_homepage_url must be null or a valid http/https URL."
  }
}

variable "web_logout_url" {
  description = "Optional logout URL for the web application."
  type        = string
  default     = null

  validation {
    condition     = var.web_logout_url == null || can(regex("^https?://", var.web_logout_url))
    error_message = "web_logout_url must be null or a valid http/https URL."
  }
}

variable "app_service_redirect_hostnames" {
  description = "Optional App Service hostnames to generate Entra redirect URIs for. This lets the module work standalone or alongside the appservice module without requiring callers to hand-build callback URLs."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for value in var.app_service_redirect_hostnames :
      trimspace(value) != "" &&
      !can(regex("^https?://", trimspace(value))) &&
      !endswith(trimspace(value), "/")
    ])
    error_message = "app_service_redirect_hostnames must contain hostnames only, without http/https prefixes or trailing slashes."
  }
}

variable "app_service_auth_mode" {
  description = "Authentication mode to use when generating App Service redirect URIs. Use easy_auth for /.auth/login/aad/callback, msal for /auth/callback, both for both redirect patterns, or none to disable generated App Service redirect URIs."
  type        = string
  default     = "easy_auth"

  validation {
    condition     = contains(["none", "easy_auth", "msal", "both"], var.app_service_auth_mode)
    error_message = "app_service_auth_mode must be one of: none, easy_auth, msal, both."
  }
}

variable "spa_redirect_uris" {
  description = "Optional redirect URIs for single-page applications (MSAL browser/client flows)."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for value in var.spa_redirect_uris :
      can(regex("^https?://", value))
    ])
    error_message = "spa_redirect_uris must contain valid http or https URLs."
  }
}

variable "required_resource_access" {
  description = "Optional API permissions to add to the app registration, keyed by logical name."
  type = map(object({
    resource_app_id = string
    resource_access = list(object({
      id                  = optional(string)
      type                = optional(string, "Role")
      value               = optional(string)
      grant_admin_consent = optional(bool, false)
    }))
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for api in values(var.required_resource_access) : [
        can(regex("^[0-9a-fA-F-]{36}$", api.resource_app_id)),
        length(api.resource_access) > 0,
        alltrue([
          for access in api.resource_access : (
            contains(["Role", "Scope"], access.type) &&
            (
              try(trimspace(access.id), "") != "" ||
              try(trimspace(access.value), "") != ""
            )
          )
        ])
      ]
    ]))
    error_message = "required_resource_access entries must include a resource_app_id GUID and at least one resource_access item with type Role or Scope plus either id or value."
  }

  validation {
    condition = (
      !anytrue(flatten([
        for api in values(var.required_resource_access) : [
          for access in api.resource_access : try(access.grant_admin_consent, false)
        ]
      ])) || var.create_service_principal
    )
    error_message = "create_service_principal must be true when any required_resource_access entry requests grant_admin_consent."
  }

  validation {
    condition = !anytrue(flatten([
      for api in values(var.required_resource_access) : [
        for access in api.resource_access : (
          try(access.grant_admin_consent, false) && try(access.type, "Role") != "Role"
        )
      ]
    ]))
    error_message = "grant_admin_consent is currently supported only for application permissions with type = \"Role\"."
  }
}

variable "app_roles" {
  description = "Application roles exposed by this app registration."
  type = list(object({
    id                   = string
    value                = string
    display_name         = string
    description          = string
    allowed_member_types = optional(set(string), ["Application"])
    enabled              = optional(bool, true)
  }))
  default = []

  validation {
    condition = alltrue([
      for role in var.app_roles :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", role.id)) &&
      trimspace(role.value) != "" &&
      trimspace(role.display_name) != "" &&
      trimspace(role.description) != "" &&
      alltrue([for member_type in role.allowed_member_types : contains(["User", "Application"], member_type)])
    ])
    error_message = "app_roles entries must include GUID id, non-empty value/display_name/description, and allowed_member_types of User and/or Application."
  }

  validation {
    condition     = length(distinct([for role in var.app_roles : lower(trimspace(role.value))])) == length(var.app_roles)
    error_message = "app_roles values must be unique."
  }

  validation {
    condition     = length(distinct([for role in var.app_roles : lower(trimspace(role.id))])) == length(var.app_roles)
    error_message = "app_roles IDs must be unique."
  }
}

variable "oauth2_permission_scopes" {
  description = "Delegated permission scopes exposed by this app registration API."
  type = list(object({
    id                         = string
    value                      = string
    admin_consent_display_name = string
    admin_consent_description  = string
    type                       = optional(string, "User")
    user_consent_display_name  = optional(string)
    user_consent_description   = optional(string)
    enabled                    = optional(bool, true)
  }))
  default = []

  validation {
    condition = alltrue([
      for scope in var.oauth2_permission_scopes :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", scope.id)) &&
      trimspace(scope.value) != "" &&
      trimspace(scope.admin_consent_display_name) != "" &&
      trimspace(scope.admin_consent_description) != "" &&
      contains(["User", "Admin"], scope.type)
    ])
    error_message = "oauth2_permission_scopes entries must include GUID id, non-empty value/admin consent text, and type User or Admin."
  }

  validation {
    condition     = length(distinct([for scope in var.oauth2_permission_scopes : lower(trimspace(scope.value))])) == length(var.oauth2_permission_scopes)
    error_message = "oauth2_permission_scopes values must be unique."
  }

  validation {
    condition     = length(distinct([for scope in var.oauth2_permission_scopes : lower(trimspace(scope.id))])) == length(var.oauth2_permission_scopes)
    error_message = "oauth2_permission_scopes IDs must be unique."
  }
}

variable "known_client_applications" {
  description = "Client application IDs known to this API for consent bundling."
  type        = set(string)
  default     = []

  validation {
    condition = alltrue([
      for value in var.known_client_applications :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value))
    ])
    error_message = "known_client_applications must contain application/client ID GUIDs."
  }
}

variable "mapped_claims_enabled" {
  description = "Whether the app can use claims mapping without a custom signing key."
  type        = bool
  default     = false
}

variable "oauth2_post_response_required" {
  description = "Whether the app requires POST responses for OAuth2 token requests."
  type        = bool
  default     = false
}

variable "web_implicit_grant_access_token_issuance_enabled" {
  description = "Whether to enable access token issuance via implicit/hybrid flow for the web app."
  type        = bool
  default     = false
}

variable "web_implicit_grant_id_token_issuance_enabled" {
  description = "Whether to enable ID token issuance via implicit/hybrid flow for the web app."
  type        = bool
  default     = false
}

variable "create_service_principal" {
  description = "When true, creates a service principal for the app registration."
  type        = bool
  default     = true
}

variable "service_principal_account_enabled" {
  description = "Whether the created service principal account is enabled."
  type        = bool
  default     = true
}

variable "service_principal_app_role_assignment_required" {
  description = "Whether users or groups must be assigned an app role before signing in through the service principal."
  type        = bool
  default     = false
}

variable "service_principal_notification_email_addresses" {
  description = "Notification email addresses for the created service principal."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for value in var.service_principal_notification_email_addresses :
      can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", value))
    ])
    error_message = "service_principal_notification_email_addresses entries must be valid email addresses."
  }
}

variable "create_client_secret" {
  description = "When true, creates a client secret for the app registration."
  type        = bool
  default     = false
}

variable "client_secret_display_name" {
  description = "Display name for the generated client secret."
  type        = string
  default     = "terraform-generated"
}

variable "client_secret_end_date_relative" {
  description = "Client secret lifetime as a duration string (for example 2160h = 90 days)."
  type        = string
  default     = "2160h"

  validation {
    condition     = can(regex("^[1-9][0-9]*h$", trimspace(var.client_secret_end_date_relative)))
    error_message = "client_secret_end_date_relative must be a positive hour duration such as 2160h."
  }
}

variable "client_secret_rotate_when_changed" {
  description = "Map of arbitrary values that force client secret rotation when changed."
  type        = map(string)
  default     = {}
}

variable "key_vault_id" {
  description = "Optional Azure Key Vault ID where the generated client secret should be stored."
  type        = string
  default     = null

  validation {
    condition = (
      var.key_vault_id == null ||
      try(trimspace(var.key_vault_id), "") == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.KeyVault/vaults/.+$", var.key_vault_id))
    )
    error_message = "key_vault_id must be null, empty, or a valid Azure Key Vault resource ID."
  }

  validation {
    condition     = var.key_vault_id == null || try(trimspace(var.key_vault_id), "") == "" || var.create_client_secret
    error_message = "key_vault_id can only be set when create_client_secret is true."
  }
}

variable "client_secret_key_vault_secret_name" {
  description = "Secret name to use in Key Vault when key_vault_id is provided."
  type        = string
  default     = null

  validation {
    condition = (
      var.key_vault_id == null ||
      try(trimspace(var.key_vault_id), "") == "" ||
      try(trimspace(var.client_secret_key_vault_secret_name), "") != ""
    )
    error_message = "client_secret_key_vault_secret_name must be set when key_vault_id is provided."
  }

  validation {
    condition = (
      var.client_secret_key_vault_secret_name == null ||
      try(trimspace(var.client_secret_key_vault_secret_name), "") == "" ||
      can(regex("^[0-9A-Za-z-]{1,127}$", var.client_secret_key_vault_secret_name))
    )
    error_message = "client_secret_key_vault_secret_name must be null, empty, or 1-127 characters using letters, numbers, and hyphens."
  }
}

variable "tags" {
  description = "Optional Microsoft Entra application tags for the app registration. This is a set(string), not Azure ARM map(string) resource tags."
  type        = set(string)
  default     = []
}

variable "identifier_uris" {
  description = "A list of user-defined URI(s) that uniquely identify a Web application within its Azure AD tenant, or within a verified custom domain if the application is multi-tenant."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for value in var.identifier_uris :
      trimspace(value) != ""
    ])
    error_message = "identifier_uris cannot contain empty values."
  }
}

variable "group_membership_claims" {
  description = "Configures the groups claim issued in a user or OAuth 2.0 access token that the application expects. Possible values are None, SecurityGroup, DirectoryRole, ApplicationGroup or All."
  type        = set(string)
  default     = []

  validation {
    condition = alltrue([
      for claim in var.group_membership_claims : contains(["None", "SecurityGroup", "DirectoryRole", "ApplicationGroup", "All"], claim)
    ])
    error_message = "Valid values for group_membership_claims are None, SecurityGroup, DirectoryRole, ApplicationGroup, or All."
  }
}

variable "requested_access_token_version" {
  description = "The access token version expected by this resource. Valid values are 1 or 2."
  type        = number
  default     = 1

  validation {
    condition     = contains([1, 2], var.requested_access_token_version)
    error_message = "requested_access_token_version must be 1 or 2."
  }
}

variable "optional_claims" {
  description = "Optional claims to include in access, ID, or SAML2 tokens."
  type = object({
    access_token = optional(list(object({
      name                  = string
      source                = optional(string)
      essential             = optional(bool, false)
      additional_properties = optional(list(string), [])
    })), [])
    id_token = optional(list(object({
      name                  = string
      source                = optional(string)
      essential             = optional(bool, false)
      additional_properties = optional(list(string), [])
    })), [])
    saml2_token = optional(list(object({
      name                  = string
      source                = optional(string)
      essential             = optional(bool, false)
      additional_properties = optional(list(string), [])
    })), [])
  })
  default = null

  validation {
    condition = var.optional_claims == null ? true : alltrue(concat(
      [for claim in try(var.optional_claims.access_token, []) : trimspace(claim.name) != ""],
      [for claim in try(var.optional_claims.id_token, []) : trimspace(claim.name) != ""],
      [for claim in try(var.optional_claims.saml2_token, []) : trimspace(claim.name) != ""]
    ))
    error_message = "optional_claims entries must include non-empty claim names."
  }
}

variable "public_client_redirect_uris" {
  description = "Optional redirect URIs for public client (mobile and desktop) applications."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for value in var.public_client_redirect_uris :
      can(regex("^https?://|^ms-appx-web://|^[a-zA-Z0-9.-]+://", value))
    ])
    error_message = "public_client_redirect_uris must contain valid URLs or custom URI schemes."
  }
}

variable "feature_tags" {
  description = "Optional feature tags to configure enterprise, gallery, custom SSO, or hidden app behavior."
  type = object({
    custom_single_sign_on = optional(bool, false)
    enterprise            = optional(bool, false)
    gallery               = optional(bool, false)
    hide                  = optional(bool, false)
  })
  default = null
}

variable "pre_authorized_applications" {
  description = "Pre-authorized client applications for exposed API permission scopes, keyed by logical name."
  type = map(object({
    authorized_client_id = string
    permission_ids       = set(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for _, app in var.pre_authorized_applications :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", app.authorized_client_id)) &&
      length(app.permission_ids) > 0 &&
      alltrue([
        for permission_id in app.permission_ids :
        can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", permission_id))
      ])
    ])
    error_message = "pre_authorized_applications entries must include authorized_client_id and permission_ids as GUIDs."
  }
}

variable "federated_identity_credentials" {
  description = "Federated identity credentials for workload identity federation, keyed by logical name."
  type = map(object({
    display_name = string
    issuer       = string
    subject      = string
    audiences    = optional(list(string), ["api://AzureADTokenExchange"])
    description  = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for _, credential in var.federated_identity_credentials :
      trimspace(credential.display_name) != "" &&
      can(regex("^https://", credential.issuer)) &&
      trimspace(credential.subject) != "" &&
      length(credential.audiences) > 0 &&
      alltrue([for audience in credential.audiences : trimspace(audience) != ""])
    ])
    error_message = "federated_identity_credentials entries must include display_name, https issuer, subject, and at least one audience."
  }
}

variable "marketing_url" {
  description = "Optional marketing URL for the application."
  type        = string
  default     = null

  validation {
    condition     = var.marketing_url == null || can(regex("^https?://", var.marketing_url))
    error_message = "marketing_url must be null or a valid http/https URL."
  }
}

variable "privacy_statement_url" {
  description = "Optional privacy statement URL for the application."
  type        = string
  default     = null

  validation {
    condition     = var.privacy_statement_url == null || can(regex("^https?://", var.privacy_statement_url))
    error_message = "privacy_statement_url must be null or a valid http/https URL."
  }
}

variable "support_url" {
  description = "Optional support URL for the application."
  type        = string
  default     = null

  validation {
    condition     = var.support_url == null || can(regex("^https?://", var.support_url))
    error_message = "support_url must be null or a valid http/https URL."
  }
}

variable "terms_of_service_url" {
  description = "Optional terms of service URL for the application."
  type        = string
  default     = null

  validation {
    condition     = var.terms_of_service_url == null || can(regex("^https?://", var.terms_of_service_url))
    error_message = "terms_of_service_url must be null or a valid http/https URL."
  }
}

check "appregistration_input_consistency" {
  assert {
    condition     = length(var.pre_authorized_applications) == 0 || length(var.oauth2_permission_scopes) > 0
    error_message = "pre_authorized_applications requires at least one oauth2_permission_scopes entry."
  }

  assert {
    condition     = !var.device_only_auth_enabled || var.fallback_public_client_enabled
    error_message = "device_only_auth_enabled requires fallback_public_client_enabled = true."
  }

  assert {
    condition     = length(var.federated_identity_credentials) == 0 || var.create_service_principal
    error_message = "federated_identity_credentials requires create_service_principal = true."
  }

  assert {
    condition     = !var.service_principal_app_role_assignment_required || var.create_service_principal
    error_message = "service_principal_app_role_assignment_required requires create_service_principal = true."
  }
}
