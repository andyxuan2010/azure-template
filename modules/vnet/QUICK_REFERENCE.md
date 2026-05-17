# Virtual Network Quick Reference

Purpose: Provision Azure Virtual Network and subnets with RBAC and diagnostics.

## Required Inputs

- `address_space`: `list(string)`
- `resource_group_name`: `string`

## Common Optional Inputs

- `app_admin_group`: `list(string)`
- `app_user_group`: `list(string)`
- `diagnostic_log_categories`: `list(string)`
- `diagnostic_metric_categories`: `list(string)`
- `enable_diagnostics`: `bool`
- `log_analytics_workspace_id`: `string`
- `tags`: `map(string)`

## Primary Outputs

- `address_space`
- `app_admin_group_role_assignment_ids`
- `app_user_group_role_assignment_ids`
- `diagnostic_setting_id`
- `id`
- `location`
- `name`
- `resource_group_name`
- `subnet_ids`
- `subnet_names`
- `tags`

## Test Commands

```powershell
terraform test
terraform test -filter='tests\live.tftest.hcl'
```
