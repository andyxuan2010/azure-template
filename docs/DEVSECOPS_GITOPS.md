# DevSecOps and GitOps Controls

This repository treats pull requests and immutable Terraform plans as the change-control boundary.

## Required branch controls

Protect `main`, `dev`, and `sbx` and require:

- pull requests with at least one reviewer;
- the `Static IaC and Security Validation` check;
- the environment-backed `Validate and Plan` check where Azure credentials are configured;
- resolved review conversations;
- blocked force pushes and branch deletion;
- approval on the `prod`, `dev`, and `sbx` GitHub environments before deployment.

Repository administrators should not bypass these controls for routine changes.

## Pull-request validation

`.github/workflows/terraform.yml` runs credential-free checks independently of Azure:

1. `terraform fmt -check -recursive`
2. backend-free `terraform init`
3. `terraform validate`
4. Trivy HIGH/CRITICAL Terraform misconfiguration and secret scanning

The Trivy step runs by default. Set the `ENABLE_IAC_SECRET_SCAN` GitHub repository variable to exactly `false` to skip it temporarily; leaving the variable unset or assigning any other value keeps the scan enabled. Any exception should be time-bound, approved, and restored after the blocking issue is resolved.

Third-party GitHub Actions are pinned to full commit SHAs. Dependabot or an equivalent controlled process should propose action updates so the reviewed SHA changes explicitly.

Azure-backed plan and module-harness jobs run only when the required repository credentials and backend configuration are present. A missing cloud credential does not skip the static validation gate.

## Apply safety

Apply is disabled unless `ENABLE_GITHUB_APPLY=true` or the manual dispatch input is enabled, `TF_BACKEND_READY=true`, and Azure credentials are available.

Additional controls are:

- pull-request runs can never apply;
- only `main`, `dev`, and `sbx` refs can apply;
- the Apply job downloads and applies the binary plan generated earlier in the same workflow run;
- GitHub environments provide the approval and secret boundary;
- the Azure DevOps Apply stage is separately gated by `ENABLE_ADO_APPLY=true` and applies its published plan artifact.

Do not place passwords, tokens, private keys, or live credentials in `terraform.tfvars`. Supply sensitive values through protected CI secrets, environment-specific secret stores, or Key Vault lookups. Example values must be empty or unmistakably non-functional test fixtures.

## Local validation

Run these checks before opening a pull request:

```powershell
terraform fmt -check -recursive
$env:TF_PLUGIN_TIMEOUT = "300s"
terraform init -backend=false -input=false
terraform validate -no-color
trivy fs --scanners misconfig,secret --severity HIGH,CRITICAL --exit-code 1 .
```

Module tests can be run with:

```powershell
.\scripts\Test-TerraformModules.ps1 -NoColor
```

Live tests and plans can incur Azure cost or require privileged access. Run them only in an approved test subscription.

## Promotion model

Changes flow through reviewed commits rather than ad hoc edits:

1. feature branch and pull request;
2. static validation, security scan, and Terraform plan;
3. review and merge into the selected environment branch;
4. protected environment approval;
5. apply of the workflow-produced plan;
6. tagged and auditable publication to configured downstream repositories.

The publishing jobs intentionally synchronize complete snapshots to downstream repositories. Their credentials must be scoped to only the destination repository and rotated regularly.
