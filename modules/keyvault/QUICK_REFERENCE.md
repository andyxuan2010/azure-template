# Key Vault Quick Reference

Purpose: Provision Azure Key Vault with RBAC, network ACLs, private endpoints, and diagnostics.

## Required Inputs

- `resource_group_name`: `string`

## Common Optional Inputs

- `app_admin_group`: `list(string)`
- `app_user_group`: `list(string)`
- `diagnostic_log_categories`: `list(string)`
- `diagnostic_metric_categories`: `list(string)`
- `enable_diagnostics`: `bool`
- `enable_private_endpoint`: `bool`
- `log_analytics_workspace_id`: `string`
- `private_dns_zone_id`: `string`
- `private_dns_zone_name`: `string`
- `private_dns_zone_resource_group_name`: `string`
- `private_endpoint_network_resource_group_name`: `string`
- `private_endpoint_subnet_id`: `string`
- `private_endpoint_subnet_name`: `string`
- `private_endpoint_vnet_name`: `string`
- `tags`: `map(string)`

## Primary Outputs

- `app_admin_group_role_assignment_ids`
- `app_user_group_role_assignment_ids`
- `diagnostic_setting_id`
- `id`
- `location`
- `name`
- `private_endpoint_id`
- `private_endpoint_name`
- `resource_group_name`
- `tags`
- `tenant_id`
- `vault_uri`

## Test Commands

```powershell
terraform test
terraform test -filter='tests\live.tftest.hcl'
```
