# Root-Level Module Guide

This document describes the root Terraform plan harness and how it maps to the module inventory under `modules/`.

## Current Root State

- `main.tf` contains one module block per root-harness-enabled module in sorted `modules/` folder order
- every module block is guarded by the effective `local.module_plan_enabled.<module_name>` map
- `variables.tf` defines the shared sample inputs, the landingzone-style `features` map, the full per-module toggle map, and module-specific pass-through inputs
- `terraform.tfvars` uses high-level `features` switches for default sample enablement and keeps module-specific sample values grouped in the same sorted module order
- `tests/root-plan.tftest.hcl` provides a root-level Terraform test entry for the harness
- `modules/loadbalancer` is root-wired and can create one or more Load Balancer module instances from the `loadbalancers` map

## Root Module Order

The root file order matches the harness-enabled module folder order:

1. `acr`
2. `adf`
3. `aks`
4. `applicationgateway`
5. `appregistration`
6. `appservice`
7. `appserviceplan`
8. `automationaccount`
9. `azure_ai_search`
10. `azure_ai_service`
11. `cosmosdb`
12. `databricks`
13. `enterpriseapplication`
14. `eventhub`
15. `firewall`
16. `fortigate`
17. `functionapp`
18. `keyvault`
19. `linuxvm`
20. `loadbalancer`
21. `loganalytics`
22. `logicapp`
23. `managedidentity`
24. `managementgroups`
25. `nsg`
26. `openai`
27. `policy`
28. `private_dns`
29. `rg`
30. `roleassignments`
31. `route_table`
32. `servicebus`
33. `sqldb`
34. `sqlmi`
35. `sqlmi_db`
36. `storageaccount`
37. `subscription_vending`
38. `vnet`
39. `winvm`

## How To Use The Harness

1. Use `features` when you want landingzone-style high-level enablement.
2. Use `module_plan_enabled` when you want to turn on one exact module for a focused `terraform plan`.
3. Set `features = {}` in focused override files so high-level defaults do not widen the plan.
4. Replace the sample values in `terraform.tfvars` with real environment values before enabling a live module plan.

## Root Input Model

The root harness keeps three related pieces together for each root-wired module:

- an `enable_<module>` flag in the `features` object, defaulting to `false`
- a `module_plan_enabled.<module>` toggle for one-module CI and local plan overrides
- module-specific input variables in `variables.tf`, with sample defaults in `terraform.tfvars`

For example, setting `features.enable_nsg = true` activates `module "nsg"` from the root harness. The actual NSG settings come from the `nsg_*` root variables, including values such as `nsg_name`, `nsg_security_rules`, and subnet or NIC association maps.

## Root Assets

| Asset | Purpose |
| --- | --- |
| `main.tf` | module wiring in repository module order |
| `data.tf` | shared lookup data for root wiring |
| `variables.tf` | shared sample inputs, `features` schema, `module_plan_enabled` schema, and module pass-through inputs |
| `terraform.tfvars` | default sample values, high-level feature switches, and module-specific sample values |
| `tests/root-plan.tftest.hcl` | root `terraform test` plan-only harness, when present |

## Module Docs, Examples, and Tests

Most modules keep their own local assets:

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
- Module `tests/live.tftest.hcl` files stay outside the default CI path. Some are mock-provider plan tests, while others may be live integration tests; review the provider and run blocks before executing them locally.
