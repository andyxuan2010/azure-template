# SQL Managed Instance Examples

Examples below were regenerated from the current `sqlmi` module interface.

## Example 1: Minimal

```hcl
module "sqlmi" {
  source = "./modules/sqlmi"

  administrator_login = "<administrator_login>"
  administrator_login_password = "<administrator_login_password>"
  name = "name-example-001"
  resource_group_name = "rg-example-prod"
  sku_name = "sku-example-001"
  storage_size_in_gb = 1
  subnet_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/<provider>/<type>/<name>"
  vcores = 1
}
```

## Example 2: Common Pattern

```hcl
module "sqlmi" {
  source = "./modules/sqlmi"

  administrator_login = "<administrator_login>"
  administrator_login_password = "<administrator_login_password>"
  name = "name-example-001"
  resource_group_name = "rg-example-prod"
  sku_name = "sku-example-001"
  storage_size_in_gb = 1
  subnet_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/<provider>/<type>/<name>"
  vcores = 1
  app_admin_group = ["00000000-0000-0000-0000-000000000000"]
  app_user_group = ["00000000-0000-0000-0000-000000000000"]
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
