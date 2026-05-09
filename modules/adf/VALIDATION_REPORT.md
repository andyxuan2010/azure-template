Validation Report - adf module

Planned hardening actions:
- Add `locals.tf` for merged tags and environment defaults.
- Replace inline tag merges with `local.merged_tags`.
- Expose `merged_tags` and `diagnostics_enabled` outputs.
- Add quick reference and examples.

Validation steps to run next:
- `terraform init -reconfigure`
- `terraform validate`

Notes:
- `monitoring.tf` already creates `azurerm_monitor_diagnostic_setting` via `for_each` over `var.log_analytics_workspace`. Ensure the map keys/values you provide are valid workspace resource IDs.

Recommendations:
- Provide a `log_analytics_workspace` mapping in `terraform.tfvars` to enable diagnostics.
- Confirm `managed_private_endpoint` targets and private DNS zones exist for private endpoint creation.
