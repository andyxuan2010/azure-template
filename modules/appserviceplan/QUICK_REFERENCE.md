# App Service Plan Quick Reference

Purpose: Provision Azure App Service Plans with standardized tags, optional Entra RBAC, diagnostics, and autoscale controls.

Explicit `tags` override `inherited_resource_group_tags`. Predictive settings, notifications, and custom rules require `enable_autoscale = true`.

## Required Inputs

- `name`: `string`
- `resource_group_name`: `string`
- `sku_name`: `string`

## Common Optional Inputs

- `location`: `string`
- `app_env`: `string`
- `os_type`: `string`
- `worker_count`: `number`
- `app_service_environment_id`: `string`
- `maximum_elastic_worker_count`: `number`
- `per_site_scaling_enabled`: `bool`
- `zone_balancing_enabled`: `bool`
- `premium_plan_auto_scale_enabled`: `bool`
- `app_admin_group`: `list(string)`
- `app_user_group`: `list(string)`
- `enable_diagnostics`: `bool`
- `log_analytics_workspace_id`: `string`
- `diagnostic_storage_account_id`: `string`
- `diagnostic_eventhub_authorization_rule_id`: `string`
- `diagnostic_eventhub_name`: `string`
- `diagnostic_log_categories`: `list(string)`
- `diagnostic_metrics`: `list(string)`
- `enable_autoscale`: `bool`
- `autoscale_enabled`: `bool`
- `autoscale_default_capacity`: `number`
- `autoscale_min_capacity`: `number`
- `autoscale_max_capacity`: `number`
- `enable_memory_autoscale`: `bool`
- `autoscale_notifications`: `object(...)`
- `autoscale_custom_rules`: `list(object(...))`
- `autoscale_recurrence`: `object(...)`
- `autoscale_fixed_date`: `object(...)`
- `autoscale_predictive`: `object(...)`
- `tags`: `map(string)`

## Primary Outputs

- `id`
- `name`
- `location`
- `resource_group_name`
- `sku_name`
- `os_type`
- `worker_count`
- `zone_balancing_enabled`
- `premium_plan_auto_scale_enabled`
- `diagnostic_setting_id`
- `autoscale_setting_id`
- `autoscale_config`
- `app_admin_group_role_assignment_ids`
- `app_user_group_role_assignment_ids`
- `tags`

## Test Commands

```powershell
terraform validate
terraform test
terraform test -filter="tests\live.tftest.hcl"
```

Notes:
- Autoscale is blocked for Free, Shared, and Consumption SKUs.
- `maximum_elastic_worker_count` is intended for Elastic Premium SKUs.
- Configure either `autoscale_recurrence` or `autoscale_fixed_date`, not both.
