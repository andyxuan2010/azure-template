# Azure Container Registry Quick Reference

Purpose: Provision Azure Container Registry with optional RBAC, network rules, private endpoints, diagnostics, managed identities, customer-managed keys, and georeplication.

## Required Inputs

- `resource_group_name`: `string`
- `location`: `string`

## Common Optional Inputs

- `app_env`: `string`
- `app_admin_group`: `list(string)`
- `app_user_group`: `list(string)`
- `customer_managed_key_id`: `string`
- `customer_managed_key_identity_client_id`: `string`
- `diagnostic_log_categories`: `list(string)`
- `diagnostic_metric_categories`: `list(string)`
- `enable_diagnostics`: `bool`
- `enable_network_rule_set`: `bool`
- `enable_private_endpoint`: `bool`
- `georeplications`: `list(object(...))`
- `identity_ids`: `list(string)`
- `identity_type`: `string`
- `log_analytics_workspace_id`: `string`
- `name`: `string`
- `network_rule_bypass_option`: `string`
- `network_rule_default_action`: `string`
- `network_rule_ip_rules`: `list(string)`
- `private_dns_zone_id`: `string`
- `private_dns_zone_name`: `string`
- `private_dns_zone_resource_group_name`: `string`
- `private_endpoint_network_resource_group_name`: `string`
- `private_endpoint_subnet_id`: `string`
- `private_endpoint_subnet_name`: `string`
- `private_endpoint_vnet_name`: `string`
- `public_network_access_enabled`: `bool`
- `sku`: `string`

## Primary Outputs

- `admin_password`
- `admin_username`
- `id`
- `identity`
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

Notes:
- `identity_type` replaces the old boolean managed identity toggle and supports `None`, `SystemAssigned`, `UserAssigned`, and `SystemAssigned, UserAssigned`.
- Georeplications require `sku = "Premium"`.
