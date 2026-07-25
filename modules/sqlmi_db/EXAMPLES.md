# SQL Managed Instance Database Examples

Examples below were regenerated from the current `sqlmi_db` module interface.

## Example 1: Minimal

```hcl
module "sqlmi_db" {
  source = "./modules/sqlmi_db"

  app_sqlmi    = "sqlmi-data-prod"
  app_sqlmi_db = "orders"
  app_sqlmi_rg = "rg-data-prod"
}
```

## Example 2: Common Pattern

```hcl
module "sqlmi_db" {
  source = "./modules/sqlmi_db"

  app_sqlmi       = "sqlmi-data-prod"
  app_sqlmi_db    = "orders"
  app_sqlmi_rg    = "rg-data-prod"
  app_admin_group = ["00000000-0000-0000-0000-000000000001"]
  app_user_group  = ["00000000-0000-0000-0000-000000000002"]

  enable_diagnostics         = true
  log_analytics_workspace_id = "/subscriptions/<subscription-id>/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/log-platform"

  tags = {
    CostCenter = "1234"
  }
}
```

## Notes

- Replace placeholder IDs, names, and resource IDs with environment-specific values.
- Prefer Entra object IDs over display names when group names are duplicated.
- Diagnostics require a Log Analytics workspace resource ID.

## Related Terraform Tests

- `tests/live.tftest.hcl`
