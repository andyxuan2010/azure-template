# First Change Walkthrough

Use this guide to make a small, reviewable change without assuming that you have Azure access. It covers discovery and validation; it does not authorize a live apply.

## 1. Identify the right change surface

- For a reusable Azure capability, start in `modules/<module-name>/`.
- For composition behavior, inspect root `main.tf`, `variables.tf`, `locals.tf`, and `terraform.tfvars`.
- For workflow behavior, inspect `.github/workflows/terraform.yml` or `azure-pipelines.yml` and its referenced templates/scripts.
- For an operational rule, update the relevant page under `docs/` and its related README links.

If you are unsure, search the [Modules Index](../20-repository/modules-index.md) and [Repository Map](repo-map.md), then ask the module owner before changing shared interfaces.

## 2. Read before editing

For a module, read its README, the `examples/basic` example, and its `tests/` folder. Check prerequisites in [Module Usage and Dependencies](../20-repository/module-usage-and-dependencies.md). Confirm which provider, identity, network, and shared resources are caller-owned.

For root wiring, read the [Root-Level Module Guide](../20-repository/root-level-modules-guide.md). A module in the catalog is not automatically enabled in the root harness.

## 3. Make the smallest useful change

Keep module inputs, outputs, examples, tests, and documentation consistent. Use outputs rather than copying Azure resource IDs between modules. Do not commit credentials, live state, generated plan files, or environment-specific secrets.

For a new module or material module change, follow the [Terraform Module Documentation Standard](../20-repository/module-documentation-standard.md) and [Create or Extend a Terraform Module](../30-deployment/create-a-new-resource.md).

## 4. Run safe local checks

From the repository root, formatting, backend-free initialization, and validation can be run without selecting a live backend:

```powershell
terraform fmt -check -recursive
terraform init -backend=false -input=false
terraform validate -no-color
```

Run the mocked module unit tests (`tests/unit.tftest.hcl`; no Azure access) with:

```powershell
.\scripts\Test-TerraformModules.ps1 -NoColor
```

Some integration tests can contact Azure or change resources. Read the test first and use an approved isolated non-production subscription when a live test is required. See [Validation Summary](../70-validation/validation-summary.md).

## 5. Open a pull request

Create a feature branch, describe the reason for the change, list the checks you ran, and call out any cloud permissions or cost implications. Keep the PR focused so the plan and review remain understandable.

GitHub Actions runs static validation on eligible changes. Azure-backed plans and applies depend on the configured branch/environment, credentials, backend readiness, and approvals. Read [GitHub Actions Terraform Pipeline](../40-pipelines/github-actions-pipeline.md) for the exact conditions. Do not apply a plan locally against shared state unless your change has been approved and the environment owner has directed you to do so.

## 6. After merge

Deployment and downstream publishing are separate gated actions. Follow the [Environment and Deployment Lifecycle](../30-deployment/environment-lifecycle.md); use the [Operations Handbook](../50-operations/operations-handbook.md) if a pipeline fails or state needs recovery.
