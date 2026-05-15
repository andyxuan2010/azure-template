variable "display_name" {
  description = "Display name of the Microsoft Entra app registration."
  type        = string

  validation {
    condition     = trimspace(var.display_name) != ""
    error_message = "display_name cannot be empty."
  }
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
      can(regex("^[0-9a-fA-F-]{36}$", value))
    ])
    error_message = "owners must contain only Microsoft Entra object IDs."
  }
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

variable "web_implicit_grant_access_token_issuance_enabled" {
  description = "Whether to enable access token issuance via implicit/hybrid flow for the web app."
  type        = bool
  default     = true
}

variable "web_implicit_grant_id_token_issuance_enabled" {
  description = "Whether to enable ID token issuance via implicit/hybrid flow for the web app."
  type        = bool
  default     = true
}

variable "create_service_principal" {
  description = "When true, creates a service principal for the app registration."
  type        = bool
  default     = true
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

