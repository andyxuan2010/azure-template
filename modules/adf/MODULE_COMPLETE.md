Module Hardened: adf

This module has been updated to follow the project's production hardening pattern.

Changes made:
- Added `locals.tf` with environment-aware tags and `local.merged_tags`.
- Updated `main.tf` and submodule invocation to use `local.merged_tags` consistently.
- Added `merged_tags` and `diagnostics_enabled` outputs.
- Added support for `github_configuration`, `identity_type` and `identity_ids`, `customer_managed_key_id`, and `purview_id`.
- Normalized naming to use `name` and `app_env` across generated resource names.
- Documented usage in `readme.md`, `QUICK_REFERENCE.md`, and `EXAMPLES.md`.

Notes:
- `monitoring.tf` already creates diagnostic settings when `log_analytics_workspace` is provided; ensure workspace IDs are valid.
- `app_vm` is only required when `self_hosted_integration_runtime_enabled` is true.
- Only one Git integration block should be configured at a time: `vsts_configuration` or `github_configuration`.
