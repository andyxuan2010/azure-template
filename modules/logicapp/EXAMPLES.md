# Logic App Examples

Examples below were regenerated from the current `logicapp` module interface.

## Example 1: Minimal

```hcl
module "logicapp" {
  source = "./modules/logicapp"

  name                 = "logic-example-001"
  resource_group_name  = "rg-example-prod"
  service_plan_id      = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Web/serverFarms/<plan-name>"
  storage_account_name = "storageexample001"
}
```

## Example 2: Common Pattern

```hcl
module "logicapp" {
  source = "./modules/logicapp"

  name                                = "logic-example-001"
  resource_group_name                 = "rg-example-prod"
  service_plan_id                     = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Web/serverFarms/<plan-name>"
  storage_account_name                = "storageexample001"
  app_admin_group                     = ["00000000-0000-0000-0000-000000000000"]
  app_user_group                      = ["00000000-0000-0000-0000-000000000000"]
  enable_private_endpoint             = false
  enable_diagnostics                  = true
  log_analytics_workspace_id          = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.OperationalInsights/workspaces/<workspace-name>"
  system_assigned_identity_enabled    = true
  public_network_access_enabled       = false
  tags = {
    Owner = "Platform"
  }
}
```

## Notes

- Replace placeholder IDs, names, and resource IDs with environment-specific values.
- Prefer Entra object IDs over display names when group names are duplicated.
- Logic App Standard requires an existing App Service Plan and Storage Account.
- For private endpoint and diagnostics options, supply the full dependent inputs together.
- `vnet_route_all_enabled` requires VNet integration.
- Connection string names must be unique.

## Related Terraform Tests

- `tests/live.tftest.hcl` uses mock providers and performs plan-only tests.
