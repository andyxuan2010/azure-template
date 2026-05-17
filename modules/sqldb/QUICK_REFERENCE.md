# SQL Database Quick Reference

Purpose: Provision Azure SQL Server and SQL Database with RBAC, auditing, private endpoint, and diagnostics.

## Required Inputs

- `app_env`: `string`
- `ad_admin_login_name`: `string`
- `ad_admin_object_id`: `string`
- `admin_password`: `string`
- `admin_username`: `string`
- `database_name`: `string`
- `max_size_gb`: `number`
- `resource_group_name`: `string`
- `server_name`: `string`
- `sku_name`: `string`

## Common Optional Inputs

- `app_admin_group`: `list(string)`
- `app_user_group`: `list(string)`
- `diagnostic_log_categories`: `list(string)`
- `diagnostic_metric_categories`: `list(string)`
- `enable_diagnostics`: `bool`
- `enable_private_endpoint`: `bool`
- `log_analytics_workspace_id`: `string`
- `private_endpoint_subnet_id`: `string`
- `tags`: `map(string)`

## Primary Outputs

- `app_admin_group_role_assignment_ids`
- `app_user_group_role_assignment_ids`
- `backup_configuration`
- `database_tags`
- `diagnostic_setting_id`
- `private_endpoint_id`
- `private_endpoint_nic_id`
- `sql_database_id`
- `database_name`
- `sql_server_fqdn`
- `sql_server_id`
- `server_name`

## Test Commands

```powershell
terraform test
terraform test -filter='tests\live.tftest.hcl'
```
