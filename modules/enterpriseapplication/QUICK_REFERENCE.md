# Enterprise Application Quick Reference

## Minimum

```hcl
module "enterpriseapplication" {
  source         = "./modules/enterpriseapplication"
  application_id = module.appregistration.application_id
}
```

## Key Inputs

- `application_id`: App registration client ID to connect.
- `create_application_proxy`: Enables Application Proxy configuration.
- `application_proxy`: Internal/external URL and proxy settings.
- `app_role_assignment_required`: Requires assignment before users can sign in.
- `app_role_assignments`: Assigns users, groups, or service principals to the Enterprise Application.

## Key Outputs

- `object_id`: Enterprise Application service principal object ID.
- `application_id`: Connected app registration client ID.
- `application_proxy_external_url`: Published proxy URL when enabled.
