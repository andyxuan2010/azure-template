# App Service Plan Examples

Examples below were regenerated from the current `appserviceplan` module interface.

## Example 1: Minimal

```hcl
module "appserviceplan" {
  source = "git::https://dev.azure.com/CCOE-Azure/CCoE-Infra-IaC/_git/template//modules/appserviceplan?ref=main"

  location = "canadacentral"
  name = "name-example-001"
  resource_group_name = "rg-example-prod"
  sku_name = "sku-example-001"
}
```

## Example 2: Common Pattern

```hcl
module "appserviceplan" {
  source = "git::https://dev.azure.com/CCOE-Azure/CCoE-Infra-IaC/_git/template//modules/appserviceplan?ref=main"

  location = "canadacentral"
  name = "name-example-001"
  resource_group_name = "rg-example-prod"
  sku_name = "sku-example-001"
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
