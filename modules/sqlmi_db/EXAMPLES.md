# SQL Managed Instance Database Examples

Examples below were regenerated from the current `sqlmi_db` module interface.

## Example 1: Minimal

```hcl
module "sqlmi_db" {
  source = "./modules/sqlmi_db"

  app_sqlmi = "<app_sqlmi>"
  app_sqlmi_db = "<app_sqlmi_db>"
  app_sqlmi_rg = "<app_sqlmi_rg>"
}
```

## Example 2: Common Pattern

```hcl
module "sqlmi_db" {
  source = "./modules/sqlmi_db"

  app_sqlmi = "<app_sqlmi>"
  app_sqlmi_db = "<app_sqlmi_db>"
  app_sqlmi_rg = "<app_sqlmi_rg>"
  app_admin_group = ["00000000-0000-0000-0000-000000000000"]
  app_user_group = ["00000000-0000-0000-0000-000000000000"]
  enable_diagnostics = false
  log_analytics_workspace_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/<provider>/<type>/<name>"
}
```

## Notes

- Replace placeholder IDs, names, and resource IDs with environment-specific values.
- Prefer Entra object IDs over display names when group names are duplicated.
- For private endpoint and diagnostics options, supply the full dependent inputs together.

## Related Terraform Tests

- `tests/live.tftest.hcl`
