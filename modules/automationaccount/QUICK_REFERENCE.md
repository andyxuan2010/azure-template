# Automation Account Quick Reference

Purpose: Provision a secure, standardized Azure Automation Account with optional private endpoints, diagnostics, runbooks, schedules, variables, identity, and RBAC.

## Required Inputs

- `resource_group_name`: target resource group name.

## Common Inputs

- `location`: Azure region. Leave empty to read the resource group location.
- `name`: explicit Automation Account name. Leave empty for generated naming.
- `workload_name`, `app_env`, `location_code`, `instance`, `use_random_suffix`: generated naming controls.
- `local_auth_enabled`: defaults to `false`.
- `public_access_enabled`: defaults to `false`.
- `system_managed_identity_enabled`: defaults to `true`.
- `identity_ids`: user-assigned managed identities.
- `encryption`: customer-managed key settings.
- `app_admin_group`, `app_user_group`: standard Contributor and Reader group assignments.
- `role_assignments`: additional Automation Account scope RBAC assignments.
- `managed_identity_role_assignments`: RBAC assignments for the system-assigned identity.
- `enable_webhook_private_endpoint`, `enable_hrw_private_endpoint`: private endpoint selectors.
- `private_endpoint_subnet_id`, `private_dns_zone_id`: private endpoint dependencies.
- `enable_diagnostics`, `log_analytics_workspace_id`, `diagnostic_storage_account_id`, `diagnostic_eventhub_authorization_rule_id`: diagnostic settings.
- `runbooks`, `schedules`, `job_schedules`: Automation workload deployment.
- `string_variables`, `bool_variables`, `int_variables`, `datetime_variables`, `object_variables`: Automation variables.

## Primary Outputs

- `id`, `name`, `resource_group_name`, `location`
- `identity`, `identity_type`, `principal_id`, `tenant_id`
- `private_endpoint_ids`, `private_endpoint_names`
- `diagnostics_enabled`, `diagnostic_setting_id`
- `runbook_ids`, `schedule_ids`, `job_schedule_ids`
- `automation_variable_ids`
- `role_assignment_ids`, `role_assignment_count`
- `tags`

## Validation Commands

```powershell
terraform fmt -check -recursive
terraform validate
terraform test
```
