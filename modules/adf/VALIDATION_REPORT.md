Validation Report - adf module

Planned hardening actions:
- Add `locals.tf` for merged tags and environment defaults.
- Replace inline tag merges with `local.merged_tags`.
- Expose `merged_tags` and `diagnostics_enabled` outputs.
- Add support for GitHub integration, customer-managed keys, Purview integration, and configurable managed identities.
- Refresh quick reference and examples to match the current interface.

Validation steps to run next:
- `terraform init -reconfigure`
- `terraform validate`

Notes:
- `monitoring.tf` already creates `azurerm_monitor_diagnostic_setting` via `for_each` over `var.log_analytics_workspace`. Ensure the map keys/values you provide are valid workspace resource IDs.
- `app_vm` remains conditionally required only for SHIR-enabled deployments.

Recommendations:
- Provide a `log_analytics_workspace` mapping in `terraform.tfvars` to enable diagnostics.
- Confirm `managed_private_endpoint` targets and private DNS zones exist for private endpoint creation.
- Choose exactly one source control configuration block: Azure DevOps or GitHub.
