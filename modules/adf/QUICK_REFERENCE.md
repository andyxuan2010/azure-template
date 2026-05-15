# Azure Data Factory Quick Reference

Purpose: Provision Azure Data Factory with optional SHIR, managed private endpoints, Azure DevOps or GitHub repository settings, RBAC, diagnostics, customer-managed keys, and Purview integration.

## Required Inputs

- `name`: `string`
- `app_env`: `string`
- `app_rg`: `string`
- `app_snet`: `string`
- `app_vnet`: `string`
- `app_vnet_rg`: `string`
- `iac_kv`: `string`
- `iac_rg`: `string`
- `iac_st`: `string`
- `resource_group`: `string`

## Common Optional Inputs

- `app_admin_group`: `list(string)`
- `app_user_group`: `list(string)`
- `custom_diagnostics_name`: `string`
- `enable_private_endpoint`: `bool`
- `github_configuration`: `object(...)`
- `identity_ids`: `list(string)`
- `identity_type`: `string`
- `log_analytics_workspace`: `map(string)`
- `managed_private_endpoint`: `set(object({ name = string target_resource_id = string subresource_name = string }))`
- `public_network_enabled`: `bool`
- `purview_id`: `string`
- `self_hosted_integration_runtime_enabled`: `bool`
- `tags`: `map(any)`
- `vsts_configuration`: `object(...)`

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

Notes:
- `app_vm` is only required when `self_hosted_integration_runtime_enabled = true`.
- Configure either `vsts_configuration` or `github_configuration`, not both.
