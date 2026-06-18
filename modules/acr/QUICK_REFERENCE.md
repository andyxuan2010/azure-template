# Azure Container Registry Quick Reference

Purpose: Provision Azure Container Registry with hardened defaults, optional premium controls, RBAC, private connectivity, and diagnostics.

## Required Inputs

- `resource_group_name`: `string`

## Common Optional Inputs

- `location`: `string`
- `name`: `string`
- `app_env`: `string`
- `sku`: `string`
- `public_network_access_enabled`: `bool`
- `identity_type`: `string`
- `identity_ids`: `list(string)`
- `managed_identity_role_assignments`: `map(object(...))`
- `app_admin_group`: `list(string)`
- `app_user_group`: `list(string)`
- `export_policy_enabled`: `bool`
- `quarantine_policy_enabled`: `bool`
- `retention_policy_in_days`: `number`
- `trust_policy_enabled`: `bool`
- `zone_redundancy_enabled`: `bool`
- `georeplications`: `list(object(...))`
- `enable_network_rule_set`: `bool`
- `network_rule_bypass_option`: `string`
- `network_rule_default_action`: `string`
- `network_rule_ip_rules`: `list(string)`
- `enable_private_endpoint`: `bool`
- `private_endpoint_subnet_id`: `string`
- `private_endpoint_subnet_name`: `string`
- `private_endpoint_vnet_name`: `string`
- `private_endpoint_network_resource_group_name`: `string`
- `private_dns_zone_id`: `string`
- `private_dns_zone_name`: `string`
- `private_dns_zone_resource_group_name`: `string`
- `customer_managed_key_id`: `string`
- `customer_managed_key_identity_client_id`: `string`
- `enable_diagnostics`: `bool`
- `log_analytics_workspace_id`: `string`
- `diagnostic_log_categories`: `list(string)`
- `diagnostic_metric_categories`: `list(string)`

## Primary Outputs

- `id`
- `name`
- `location`
- `login_server`
- `identity`
- `principal_id`
- `tenant_id`
- `managed_identity_role_assignment_ids`
- `app_admin_group_role_assignment_ids`
- `app_user_group_role_assignment_ids`
- `private_endpoint_id`
- `private_endpoint_ip_address`
- `diagnostic_setting_id`
- `tags`

## Test Commands

```powershell
terraform test
terraform test -filter="tests\live.tftest.hcl"
```

Notes:
- `location` is optional; when omitted, the module uses the resource group location.
- Premium-only settings include `export_policy_enabled`, `quarantine_policy_enabled`, `retention_policy_in_days`, `trust_policy_enabled`, `zone_redundancy_enabled`, and `georeplications`.
- `managed_identity_role_assignments` requires `identity_type` to include `SystemAssigned`.
- Customer-managed keys require `identity_type` to include `UserAssigned`.
