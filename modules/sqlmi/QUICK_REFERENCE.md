# SQL Managed Instance Quick Reference

Purpose: Provision Azure SQL Managed Instance with identity, Entra administrator, RBAC, and diagnostics.

## Required Inputs

- `administrator_login`: `string`
- `administrator_login_password`: `string`
- `name`: `string`
- `resource_group_name`: `string`
- `sku_name`: `string`
- `storage_size_in_gb`: `number`
- `subnet_id`: `string`
- `vcores`: `number`

## Common Optional Inputs

- `app_admin_group`: `list(string)`
- `app_user_group`: `list(string)`
- `diagnostic_log_categories`: `list(string)`
- `diagnostic_metric_categories`: `list(string)`
- `enable_diagnostics`: `bool`
- `identity_ids`: `set(string)`
- `identity_type`: `string`
- `log_analytics_workspace_id`: `string`
- `tags`: `map(string)`

## Primary Outputs

- `administrator_login`
- `app_admin_group_role_assignment_ids`
- `app_user_group_role_assignment_ids`
- `diagnostic_setting_id`
- `fqdn`
- `id`
- `location`
- `name`
- `principal_id`
- `resource_group_name`
- `subnet_id`
- `tags`

## Test Commands

```powershell
terraform test
terraform test -filter='tests\live.tftest.hcl'
```
