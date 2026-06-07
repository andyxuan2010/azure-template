# template

Shared source-of-truth repository for:

- reusable Terraform modules under `modules/`
- the root Terraform validation harness in `main.tf`, `data.tf`, `variables.tf`, and `terraform.tfvars`
- shared Azure DevOps pipeline templates under `templates/`
- tests and reference docs used by consumers of this repo

## Table Of Contents

- [What This Repo Is](#what-this-repo-is)
- [Repository Layout](#repository-layout)
- [Start Here](#start-here)
- [Docs Index](#docs-index)
- [Local Validation](#local-validation)
- [CI And Publish Model](#ci-and-publish-model)
- [Required Secrets And Credentials](#required-secrets-and-credentials)
- [Important Publish Notes](#important-publish-notes)
- [Module Docs, Examples, And Tests](#module-docs-examples-and-tests)

## What This Repo Is

This repo is primarily a validation and distribution repo, not a single always-on deployment stack.

- The root Terraform files are organized as a harness that can plan one module at a time or enable selected landing-zone features.
- Root-wired module blocks in `main.tf` are ordered to match the sorted `modules/` folder names and are guarded by the effective `local.module_plan_enabled.<module_name>` map.
- `terraform.tfvars` can use the landingzone-style `features` map for high-level enablement, while `module_plan_enabled` remains available for precise one-module harness plans.
- Root-wired modules expose matching pass-through inputs in `variables.tf` and sample defaults in `terraform.tfvars` so modules can be enabled and configured from the root.
- `modules/loadbalancer` is available as a standalone child module, but it is not currently wired into the root harness or CI module matrix.
- Module source paths are called from the repo root as `./modules/<name>`.

## Repository Layout

- `modules/`: reusable Azure Terraform modules
- `docs/`: root guides, validation notes, runner notes, and module index
- `tests/`: root Terraform test harness files
- `templates/`: shared Azure DevOps pipeline templates such as `shared-runner-hygiene.yml`
- `.github/workflows/terraform.yml`: GitHub Actions validation and publish workflow
- `azure-pipelines.yml`: Azure DevOps validation and sync pipeline

## Start Here

Recommended entry docs:

- [docs/MODULES_INDEX.md](docs/MODULES_INDEX.md)
- [docs/MODULE_USAGE_AND_DEPENDENCIES.md](docs/MODULE_USAGE_AND_DEPENDENCIES.md)
- [docs/ROOT_LEVEL_MODULES_GUIDE.md](docs/ROOT_LEVEL_MODULES_GUIDE.md)
- [docs/VALIDATION_SUMMARY.md](docs/VALIDATION_SUMMARY.md)

Useful focused notes:

- [docs/SHARED-RUNNER-HYGIENE-STANDARD.md](docs/SHARED-RUNNER-HYGIENE-STANDARD.md)
- [docs/GIT-EXTRAHEADER-RUNNER-ISSUE.md](docs/GIT-EXTRAHEADER-RUNNER-ISSUE.md)
- [docs/PRIVATE_ENDPOINT_PRIVATE_DNS_LOOKUP_PATTERN.md](docs/PRIVATE_ENDPOINT_PRIVATE_DNS_LOOKUP_PATTERN.md)
- [docs/AKS_AUTHENTICATION_KUBELOGIN.md](docs/AKS_AUTHENTICATION_KUBELOGIN.md)

## Docs Index

| Document | Purpose |
| --- | --- |
| [docs/AKS_AUTHENTICATION_KUBELOGIN.md](docs/AKS_AUTHENTICATION_KUBELOGIN.md) | AKS `kubelogin` authentication notes, troubleshooting, and Terraform execution identity role support. |
| [docs/APP_SERVICE_PLAN_FUNCTION_APP_NOTES.md](docs/APP_SERVICE_PLAN_FUNCTION_APP_NOTES.md) | App Service Plan guidance for Function App module usage. |
| [docs/GIT-EXTRAHEADER-RUNNER-ISSUE.md](docs/GIT-EXTRAHEADER-RUNNER-ISSUE.md) | Shared-runner Git `extraheader` issue analysis and cleanup pattern. |
| [docs/MODULES_INDEX.md](docs/MODULES_INDEX.md) | Module-by-module README, example, and test index. |
| [docs/MODULE_USAGE_AND_DEPENDENCIES.md](docs/MODULE_USAGE_AND_DEPENDENCIES.md) | Module use cases, dependencies, common chains, and module guidance. |
| [docs/PRIVATE_ENDPOINT_PRIVATE_DNS_LOOKUP_PATTERN.md](docs/PRIVATE_ENDPOINT_PRIVATE_DNS_LOOKUP_PATTERN.md) | Private endpoint and private DNS lookup pattern used by supported modules. |
| [docs/REPO_MODULES_GUIDE.md](docs/REPO_MODULES_GUIDE.md) | Repository module usage flow and focused root harness planning guidance. |
| [docs/ROOT_LEVEL_MODULES_GUIDE.md](docs/ROOT_LEVEL_MODULES_GUIDE.md) | Root Terraform harness structure, enabled module order, and CI usage. |
| [docs/SHARED-RUNNER-HYGIENE-STANDARD.md](docs/SHARED-RUNNER-HYGIENE-STANDARD.md) | Shared self-hosted runner hygiene standard and reusable pipeline controls. |
| [docs/VALIDATION_SUMMARY.md](docs/VALIDATION_SUMMARY.md) | Validation status summary and known remaining module validation notes. |

## Local Validation

From the repo root:

```powershell
terraform init -input=false -no-color -reconfigure
terraform fmt -check -recursive
terraform validate
terraform test -filter=tests/root-plan.tftest.hcl -no-color
terraform plan -input=false -no-color
```

Important notes:

- The root harness uses the backend declared in `backend.tf`.
- If backend or module wiring changes, rerun `terraform init -reconfigure`.
- If the backend is temporarily unavailable, use `terraform init -backend=false` only for `terraform fmt` and `terraform validate`; root `terraform plan` still requires backend initialization.
- Module live tests under `modules/<name>/tests/live.tftest.hcl` are separate from default CI and may create or modify real Azure resources.

## CI And Publish Model

### GitHub Actions

The workflow in [`.github/workflows/terraform.yml`](.github/workflows/terraform.yml):

- runs a `check-required-secrets-variables` preflight job before validation, apply, and publish jobs
- prints a preflight table in the `Check Required Secrets and Variables` step showing each checked item, whether it is a secret or variable, whether it is present, and which downstream job condition uses it
- checks whether required Azure validation secrets exist before starting validation
- skips validation jobs when `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_TENANT_ID`, or `AZURE_SUBSCRIPTION_ID` are missing
- uses the GitHub Actions variable `TF_BACKEND_READY` to decide whether the configured Terraform backend can be initialized
- when `TF_BACKEND_READY` is not `true`, runs backend-free `terraform init -backend=false`, `terraform fmt`, and `terraform validate`, then skips root and module plan steps
- when `TF_BACKEND_READY` is `true`, runs backend initialization with `terraform init -reconfigure`, root `terraform test`, root `terraform plan`, and plan artifact upload
- runs the per-module plan matrix only when `TF_BACKEND_READY` is `true`; the matrix enables one root-harness module at a time
- clears the high-level `features` map in generated module-matrix override files so each matrix job validates only the selected module set
- creates an annotated semantic version tag after successful non-PR validation runs by reading commit messages since the latest `v1+` tag, using `v1.0.0` as the baseline when no `v1+` version tag exists: `fix:` creates a patch release, `feat:` creates a minor release, and `BREAKING CHANGE:`, `BREAKING-CHANGE:`, or `type!:` creates a major release; commits without one of those prefixes default to a patch release so every successful commit receives a version tag
- includes a short commit-summary changelog in the annotated source, GitHub stage, and Azure DevOps snapshot tag messages
- runs `apply` only when `ENABLE_GITHUB_APPLY` is `true`, `TF_BACKEND_READY` is `true`, and the required Azure secrets are available
- skips each publish job before checkout/push work starts when that job's required secret or repository variable is missing
- publishes a clean single-commit snapshot to the GitHub stage repo after successful validation, tagging the snapshot commit with the same semantic version when a release tag is created
- publishes Git history to the Azure DevOps dev repo after successful validation, tagging the published repo with the same semantic version when a release tag is created

The publish jobs do not run for pull requests.

Define `TF_BACKEND_READY` as a GitHub Actions repository or environment variable under **Settings** -> **Secrets and variables** -> **Actions** -> **Variables**. Use `false` while the AzureRM backend storage is not available, then switch it to `true` when the backend is ready for real plan runs.

Define `ENABLE_GITHUB_APPLY` in the same GitHub Actions variables area only when GitHub Actions should run the apply job after validation. Any value other than `true`, including a missing variable, skips apply.

### Azure DevOps

The pipeline in [`azure-pipelines.yml`](azure-pipelines.yml):

- follows the same high-level structure as the sibling `landingzone` repo where it fits this validation-only repository: `Validate`, `Plan`, `ValidateModules`, and `CreateGitTag`
- uses a Microsoft-hosted `ubuntu-latest` agent, repo-local pipeline scripts under `scripts/azure-pipelines/`, and the fixed `terraformVersion` pipeline variable
- uses a fixed stage-level Azure service connection instead of deriving the service connection from the Git branch
- runs `scripts/azure-pipelines/terraform-validate.sh` for backend-free `terraform init -backend=false`, `terraform fmt`, and `terraform validate`
- keeps the backend values directly in `azure-pipelines.yml` stage variables and passes them into the plan helper script, so no separate backend config file is needed
- runs `scripts/azure-pipelines/terraform-plan.sh` with those inline backend settings and `terraform.tfvars`, then publishes both the binary plan and plan text artifacts
- uses a shared module-target detection flow in both GitHub Actions and Azure DevOps so module-harness validation runs only for changed modules, plus related dependencies such as `appserviceplan`, `storageaccount`, `sqlmi`, and `vnet` when required
- uses the Azure DevOps build change API during module-target detection so the ADO harness selection follows the actual files in the triggering change set instead of assuming a single-commit push
- uses the shared `scripts/create-release-tag.sh` helper in both pipelines so semantic version bumps, release notes, and annotated tag contents stay identical across GitHub Actions and Azure DevOps
- runs a per-module harness validation matrix aligned with the GitHub Actions workflow, enabling one `module_plan_enabled` entry at a time for just that selected module set
- clears `features` in the generated per-module override file so `terraform.tfvars` high-level feature defaults do not widen matrix validation
- sets `maxParallel: 4` for the Azure DevOps module-harness matrix, but actual ADO concurrency still depends on the organization-level parallel jobs entitlement; for a private project on the free Microsoft-hosted tier, jobs can still queue one at a time
- does not include an `Apply` stage because this repo is used to validate and publish modules rather than deploy a standalone workload
- creates annotated semantic version tags with commit-summary changelogs when tags do not already exist in the ADO repo

## Required Secrets And Credentials

GitHub Actions validation expects these secrets when Azure validation should run:

- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

GitHub Actions uses these repository variables:

- `STAGE_REPOSITORY`, for example `owner/repo`
- `ADO_DEV_REPOSITORY`, for example `CCOE-Azure/IaC/_git/template`
- `ADO_PROD_REPOSITORY`, for example `CCOE-Azure/IaC/_git/template-prod`
- `TF_BACKEND_READY` for backend-enabled validation and plan jobs
- `ENABLE_GITHUB_APPLY` for the optional apply job

GitHub Actions publish jobs also expect these secrets:

- `STAGE_REPO_TOKEN` for the `STAGE_REPOSITORY` GitHub repo
- `ADO_REPO_DEV_PAT` for the `ADO_DEV_REPOSITORY` Azure DevOps repo
- `ADO_PROD_REPO_PAT` for the `ADO_PROD_REPOSITORY` Azure DevOps repo, if the production publish job is enabled

The `check-required-secrets-variables` job exposes preflight switches for each downstream area. If a required secret or variable is missing, the related apply or publish job is skipped because its condition is not met instead of failing inside the publish step.

## Important Publish Notes

- The GitHub stage publish job pushes a clean snapshot without preserving source commit history.
- The Azure DevOps publish job in GitHub Actions pushes the real branch history into the ADO repo, so commit SHAs and commit messages stay aligned with GitHub for the published branch.
- The GitHub validation jobs are intentionally skipped in the stage repo when the run comes from the GitHub Actions bot.
- The Azure DevOps pipeline no longer mirrors to another ADO repo; publishing into ADO is handled by GitHub Actions.

## Module Docs, Examples, And Tests

Each module usually keeps:

- `modules/<name>/README.md`
- `modules/<name>/EXAMPLES.md`
- `modules/<name>/tests/live.tftest.hcl`

Use [docs/MODULES_INDEX.md](docs/MODULES_INDEX.md) as the main directory for module docs, examples, and tests.
The root harness and CI module matrix use the `module_plan_enabled` module list in [variables.tf](variables.tf), the root pass-through variables in [terraform.tfvars](terraform.tfvars), and `scripts/azure-pipelines/module-harness-targets.sh` for one-module-at-a-time validation.
