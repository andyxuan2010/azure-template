# SQL Managed Instance Database Quick Reference

Purpose: Provision Azure SQL Managed Instance databases with RBAC, tagging, and diagnostics.

## Required Inputs

- `app_sqlmi`: `string`
- `app_sqlmi_db`: `string`
- `app_sqlmi_rg`: `string`

## Common Optional Inputs

- `app_admin_group`: `list(string)`
- `app_user_group`: `list(string)`
- `diagnostic_log_categories`: `list(string)`
- `diagnostic_metric_categories`: `list(string)`
- `enable_diagnostics`: `bool`
- `log_analytics_workspace_id`: `string`

## Primary Outputs

- `administrator_login`
- `app_admin_group_role_assignment_ids`
- `app_user_group_role_assignment_ids`
- `diagnostics_enabled`
- `fqdn`
- `managed_database_id`
- `managed_database_name`
- `managed_database_tags`
- `managed_instance_id`
- `name`

## Test Commands

```powershell
terraform test
terraform test -filter='tests\live.tftest.hcl'
```
