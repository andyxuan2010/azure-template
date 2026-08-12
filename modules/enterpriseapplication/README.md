# Microsoft Entra Enterprise Application

Creates or adopts a Microsoft Entra service principal for an existing app registration, with controlled ownership, sign-on metadata, app-role assignments, and optional Application Proxy configuration.

## Features

- Creates or reuses the service principal associated with an application client ID.
- Controls account enablement and assignment-required behavior.
- Supports owner management, notification addresses, feature classification, and launch metadata.
- Supports OIDC, password, SAML, and unsupported-mode metadata.
- Creates app-role assignments for users, groups, or service principals.
- Optionally configures Microsoft Entra Application Proxy through Microsoft Graph beta.

## Resources Created

The module always manages one `azuread_service_principal`. It conditionally creates:

- `azuread_app_role_assignment` resources.
- One Microsoft Graph update operation for Application Proxy.

The app registration is caller-owned. The module only looks it up when Application Proxy is enabled.

## Prerequisites and Dependencies

- An existing Microsoft Entra app registration and its application/client ID.
- Tenant permission to create or update service principals, owners, and app-role assignments.
- A licensed and operational Application Proxy environment, including connectors and verified URLs, when proxy publishing is enabled.
- Terraform `>= 1.6.0`; AzureAD `>= 3.0, < 4.0`; Microsoft Graph provider `>= 0.3, < 1.0`.

Pass `module.appregistration.application_id` directly from the app registration composition when both resources are managed together.

## Provider Configuration

Configure both providers in the calling root module:

```hcl
provider "azuread" {}

provider "msgraph" {}
```

Application Proxy uses the Microsoft Graph beta API surface. Treat provider and API upgrades as compatibility-sensitive changes and validate them in a non-production tenant.

## Basic Usage

See the executable [basic example](examples/basic/), [complete example](examples/complete/), and isolated [Application Proxy example](examples/application-proxy/).

```hcl
module "enterprise_application" {
  source = "../../modules/enterpriseapplication"

  application_id               = module.appregistration.application_id
  use_existing                 = true
  add_current_caller_as_owner  = true
  app_role_assignment_required = true
}
```

## Important Behavior and Secure Defaults

- `use_existing` defaults to `true`, allowing adoption of the service principal already associated with the app registration.
- The current Terraform caller is added as an owner by default. Set explicit owners and disable this behavior when ownership must be independent of the deployment identity.
- `app_role_assignment_required` defaults to `false`; enable it when access must be restricted to assigned principals.
- The all-zero app role ID represents default access and may not be appropriate when the application defines explicit roles.
- Application Proxy inputs are accepted only when `create_application_proxy` is enabled.
- SAML relay state is accepted only when the preferred sign-on mode is SAML.

## Identity and Access

This module manages tenant objects rather than Azure Resource Manager resources. Azure RBAC, ARM tags, resource groups, and subscriptions do not apply.

App-role assignments authorize a principal against this enterprise application. Conditional Access, access reviews, entitlement management, consent, application credentials, certificates, and application-defined role declarations remain separate responsibilities.

## Application Proxy

Application Proxy changes update the connected app registration through Microsoft Graph beta. The external URL, internal URL, connector topology, TLS trust, backend authentication, cookie settings, and preauthentication mode must be reviewed together.

Do not treat the example URLs as deployable values. Validate connector reachability and sign-in behavior before production rollout.

## Testing

The unit tests use mocked AzureAD and Microsoft Graph providers:

```shell
terraform init -backend=false
terraform test
```

## Known Limitations

- The module does not create the app registration, credentials, API permissions, app roles, Conditional Access policies, or Application Proxy connectors.
- Application Proxy relies on a beta Graph API and may change independently of the Terraform module.
- Display-name uniqueness and assignment-principal lifecycle remain tenant governance concerns.
- Adoption with `use_existing = true` requires the existing service principal to be compatible with the desired state.

## Terraform Reference

