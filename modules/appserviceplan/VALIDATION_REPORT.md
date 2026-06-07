# Validation Report

## Checks Performed

- `terraform init -backend=false`
- `terraform fmt -recursive`
- `terraform validate`
- `terraform test`
- `terraform-docs markdown table --output-file README.md --output-mode inject modules/appserviceplan`

## Result

Validation completed successfully after standardizing the `appserviceplan` module. Terraform tests cover the baseline plan, Azure Monitor autoscale with notifications and a custom rule, and a zone-balanced Premium plan.

## Notes

- Diagnostics now support Log Analytics, Storage Account, and Event Hub destinations.
- Autoscale now supports enablement state, notifications, recurrence/fixed schedules, predictive autoscale, and custom rules.
- `zone_balancing_enabled` requires at least three workers.
- `premium_plan_auto_scale_enabled` is mutually exclusive with Azure Monitor autoscale.
