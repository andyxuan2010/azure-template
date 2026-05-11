# SQL Database Quick Reference

Purpose: Provision Azure SQL Server and SQL Database with RBAC, auditing, private endpoint, and diagnostics.

## Required Inputs

- `app_env`: `string`
- `sql_ad_admin`: `string`
- `sql_ad_admin_id`: `string`
- `sql_admin_password`: `string`
- `sql_admin_username`: `string`
- `sql_database_name`: `string`
- `sql_max_size_gb`: `number`
- `sql_rg_name`: `string`
- `sql_server_name`: `string`
- `sql_sku_name`: `string`

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
- `sql_database_name`
- `sql_server_fqdn`
- `sql_server_id`
- `sql_server_name`

## Test Commands

```powershell
terraform test
terraform test -filter='tests\live.tftest.hcl'
```
