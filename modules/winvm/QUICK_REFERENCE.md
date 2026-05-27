# Windows VM Quick Reference

Purpose: Provision Windows virtual machines with bootstrap, RBAC, SHIR integration, networking, and optional diagnostics.

## Required Inputs

- `app_rg`: `string`
- `app_snet`: `string`
- `app_vm`: `string`
- `app_vnet`: `string`
- `app_vnet_rg`: `string`
- `iac_rg`: `string`

## Common Optional Inputs

- `app_admin_group`: `list(string)`
- `app_user_group`: `list(string)`
- `windows_group_domain_prefix`: `string`; optional prefix for bare Windows local group membership names, for example `BBD`
- `iac_kv`: `string`, defaults to `kvplatformccdev`; used to derive the shared IaC Key Vault resource ID
- `iac_st`: `string`, defaults to `stplatformccdev`; used to derive the shared IaC storage account resource ID and `scripts` container URL
- `azure-user`: `string`; when empty, fall back to the configured Key Vault username secret
- `azure-password`: `string`; when empty, fall back to the configured Key Vault password secret
- `admin_credentials_key_vault_id`: `string`; optional explicit Key Vault resource ID for admin credentials
- `admin_username_secret_name`: `string`; defaults to `azure-user`
- `admin_password_secret_name`: `string`; defaults to `azure-password`
- `domain_join_user`: `string`; when empty, fall back to the configured Key Vault domain join username secret
- `domain_join_password`: `string`; when empty, fall back to the configured Key Vault domain join password secret
- `domain_join_username_secret_name`: `string`; defaults to `domain-join-user`
- `domain_join_password_secret_name`: `string`; defaults to `domain-join-password`
- `enable_zone_spread`: `bool`, defaults to `true`; when enabled and `app_vm_number > 1`, spreads VMs and optional managed data disks across availability zones in round-robin order
- `availability_zones`: `list(string)`, defaults to `["1", "2", "3"]`; used for round-robin zone placement of multi-VM deployments
- `enable_diagnostics`: `bool`
- `log_analytics_workspace_id`: `string`
- `tags`: `map(string)`; overrides matching inherited resource group tag values

## Tags

`local.tags` starts with the existing application resource group's tags, then overlays `tags` and the computed `workload` tag. Later layers win for duplicate keys.

## Shared IaC References

The module does not look up the shared Key Vault, storage account, or `scripts` container with data sources. It derives their resource IDs and blob URL from `iac_rg`, `iac_kv`, `iac_st`, and the current Azure subscription.

## Access Model

- `app_admin_group`: `Virtual Machine Administrator Login`, VM/NIC `Contributor`, and local `Administrators` membership when Windows can resolve the identity.
- `app_user_group`: `Virtual Machine User Login`, VM `Reader`, and local `Remote Desktop Users` membership when Windows can resolve the identity.
- GUID group values are resolved to Entra group display names before being passed to `init2.ps1` for local group membership. `windows_group_domain_prefix` prefixes bare names only.
- `scripts/validation.ps1` is downloaded to `$env:ProgramData\Bootstrap\validation.ps1` when it exists in the storage `scripts` container. Run it with `-AppAdminGroup '<groups>' -AppUserGroup '<groups>'` to validate local group membership on the target VM.

## Primary Outputs

- `diagnostics_enabled`
- `merged_tags`
- `principal_ids`
- `privateips`
- `public_ip`
- `role_assignment_ids`
- `vm_ids`

## Test Commands

```powershell
terraform test
terraform test -filter='tests\live.tftest.hcl'
```
