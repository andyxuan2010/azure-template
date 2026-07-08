# Module Complete - App Service

The `appservice` module has been standardized and validated.

## Completed

- Provider constraints now match the project AzureRM 4.x and AzureAD 3.x baseline.
- Resource configuration now exposes key App Service hardening, runtime, auth, diagnostics, networking, backup, and auto-heal options.
- Tags are standardized and environment-aware.
- Diagnostics support Log Analytics, Storage Account, and Event Hub destinations.
- Tests are plan-only and cover Linux, Windows, hardened settings, Easy Auth, diagnostics, and private endpoint wiring.
- README, examples, quick reference, and validation report were refreshed.

## Validation

```powershell
terraform -chdir=modules\appservice fmt -check -recursive
terraform -chdir=modules\appservice validate
terraform -chdir=modules\appservice test
```

Latest test result: `4 passed, 0 failed`.
