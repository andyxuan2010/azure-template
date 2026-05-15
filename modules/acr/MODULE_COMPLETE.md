# Azure Container Registry Module Complete

The `acr` module has been added using the same modernized pattern used by the newer hardened modules in this repository.

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
- environment-aware naming and tags
- optional system-assigned or user-assigned managed identity
- optional customer-managed key encryption
- optional georeplication on Premium SKU
- optional network rules
- optional private endpoint
- optional Log Analytics diagnostics
- Entra group RBAC via `app_admin_group` and `app_user_group`
