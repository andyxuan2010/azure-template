# Windows VM Pipeline Notes

## Pipeline Entry Point

The repository-level pipeline is `azure-pipelines.yml`. It runs on `main` and uses the `IaCRunner` Linux pool.

The winvm module is validated through the same common repository pipeline as other modules.

## Pipeline Variables

Important root variables:

- `terraformVersion`: currently `1.10.5`.
- `selfRepoRoot`: `$(Pipeline.Workspace)/s/template`.

Plan-stage backend variables:

- `backendSubscriptionId`: `ef8ff35a-8548-485c-be32-204db0340dd1`
- `backendTenantId`: `b0f3630d-e5de-4172-b492-0cf5cd387a41`
- `backendResourceGroupName`: `rg-ccoe-iac-cc-prod`
- `backendStorageAccountName`: `stccoeiacccprod`
- `backendContainerName`: `terraform`
- `backendKey`: `template/terraform.tfstate`

## Stages

### Validate

Runs common repo validation:

1. Shared runner hygiene.
2. Checkout.
3. Install Terraform using `scripts/azure-pipelines/install-terraform.sh`.
4. Run `scripts/azure-pipelines/terraform-validate.sh`.
5. Runner cleanup.

### Plan

Runs a full Terraform plan:

1. Shared runner hygiene.
2. Checkout.
3. Install Terraform.
4. Azure CLI login through service connection `sc-ccoe-iac-devops-prod`.
5. Run `scripts/azure-pipelines/terraform-plan.sh`.
6. Publish binary plan artifact.
7. Publish text plan artifact.

### DetectModuleTargets

Detects changed files for module harness validation:

1. Uses Azure DevOps build change API when available.
2. Falls back to Git diff when needed.
3. Calls `scripts/azure-pipelines/module-harness-targets.sh`.
4. Emits matrix output for changed modules.

### ValidateModules

Runs module-specific plan harnesses only when changed modules are detected:

1. Builds module override tfvars JSON.
2. Runs `terraform init` with backend config.
3. Runs `terraform plan -lock=false` with generated overrides.

## Winvm-Specific Validation

The module test is:

```text
modules/winvm/tests/live.tftest.hcl
```

It defines a live apply harness with multiple VMs, zone spread, data disk, AAD login, custom script extension, storage/Key Vault inputs, RBAC groups, and disabled domain join.

## Backend

The root backend is declared in `backend.tf`. The pipeline reconfigures the same AzureRM backend values during `terraform init`.

## Notes For Changes

- Changes under `modules/winvm/**` should be detected by `DetectModuleTargets`.
- Script changes under `modules/winvm/scripts/**` affect bootstrap behavior and the Run Command source payload.
- The VM resource ignores `custom_data` drift, but the Run Command source still reflects the current `init2.ps1` payload when `enable_virtual_machine_run_command = true`.
- Keep the Run Command wrapper base64 based to avoid PowerShell parser failures from embedded here-strings.
