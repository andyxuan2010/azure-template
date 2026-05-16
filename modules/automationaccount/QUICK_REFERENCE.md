# Automation Account Quick Reference

Purpose: Provision Azure Automation Account with RBAC, optional private endpoints, and diagnostics.

## Required Inputs

- `resource_group_name`: `string`

## Common Optional Inputs

- `app_admin_group`: `list(string)`
- `app_user_group`: `list(string)`
- `diagnostic_log_categories`: `list(string)`
- `diagnostic_metric_categories`: `list(string)`
- `enable_diagnostics`: `bool`
- `enable_hrw_private_endpoint`: `bool`
- `enable_webhook_private_endpoint`: `bool`
- `log_analytics_workspace_id`: `string`
- `managed_identity_role_assignments`: `map(object({ scope = string role_definition_name = optional(string) role_definition_id = optional(string) }))`
- `private_endpoint_network_resource_group_name`: `string`
- `private_endpoint_subnet_id`: `string`
- `private_endpoint_subnet_name`: `string`

## Primary Outputs

- `app_admin_group_role_assignment_ids`
- `app_user_group_role_assignment_ids`
- `diagnostic_setting_id`
- `id`
- `identity`
- `local_authentication_enabled`
- `location`
- `managed_identity_role_assignment_ids`
- `name`
- `principal_id`
- `private_endpoint_id`
- `private_endpoint_ids`

## Test Commands

```powershell
terraform test
terraform test -filter='tests\live.tftest.hcl'
```
