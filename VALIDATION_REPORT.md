## Validation Report

This repository now uses a root plan-validation harness plus module-local live tests.

## Root Validation

- `terraform fmt -recursive`
- `terraform validate`
- `terraform test -filter=tests/root-plan.tftest.hcl`

The root harness keeps every `module_plan_enabled` value set to `false` by default so the root can validate without trying to deploy every module at once.

## Module Validation Pattern

Each module is expected to keep these assets together:

- `README.md` or `readme.md`
- `EXAMPLES.md`
- `tests/live.tftest.hcl`

See [docs/MODULES_INDEX.md](./docs/MODULES_INDEX.md) for the current module-by-module links.

## Notes

- Module `live.tftest.hcl` files are intended for Azure-backed live validation.
- The root `tests/root-plan.tftest.hcl` file is intended for plan-only validation of the repository harness.
