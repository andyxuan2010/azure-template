Template Repo — Modules Guide

Purpose
- Provide repository-level guidance for using, validating, and contributing Terraform modules in this template repository.
- Use [MODULE_USAGE_AND_DEPENDENCIES.md](./MODULE_USAGE_AND_DEPENDENCIES.md) for the current module-by-module dependency map, usage guidance, and example entry points.
- Use [ROOT_LEVEL_MODULES_GUIDE.md](./ROOT_LEVEL_MODULES_GUIDE.md) for root `main.tf` wiring order, dependencies, and example `terraform.tfvars` values.

Module standards applied
- Validation: modules should include strong `variable` validation blocks and local cross-checks where applicable.
- Tagging: modules should merge environment defaults, managed metadata and `var.tags` into `local.merged_tags`.
- Diagnostics: modules may expose `enable_diagnostics` and `log_analytics_workspace`/`workspace_id` inputs and create `azurerm_monitor_diagnostic_setting` when compatible with the provider version. Where provider compatibility is uncertain, diagnostics are documented but not applied automatically.
- Outputs: modules should export `merged_tags` and a diagnostics flag (e.g. `diagnostics_enabled`) in addition to resource-specific outputs.
- Docs: every module should contain `README.md`, `QUICK_REFERENCE.md`, `EXAMPLES.md`, `VALIDATION_REPORT.md`, and `MODULE_COMPLETE.md` when hardened.

How to validate a module locally
1. Change into the module folder:

```powershell
cd "..\modules\<module>"
```
2. Initialize providers:

```powershell
terraform init -reconfigure
```
3. Validate configuration:

```powershell
terraform validate
```
4. (Optional) Run `terraform plan` with required variables and a backend configured.

How to validate a module in caller context
1. Stay at the repo root.
2. Keep the default root harness values in place.
3. Set `features = {}` when you want a focused one-module plan instead of high-level feature enablement.
4. Enable only the target entry in `module_plan_enabled`.
5. Configure the target module through its root pass-through variables in `terraform.tfvars`, such as `nsg_*`, `storageaccount_*`, or `winvm_*`.
6. Run `terraform init -backend=false -reconfigure` when you want a non-stateful harness check.
7. Run `terraform plan` from the repo root.

Repository-level CI recommendations
- Run `terraform fmt -check -recursive`, `terraform validate`, and `terraform test -filter=tests/root-plan.tftest.hcl` at the repo root during CI.
- Run one-module-at-a-time root-harness plans during CI instead of direct child-module validation when aliased providers or caller wiring matter.
- Keep root `main.tf`, `variables.tf`, and `terraform.tfvars` module sections sorted by `modules/` folder name when adding or changing root-wired modules.
- Use a pinned `azurerm` provider version in root `required_providers` or lockfile to maintain consistent schema for diagnostics.
- If adding diagnostics automation, include a compatibility test matrix for `azurerm` provider versions.

Diagnostics guidance
- When adding `azurerm_monitor_diagnostic_setting`, ensure block names (`log`, `metric` vs `logs`, `metrics`) match the `azurerm` provider version in use.
- Prefer adding diagnostic settings in a module only when `log_analytics_workspace_id` is provided; otherwise document how to add them externally.

Contribution checklist for new modules
- Add `variables.tf` with validations
- Add `locals.tf` with `local.merged_tags`
- Use `local.merged_tags` on all resources
- Add `outputs.tf` exporting `merged_tags` and diagnostics flag
- Add `README.md`, `QUICK_REFERENCE.md`, `EXAMPLES.md`, `VALIDATION_REPORT.md`, `MODULE_COMPLETE.md`
- Add or update the root `features` flag, `module_plan_enabled` entry, module block, pass-through variables, and `terraform.tfvars` sample values when the module should be root-wired
- Make sure the root harness can enable the module cleanly and that the CI matrix can run a root-harness plan for it

Next steps I can take
- Generate missing module docs automatically for modules lacking them, or
- Expand or harden the root harness sample inputs for modules that still need special-case plan fixtures.
