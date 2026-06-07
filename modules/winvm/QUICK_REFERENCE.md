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
- `windows_group_domain_prefix`: `string`; optional prefix for bare Windows local group membership names
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
- `enable_custom_script_extension`: `bool`; run bootstrap through the Custom Script Extension
- `enable_virtual_machine_run_command`: `bool`; run the same bootstrap through `azurerm_virtual_machine_run_command`; mutually exclusive with `enable_custom_script_extension`
- `enable_zone_spread`: `bool`, defaults to `true`; when enabled and `app_vm_number > 1`, spreads VMs and optional managed data disks across availability zones in round-robin order
- `availability_zones`: `list(string)`, defaults to `["1", "2", "3"]`; used for round-robin zone placement of multi-VM deployments
- `enable_diagnostics`: `bool`
- `log_analytics_workspace_id`: `string`
- `tags`: `map(string)`; overrides matching inherited resource group tag values

## Tags

`local.tags` starts with the existing application resource group's tags, then overlays `tags` and the computed `workload` tag. Later layers win for duplicate keys.

## Shared IaC References

The module does not look up the shared Key Vault, storage account, or `scripts` container with data sources. It derives their resource IDs and blob URL from `iac_rg`, `iac_kv`, `iac_st`, and the current Azure subscription.

## Windows Localization

Optional localization scripts are read from the configured localization container by `scheduled.ps1` after the VM has been idle for 5 minutes, no users are logged on, scheduled packages have installed, and PATH updates have completed:

- `localization/localization.ps1`: OS/base Windows localization by default; `windows-localization.ps1` is also supported
- `localization/<COMPUTERNAME>.ps1` or `localization/<VM_NAME>.ps1`: VM-specific localization, for example `localization/azuwiccoejmp601.ps1`

Missing or empty localization scripts are skipped without failing bootstrap. Script execution failures are logged as warnings.

## Bootstrap Notes

- `init2.ps1` sets the Windows time zone to `Eastern Standard Time` by default.
- Current package installs are PowerShell 7, Azure CLI, 7-Zip, and standalone BGInfo.
- BGInfo downloads `default.bgi` and `background.png`, applies the background wallpaper, and runs through a logon helper for interactive users such as `azureadmin`.
- Az Modules, Git, Terraform, Sysinternals Suite, AWS CLI, Postman, MobaXterm, and AzCopy run from `scheduled.ps1` after the VM is idle and no users are logged on.
- Storage and Key Vault bootstrap access use managed-identity REST calls instead of Az PowerShell modules.
- Missing optional script blobs fail fast and are logged as skipped.
- Azure Arc surfacing cleanup is warning-only and removes registry surfacing, shortcuts, matching scheduled tasks, and the `AzureArcSetup~~~~` capability when present.
- VM `custom_data` changes are ignored to avoid rebuilding existing VMs when `init2.ps1` changes.

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
