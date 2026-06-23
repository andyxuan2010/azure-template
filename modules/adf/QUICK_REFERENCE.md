# Azure Data Factory Quick Reference

Purpose: Provision Azure Data Factory with hardened networking defaults, optional managed private endpoints, source control, diagnostics, CMK, Purview, and SHIR support.

## Required Inputs

- `name`: `string`
- `resource_group`: `string`

## Common Optional Inputs

- `app_env`: `string`
- `location`: `string`
- `custom_adf_name`: `string`
- `public_network_enabled`: `bool`
- `managed_virtual_network_enabled`: `bool`
- `create_default_azure_integration_runtime`: `bool`
- `identity_type`: `string`
- `identity_ids`: `list(string)`
- `customer_managed_key_id`: `string`
- `customer_managed_key_identity_id`: `string`
- `purview_id`: `string`
- `permissions`: `list(object(...))`
- `app_admin_group`: `list(string)`
- `app_user_group`: `list(string)`
- `enable_private_endpoint`: `bool`
- `private_endpoint_subnet_id`: `string`
- `private_endpoint_subnet_name`: `string`
- `private_endpoint_vnet_name`: `string`
- `private_endpoint_network_resource_group_name`: `string`
- `private_dns_zone_id`: `string`
- `private_dns_zone_name`: `string`
- `private_dns_zone_resource_group_name`: `string`
- `managed_private_endpoint`: `set(object(...))`
- `global_parameter`: `list(object(...))`
- `vsts_configuration`: `object(...)`
- `github_configuration`: `object(...)`
- `enable_diagnostics`: `bool`
- `log_analytics_workspace`: `map(string)`
- `diagnostic_log_categories`: `list(string)`
- `diagnostic_metric_categories`: `list(string)`
- `self_hosted_integration_runtime_enabled`: `bool`
- `app_vm`, `app_rg`, `app_snet`, `app_vnet`, `app_vnet_rg`
- `iac_rg`, `iac_kv`, `iac_st`

## Primary Outputs

- `id`
- `name`
- `location`
- `identity`
- `principal_id`
- `tenant_id`
- `default_integration_runtime_id`
- `default_integration_runtime_name`
- `self_hosted_integration_runtime_id`
- `self_hosted_integration_runtime_name`
- `private_endpoint_id`
- `private_endpoint_ip_address`
- `managed_private_endpoint_ids`
- `managed_private_endpoint_fqdns`
- `diagnostic_setting_ids`
- `app_admin_group_role_assignment_ids`
- `app_user_group_role_assignment_ids`
- `additional_role_assignment_ids`
- `merged_tags`

## Test Commands

```powershell
terraform validate
terraform test
terraform test -filter="tests\live.tftest.hcl"
```

Notes:
- `location` is optional; when omitted, the module reads the target resource group location.
- `log_analytics_workspace` still enables diagnostics for backward compatibility; `enable_diagnostics` makes that intent explicit.
- SHIR dependencies are required only when `self_hosted_integration_runtime_enabled = true`.
- Customer-managed keys require a user-assigned identity and `customer_managed_key_identity_id`.
