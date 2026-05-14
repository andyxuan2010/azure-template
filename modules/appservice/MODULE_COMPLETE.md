Module Hardened: appservice

This module has been updated to follow the project's production hardening pattern.

Changes made:
- Added `app_env` variable and environment-aware tagging via `local.merged_tags`.
- Applied `local.merged_tags` consistently across web app resources.
- Exposed `merged_tags` and `diagnostics_enabled` outputs.
- Added `QUICK_REFERENCE.md` and `EXAMPLES.md`.

Notes:
- Diagnostics are implemented by the existing `azurerm_monitor_diagnostic_setting` resource; provide `log_analytics_workspace_id` to enable.
- I will run `terraform init` and `terraform validate` next and report results.
