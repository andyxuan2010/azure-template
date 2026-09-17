# GitHub Actions Terraform Pipeline

This document is the operational guide for `.github/workflows/terraform.yml`. The workflow first checks whether the repository is the origin repository, then validates Terraform changes, scans the repository for IaC misconfigurations and secrets, creates reviewed plans, optionally applies them, creates release tags, and publishes approved snapshots to downstream repositories.

## Triggers and branches

The workflow runs for:

- pushes to `main`, `dev`, and `sbx`;
- pull requests targeting `main`, `dev`, and `sbx`; and
- manual `workflow_dispatch` runs, with an optional `apply` input.

Documentation-only changes and the GitHub Pages workflow are excluded through `paths-ignore`. Pull-request runs are cancellation-aware: a newer run for the same pull request cancels the older run.

The branch selects the protected GitHub environment:

| Branch | Environment |
| --- | --- |
| `main` | `prod` |
| `dev` | `dev` |
| `sbx` | `sbx` |
| Other manual context | `dev` |

## Pipeline flow

1. **Terraform Workflow Gate** reads the repository variable `IS_ORIGIN`. When it is exactly `true`, downstream Terraform jobs are enabled. When it is missing or has another value, the gate succeeds and all downstream Terraform jobs are skipped.
2. **Static IaC and Security Validation** runs without Azure credentials. Immediately after checkout, Trivy scans the repository for HIGH and CRITICAL Terraform misconfigurations and secrets. Terraform formatting, backend-free initialization, and validation then run.
3. **Check Required Secrets and Variables** reports whether each optional pipeline path has its required configuration. Secret values are never printed.
4. **Validate and Plan** runs when all Azure credentials are present. It initializes without a backend when `TF_BACKEND_READY` is not `true`; when the backend is ready, it also runs the root harness test, creates a binary plan, and uploads that plan for non-pull-request runs.
5. **Detect Module Harness Targets** identifies changed modules and related dependency targets.
6. **Validate Module Harness** plans selected module harnesses in a matrix of up to four parallel jobs when credentials and the backend are ready.
7. **Apply** downloads and applies the binary plan created earlier in the same workflow run. It never runs for pull requests.
8. **Create Git Tag** creates the canonical release tag after successful validation on an environment branch.
9. **Publish** synchronizes the validated branch and release tag to configured GitHub stage and Azure DevOps repositories.

When `IS_ORIGIN` is not `true`, the gate itself is successful; the workflow is intentionally skipped rather than failed. When the gate is enabled, missing optional credentials cause only their dependent jobs to skip; they do not bypass the static security gate.

## Repository variables

Configure variables under **Settings > Secrets and variables > Actions > Variables**.

| Variable | Purpose | Required behavior |
| --- | --- | --- |
| `IS_ORIGIN` | Identifies whether this is the source/origin repository. | Set to `true` in the origin repository. A missing value or any value other than `true` skips the downstream Terraform jobs. |
| `ENABLE_IAC_SECRET_SCAN` | Controls Trivy IaC and secret scanning. | Secure by default. Only the exact value `false` skips the scan. |
| `TF_BACKEND_READY` | Enables backend initialization, root tests, planning, module planning, and apply eligibility. | Set to `true` only after backend configuration is operational. |
| `ENABLE_GITHUB_APPLY` | Allows apply on eligible push/manual runs. | Must be `true`, unless manual dispatch uses `apply=true`. |
| `STAGE_REPOSITORY` | GitHub stage destination in `owner/repository` form. | Required only for stage publishing. |
| `ADO_DEV_REPOSITORY` | Azure DevOps development destination path. | Required only for development publishing. |
| `PUBLISH_ADO_PROD` | Enables Azure DevOps production/sandbox publishing. | Must be exactly `true`. |
| `ADO_PROD_REPOSITORY` | Azure DevOps production/sandbox destination path. | Required only for production/sandbox publishing. |

## Secrets

Configure secrets at repository or protected-environment scope. Prefer environment secrets for credentials that differ among `prod`, `dev`, and `sbx`.