The content below is generated from the module source. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 3.0, < 4.0 |
| <a name="requirement_msgraph"></a> [msgraph](#requirement\_msgraph) | >= 0.3, < 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >= 3.0, < 4.0 |
| <a name="provider_msgraph"></a> [msgraph](#provider\_msgraph) | >= 0.3, < 1.0 |

## Resources

| Name | Type |
|------|------|
| [azuread_app_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_service_principal.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [msgraph_update_resource.application_proxy](https://registry.terraform.io/providers/microsoft/msgraph/latest/docs/resources/update_resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_enabled"></a> [account\_enabled](#input\_account\_enabled) | Whether the Enterprise Application service principal account is enabled. | `bool` | `true` | no |
| <a name="input_add_current_caller_as_owner"></a> [add\_current\_caller\_as\_owner](#input\_add\_current\_caller\_as\_owner) | When true, the current Terraform caller object ID is added as an owner. | `bool` | `true` | no |
| <a name="input_app_role_assignment_required"></a> [app\_role\_assignment\_required](#input\_app\_role\_assignment\_required) | Whether users or groups must be assigned an app role before signing in through the Enterprise Application. | `bool` | `false` | no |
| <a name="input_app_role_assignments"></a> [app\_role\_assignments](#input\_app\_role\_assignments) | App role assignments for users, groups, or service principals, keyed by logical name. | <pre>map(object({<br>    principal_object_id = string<br>    app_role_id         = optional(string, "00000000-0000-0000-0000-000000000000")<br>  }))</pre> | `{}` | no |
| <a name="input_application_id"></a> [application\_id](#input\_application\_id) | Application (client) ID of the app registration this Enterprise Application/service principal connects to. | `string` | n/a | yes |
| <a name="input_application_proxy"></a> [application\_proxy](#input\_application\_proxy) | Application Proxy settings applied to the connected app registration when create\_application\_proxy is true. | <pre>object({<br>    internal_url                                   = string<br>    external_url                                   = string<br>    external_authentication_type                   = optional(string, "aadPreAuthentication")<br>    application_server_timeout                     = optional(string, "Default")<br>    is_backend_certificate_validation_enabled      = optional(bool, true)<br>    is_http_only_cookie_enabled                    = optional(bool, true)<br>    is_persistent_cookie_enabled                   = optional(bool, false)<br>    is_secure_cookie_enabled                       = optional(bool, true)<br>    is_state_session_enabled                       = optional(bool, true)<br>    is_translate_host_header_enabled               = optional(bool, true)<br>    is_translate_links_in_body_enabled             = optional(bool, false)<br>    is_continuous_access_evaluation_enabled        = optional(bool, true)<br>    traffic_routing_method                         = optional(string, "none")<br>    use_alternate_url_for_translation_and_redirect = optional(bool, false)<br>    alternate_url                                  = optional(string)<br>    verified_custom_domain_key_credential          = optional(any)<br>    verified_custom_domain_password_credential     = optional(any)<br>    single_sign_on_settings                        = optional(any)<br>  })</pre> | `null` | no |
| <a name="input_create_application_proxy"></a> [create\_application\_proxy](#input\_create\_application\_proxy) | When true, configures Microsoft Entra Application Proxy on the connected app registration. | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | Optional description for the Enterprise Application. | `string` | `null` | no |
| <a name="input_feature_tags"></a> [feature\_tags](#input\_feature\_tags) | Feature tags to classify the service principal as an Enterprise Application, gallery app, custom SSO app, or hidden app. | <pre>object({<br>    custom_single_sign_on = optional(bool, false)<br>    enterprise            = optional(bool, true)<br>    gallery               = optional(bool, false)<br>    hide                  = optional(bool, false)<br>  })</pre> | <pre>{<br>  "enterprise": true<br>}</pre> | no |
| <a name="input_login_url"></a> [login\_url](#input\_login\_url) | Optional URL Azure AD uses to launch the application from Microsoft 365 or My Apps. | `string` | `null` | no |
| <a name="input_notes"></a> [notes](#input\_notes) | Optional notes for the Enterprise Application. | `string` | `null` | no |
| <a name="input_notification_email_addresses"></a> [notification\_email\_addresses](#input\_notification\_email\_addresses) | Notification email addresses for the Enterprise Application. | `list(string)` | `[]` | no |
| <a name="input_owners"></a> [owners](#input\_owners) | List of Entra object IDs to set as Enterprise Application owners. | `list(string)` | `[]` | no |
| <a name="input_preferred_single_sign_on_mode"></a> [preferred\_single\_sign\_on\_mode](#input\_preferred\_single\_sign\_on\_mode) | Preferred single sign-on mode for the Enterprise Application. Use null to leave unset. | `string` | `null` | no |
| <a name="input_saml_relay_state"></a> [saml\_relay\_state](#input\_saml\_relay\_state) | Optional SAML relay state. Applies only when preferred\_single\_sign\_on\_mode is saml. | `string` | `null` | no |
| <a name="input_use_existing"></a> [use\_existing](#input\_use\_existing) | When true, the AzureAD provider attempts to use an existing service principal for application\_id. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_role_assignment_ids"></a> [app\_role\_assignment\_ids](#output\_app\_role\_assignment\_ids) | App role assignment IDs keyed by input name. |
| <a name="output_application_id"></a> [application\_id](#output\_application\_id) | Application (client) ID connected to this Enterprise Application. |
| <a name="output_application_proxy_enabled"></a> [application\_proxy\_enabled](#output\_application\_proxy\_enabled) | Whether this module configured Application Proxy. |
| <a name="output_application_proxy_external_url"></a> [application\_proxy\_external\_url](#output\_application\_proxy\_external\_url) | Application Proxy external URL configured on the connected app registration. |
| <a name="output_application_proxy_internal_url"></a> [application\_proxy\_internal\_url](#output\_application\_proxy\_internal\_url) | Application Proxy internal URL configured on the connected app registration. |
| <a name="output_display_name"></a> [display\_name](#output\_display\_name) | Display name of the Enterprise Application. |
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the Enterprise Application service principal. |
| <a name="output_object_id"></a> [object\_id](#output\_object\_id) | Object ID of the Enterprise Application service principal. |
| <a name="output_owners"></a> [owners](#output\_owners) | Effective owner object IDs applied to the Enterprise Application. |
<!-- END_TF_DOCS -->
