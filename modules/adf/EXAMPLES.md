# Azure Data Factory Examples

Examples below were regenerated from the current `adf` module interface.

## Example 1: Minimal

```hcl
module "adf" {
  source = "./modules/adf"

  app_env = "<app_env>"
  app_rg = "<app_rg>"
  app_snet = "<app_snet>"
  app_vm = "<app_vm>"
  app_vnet = "<app_vnet>"
  app_vnet_rg = "<app_vnet_rg>"
  iac_kv = "<iac_kv>"
  iac_rg = "<iac_rg>"
}
```

## Example 2: Common Pattern

```hcl
module "adf" {
  source = "./modules/adf"

  app_env = "<app_env>"
  app_rg = "<app_rg>"
  app_snet = "<app_snet>"
  app_vm = "<app_vm>"
  app_vnet = "<app_vnet>"
  app_vnet_rg = "<app_vnet_rg>"
  iac_kv = "<iac_kv>"
  iac_rg = "<iac_rg>"
  app_admin_group = ["00000000-0000-0000-0000-000000000000"]
  app_user_group = ["00000000-0000-0000-0000-000000000000"]
  enable_private_endpoint = false
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