| Secret | Purpose |
| --- | --- |
| `AZURE_CLIENT_ID` | Terraform Azure service-principal client ID. |
| `AZURE_CLIENT_SECRET` | Terraform Azure service-principal credential. |
| `AZURE_TENANT_ID` | Azure tenant ID. |
| `AZURE_SUBSCRIPTION_ID` | Target Azure subscription ID. |
| `STAGE_REPO_TOKEN` | Dedicated PAT or GitHub App installation token scoped to the configured GitHub stage repository. |
| `ADO_DEV_REPO_PAT` | PAT scoped to the configured Azure DevOps development repository. |
| `ADO_PROD_REPO_PAT` | PAT scoped to the configured Azure DevOps production/sandbox repository. |

Use least-privilege, destination-specific publishing tokens and rotate them regularly. Never store credential values in repository variables, Terraform variable files, workflow YAML, logs, or documentation.

GitHub automatically provides a temporary `GITHUB_TOKEN` inside each Actions job, but pushes made with it do not create new `push` workflow runs. Therefore, `STAGE_REPO_TOKEN` must be a separate PAT or GitHub App installation token when the mirrored repository is expected to start its own workflows. If the mirror includes files under `.github/workflows`, the destination token must also be allowed to update workflow files.

## Security scan behavior

The Trivy step runs immediately after checkout and before Terraform downloads providers or modules. This keeps the target limited to repository content and fails early. It uses:

- filesystem scan mode;
- `misconfig` and `secret` scanners;
- HIGH and CRITICAL severity filtering;
- a nonzero exit code when findings exist; and
- a 10-minute scan timeout within the 20-minute static-validation job.

Temporarily setting `ENABLE_IAC_SECRET_SCAN=false` is an exception path, not a normal operating mode. Record approval and a restoration date before disabling the gate.

## Apply safeguards

Apply is eligible only when all of these conditions are true:

- the event is not a pull request;
- the ref is `main`, `dev`, or `sbx`;
- Azure credentials are present;
- `TF_BACKEND_READY=true`;
- `ENABLE_GITHUB_APPLY=true` or a manual run uses `apply=true`;
- root validation and plan succeed; and
- module validation succeeds or has no selected modules.

The Apply job uses the uploaded binary plan from the same workflow run. Configure required reviewers on the `prod`, `dev`, and `sbx` GitHub environments to enforce deployment approval.

## Publishing safeguards

Publishing never runs on pull requests. Each destination is independently gated by its variable and secret pair. The workflow detects when it is running in the configured stage repository and suppresses loop-prone bot jobs.

GitHub stage publishing creates a clean snapshot without source Git history and force-updates the destination branch. The snapshot includes the `.github` directory so destination workflow files are retained. Azure DevOps publishing synchronizes Git history and force-updates the corresponding destination branch. Restrict destination credentials accordingly and protect downstream repositories against unintended manual changes.

## Local validation

Run the credential-free checks before opening a pull request:

```powershell
terraform fmt -check -recursive
$env:TF_PLUGIN_TIMEOUT = "300s"
terraform init -backend=false -input=false
terraform validate -no-color
trivy fs --scanners misconfig,secret --severity HIGH,CRITICAL --exit-code 1 --timeout 10m .
```

Module harness validation is available through:

```powershell
.\scripts\Test-TerraformModules.ps1 -NoColor
```

Live plans and tests can require privileged Azure access and may incur cost. Run them only in an approved test subscription.

## Troubleshooting

| Symptom | Likely cause and response |
| --- | --- |
| Trivy job is skipped | Confirm `ENABLE_IAC_SECRET_SCAN` is not set to the exact value `false`. |
| Validate and Plan is skipped | Add all four Azure credential secrets at the repository or selected environment scope. |
| Plan steps are skipped | Set `TF_BACKEND_READY=true` after verifying the backend configuration. |
| Apply is skipped | Check the event/branch restrictions, apply toggle or manual input, backend readiness, credentials, and upstream job results. |
| Only the Terraform gate runs | Check `IS_ORIGIN`. The downstream jobs intentionally skip unless the value is exactly `true`. |
| A publish job is skipped | Check the destination variable and its matching token/PAT; production publishing also requires `PUBLISH_ADO_PROD=true`. |
| Mirror updated but no destination workflow run was created | Confirm that `STAGE_REPO_TOKEN` is a PAT or GitHub App token, not `GITHUB_TOKEN`. GitHub suppresses normal workflow runs created by `GITHUB_TOKEN` pushes. |
| Stage-generated runs do not republish | This is intentional loop prevention when the current repository matches `STAGE_REPOSITORY` and the actor is `github-actions[bot]`. |

Use the **Check Required Secrets and Variables** job log for presence checks. It reports names and status without revealing secret values.
