# App Registration Module

Provision Microsoft Entra application registrations, service principals, and optional client secrets.

## Overview

- Providers: `azuread` `3.8.0`, `azurerm` `4.61.0`
- Inputs: 18
- Outputs: 8
- Nested modules: 0
- Terraform tests: `tests/live.tftest.hcl`

## Features

- Creates managed resources including `azuread_application`, `azuread_application_password`, `azurerm_key_vault_secret`, `azuread_service_principal`, and optional `azuread_app_role_assignment`.
- Supports optional API permissions through `required_resource_access`, including application permissions such as `Sites.Read.All` or `Sites.Selected`.
- Can grant admin consent for application permissions (`type = "Role"`) when `grant_admin_consent = true`.
- Can be used standalone or paired with App Service by generating redirect URIs from one or more App Service hostnames.
- Includes Terraform test coverage files: `tests/live.tftest.hcl`.

## Basic Usage

```hcl
module "appregistration" {
  source = "./modules/appregistration"

  display_name = "display-example-001"

  required_resource_access = {
    microsoft_graph = {
      resource_app_id = "00000003-0000-0000-c000-000000000000"
      resource_access = [
        {
          type                = "Role"
          value               = "Sites.Selected"
          grant_admin_consent = true
        }
      ]
    }
  }

  tags = [
    "ManagedBy:Terraform"
  ]
}
```

## Key Inputs

- `display_name`: Display name of the Microsoft Entra app registration. `string` (required)
- `app_service_redirect_hostnames`: Optional App Service hostnames used to generate callback URIs such as `/.auth/login/aad/callback` or `/auth/callback`. `list(string)` (default: `[]`)
- `app_service_auth_mode`: Redirect URI generation mode for App Service integration. `string` (default: `"easy_auth"`)
- `required_resource_access`: Optional API permissions to add to the app registration. `map(object(...))` (default: `{}`)
- `tags`: Optional tags for the app registration. `set(string)` (default: [])

## Naming

The app registration name is always controlled by `display_name`.

- Standalone usage: set `display_name` directly to whatever you want the Entra application to be named.
- App Service-integrated usage: you still control the name with `display_name`; App Service-related inputs only help generate redirect URIs and do not rename the app registration.
- Higher-level wrapper modules may compute a default name before calling this module, but this module itself does not derive the name from App Service.

## Notable Outputs

- `application_id`: Application (client) ID of the app registration.
- `application_object_id`: Object ID of the app registration.
- `client_secret`: Generated client secret value.
- `client_secret_key_id`: Key ID of the generated client secret.
- `client_secret_key_vault_secret_id`: ID of the Key Vault secret storing the generated client secret.
- `required_resource_access`: Resolved API permissions configured on the app registration.
- `service_principal_object_id`: Object ID of the created service principal.
- `web_redirect_uris`: Effective redirect URIs configured on the application.

## App Service Integration

When you want this module to work with `modules/appservice`, you can either:

- Keep passing explicit `web_redirect_uris`, as existing callers already do.
- Or pass `app_service_redirect_hostnames` and let this module generate the expected callback URIs for `easy_auth`, `msal`, or `both`.

Example:

```hcl
module "appregistration" {
  source = "./modules/appregistration"

  display_name = "app-contoso-web-prod"

  app_service_redirect_hostnames = [
    module.app_service.default_hostname
  ]
  app_service_auth_mode = "both"
}
```

## Testing

Run module tests from the module directory:

```powershell
terraform test
```

- `terraform test -filter='tests\live.tftest.hcl'`
