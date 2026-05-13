# Function App Quick Reference

Purpose: Provision Azure Function App with runtime stack, storage integration, networking, RBAC, and diagnostics.

## Required Inputs

- `name`: `string`
- `resource_group_name`: `string`
- `service_plan_id`: `string`
- `storage_account_name`: `string`

## Common Optional Inputs

- `app_admin_group`: `list(string)`
- `app_user_group`: `list(string)`
- `diagnostic_log_categories`: `list(string)`
- `diagnostic_metric_categories`: `list(string)`
- `enable_diagnostics`: `bool`
- `enable_private_endpoint`: `bool`
- `identity_ids`: `list(string)`
- `key_vault_reference_identity_id`: `string`
- `log_analytics_workspace_id`: `string`
- `private_endpoint_network_resource_group_name`: `string`
- `private_endpoint_subnet_id`: `string`
- `private_endpoint_subnet_name`: `string`

## Primary Outputs

- `app_admin_group_role_assignment_ids`
- `app_user_group_role_assignment_ids`
- `default_hostname`
- `diagnostic_setting_id`
- `id`
- `identity_principal_id`
- `identity_tenant_id`
- `kind`
- `name`
- `private_endpoint_id`
- `service_plan_id`
- `storage_account_id`

## Test Commands

```powershell
terraform test
terraform test -filter='tests\live.tftest.hcl'
```
