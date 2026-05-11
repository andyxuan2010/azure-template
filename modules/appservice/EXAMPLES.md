# App Service Examples

Examples below were regenerated from the current `appservice` module interface.

## Example 1: Minimal

```hcl
module "appservice" {
  source = "./modules/appservice"

  app_name = "app-example-001"
  app_service_plan_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/<provider>/<type>/<name>"
  location = "eastus"
  resource_group_name = "rg-example-prod"
}
```

## Example 2: Common Pattern

```hcl
module "appservice" {
  source = "./modules/appservice"

  app_name = "app-example-001"
  app_service_plan_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/<provider>/<type>/<name>"
  location = "eastus"
  resource_group_name = "rg-example-prod"
  app_admin_group = ["00000000-0000-0000-0000-000000000000"]
  app_user_group = ["00000000-0000-0000-0000-000000000000"]
  enable_application_insights = true
  enable_private_endpoint = false
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
