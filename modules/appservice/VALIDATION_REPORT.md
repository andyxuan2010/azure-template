Validation Report - appservice module

Actions applied:
- Added `app_env` variable for environment tagging.
- Extended `locals.tf` with `local.merged_tags`, `diagnostics_enabled`, and environment tag defaults.
- Updated `main.tf` to apply `local.merged_tags` to resources instead of raw `var.tags`.
- Added outputs `merged_tags` and `diagnostics_enabled`.
- Added `QUICK_REFERENCE.md` and `EXAMPLES.md` for usage guidance.

Validation steps to run:
- `terraform init -reconfigure`
- `terraform validate`

Notes:
- The module already contains a `azurerm_monitor_diagnostic_setting` resource; ensure `var.log_analytics_workspace_id` is supplied to enable diagnostics.
- Review `app_settings` and CI/CD practices: build-specific app settings should be configured outside Terraform.

Next steps I will run: `terraform init -reconfigure` and `terraform validate` in `modules/appservice` and report results.
