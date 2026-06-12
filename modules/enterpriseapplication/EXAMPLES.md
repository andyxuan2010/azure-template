# Enterprise Application Examples

## Example 1: Connect To App Registration

```hcl
module "appregistration" {
  source = "./modules/appregistration"

  display_name             = "app-contoso-web-prod"
  create_service_principal = false
}

module "enterpriseapplication" {
  source = "./modules/enterpriseapplication"

  application_id = module.appregistration.application_id
}
```

## Example 2: Require Assignment And Assign A Group

```hcl
module "enterpriseapplication" {
  source = "./modules/enterpriseapplication"

  application_id                  = module.appregistration.application_id
  app_role_assignment_required    = true
  preferred_single_sign_on_mode   = "oidc"

  app_role_assignments = {
    readers = {
      principal_object_id = azuread_group.readers.object_id
    }
  }
}
```

## Example 3: Application Proxy

```hcl
module "enterpriseapplication" {
  source = "./modules/enterpriseapplication"

  application_id           = module.appregistration.application_id
  create_application_proxy = true

  application_proxy = {
    internal_url                              = "https://intranet.contoso.local/"
    external_url                              = "https://intranet-contoso.msappproxy.net/"
    external_authentication_type              = "aadPreAuthentication"
    application_server_timeout                = "long"
    is_backend_certificate_validation_enabled = true
  }
}
```
