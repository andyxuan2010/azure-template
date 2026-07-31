# Validation Report - Resource Group Module

## Scope

The `rg` module was standardized for provider constraints, deterministic naming options, environment-aware tags, management locks, flexible RBAC, outputs, docs, and plan-only tests.

## Changes Validated

- Added Terraform and provider version constraints for Terraform `>= 1.0`, AzureRM `>= 4.0`, AzureAD `>= 3.0`, and Random `>= 3.0`.
- Added generated naming controls for prefix, workload, environment, location code, instance, and random suffix behavior.
- Added environment tags and standard module tags while preserving caller tag overrides.
- Added resource group `managed_by` and `timeouts` support.
- Added custom lock name support.
- Added arbitrary `role_assignments` in addition to the existing admin/user group shortcuts.
- Replaced apply-time tests with deterministic plan-only coverage.

## Commands

```powershell
terraform -chdir=modules\rg init -backend=false
terraform -chdir=modules\rg fmt -recursive
terraform -chdir=modules\rg validate
terraform -chdir=modules\rg test
```

## Latest Result

- `terraform validate`: passed.
- `terraform test`: passed, `4 passed, 0 failed`.

## Notes
