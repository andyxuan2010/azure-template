# Azure DevOps Terraform Pipeline

This guide describes the stages in the repository's `azure-pipelines.yml`. Pipeline settings and Azure permissions are managed outside that YAML and must be verified in the target Azure DevOps project.

## Trigger and variables

The pipeline batches changes on `main`; `pr: none` means this YAML does not define a pull-request trigger. Pull request controls must be configured separately if desired.

The active variable group is `iac-shared-vars`, which supplies `ADO_AGENT_POOL` and `ADO_AGENT_VM_IMAGE`. The `azure-terraform` group is commented out. The following values must therefore be set through pipeline/project settings or another active variable group:

- `AZURE_SERVICE_CONNECTION`
- `ENVIRONMENT` (`dev`, `sandbox`, or a separately approved backend)
- `TERRAFORM_VAR_FILE`
- `TERRAFORM_VERSION`
- optionally `ENABLE_ADO_APPLY=true`

`ADO_AGENT_ENABLED=false` skips agent-backed stages. The selected environment resolves to `environments/<ENVIRONMENT>/backend.hcl`. The production file currently contains placeholders and is not usable.

## Stage flow

1. **Validate**: initializes shared-runner hygiene, checks required settings/backend file, installs Terraform, then runs the repository validation script.
2. **Plan**: initializes the selected AzureRM backend through the Azure service connection; publishes the binary plan and readable plan text as separate artifacts.
3. **DetectModuleTargets**: finds changed module harness targets through Azure DevOps change APIs, with Git diff fallback.
4. **ValidateModules**: plans selected module harness targets in a matrix. Matrix `maxParallel` is four, subject to Azure DevOps parallel-job entitlement. These are plans, not applies; the harness uses `-lock=false` for this validation path.
5. **Apply**: runs only on `main`, when `ENABLE_ADO_APPLY=true`, prerequisite stages pass, and agent stages are enabled. It downloads and applies the plan artifact produced by the Plan stage.

## Operational notes

- Keep service connection permissions and backend data-plane access at the narrowest workable scope.
- Protect plan artifacts because they can reveal infrastructure details and may contain sensitive values.
- Use branch and environment approvals to enforce human review; YAML conditions do not substitute for project-level authorization.
- Do not run against `prod` until its backend placeholders are replaced with approved state resources and access is verified.
- If validation is skipped, inspect the reason and pipeline entitlement before treating a plan as fully checked.
- Runner cleanup and Git credential handling are described in [Shared Runner Hygiene](shared-runner-hygiene.md).

See [Terraform State and Recovery](../50-operations/terraform-state-and-recovery.md), [Root-Level Module Guide](../20-repository/root-level-modules-guide.md), and [DevSecOps and GitOps Controls](../60-security-governance/devsecops-gitops.md).
