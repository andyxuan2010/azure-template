Repository Validation Summary

This file summarizes which modules have been hardened, validated, and documented during the current pass.

Status:
- appserviceplan: Hardened, validated, docs present (`VALIDATION_REPORT.md`, `MODULE_COMPLETE.md`, `QUICK_REFERENCE.md`).
- applicationgateway: Hardened, validated, docs present (`README.md`, `EXAMPLES.md`, `VALIDATION_REPORT.md`, `MODULE_COMPLETE.md`, `QUICK_REFERENCE.md`).
- rg: Hardened, validated, docs present.
- adf: Hardened, validated, docs present.
- appregistration: README present for module usage and outputs.
- appservice: Hardened, validated, docs present.
- winvm: Hardened, `VALIDATION_REPORT.md` and `MODULE_COMPLETE.md` present. Diagnostics omitted due to provider compatibility.
- sqldb: Hardened, validated, docs present.
- sqlmi_db: Partially hardened (locals/outputs/docs added); variables/main updated — recommend running `terraform validate` in `modules/sqlmi_db` with required inputs to finalize.
- linuxvm: README present for module usage; expanded example/reference docs are still limited.
- automationaccount: Module docs present and updated for explicit private endpoint controls and managed identity role assignments.
- automationaccount: Module docs present and updated for explicit private endpoint controls, managed identity role assignments, and private DNS zone lookup pattern.

Notes & recommended next actions:
- Normalize `azurerm` provider version across repo (pin in root) so diagnostics schema can be applied consistently.
- Repository CI now uses root `fmt`, `validate`, `terraform test -filter=tests/root-plan.tftest.hcl`, and one-module-at-a-time root-harness `terraform plan` runs in both GitHub Actions and Azure DevOps.
- The root harness now supports the landingzone-style `features` map for high-level enablement while keeping `module_plan_enabled` available for precise one-module CI overrides.
- Root-wired module blocks, `features` entries, `module_plan_enabled` entries, pass-through variables, and `terraform.tfvars` sample values are organized by sorted `modules/` folder name.
- Root-wired modules now expose module-specific root inputs so enabled modules such as `nsg`, `storageaccount`, `vnet`, and `winvm` can be configured from `terraform.tfvars` before live planning.
- `modules/loadbalancer` remains standalone and is not yet included in the root harness or CI module matrix.
- Continue moving any module that only validates correctly in isolation toward clean root-harness planning so the CI matrix can cover it reliably.
- Complete `sqlmi_db` validation by ensuring it plans cleanly through the root harness and by fixing any remaining variable or provider issues.
