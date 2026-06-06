Validation Report - winvm module

Status: Passed `terraform validate`

Summary of changes applied:
- Added `locals.tf` with `merged_tags` and environment tag defaults.
- Hardened `variables.tf`:
  - Stronger `app_env` validation (prod, staging, dev, qa, sbx, poc, test).
  - Added `enable_diagnostics` and `log_analytics_workspace_id` variables with validation.
- Replaced inline `merge(data.azurerm_resource_group.app.tags, var.tags)` usages with `local.merged_tags` across resources.
- Added `merged_tags` and `diagnostics_enabled` outputs in `output.tf`.
- Removed an automated `azurerm_monitor_diagnostic_setting` resource due to provider schema variations; documented recommended approach.

Note on diagnostics:

- I attempted to add an `azurerm_monitor_diagnostic_setting` resource guarded by `enable_diagnostics`, but `terraform validate` reported the provider schema in this workspace did not accept the nested `log`/`metric` blocks as used. Provider versions differ in expected schema for diagnostics blocks.
- To avoid introducing a failing resource, the diagnostics resource is omitted from the module code; an example implementation is included in `EXAMPLES.md`.
- If you'd like, I can detect your exact `azurerm` provider version and add a provider-compatible diagnostics resource (or implement it behind a module-level submodule), then run validation again.

Validation steps run:
- `terraform init -reconfigure` (succeeded)
- `terraform validate` (succeeded)

Recommendations before production rollout:
- Provide `var.log_analytics_workspace_id` and add a provider-compatible `azurerm_monitor_diagnostic_setting` if you want centralized Log Analytics diagnostics.
- Consider enabling `public_network_enabled = false` and using private endpoints for production.
- Review and set `var.app_vm_size`, `var.app_vm_number`, and `var.disksize` to production-appropriate values.
- Ensure secrets (admin username/password, domain join password) are stored in Key Vault and referenced via `terraform.tfvars` or pipeline secrets.

Next steps I can take for you:
- Add a provider-compatible diagnostic settings block (I can detect the correct block names for your azurerm version and add it).
- Update `README.md` with a quick reference and examples for production usage.
