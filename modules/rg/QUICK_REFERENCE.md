# Resource Group Quick Reference

Purpose: Provision Azure Resource Group with optional lock, RBAC, and tagging.

## Required Inputs

- `location`: `string`

## Common Optional Inputs

- `app_admin_group`: `list(string)`
- `app_user_group`: `list(string)`
- `tags`: `map(string)`

## Primary Outputs

- `app_admin_group_role_assignment_ids`
- `app_user_group_role_assignment_ids`
- `id`
- `location`
- `lock_id`
- `name`
- `tags`

## Test Commands

```powershell
terraform test
terraform test -filter='tests\live.tftest.hcl'
```
