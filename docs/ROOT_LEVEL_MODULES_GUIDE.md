# Root-Level Module Guide

This document describes the root Terraform plan harness and how it maps to the module inventory under `modules/`.

## Current Root State

- `main.tf` contains one module block per module directory in exact `modules/` folder order
- every module block is guarded by the effective `local.module_plan_enabled.<module_name>` map
- `variables.tf` defines the shared sample inputs, the landingzone-style `features` map, and the full per-module toggle map
- `terraform.tfvars` uses high-level `features` switches for default sample enablement
- `tests/root-plan.tftest.hcl` provides a root-level Terraform test entry for the harness

## Root Module Order

The root file order matches the module folder order exactly:

1. `acr`
2. `adf`
3. `aks`
4. `appregistration`
5. `appservice`
6. `appserviceplan`
7. `applicationgateway`
8. `automationaccount`
9. `azure_ai_service`
10. `azure_ai_search`
11. `cosmosdb`
12. `databricks`
13. `eventhub`
14. `firewall`
15. `functionapp`
16. `keyvault`
17. `linuxvm`
18. `loganalytics`
19. `logicapp`
20. `managedidentity`
21. `managementgroups`
22. `nsg`
23. `openai`
24. `policy`
25. `private_dns`
26. `rg`
27. `roleassignments`
28. `route_table`
29. `servicebus`
30. `sqldb`
31. `sqlmi`
32. `sqlmi_db`
33. `storageaccount`
34. `subscription_vending`
35. `vnet`
36. `winvm`

## How To Use The Harness

1. Use `features` when you want landingzone-style high-level enablement.
2. Use `module_plan_enabled` when you want to turn on one exact module for a focused `terraform plan`.
3. Set `features = {}` in focused override files so high-level defaults do not widen the plan.
4. Replace the sample values in `terraform.tfvars` with real environment values before enabling a live module plan.

## Root Assets

| Asset | Purpose |
| --- | --- |
| `main.tf` | module wiring in repository module order |
| `data.tf` | shared lookup data for root wiring |
| `variables.tf` | shared sample inputs, `features` schema, and `module_plan_enabled` schema |
| `terraform.tfvars` | default sample values and high-level feature switches |
| `tests/root-plan.tftest.hcl` | root `terraform test` plan-only harness |
| `examples/root-plan-harness/README.md` | root usage example and command flow |

## Module Docs, Examples, and Tests

Each module keeps its own local assets:

- `modules/<name>/README.md`
- `modules/<name>/EXAMPLES.md`
- `modules/<name>/tests/live.tftest.hcl`

Use [MODULES_INDEX.md](./MODULES_INDEX.md) when you want the full module-by-module link map.

## Recommended Validation Commands

From the repo root:

```powershell
terraform fmt -recursive
terraform validate
terraform test -filter=tests/root-plan.tftest.hcl
```

When a specific module toggle is enabled:

```powershell
terraform plan
```

## CI Usage

- GitHub Actions runs the root commands above and then executes a per-module matrix that turns on one `module_plan_enabled` entry at a time.
- Azure DevOps uses a concise `Validate` then `Plan` flow in `azure-pipelines.yml`, with an explicit `azureSubscription` input instead of branch-based environment mapping.
- Both CI systems use the same changed-module detection flow and then run a per-module matrix only for the affected modules plus any required related dependencies.
- Azure DevOps resolves its changed-file list from the build change API first, then falls back to local git diff logic if that API returns nothing, so harness targeting tracks the actual pushed change set more closely.
- Azure DevOps also runs a per-module matrix that turns on one `module_plan_enabled` entry at a time so the module harness validation matches the GitHub Actions reference workflow.
- Both matrix flows clear `features` in the generated override file so `terraform.tfvars` feature defaults do not expand one-module validation into broader deployment plans.
- Both CI systems also use the shared `scripts/create-release-tag.sh` helper so semantic version bumps and annotated tag contents stay aligned.
- The Azure DevOps matrix is configured with `maxParallel: 4`, but the number of jobs that truly run at once depends on the Azure DevOps organization's available parallel jobs.
- The Azure DevOps `Validate` stage always uses `terraform init -backend=false` so the harness can validate wiring without competing for shared state.
- Module `tests/live.tftest.hcl` files stay outside the default CI path because they are intended for live Azure integration validation.
