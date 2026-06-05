# Resource Group Module Complete

The `rg` module has been standardized and validated.

## Completed

- Provider constraints now match the project AzureRM 4.x, AzureAD 3.x, and Random 3.x baseline.
- Naming supports explicit names and deterministic or random generated names.
- Tags are standardized and environment-aware.
- Management locks support custom names, levels, and notes.
- RBAC supports admin/user group shortcuts and arbitrary additional role assignments.
- README, examples, quick reference, validation report, and tests were refreshed.

## Validation

```powershell
terraform -chdir=modules\rg fmt -check -recursive
terraform -chdir=modules\rg validate
terraform -chdir=modules\rg test
```

Latest test result: `4 passed, 0 failed`.
