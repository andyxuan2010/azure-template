# SQL Database Examples

Examples below were regenerated from the current `sqldb` module interface.

## Example 1: Minimal

```hcl
module "sqldb" {
  source = "./modules/sqldb"

  app_env = "<app_env>"
  ad_admin_login_name = "<ad_admin_login_name>"
  ad_admin_object_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/<provider>/<type>/<name>"
  admin_password = "<admin_password>"
  admin_username = "<admin_username>"
}
```

## Example 2: Common Pattern

```hcl
module "sqldb" {
  source = "./modules/sqldb"

  app_env = "<app_env>"
  ad_admin_login_name = "<ad_admin_login_name>"
  ad_admin_object_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/<provider>/<type>/<name>"
  admin_password = "<admin_password>"
  admin_username = "<admin_username>"
  app_admin_group = ["00000000-0000-0000-0000-000000000000"]
  app_user_group = ["00000000-0000-0000-0000-000000000000"]
  enable_private_endpoint = false
  enable_diagnostics = false
  log_analytics_workspace_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/<provider>/<type>/<name>"
  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Notes

- Replace placeholder IDs, names, and resource IDs with environment-specific values.
- Prefer Entra object IDs over display names when group names are duplicated.
- For private endpoint and diagnostics options, supply the full dependent inputs together.

## Related Terraform Tests

- `tests/live.tftest.hcl`
