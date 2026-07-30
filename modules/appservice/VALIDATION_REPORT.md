# Validation Report - App Service Module

## Scope

The `appservice` module was standardized for AzureRM 4.x usage, safer defaults, broader App Service feature coverage, deterministic tests, and refreshed documentation.

## Changes Validated

- Added Terraform and provider version constraints for Terraform `>= 1.0`, AzureRM `>= 4.0`, and AzureAD `>= 3.0`.
- Removed the unused `azurerm.prod` provider alias requirement from the module contract and examples.
- Added optional resource group location fallback when `location` is empty.
- Standardized environment-aware tags without module-generated marker tags.
- Expanded Web App options for app enablement, client certificate exclusions, VNet backup/restore, container image pull routing, TLS/SCM TLS, SCM restrictions, load balancing, worker count, app stack runtimes, auto-heal, backup, and Windows handler mappings.
- Expanded Easy Auth options for allowed audiences, groups, applications, identities, token store, excluded paths, and redirect URLs.
- Expanded diagnostics to support Log Analytics, Storage Account, and Event Hub destinations with resource-specific Log Analytics tables.
- Replaced apply-time live tests with plan-only coverage for Linux baseline, hardened Linux, Easy Auth plus diagnostics, and Windows private endpoint scenarios.

## Commands

```powershell
terraform -chdir=modules\appservice init -backend=false
terraform -chdir=modules\appservice fmt -recursive
terraform -chdir=modules\appservice validate
terraform -chdir=modules\appservice test
```

## Latest Result

- `terraform validate`: passed.
- `terraform test`: passed, `4 passed, 0 failed`.

## Notes

- Literal App Service Plan IDs must use the `serverFarms` casing because the AzureRM provider parser validates that segment.
- Diagnostic category discovery is optional and disabled by default so plan tests stay deterministic.
