# Azure Container Registry Module Complete

The `acr` module now follows the same hardened pattern used by the newer standardized modules in this repository.

Included artifacts:

- `terraform.tf`
- `variables.tf`
- `locals.tf`
- `main.tf`
- `outputs.tf`
- `README.md`
- `EXAMPLES.md`
- `INDEX.md`
- `QUICK_REFERENCE.md`
- `VALIDATION_REPORT.md`

Current highlights:

- secure-by-default registry configuration
- resource-group-based location fallback
- environment-aware naming and tags
- optional system-assigned, user-assigned, or mixed managed identity
- optional managed identity role assignments for system-assigned identity
- optional customer-managed key encryption with validation
- optional Premium-only controls for export policy, quarantine policy, retention, trust policy, and zone redundancy
- stable geo-replication ordering with regional endpoint support
- optional network rules
- optional private endpoint with `azurerm.prod` lookup support
- optional Log Analytics diagnostics
- Entra group RBAC via `app_admin_group` and `app_user_group`
