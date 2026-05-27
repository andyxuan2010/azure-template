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
  iac_rg = "<iac_rg>"
  windows_image_publisher = "MicrosoftWindowsServer"
  windows_image_offer     = "WindowsServer"
  windows_image_sku       = "2025-Datacenter"
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
  iac_rg = "<iac_rg>"
  app_admin_group            = ["00000000-0000-0000-0000-000000000000"]
  app_user_group             = ["00000000-0000-0000-0000-000000000000"]
  windows_group_domain_prefix = "BBD"
  app_vm_number              = 3
  enable_zone_spread         = true
  availability_zones         = ["1", "2", "3"]
  enable_diagnostics         = false
  log_analytics_workspace_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/<provider>/<type>/<name>"
  windows_image_publisher    = "MicrosoftWindowsServer"
  windows_image_offer        = "WindowsServer"
  windows_image_sku          = "2025-Datacenter"
  windows_image_version      = "latest"
  tags = {
    Owner = "Platform"
  }
}
```

## Notes

- Replace placeholder IDs, names, and resource IDs with environment-specific values.
- Prefer Entra object IDs over display names when group names are duplicated.
- `azure-user` and `azure-password` are optional overrides. If either is empty, the module falls back to the configured Key Vault secret name for that credential.
- `admin_credentials_key_vault_id` can point to a different Key Vault than the shared IaC vault when Windows admin credentials are stored separately.
- `domain_join_user` and `domain_join_password` use the same direct-input-first fallback pattern when `enable_domain_join = true`; if either is empty, the module reads `domain_join_username_secret_name` or `domain_join_password_secret_name` from the selected Key Vault.
- `iac_kv` defaults to `kvplatformccdev` and `iac_st` defaults to `stplatformccdev`. Override them when an environment uses different shared IaC resource names.
- The module derives the shared Key Vault ID, storage account ID, and `scripts` container URL from inputs instead of reading those resources through Terraform data sources.
- `app_admin_group` gets `Virtual Machine Administrator Login`, `Contributor` on each VM and NIC, and local `Administrators` membership when Windows can resolve the value.
- `app_user_group` gets `Virtual Machine User Login`, `Reader` on each VM, and local `Remote Desktop Users` membership when Windows can resolve the value.
- Entra object IDs are preferred for Azure RBAC. GUID values are resolved to group display names before being passed to `init2.ps1` for local group membership. Set `windows_group_domain_prefix` when the VM needs `DOMAIN\GroupName` style values.
- When `enable_zone_spread = true` and `app_vm_number > 1`, the module assigns VM and optional managed data disk zones in round-robin order across `availability_zones`.
- For private endpoint and diagnostics options, supply the full dependent inputs together.
- For SHIR scenarios, use `enable_shir = true` and set `adf_id`; do not provide a separate `shir_enabled` flag.

## Related Terraform Tests

- `tests/live.tftest.hcl`
