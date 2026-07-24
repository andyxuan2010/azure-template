# App Registration Examples

## Example 1: Minimal

```hcl
module "appregistration" {
  source = "./modules/appregistration"

  display_name = "app-contoso-api-dev"

  tags = [
    "env:dev",
    "iac:terraform",
    "module:appregistration"
  ]
}
```

## Example 2: App Service Web Sign-In

```hcl
module "appregistration" {
  source = "./modules/appregistration"

  display_name = "app-contoso-web-prod"

  web_redirect_uris = [
    "https://web.contoso.com/signin-oidc"
  ]

  app_service_redirect_hostnames = [
    module.appservice.default_hostname
  ]

  app_service_auth_mode = "both"
  web_homepage_url      = "https://web.contoso.com"
  web_logout_url        = "https://web.contoso.com/logout"
}
```

## Example 3: Exposed API

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

## Example 4: Microsoft Graph Application Permission

```hcl
module "appregistration" {
  source = "./modules/appregistration"

  display_name = "app-contoso-graph-prod"

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
}
```

## Example 5: GitHub Workload Identity Federation

```hcl
module "appregistration" {
  source = "./modules/appregistration"

  display_name             = "app-contoso-github-prod"
  create_service_principal = false

  federated_identity_credentials = {
    github_main = {
      display_name = "github-main"
      issuer       = "https://token.actions.githubusercontent.com"
      subject      = "repo:contoso/platform:ref:refs/heads/main"
    }
  }
}
```

A service principal is optional for workload identity federation because the credential is attached directly to the application registration.

## Example 6: Client Secret Stored in Key Vault

```hcl
module "appregistration" {
  source = "./modules/appregistration"

  display_name = "app-contoso-secret-prod"

  create_client_secret                 = true
  client_secret_display_name           = "deployment"
  client_secret_end_date_relative      = "2160h"
  key_vault_id                         = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.KeyVault/vaults/<vault-name>"
  client_secret_key_vault_secret_name  = "app-contoso-secret-client-secret"
}
```

## Notes

- Prefer explicit GUIDs for `app_roles`, `oauth2_permission_scopes`, and owners so Terraform remains stable.
- `grant_admin_consent` is supported only for application permissions where `type = "Role"`.
- Federated identity credentials require `create_service_principal = true`.
- Microsoft Entra application `tags` are a `set(string)`, not Azure ARM tags.
