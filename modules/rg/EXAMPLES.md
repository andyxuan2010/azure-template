# Resource Group Examples

Examples below were regenerated from the current `rg` module interface.

## Example 1: Minimal

```hcl
module "rg" {
  source = "./modules/rg"

  location = "eastus"
}
```

## Example 2: Common Pattern

```hcl
module "rg" {
  source = "./modules/rg"

  location = "eastus"
  app_admin_group = ["00000000-0000-0000-0000-000000000000"]
  app_user_group = ["00000000-0000-0000-0000-000000000000"]
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
