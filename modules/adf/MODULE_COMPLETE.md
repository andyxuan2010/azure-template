Module Hardened: adf

This module has been updated to follow the project's production hardening pattern.

Changes made:
- Added `locals.tf` with environment-aware tags and `local.merged_tags`.
- Updated `main.tf` and submodule invocation to use `local.merged_tags` consistently.
- Added `merged_tags` and `diagnostics_enabled` outputs.
- Documented usage in `QUICK_REFERENCE.md` and `EXAMPLES.md`.

Notes:
- `monitoring.tf` already creates diagnostic settings when `log_analytics_workspace` is provided; ensure workspace IDs are valid.
- I will run `terraform init` and `terraform validate` next to confirm configuration correctness.
