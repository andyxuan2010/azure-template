# App Service Quick Reference

Purpose: Provision Azure App Service with authentication, networking, private endpoints, RBAC, and deployment-center options.

## Required Inputs

- `app_name`: `string`
- `app_service_plan_id`: `string`
- `location`: `string`
- `resource_group_name`: `string`

## Common Optional Inputs

- `app_admin_group`: `list(string)`
- `app_command_line`: `string`
- `app_user_group`: `list(string)`
- `container_registry_managed_identity_client_id`: `string`
- `container_registry_use_managed_identity`: `bool`
- `diagnostic_setting_enabled_log_categories`: `list(string)`
- `diagnostic_setting_enabled_metric_categories`: `list(string)`
- `diagnostic_setting_name`: `string`
- `enable_private_endpoint`: `bool`
- `identity_ids`: `list(string)`
- `key_vault_reference_identity_id`: `string`
- `log_analytics_workspace_id`: `string`
- `private_endpoint_network_resource_group_name`: `string`

## Primary Outputs

- `app_admin_group_role_assignment_ids`
- `app_id`
- `app_name`
- `app_user_group_role_assignment_ids`
- `custom_domain_verification_id`
- `default_hostname`
- `diagnostics_enabled`
- `identity_principal_id`
- `identity_tenant_id`
- `merged_tags`
- `private_endpoint_sites_id`
- `site_credential_name`

## Test Commands

```powershell
terraform test
terraform test -filter='tests\live.tftest.hcl'
```

Linux Python note: set `app_command_line` when you need a startup command such as `gunicorn --bind=0.0.0.0 --timeout 600 app:app`.
