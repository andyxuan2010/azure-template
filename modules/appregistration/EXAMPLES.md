# App Registration Examples

Examples below were regenerated from the current `appregistration` module interface.

## Example 1: Minimal

```hcl
module "appregistration" {
  source = "./modules/appregistration"

  display_name = "app-contoso-api-dev"
}
```

## Example 2: Common Pattern

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
  tags = [
    "ManagedBy:Terraform"
  ]
}
```

## Example 3: App Service Integration

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

## Example 4: Microsoft Graph Sites.Read.All

```hcl
module "appregistration" {
  source = "./modules/appregistration"

  display_name = "app-contoso-sharepoint-prod"

  required_resource_access = {
    microsoft_graph = {
      resource_app_id = "00000003-0000-0000-c000-000000000000"
      resource_access = [
        {
          type                = "Role"
          value               = "Sites.Read.All"
          grant_admin_consent = true
        }
      ]
    }
  }
}
```

## Notes

- Replace placeholder IDs, names, and resource IDs with environment-specific values.
- `display_name` is always the app registration name; App Service integration only affects generated redirect URIs.
- Prefer Entra object IDs over display names when group names are duplicated.
- For private endpoint and diagnostics options, supply the full dependent inputs together.

## Related Terraform Tests

- `tests/live.tftest.hcl`
