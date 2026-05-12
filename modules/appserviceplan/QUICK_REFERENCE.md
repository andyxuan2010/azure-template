# App Service Plan Quick Reference

Purpose: Provision Azure App Service Plan with optional autoscale, RBAC, and diagnostics.

## Required Inputs

- `location`: `string`
- `name`: `string`
- `resource_group_name`: `string`
- `sku_name`: `string`

## Common Optional Inputs

- `app_admin_group`: `list(string)`
- `app_user_group`: `list(string)`
- `diagnostic_log_categories`: `list(string)`
- `diagnostic_metrics`: `list(string)`
- `enable_diagnostics`: `bool`
- `log_analytics_workspace_id`: `string`
- `tags`: `map(string)`

## Primary Outputs

- `app_admin_group_role_assignment_ids`
- `app_user_group_role_assignment_ids`
- `autoscale_config`
- `autoscale_setting_id`
- `autoscale_setting_name`
- `diagnostic_setting_id`
- `diagnostic_setting_name`
- `id`
- `location`
- `name`
- `os_type`
- `resource_group_name`

## Test Commands

```powershell
terraform test
terraform test -filter='tests\live.tftest.hcl'
```
