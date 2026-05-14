# Storage Account Quick Reference

Purpose: Provision Azure Storage Account with RBAC, network rules, private endpoints, and diagnostics.

## Required Inputs

- `resource_group_name`: `string`

## Common Optional Inputs

- `app_admin_group`: `list(string)`
- `app_user_group`: `list(string)`
- `diagnostic_log_categories`: `list(string)`
- `diagnostic_metric_categories`: `list(string)`
- `enable_diagnostics`: `bool`
- `enable_network_rules`: `bool` (default: `true`)
- `log_analytics_workspace_id`: `string`
- `managed_identity_role_assignments`: `map(object({ scope = string role_definition_name = optional(string) role_definition_id = optional(string) }))`
- `network_rules_default_action`: `string` (default: `"Deny"`)
- `network_rules_ip_rules`: `list(string)`
- `network_rules_virtual_network_subnet_ids`: `list(string)`
- `private_endpoint_network_resource_group_name`: `string`
- `private_endpoint_subnet_id`: `string`
- `private_endpoint_subnet_name`: `string`
- `private_endpoint_subresource_names`: `list(string)`
- `private_endpoint_vnet_name`: `string`
- `private_dns_zone_ids`: `map(string)`
- `private_dns_zone_names`: `map(string)`
- `private_dns_zone_resource_group_name`: `string`

## Primary Outputs

- `app_admin_group_role_assignment_ids`
- `app_user_group_role_assignment_ids`
- `diagnostic_setting_id`
- `id`
- `identity`
- `location`
- `managed_identity_role_assignment_ids`
- `name`
- `network_rules_id`
- `primary_blob_endpoint`
- `primary_dfs_endpoint`
- `primary_file_endpoint`

## Test Commands

```powershell
terraform test
terraform test -filter='tests\live.tftest.hcl'
```

Default behavior: public network access is disabled and network rules are enabled with a `Deny` default action. Supply explicit IP rules, subnet IDs, or private endpoints before expecting connectivity.
