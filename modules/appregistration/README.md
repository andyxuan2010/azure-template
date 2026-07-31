# Microsoft Entra Application Registration

Provisions a Microsoft Entra application with optional service principal, API permissions, exposed roles and scopes, workload identity federation, client credentials, and App Service redirect integration.

## Features

- Creates an application and, optionally, its service principal.
- Supports web, single-page application, and public-client redirect URIs.
- Generates App Service Easy Auth and MSAL callback URIs from hostnames.
- Models required API permissions, application roles, delegated scopes, optional claims, and pre-authorized clients.
- Supports GitHub Actions and other OpenID Connect workload identity issuers.
- Optionally creates a client secret and stores it in an existing Azure Key Vault.
- Supports application ownership, metadata, feature tags, and duplicate-name prevention.

## Resources Created

The module always creates one `azuread_application`. Depending on inputs, it can also create:

- a Microsoft Entra service principal;
- application-password credentials and a rotation offset;
- an Azure Key Vault secret containing the credential;
- app-role assignments for requested admin consent;
- pre-authorized application relationships;
- federated identity credentials.

The module looks up the current Entra caller and permission resource service principals when required; it does not manage those dependencies.

## Prerequisites and Dependencies

- Access to the target Microsoft Entra tenant.
- Directory permissions to create applications, service principals, credentials, consent assignments, and federated credentials requested by the configuration.
- Optional existing Key Vault and permission to write secrets.
- Stable GUIDs for exposed app roles and OAuth2 permission scopes.
- Verified publisher domains when tenant policy requires them.

Admin consent is a privileged tenant operation. Review requested permissions and separate approval from application deployment where required.

## Provider Configuration

Configure providers in the calling root module:

```hcl
provider "azuread" {}

provider "azurerm" {
  features {}
}
```

The AzureAD provider must target the intended tenant. AzureRM is used only when storing a generated credential in Key Vault. The Time provider is configured implicitly by Terraform.

## Basic Usage

```hcl
module "application" {
  source = "./modules/appregistration"

  name                     = "appreg-orders-prod"
  sign_in_audience         = "AzureADMyOrg"
  create_service_principal = true

  tags = [
    "environment:prod",
    "owner:platform"
  ]
}
```

Runnable configurations are available in:

- [`examples/basic`](examples/basic/)
- [`examples/complete`](examples/complete/)
- [`examples/workload-identity`](examples/workload-identity/)

## Important Behavior and Secure Defaults

- Client-secret creation is disabled by default. Prefer workload identity federation or managed identity where supported.
- A generated client secret is sensitive and remains in Terraform state even when copied to Key Vault.
- `grant_admin_consent` applies only to application permissions and requires a service principal.
- Exposed role and scope IDs are durable API contracts; changing an ID can break clients and consent assignments.
- Redirect URIs must exactly match the application's sign-in flow.
- Set `prevent_duplicate_names` when tenant naming policy requires unique display names.
- Federated identity credentials belong to the application and do not require a service principal.

## Identity and RBAC

Application owners can be explicit object IDs, and the current caller can be added automatically. Prefer stable object IDs and keep ownership limited to operational principals.

Required resource access declares permissions but does not automatically grant delegated consent. Application permission admin consent can be assigned only when explicitly requested and when the Terraform identity has sufficient directory privileges.

## Naming and Tagging

Set `name` explicitly or let the module generate `appreg-<workload>-<environment>-<instance>`. `display_name` is retained as a deprecated compatibility alias.

Microsoft Entra application tags are strings rather than Azure Resource Manager key/value tags. Follow the repository [naming convention](../../docs/NAMING_CONVENTION.md); the ARM [tagging standard](../../docs/TAGGING_STANDARD.md) does not apply directly to directory objects.

## Testing

`tests/unit.tftest.hcl` uses mocked AzureAD, AzureRM, and Time providers with plan-only runs:

```powershell
terraform init -backend=false
terraform validate
terraform test
```

The test does not access the tenant, Key Vault, or other cloud resources.

## Known Limitations

- The module cannot approve delegated user consent.
- Tenant policies, verified domains, permission grants, and Conditional Access can reject otherwise valid plans at apply time.
- Secret values are present in Terraform state; Key Vault storage does not remove that exposure.
- Removing roles, scopes, or federated credentials can disrupt existing clients and pipelines.

## Terraform Reference

The content below is generated from the module source. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 3.0, < 4.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.13, < 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >= 3.0, < 4.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, < 5.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.13, < 1.0 |

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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_current_caller_as_owner"></a> [add\_current\_caller\_as\_owner](#input\_add\_current\_caller\_as\_owner) | When true, the current Terraform caller object ID is added as an owner. | `bool` | `true` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used when name is not provided. | `string` | `"dev"` | no |
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
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | Deprecated alias for name. Use name for the app registration display name override. | `string` | `""` | no |
| <a name="input_fallback_public_client_enabled"></a> [fallback\_public\_client\_enabled](#input\_fallback\_public\_client\_enabled) | Whether the application can use public client flows when no redirect URI is specified. | `bool` | `false` | no |
| <a name="input_feature_tags"></a> [feature\_tags](#input\_feature\_tags) | Optional feature tags to configure enterprise, gallery, custom SSO, or hidden app behavior. | <pre>object({<br>    custom_single_sign_on = optional(bool, false)<br>    enterprise            = optional(bool, false)<br>    gallery               = optional(bool, false)<br>    hide                  = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_federated_identity_credentials"></a> [federated\_identity\_credentials](#input\_federated\_identity\_credentials) | Federated identity credentials for workload identity federation, keyed by logical name. | <pre>map(object({<br>    display_name = string<br>    issuer       = string<br>    subject      = string<br>    audiences    = optional(list(string), ["api://AzureADTokenExchange"])<br>    description  = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_group_membership_claims"></a> [group\_membership\_claims](#input\_group\_membership\_claims) | Configures the groups claim issued in a user or OAuth 2.0 access token that the application expects. Possible values are None, SecurityGroup, DirectoryRole, ApplicationGroup or All. | `set(string)` | `[]` | no |
| <a name="input_identifier_uris"></a> [identifier\_uris](#input\_identifier\_uris) | A list of user-defined URI(s) that uniquely identify a Web application within its Azure AD tenant, or within a verified custom domain if the application is multi-tenant. | `list(string)` | `[]` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance identifier used when name is not provided. | `string` | `"001"` | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | Optional Azure Key Vault ID where the generated client secret should be stored. | `string` | `null` | no |
| <a name="input_known_client_applications"></a> [known\_client\_applications](#input\_known\_client\_applications) | Client application IDs known to this API for consent bundling. | `set(string)` | `[]` | no |
| <a name="input_mapped_claims_enabled"></a> [mapped\_claims\_enabled](#input\_mapped\_claims\_enabled) | Whether the app can use claims mapping without a custom signing key. | `bool` | `false` | no |
| <a name="input_marketing_url"></a> [marketing\_url](#input\_marketing\_url) | Optional marketing URL for the application. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Optional display name override for the Microsoft Entra app registration. Leave empty to generate one from the global naming convention. | `string` | `""` | no |
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
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier used when name is not provided. | `string` | `"project"` | no |

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
