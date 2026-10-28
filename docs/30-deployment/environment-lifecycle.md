# Environment and Deployment Lifecycle

This guide separates the repository's environment names, Terraform backends, GitHub Actions protections, and Azure DevOps pipeline settings. These are related but separately configured systems.

## Environment map

| Environment | GitHub Actions ref mapping | Backend configuration | Current source status |
| --- | --- | --- | --- |
| Development | `dev` branch selects GitHub environment `dev`. | `environments/dev/backend.hcl` | Values are populated; owners must confirm access and backend safeguards. |
| Sandbox | `sbx` branch selects GitHub environment `sbx`. | `environments/sandbox/backend.hcl` | Values are populated; owners must confirm access and backend safeguards. |
| Production | `main` branch selects GitHub environment `prod`. | `environments/prod/backend.hcl` | Placeholder values. Do not initialize or use until approved and completed. |

Other manual GitHub dispatch refs fall back to the `dev` GitHub environment in the workflow. Keep dispatches on approved branches and verify the selected environment before using cloud credentials.

## GitHub Actions lifecycle

1. The `IS_ORIGIN` variable enables the Terraform workflow; otherwise Terraform jobs skip.
2. Eligible changes receive static Terraform checks and repository security scanning.
3. Azure-backed planning depends on credentials and the `TF_BACKEND_READY` variable.
4. Apply is separately gated by `ENABLE_GITHUB_APPLY=true` or the manual `apply` input, backend readiness, successful validation/plan, and a non-PR ref among `main`, `dev`, or `sbx`.
5. GitHub environment approvals and branch protections should be configured by repository owners. Workflow YAML alone does not prove these settings are active.
6. Downstream publishing is optional and separate from Azure apply. Development publishing needs `ADO_DEV_REPOSITORY` and `ADO_DEV_REPO_PAT`; production/sandbox publishing uses `PUBLISH_ADO_PROD`, `ADO_PROD_REPOSITORY`, and `ADO_PROD_REPO_PAT`.

See [GitHub Actions Terraform Pipeline](../40-pipelines/github-actions-pipeline.md) for complete input and job conditions.

## Azure DevOps lifecycle

The checked-in `azure-pipelines.yml` triggers on `main` and sets `pr: none`. It reads `ENVIRONMENT`, `AZURE_SERVICE_CONNECTION`, `TERRAFORM_VERSION`, and `TERRAFORM_VAR_FILE` from Azure DevOps configuration; the shared `iac-shared-vars` group is declared in YAML, while other variable-group guidance in the file is commented. Confirm the actual pipeline variable-group configuration with the Azure DevOps owner.

The pipeline validates, plans, publishes plan artifacts, and has a separately gated apply stage. Its `ENVIRONMENT` selection is independent of the GitHub branch-to-environment expression. See [Azure DevOps Pipeline](../40-pipelines/azure-devops-pipeline.md).

## Safe promotion checklist

- Confirm the branch/ref, GitHub environment, Azure subscription, backend file, state key, and variable file agree.
- Confirm the target environment's approvals and identity are configured and authorized.
- Review the complete plan, including replacements, deletes, role assignments, network exposure, and estimated cost.
- Apply only the reviewed plan artifact under the approved process.
- Verify the resulting resources and update operational records.
- For failed or partial applies, stop concurrent changes and follow [Terraform State and Recovery](../50-operations/terraform-state-and-recovery.md).

## Important limits

Environment names in this repository are configuration labels, not proof that a matching subscription, backend, approval rule, or service is healthy. Confirm live configuration with the responsible platform owners before any plan or apply.
