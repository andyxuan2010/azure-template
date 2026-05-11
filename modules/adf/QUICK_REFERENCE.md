# Azure Data Factory Quick Reference

Purpose: Provision Azure Data Factory with optional SHIR, managed private endpoints, Azure DevOps repository settings, RBAC, and diagnostics.

## Required Inputs

- `app_env`: `string`
- `app_rg`: `string`
- `app_snet`: `string`
- `app_vm`: `string`
- `app_vnet`: `string`
- `app_vnet_rg`: `string`
- `iac_kv`: `string`
- `iac_rg`: `string`
- `iac_st`: `string`
- `project`: `string`
- `resource_group`: `string`

## Common Optional Inputs

- `app_admin_group`: `list(string)`
- `app_user_group`: `list(string)`
- `custom_diagnostics_name`: `string`
- `enable_private_endpoint`: `bool`
- `log_analytics_workspace`: `map(string)`
- `managed_private_endpoint`: `set(object({ name = string target_resource_id = string subresource_name = string }))`
- `tags`: `map(any)`

## Primary Outputs

- `app_admin_group_role_assignment_ids`
- `app_user_group_role_assignment_ids`
- `default_integration_runtime_name`
- `diagnostics_enabled`
- `id`
- `identity`
- `merged_tags`
- `name`
- `self_hosted_integration_runtime_key`

## Test Commands

```powershell
terraform test
terraform test -filter='tests\live.tftest.hcl'
```
