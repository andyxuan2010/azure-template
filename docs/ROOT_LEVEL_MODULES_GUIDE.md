# Root-Level Module Guide

This document describes the root Terraform plan harness and how it maps to the module inventory under `modules/`.

## Current Root State

- `main.tf` contains one module block per module directory in exact `modules/` folder order
- every module block is guarded by `var.module_plan_enabled.<module_name>`
- `variables.tf` defines the shared sample inputs and the full toggle map
- `terraform.tfvars` keeps all toggles `false` by default for safe validation
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
10. `databricks`
11. `eventhub`
12. `firewall`
13. `functionapp`
14. `keyvault`
15. `linuxvm`
16. `loganalytics`
17. `logicapp`
18. `managedidentity`
19. `managementgroups`
20. `nsg`
21. `openai`
22. `policy`
23. `private_dns`
24. `rg`
25. `roleassignments`
26. `route_table`
27. `servicebus`
28. `sqldb`
29. `sqlmi`
30. `sqlmi_db`
31. `storageaccount`
32. `subscription_vending`
33. `vnet`
34. `winvm`

## How To Use The Harness

1. Keep all entries in `module_plan_enabled` set to `false` for baseline validation.
2. Turn on one module when you want to run a focused `terraform plan`.
3. Replace the sample values in `terraform.tfvars` with real environment values before enabling a live module plan.

## Root Assets

| Asset | Purpose |
| --- | --- |
| `main.tf` | module wiring in repository module order |
| `data.tf` | shared lookup data for root wiring |
| `variables.tf` | shared sample inputs and `module_plan_enabled` schema |
| `terraform.tfvars` | default sample values and all-disabled module toggle map |
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
- Azure DevOps also runs a per-module matrix that turns on one `module_plan_enabled` entry at a time so the module harness validation matches the GitHub Actions reference workflow.
- Both CI systems also use the shared `scripts/create-release-tag.sh` helper so semantic version bumps and annotated tag contents stay aligned.
- The Azure DevOps matrix is configured with `maxParallel: 4`, but the number of jobs that truly run at once depends on the Azure DevOps organization's available parallel jobs.
- The Azure DevOps `Validate` stage always uses `terraform init -backend=false` so the harness can validate wiring without competing for shared state.
- Module `tests/live.tftest.hcl` files stay outside the default CI path because they are intended for live Azure integration validation.
