# Enterprise Application Module

Creates and manages a Microsoft Entra Enterprise Application service principal connected to an app registration, with optional user/group/service-principal assignments and optional Microsoft Entra Application Proxy configuration.

## Overview

- Providers: `azuread`, `msgraph`
- Use case: Enterprise Application lifecycle for an existing app registration
- Optional: Application Proxy publishing through Microsoft Graph beta `onPremisesPublishing`
- Terraform tests: `tests/live.tftest.hcl`
- The app registration lookup is performed only when Application Proxy is enabled.
- Tests use mocked AzureAD and Microsoft Graph providers.

## Basic Usage

```hcl
module "enterpriseapplication" {
  source = "./modules/enterpriseapplication"

  application_id = module.appregistration.application_id
}
```

## Application Proxy

```hcl
module "enterpriseapplication" {
  source = "./modules/enterpriseapplication"

  application_id             = module.appregistration.application_id
  create_application_proxy   = true

  application_proxy = {
    internal_url                 = "https://intranet.contoso.local/"
    external_url                 = "https://intranet-contoso.msappproxy.net/"
    external_authentication_type = "aadPreAuthentication"
  }
}
```

## Proper Usage

- Use `application_id = module.appregistration.application_id` to connect to the app registration module.
- Keep `use_existing = true` when an Enterprise Application already exists for the app registration.
- Set `app_role_assignment_required = true` only when assignments are owned by Terraform or another controlled process.
- Application Proxy uses Microsoft Graph beta APIs, which Microsoft documents as subject to change and not supported for production use.
- `application_proxy` and `create_application_proxy` must be set together; proxy settings are never silently ignored.

## Dependencies

- Required: existing app registration client ID
- Common upstream: `appregistration`
- Common downstream: app role assignments, conditional access, access packages
