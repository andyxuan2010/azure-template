# Databricks Validation Report

## Scope

- Module structure created to match the hardened module pattern used in this repository.
- Input validation added for resource group, SKU, diagnostics, tag hygiene, and VNet injection prerequisites.
- RBAC output shape aligned with recent modules such as `eventhub` and `servicebus`.

## Validation Status

- `terraform validate`: expected to pass after provider initialization
- `terraform test`: uses a plan-based test to validate interface and planning behavior without provisioning a live Databricks workspace by default

## Notes

- Databricks workspace creation is materially slower and more expensive than lighter platform resources, so the default test is plan-based rather than apply-based.
- VNet injection support is included through the `custom_parameters` block and requires existing subnet names plus NSG association IDs.
