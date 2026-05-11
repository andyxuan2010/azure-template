# template

Shared source-of-truth repository for:

- reusable Terraform modules under `modules/`
- the root Terraform validation harness in `main.tf`, `data.tf`, `variables.tf`, and `terraform.tfvars`
- shared Azure DevOps pipeline templates under `templates/`
- examples, tests, and reference docs used by consumers of this repo

## What This Repo Is

This repo is primarily a validation and distribution repo, not a single always-on deployment stack.

- The root Terraform files are organized as a harness that can plan one module at a time.
- Most module blocks in `main.tf` are guarded by `var.module_plan_enabled.<module_name>`.
- `terraform.tfvars` keeps those toggles `false` by default so the repo can validate cleanly.
- Module source paths are called from the repo root as `./modules/<name>`.

## Repository Layout

- `modules/`: reusable Azure Terraform modules
- `docs/`: root guides, validation notes, runner notes, and module index
- `examples/`: example usage and the root plan harness example
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
- [VALIDATION_REPORT.md](VALIDATION_REPORT.md)

Useful focused notes:

- [docs/SHARED-RUNNER-HYGIENE-STANDARD.md](docs/SHARED-RUNNER-HYGIENE-STANDARD.md)
- [docs/GIT-EXTRAHEADER-RUNNER-ISSUE.md](docs/GIT-EXTRAHEADER-RUNNER-ISSUE.md)
- [docs/PRIVATE_ENDPOINT_PRIVATE_DNS_LOOKUP_PATTERN.md](docs/PRIVATE_ENDPOINT_PRIVATE_DNS_LOOKUP_PATTERN.md)
- [docs/AKS_AUTHENTICATION_KUBELOGIN.md](docs/AKS_AUTHENTICATION_KUBELOGIN.md)

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

- checks whether required Azure validation secrets exist before starting validation
- skips validation jobs when `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_TENANT_ID`, or `AZURE_SUBSCRIPTION_ID` are missing
- uses the GitHub Actions variable `TF_BACKEND_READY` to decide whether the configured Terraform backend can be initialized
- when `TF_BACKEND_READY` is not `true`, runs backend-free `terraform init -backend=false`, `terraform fmt`, and `terraform validate`, then skips root and module plan steps
- when `TF_BACKEND_READY` is `true`, runs backend initialization with `terraform init -reconfigure`, root `terraform test`, root `terraform plan`, and plan artifact upload
- runs the per-module plan matrix only when `TF_BACKEND_READY` is `true`; the matrix enables one root-harness module at a time
- creates an annotated semantic version tag after successful non-PR validation runs by reading commit messages since the latest `v1+` tag, using `v1.0.0` as the baseline when no `v1+` version tag exists: `fix:` creates a patch release, `feat:` creates a minor release, and `BREAKING CHANGE:`, `BREAKING-CHANGE:`, or `type!:` creates a major release; commits without one of those prefixes default to a patch release so every successful commit receives a version tag
- includes a short commit-summary changelog in the annotated source, GitHub stage, and Azure DevOps snapshot tag messages
- keeps `apply` disabled for now
- publishes a clean single-commit snapshot to the GitHub stage repo after successful validation, tagging the snapshot commit with the same semantic version when a release tag is created
- publishes a clean single-commit snapshot to the Azure DevOps `template` repo after successful validation, tagging the snapshot commit with the same semantic version when a release tag is created

The publish jobs do not run for pull requests.

Define `TF_BACKEND_READY` as a GitHub Actions repository or environment variable under **Settings** -> **Secrets and variables** -> **Actions** -> **Variables**. Use `false` while the AzureRM backend storage is not available, then switch it to `true` when the backend is ready for real plan runs.

### Azure DevOps

The pipeline in [`azure-pipelines.yml`](azure-pipelines.yml):

- follows the same high-level stage structure as the sibling `landingzone` repo: `Validate`, `Plan`, `CreateGitTag`, and a disabled `Apply` stage
- uses a Microsoft-hosted `ubuntu-latest` agent, repo-local pipeline scripts under `scripts/azure-pipelines/`, and the fixed `terraformVersion` pipeline variable
- uses a fixed stage-level Azure service connection instead of deriving the service connection from the Git branch
- runs `scripts/azure-pipelines/terraform-validate.sh` for backend-free `terraform init -backend=false`, `terraform fmt`, and `terraform validate`
- runs `scripts/azure-pipelines/terraform-plan.sh` with repo-local `backend.hcl` and `terraform.tfvars`, then publishes both the binary plan and plan text artifacts
- keeps `Apply` disabled for now, but the disabled stage already uses `scripts/azure-pipelines/terraform-apply.sh` and downloads the published plan artifact in the same style as the sibling repo
- creates annotated semantic version tags with commit-summary changelogs when tags do not already exist in the ADO repo

## Required Secrets And Credentials

GitHub Actions validation expects these secrets when Azure validation should run:

- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

GitHub Actions publish jobs also expect:

- `STAGE_REPO_TOKEN` for `andyxuan2010/azure-template`
- `ADO_REPO_PAT` for `https://dev.azure.com/CCOE-Azure/IaC/_git/template`

## Important Publish Notes

- The GitHub stage publish job pushes a clean snapshot without preserving source commit history.
- The Azure DevOps publish job in GitHub Actions also pushes a clean snapshot instead of the full source history.
- The GitHub validation jobs are intentionally skipped in the stage repo when the run comes from the GitHub Actions bot.
- The Azure DevOps pipeline no longer mirrors to another ADO repo; publishing into ADO is handled by GitHub Actions.

## Module Docs, Examples, And Tests

Each module usually keeps:

- `modules/<name>/README.md`
- `modules/<name>/EXAMPLES.md`
- `modules/<name>/tests/live.tftest.hcl`

Use [docs/MODULES_INDEX.md](docs/MODULES_INDEX.md) as the main directory for module docs, examples, and tests.
The root harness and CI module matrix now also include `modules/applicationgateway` for one-module-at-a-time validation.
