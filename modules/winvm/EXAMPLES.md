# Windows VM Examples

Examples below were regenerated from the current `winvm` module interface.

## Example 1: Minimal

```hcl
module "winvm" {
  source = "./modules/winvm"

  app_rg = "<app_rg>"
  app_snet = "<app_snet>"
  app_vm = "<app_vm>"
  app_vnet = "<app_vnet>"
  app_vnet_rg = "<app_vnet_rg>"
  iac_kv = "<iac_kv>"
  iac_rg = "<iac_rg>"
  iac_st = "<iac_st>"
  windows_image_publisher = "MicrosoftWindowsServer"
  windows_image_offer     = "WindowsServer"
  windows_image_sku       = "2022-Datacenter"
  windows_image_version   = "latest"
  azure-user              = "azureadmin"
  azure-password          = "ChangeMe123!"
}
```

## Example 2: Common Pattern

```hcl
module "winvm" {
  source = "./modules/winvm"

  app_rg = "<app_rg>"
  app_snet = "<app_snet>"
  app_vm = "<app_vm>"
  app_vnet = "<app_vnet>"
  app_vnet_rg = "<app_vnet_rg>"
  iac_kv = "<iac_kv>"
  iac_rg = "<iac_rg>"
  iac_st = "<iac_st>"
  app_admin_group            = ["00000000-0000-0000-0000-000000000000"]
  app_user_group             = ["00000000-0000-0000-0000-000000000000"]
  app_vm_number              = 3
  enable_zone_spread         = true
  availability_zones         = ["1", "2", "3"]
  enable_diagnostics         = false
  log_analytics_workspace_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/<provider>/<type>/<name>"
  windows_image_publisher    = "MicrosoftWindowsServer"
  windows_image_offer        = "WindowsServer"
  windows_image_sku          = "2022-Datacenter"
  windows_image_version      = "latest"
  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Notes

- Replace placeholder IDs, names, and resource IDs with environment-specific values.
- Prefer Entra object IDs over display names when group names are duplicated.
- `azure-user` and `azure-password` are optional overrides. If either is empty, the module falls back to the matching Key Vault secret.
- `app_admin_group` gets `Contributor` on each VM resource and each NIC created by the module.
- When `enable_zone_spread = true` and `app_vm_number > 1`, the module assigns VM and optional managed data disk zones in round-robin order across `availability_zones`.
- For private endpoint and diagnostics options, supply the full dependent inputs together.
- For SHIR scenarios, use `enable_shir = true` and set `adf_id`; do not provide a separate `shir_enabled` flag.

## Related Terraform Tests

- `tests/live.tftest.hcl`
