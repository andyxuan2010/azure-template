# App Registration Module

Provision Microsoft Entra app registrations with service principals, redirect URI patterns, exposed API roles/scopes, API permissions, optional admin consent for app roles, workload identity federation, optional client secrets, and optional Key Vault secret storage.

## Overview

- Providers: `azuread`, `azurerm`, `time`
- Terraform tests: `tests/live.tftest.hcl`
- Supports plan-based validation for minimal, web app, and exposed API scenarios

## Features

- Creates `azuread_application` with owners, sign-in audience, identifier URIs, group claims, and metadata URLs.
- Supports web, SPA, and public client redirect URI blocks, including generated App Service callback URLs.
- Exposes custom app roles and delegated OAuth2 permission scopes.
- Supports required resource access by direct permission IDs or by resolving Graph/API app role and scope values.
- Optionally creates a service principal with account and assignment controls.
- Optionally grants admin consent for application permissions by creating app role assignments.
- Supports pre-authorized client applications for exposed API scopes.
- Supports federated identity credentials for workload identity federation.
- Supports optional client secret generation and Key Vault storage.

## Basic Usage

```hcl
module "appregistration" {
  source = "./modules/appregistration"

  display_name = "app-contoso-api-prod"

  tags = [
    "env:prod",
    "iac:terraform",
    "module:appregistration"
  ]
}
```

## Exposed API Pattern

```hcl
module "appregistration" {
  source = "./modules/appregistration"

  display_name                   = "app-contoso-api-prod"
  requested_access_token_version = 2
  identifier_uris                = ["api://app-contoso-api-prod"]

  app_roles = [
    {
      id                   = "11111111-1111-1111-1111-111111111111"
      value                = "Data.Read.All"
      display_name         = "Data reader"
      description          = "Read all application data."
      allowed_member_types = ["Application"]
    }
  ]

  oauth2_permission_scopes = [
    {
      id                         = "22222222-2222-2222-2222-222222222222"
      value                      = "Data.Read"
      admin_consent_display_name = "Read data"
      admin_consent_description  = "Allows the app to read data."
      user_consent_display_name  = "Read data"
      user_consent_description   = "Allows the app to read your data."
      type                       = "User"
    }
  ]
}
```

## Workload Identity Pattern

```hcl
module "appregistration" {
  source = "./modules/appregistration"

  display_name = "app-contoso-github-prod"

  federated_identity_credentials = {
    github_main = {
      display_name = "github-main"
      issuer       = "https://token.actions.githubusercontent.com"
      subject      = "repo:contoso/platform:ref:refs/heads/main"
    }
  }
}
```

## Testing

Run module tests from the module directory:

