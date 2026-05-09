# Windows VM Quick Reference

Purpose: Provision Windows virtual machines with bootstrap, RBAC, SHIR integration, networking, and optional diagnostics.

## Required Inputs

- `app_rg`: `string`
- `app_snet`: `string`
- `app_vm`: `string`
- `app_vnet`: `string`
- `app_vnet_rg`: `string`
- `iac_kv`: `string`
- `iac_rg`: `string`
- `iac_st`: `string`

## Common Optional Inputs

- `app_admin_group`: `list(string)`
- `app_user_group`: `list(string)`
- `enable_zone_spread`: `bool`, defaults to `true`; when enabled and `app_vm_number > 1`, spreads VMs and optional managed data disks across availability zones in round-robin order
- `availability_zones`: `list(string)`, defaults to `["1", "2", "3"]`; used for round-robin zone placement of multi-VM deployments
- `enable_diagnostics`: `bool`
- `log_analytics_workspace_id`: `string`
- `tags`: `map(string)`

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
