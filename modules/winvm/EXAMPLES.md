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
  windows_group_domain_prefix = "example"
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
- `private_ip_addresses = []` keeps dynamic private IP allocation. When static private IPs are needed, provide exactly one IPv4 address per VM in `app_vm_number` order.
- When `enable_zone_spread = true` and `app_vm_number > 1`, the module assigns VM and optional managed data disk zones in round-robin order across `availability_zones`.
- For private endpoint and diagnostics options, supply the full dependent inputs together.
- Public networking is disabled by default. If enabled, `rdp_source_address_prefixes` must contain trusted IPv4 addresses or CIDR ranges; open-internet RDP is not provided by the module.

## Restricted Public RDP

```hcl
module "winvm" {
  source = "./modules/winvm"

  # Required existing-resource and credential inputs omitted for brevity.
  public_network_enabled      = true
  rdp_source_address_prefixes = ["203.0.113.10/32"]
}
```

## Multiple VMs With Static Private IPs

```hcl
module "winvm" {
  source = "./modules/winvm"

  # Required existing-resource and credential inputs omitted for brevity.
  app_vm_number = 2

  private_ip_addresses = [
    "10.42.20.20",
    "10.42.20.21",
  ]
}
```

## VM Diagnostics

```hcl
module "winvm" {
  source = "./modules/winvm"

  # Required existing-resource and credential inputs omitted for brevity.
  enable_diagnostics         = true
  log_analytics_workspace_id = "/subscriptions/<subscription-id>/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/log-platform"
}
```
- For SHIR scenarios, use `enable_shir = true` and set `adf_id`; do not provide a separate `shir_enabled` flag.

## Related Terraform Tests

- `tests/live.tftest.hcl`
