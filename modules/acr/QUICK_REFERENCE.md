# Azure Container Registry Quick Reference

Purpose: Provision Azure Container Registry with optional RBAC, network rules, private endpoints, and diagnostics.

## Required Inputs

- `resource_group_name`: `string`
- `location`: `string`

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
- `system_managed_identity_enabled`: `bool`

## Primary Outputs

- `admin_password`
- `admin_username`
- `id`
- `login_server`
- `name`
- `private_endpoint_id`
- `role_assignment_ids`
- `tags`

## Test Commands

```powershell
terraform test
terraform test -filter='tests\live.tftest.hcl'
```
