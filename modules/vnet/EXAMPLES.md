# Virtual Network Examples

Examples below were regenerated from the current `vnet` module interface.

## Example 1: Minimal

```hcl
module "vnet" {
  source = "./modules/vnet"

  address_space       = ["10.20.0.0/16"]
  resource_group_name = "rg-example-prod"
  location            = "canadacentral"
}
```

## Example 2: Common Pattern

```hcl
module "vnet" {
  source = "./modules/vnet"

  address_space       = ["10.20.0.0/16"]
  resource_group_name = "rg-example-prod"
  location            = "canadacentral"
  inherited_resource_group_tags = {
    Owner          = "Network"
    application_id = "hub"
  }
  subnets = {
    application = {
      address_prefixes  = ["10.20.1.0/24"]
      service_endpoints = ["Microsoft.Storage"]
    }
    private_endpoints = {
      address_prefixes                  = ["10.20.2.0/24"]
      private_endpoint_network_policies = "Disabled"
    }
  }
  app_admin_group = ["00000000-0000-0000-0000-000000000001"]
  app_user_group  = ["00000000-0000-0000-0000-000000000002"]
  enable_diagnostics         = true
  log_analytics_workspace_id = "/subscriptions/<subscription-id>/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/log-platform"
  tags = {
    Owner = "Platform"
  }
}
```

## Notes

- Replace placeholder IDs, names, and resource IDs with environment-specific values.
- Prefer Entra object IDs over display names when group names are duplicated.
- Set both `location` and `inherited_resource_group_tags` to avoid a resource-group data lookup during plan.

## Related Terraform Tests

- `tests/live.tftest.hcl`