```powershell
terraform validate
terraform test
terraform test -filter="tests\live.tftest.hcl"
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 3.8.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.61.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.13.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_app_role_assignment.admin_consent](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_application.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_federated_identity_credential.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_federated_identity_credential) | resource |
| [azuread_application_password.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_application_pre_authorized.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_pre_authorized) | resource |
| [azuread_service_principal.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_key_vault_secret.client_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [time_offset.client_secret_expiry](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/offset) | resource |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azuread_service_principal.api](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_current_caller_as_owner"></a> [add\_current\_caller\_as\_owner](#input\_add\_current\_caller\_as\_owner) | When true, the current Terraform caller object ID is added as an owner. | `bool` | `true` | no |
| <a name="input_app_roles"></a> [app\_roles](#input\_app\_roles) | Application roles exposed by this app registration. | <pre>list(object({<br>    id                   = string<br>    value                = string<br>    display_name         = string<br>    description          = string<br>    allowed_member_types = optional(set(string), ["Application"])<br>    enabled              = optional(bool, true)<br>  }))</pre> | `[]` | no |
| <a name="input_app_service_auth_mode"></a> [app\_service\_auth\_mode](#input\_app\_service\_auth\_mode) | Authentication mode to use when generating App Service redirect URIs. Use easy\_auth for /.auth/login/aad/callback, msal for /auth/callback, both for both redirect patterns, or none to disable generated App Service redirect URIs. | `string` | `"easy_auth"` | no |
| <a name="input_app_service_redirect_hostnames"></a> [app\_service\_redirect\_hostnames](#input\_app\_service\_redirect\_hostnames) | Optional App Service hostnames to generate Entra redirect URIs for. This lets the module work standalone or alongside the appservice module without requiring callers to hand-build callback URLs. | `list(string)` | `[]` | no |
| <a name="input_client_secret_display_name"></a> [client\_secret\_display\_name](#input\_client\_secret\_display\_name) | Display name for the generated client secret. | `string` | `"terraform-generated"` | no |
| <a name="input_client_secret_end_date_relative"></a> [client\_secret\_end\_date\_relative](#input\_client\_secret\_end\_date\_relative) | Client secret lifetime as a duration string (for example 2160h = 90 days). | `string` | `"2160h"` | no |
| <a name="input_client_secret_key_vault_secret_name"></a> [client\_secret\_key\_vault\_secret\_name](#input\_client\_secret\_key\_vault\_secret\_name) | Secret name to use in Key Vault when key\_vault\_id is provided. | `string` | `null` | no |
| <a name="input_client_secret_rotate_when_changed"></a> [client\_secret\_rotate\_when\_changed](#input\_client\_secret\_rotate\_when\_changed) | Map of arbitrary values that force client secret rotation when changed. | `map(string)` | `{}` | no |
| <a name="input_create_client_secret"></a> [create\_client\_secret](#input\_create\_client\_secret) | When true, creates a client secret for the app registration. | `bool` | `false` | no |
| <a name="input_create_service_principal"></a> [create\_service\_principal](#input\_create\_service\_principal) | When true, creates a service principal for the app registration. | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | Optional description for the Microsoft Entra app registration. | `string` | `null` | no |
| <a name="input_device_only_auth_enabled"></a> [device\_only\_auth\_enabled](#input\_device\_only\_auth\_enabled) | Whether device-only authentication is enabled for the application. | `bool` | `false` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | Display name of the Microsoft Entra app registration. | `string` | n/a | yes |
| <a name="input_fallback_public_client_enabled"></a> [fallback\_public\_client\_enabled](#input\_fallback\_public\_client\_enabled) | Whether the application can use public client flows when no redirect URI is specified. | `bool` | `false` | no |
| <a name="input_feature_tags"></a> [feature\_tags](#input\_feature\_tags) | Optional feature tags to configure enterprise, gallery, custom SSO, or hidden app behavior. | <pre>object({<br>    custom_single_sign_on = optional(bool, false)<br>    enterprise            = optional(bool, false)<br>    gallery               = optional(bool, false)<br>    hide                  = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_federated_identity_credentials"></a> [federated\_identity\_credentials](#input\_federated\_identity\_credentials) | Federated identity credentials for workload identity federation, keyed by logical name. | <pre>map(object({<br>    display_name = string<br>    issuer       = string<br>    subject      = string<br>    audiences    = optional(list(string), ["api://AzureADTokenExchange"])<br>    description  = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_group_membership_claims"></a> [group\_membership\_claims](#input\_group\_membership\_claims) | Configures the groups claim issued in a user or OAuth 2.0 access token that the application expects. Possible values are None, SecurityGroup, DirectoryRole, ApplicationGroup or All. | `set(string)` | `[]` | no |
| <a name="input_identifier_uris"></a> [identifier\_uris](#input\_identifier\_uris) | A list of user-defined URI(s) that uniquely identify a Web application within its Azure AD tenant, or within a verified custom domain if the application is multi-tenant. | `list(string)` | `[]` | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | Optional Azure Key Vault ID where the generated client secret should be stored. | `string` | `null` | no |
| <a name="input_known_client_applications"></a> [known\_client\_applications](#input\_known\_client\_applications) | Client application IDs known to this API for consent bundling. | `set(string)` | `[]` | no |
| <a name="input_mapped_claims_enabled"></a> [mapped\_claims\_enabled](#input\_mapped\_claims\_enabled) | Whether the app can use claims mapping without a custom signing key. | `bool` | `false` | no |
| <a name="input_marketing_url"></a> [marketing\_url](#input\_marketing\_url) | Optional marketing URL for the application. | `string` | `null` | no |
| <a name="input_notes"></a> [notes](#input\_notes) | Optional notes for the Microsoft Entra app registration. | `string` | `null` | no |
| <a name="input_oauth2_permission_scopes"></a> [oauth2\_permission\_scopes](#input\_oauth2\_permission\_scopes) | Delegated permission scopes exposed by this app registration API. | <pre>list(object({<br>    id                         = string<br>    value                      = string<br>    admin_consent_display_name = string<br>    admin_consent_description  = string<br>    type                       = optional(string, "User")<br>    user_consent_display_name  = optional(string)<br>    user_consent_description   = optional(string)<br>    enabled                    = optional(bool, true)<br>  }))</pre> | `[]` | no |
| <a name="input_oauth2_post_response_required"></a> [oauth2\_post\_response\_required](#input\_oauth2\_post\_response\_required) | Whether the app requires POST responses for OAuth2 token requests. | `bool` | `false` | no |
| <a name="input_optional_claims"></a> [optional\_claims](#input\_optional\_claims) | Optional claims to include in access, ID, or SAML2 tokens. | <pre>object({<br>    access_token = optional(list(object({<br>      name                  = string<br>      source                = optional(string)<br>      essential             = optional(bool, false)<br>      additional_properties = optional(list(string), [])<br>    })), [])<br>    id_token = optional(list(object({<br>      name                  = string<br>      source                = optional(string)<br>      essential             = optional(bool, false)<br>      additional_properties = optional(list(string), [])<br>    })), [])<br>    saml2_token = optional(list(object({<br>      name                  = string<br>      source                = optional(string)<br>      essential             = optional(bool, false)<br>      additional_properties = optional(list(string), [])<br>    })), [])<br>  })</pre> | `null` | no |
| <a name="input_owners"></a> [owners](#input\_owners) | List of Entra object IDs to set as app owners. | `list(string)` | `[]` | no |
| <a name="input_pre_authorized_applications"></a> [pre\_authorized\_applications](#input\_pre\_authorized\_applications) | Pre-authorized client applications for exposed API permission scopes, keyed by logical name. | <pre>map(object({<br>    authorized_client_id = string<br>    permission_ids       = set(string)<br>  }))</pre> | `{}` | no |
| <a name="input_prevent_duplicate_names"></a> [prevent\_duplicate\_names](#input\_prevent\_duplicate\_names) | Whether AzureAD provider should prevent creating an application when another app with the same display name exists. | `bool` | `false` | no |
| <a name="input_privacy_statement_url"></a> [privacy\_statement\_url](#input\_privacy\_statement\_url) | Optional privacy statement URL for the application. | `string` | `null` | no |
| <a name="input_public_client_redirect_uris"></a> [public\_client\_redirect\_uris](#input\_public\_client\_redirect\_uris) | Optional redirect URIs for public client (mobile and desktop) applications. | `list(string)` | `[]` | no |
| <a name="input_requested_access_token_version"></a> [requested\_access\_token\_version](#input\_requested\_access\_token\_version) | The access token version expected by this resource. Valid values are 1 or 2. | `number` | `1` | no |
| <a name="input_required_resource_access"></a> [required\_resource\_access](#input\_required\_resource\_access) | Optional API permissions to add to the app registration, keyed by logical name. | <pre>map(object({<br>    resource_app_id = string<br>    resource_access = list(object({<br>      id                  = optional(string)<br>      type                = optional(string, "Role")<br>      value               = optional(string)<br>      grant_admin_consent = optional(bool, false)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_service_principal_account_enabled"></a> [service\_principal\_account\_enabled](#input\_service\_principal\_account\_enabled) | Whether the created service principal account is enabled. | `bool` | `true` | no |
| <a name="input_service_principal_app_role_assignment_required"></a> [service\_principal\_app\_role\_assignment\_required](#input\_service\_principal\_app\_role\_assignment\_required) | Whether users or groups must be assigned an app role before signing in through the service principal. | `bool` | `false` | no |
| <a name="input_service_principal_notification_email_addresses"></a> [service\_principal\_notification\_email\_addresses](#input\_service\_principal\_notification\_email\_addresses) | Notification email addresses for the created service principal. | `list(string)` | `[]` | no |
| <a name="input_sign_in_audience"></a> [sign\_in\_audience](#input\_sign\_in\_audience) | Intended audience for the app registration. | `string` | `"AzureADMyOrg"` | no |
| <a name="input_spa_redirect_uris"></a> [spa\_redirect\_uris](#input\_spa\_redirect\_uris) | Optional redirect URIs for single-page applications (MSAL browser/client flows). | `list(string)` | `[]` | no |
| <a name="input_support_url"></a> [support\_url](#input\_support\_url) | Optional support URL for the application. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Optional Microsoft Entra application tags for the app registration. This is a set(string), not Azure ARM map(string) resource tags. | `set(string)` | `[]` | no |
| <a name="input_terms_of_service_url"></a> [terms\_of\_service\_url](#input\_terms\_of\_service\_url) | Optional terms of service URL for the application. | `string` | `null` | no |
| <a name="input_web_homepage_url"></a> [web\_homepage\_url](#input\_web\_homepage\_url) | Optional home page URL for the web application. | `string` | `null` | no |
| <a name="input_web_implicit_grant_access_token_issuance_enabled"></a> [web\_implicit\_grant\_access\_token\_issuance\_enabled](#input\_web\_implicit\_grant\_access\_token\_issuance\_enabled) | Whether to enable access token issuance via implicit/hybrid flow for the web app. | `bool` | `false` | no |
| <a name="input_web_implicit_grant_id_token_issuance_enabled"></a> [web\_implicit\_grant\_id\_token\_issuance\_enabled](#input\_web\_implicit\_grant\_id\_token\_issuance\_enabled) | Whether to enable ID token issuance via implicit/hybrid flow for the web app. | `bool` | `false` | no |
| <a name="input_web_logout_url"></a> [web\_logout\_url](#input\_web\_logout\_url) | Optional logout URL for the web application. | `string` | `null` | no |
| <a name="input_web_redirect_uris"></a> [web\_redirect\_uris](#input\_web\_redirect\_uris) | Optional redirect URIs for web applications. These are merged with any App Service callback URIs generated from app\_service\_redirect\_hostnames. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_role_ids"></a> [app\_role\_ids](#output\_app\_role\_ids) | Map of app role values to role IDs exposed by the app registration. |
| <a name="output_application_id"></a> [application\_id](#output\_application\_id) | Application (client) ID of the app registration. |
| <a name="output_application_object_id"></a> [application\_object\_id](#output\_application\_object\_id) | Object ID of the app registration. |
| <a name="output_client_secret"></a> [client\_secret](#output\_client\_secret) | Generated client secret value. |
| <a name="output_client_secret_key_id"></a> [client\_secret\_key\_id](#output\_client\_secret\_key\_id) | Key ID of the generated client secret. |
| <a name="output_client_secret_key_vault_secret_id"></a> [client\_secret\_key\_vault\_secret\_id](#output\_client\_secret\_key\_vault\_secret\_id) | ID of the Key Vault secret storing the generated client secret. |
| <a name="output_display_name"></a> [display\_name](#output\_display\_name) | Display name of the app registration. |
| <a name="output_federated_identity_credential_ids"></a> [federated\_identity\_credential\_ids](#output\_federated\_identity\_credential\_ids) | Federated identity credential resource IDs keyed by input name. |
| <a name="output_oauth2_permission_scope_ids"></a> [oauth2\_permission\_scope\_ids](#output\_oauth2\_permission\_scope\_ids) | Map of delegated permission scope values to scope IDs exposed by the app registration. |
| <a name="output_pre_authorized_application_ids"></a> [pre\_authorized\_application\_ids](#output\_pre\_authorized\_application\_ids) | Pre-authorized application resource IDs keyed by input name. |
| <a name="output_public_client_redirect_uris"></a> [public\_client\_redirect\_uris](#output\_public\_client\_redirect\_uris) | Public client redirect URIs configured on the app registration. |
| <a name="output_publisher_domain"></a> [publisher\_domain](#output\_publisher\_domain) | Publisher domain associated with the app registration. |
| <a name="output_required_resource_access"></a> [required\_resource\_access](#output\_required\_resource\_access) | Resolved API permissions configured on the app registration. |
| <a name="output_service_principal_id"></a> [service\_principal\_id](#output\_service\_principal\_id) | Resource ID of the created service principal. |
| <a name="output_service_principal_object_id"></a> [service\_principal\_object\_id](#output\_service\_principal\_object\_id) | Object ID of the created service principal. |
| <a name="output_spa_redirect_uris"></a> [spa\_redirect\_uris](#output\_spa\_redirect\_uris) | SPA redirect URIs configured on the app registration. |
| <a name="output_web_redirect_uris"></a> [web\_redirect\_uris](#output\_web\_redirect\_uris) | Effective web redirect URIs configured on the app registration, including any generated App Service callback URIs. |
<!-- END_TF_DOCS -->
