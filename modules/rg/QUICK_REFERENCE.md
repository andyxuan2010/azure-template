# Resource Group Quick Reference

Purpose: provision an Azure Resource Group with standardized tags, optional naming automation, management locks, and resource group scope RBAC.

## Required Inputs

- `location`: Azure region where the resource group is created.

## Naming Inputs

- `name`: explicit resource group name. Leave empty to generate one.
- `name_prefix`: default `rg`.
- `workload_name`: optional workload segment.
- `app_env`: `prod`, `staging`, `dev`, `qa`, `sbx`, `test`, or `poc`.
- `location_code`: optional short location override.
- `instance`: deterministic suffix when `use_random_suffix = false`.
- `use_random_suffix`: default `true`.

## Common Optional Inputs

- `enable_lock`, `lock_name`, `lock_level`, `lock_notes`.
- `app_admin_group`: Contributor group display names or object IDs.
- `app_user_group`: Reader group display names or object IDs.
- `role_assignments`: additional arbitrary role assignments.
- `managed_by`: managed application resource ID.
- `timeouts`: resource group operation timeouts.
- `tags`: additional caller tags.

## Primary Outputs

- `id`, `name`, `location`, `location_code`.
- `tags`, `app_env`, `managed_by`.
- `lock_id`, `lock_config`.
- `app_admin_group_principal_ids`, `app_user_group_principal_ids`.
- `app_admin_group_role_assignment_ids`, `app_user_group_role_assignment_ids`, `role_assignment_ids`, `role_assignment_count`.

## Test Commands

```powershell
terraform -chdir=modules\rg fmt -check -recursive
terraform -chdir=modules\rg validate
terraform -chdir=modules\rg test
```
