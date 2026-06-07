# Virtual Network Examples

Examples below were regenerated from the current `vnet` module interface.

## Example 1: Minimal

```hcl
module "vnet" {
  source = "./modules/vnet"

  address_space = []
  resource_group_name = "rg-example-prod"
}
```

## Example 2: Common Pattern

```hcl
module "vnet" {
  source = "./modules/vnet"

  address_space = []
  resource_group_name = "rg-example-prod"
  app_admin_group = ["00000000-0000-0000-0000-000000000000"]
  app_user_group = ["00000000-0000-0000-0000-000000000000"]
  enable_diagnostics = false
  log_analytics_workspace_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/<provider>/<type>/<name>"
  tags = {
    Owner = "Platform"
  }
}
```

## Notes

- Replace placeholder IDs, names, and resource IDs with environment-specific values.
- Prefer Entra object IDs over display names when group names are duplicated.
- For private endpoint and diagnostics options, supply the full dependent inputs together.

## Related Terraform Tests

- `tests/live.tftest.hcl`
