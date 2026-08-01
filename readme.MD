# Azure Terraform Template

This repository is the shared source of truth for reusable Azure Terraform modules, a root-level validation and composition harness, and the CI/CD controls used to validate and distribute the code.

It is primarily a **module development, validation, and distribution repository**. The root Terraform configuration is a harness that can compose selected capabilities or plan one module at a time; it is not intended to represent one permanently deployed environment.

## Contents

- [What is in this repository](#what-is-in-this-repository)
- [Start here](#start-here)
- [How the root harness works](#how-the-root-harness-works)
- [Standards and required controls](#standards-and-required-controls)
- [Documentation catalog](#documentation-catalog)
- [Using a module](#using-a-module)
- [Validation and testing](#validation-and-testing)
- [CI/CD and publishing](#cicd-and-publishing)
- [Secrets and configuration](#secrets-and-configuration)
- [Contributing](#contributing)

## What is in this repository

| Path | Purpose |
| --- | --- |
| `modules/` | Reusable Terraform modules for Azure infrastructure, platform services, identity, policy, and networking. |
| `main.tf` | Root module wiring, ordered by module folder name and guarded by module enablement settings. |
| `variables.tf` | Root feature flags, focused module-plan toggles, and module pass-through inputs. |
| `terraform.tfvars` | Sample feature settings and module input values. Replace them with environment-appropriate values before a live plan. |
| `locals.tf` and `data.tf` | Shared root-harness normalization, dependency, naming, tagging, and lookup logic. |
| `environments/` | Environment-specific backend configuration for `dev`, `sandbox`, and `prod`. |
| `docs/` | Architecture, standards, operating guidance, troubleshooting, and repository validation status. |
| `templates/` | Reusable Azure DevOps templates, including shared-runner hygiene controls. |
| `scripts/` | Pipeline, validation, release, and repository synchronization helpers. |
| `.github/workflows/terraform.yml` | GitHub Actions validation, optional apply, release tagging, and publishing workflow. |
| `azure-pipelines.yml` | Azure DevOps validation, plan, optional apply, and module-targeting pipeline. |
| `references/` | Supplemental contributor how-to guides and naming, tagging, and coding references. |

The repository currently contains 44 module directories. Use the [Modules Index](docs/MODULES_INDEX.md) for direct links to each canonical README, executable examples, and classified Terraform tests.

## Start here

Choose the path that matches what you are trying to do:

| If you want to... | Read first |
| --- | --- |
| Find a module and its examples | [Modules Index](docs/MODULES_INDEX.md) |
| Understand what a module needs and which order to deploy dependencies | [Module Usage and Dependencies](docs/MODULE_USAGE_AND_DEPENDENCIES.md) |
| Enable or plan modules from the repository root | [Root-Level Module Guide](docs/ROOT_LEVEL_MODULES_GUIDE.md) |
| Contribute or change a module | [Terraform Module Documentation Standard](docs/documentation.md) |
| Understand the delivery and security controls | [DevSecOps and GitOps Controls](docs/DEVSECOPS_GITOPS.md) |
| Apply the repository naming and tagging rules | [Naming Convention](docs/NAMING_CONVENTION.md) and [Tagging Standard](docs/TAGGING_STANDARD.md) |
| Review current validation coverage and known gaps | [Validation Summary](docs/VALIDATION_SUMMARY.md) |

For a first visit, the recommended reading order is:

1. Read this README for the repository model and safety boundaries.
2. Select a module in the [Modules Index](docs/MODULES_INDEX.md).
3. Check its prerequisites in [Module Usage and Dependencies](docs/MODULE_USAGE_AND_DEPENDENCIES.md).
4. Read the module's own `README.md` and executable `examples/` scenarios.
5. Review [Naming Convention](docs/NAMING_CONVENTION.md), [Tagging Standard](docs/TAGGING_STANDARD.md), and any relevant focused design note.
6. Validate through the root harness before proposing the change.

## How the root harness works

The root configuration offers two related enablement mechanisms:

- `features.enable_<module>` enables capabilities at a high level for composition-style runs.
- `module_plan_enabled.<module>` enables an exact module set for focused local or CI plans.

Every root-wired module block in `main.tf` is guarded by the effective `local.module_plan_enabled` map. Module-specific values are exposed through root variables and illustrated in `terraform.tfvars`.

For a focused plan:

1. Create an override `.tfvars` file containing the required module inputs.
2. Set `features = {}` so sample high-level feature settings do not widen the plan.
3. Enable only the required `module_plan_enabled` entry or entries.
4. Initialize the correct backend and run the plan with the override file.
5. Inspect all proposed resources, data lookups, role assignments, networking changes, and costs before apply.

Prefer connecting modules through Terraform outputs rather than copying resource IDs. Deploy shared foundations first, platform or hosting resources second, and dependent workloads last. The detailed dependency chains are maintained in [Module Usage and Dependencies](docs/MODULE_USAGE_AND_DEPENDENCIES.md).

## Standards and required controls

These documents describe repository-wide behavior and should be treated as required guidance for new work.

### Delivery and security

[DevSecOps and GitOps Controls](docs/DEVSECOPS_GITOPS.md) defines pull-request validation, protected-branch expectations, security scanning, environment approvals, immutable Terraform plan application, secret handling, and promotion. Changes should be reviewed and the exact plan produced by CI should be the plan applied.

### Naming

[Resource Naming Convention](docs/NAMING_CONVENTION.md) defines the target naming shape:

```text
<resource-type>-<workload>-<region-code>-<environment>-<instance>
```

Use deterministic lowercase names where Azure permits them. The guide also inventories existing module patterns and known gaps, because the repository has not yet reached one universal convention.

### Tagging

[Tagging Standard](docs/TAGGING_STANDARD.md) makes the root composition the owner of enterprise ARM tag normalization. Child modules receive canonical resource-group tags through `inherited_resource_group_tags`, merge resource-specific tags over that baseline, and avoid redefining reserved `Environment` or `Workload` behavior. Microsoft Entra object tags are metadata sets and must not be treated as Azure Resource Manager tags.

### Shared runners

[Shared Self-Hosted Runner Hygiene Standard](docs/SHARED-RUNNER-HYGIENE-STANDARD.md) treats a long-lived runner as a stateful, partially untrusted environment. The minimum controls are pre- and post-job Git authentication cleanup, non-persistent checkout credentials, job-scoped temporary/configuration directories, deterministic tool setup, and cleanup that runs even after failure. Use [`templates/shared-runner-hygiene.yml`](templates/shared-runner-hygiene.yml) as the implementation starting point.

## Documentation catalog

This catalog covers every artifact currently stored in `docs/`. Critical repository-wide documents have expanded summaries; focused notes are summarized briefly.

### Core repository guides

| Document | Scope and when to use it |
| --- | --- |
| [Module Usage and Dependencies](docs/MODULE_USAGE_AND_DEPENDENCIES.md) | **Critical.** Explains how to consume modules, the dependency matrix, common deployment chains, module-by-module use cases, example entry points, and testing cautions. Consult it before composing an environment or changing module wiring. |
| [Modules Index](docs/MODULES_INDEX.md) | The complete navigation map for module READMEs, executable examples, and classified Terraform tests. |
| [Root-Level Module Guide](docs/ROOT_LEVEL_MODULES_GUIDE.md) | **Critical for root plans and CI.** Describes root wiring, module order, `features`, `module_plan_enabled`, pass-through inputs, focused planning, and CI matrix behavior. |
| [Terraform Module Documentation Standard](docs/documentation.md) | Canonical module folder structure, README requirements, executable example rules, generated reference ownership, test safety classifications, documentation style, migration guidance, and definition of done. |
| [Validation Summary](docs/VALIDATION_SUMMARY.md) | Current hardening and documentation status for selected modules, plus known follow-up work. It is a point-in-time status report, not proof that every module is safe to deploy without a new plan. |
| [Validation Summary (PDF)](docs/VALIDATION_SUMMARY.pdf) | Portable PDF rendition of the validation summary. Prefer the Markdown version for the latest reviewable source. |

### Governance, security, and operations

| Document | Scope and when to use it |
| --- | --- |
| [DevSecOps and GitOps Controls](docs/DEVSECOPS_GITOPS.md) | **Critical.** Defines required branch protections, pull-request checks, plan/apply safety, local validation, secrets handling, approvals, and promotion expectations. |
| [Naming Convention](docs/NAMING_CONVENTION.md) | **Required for new resources.** Defines the target naming model, records current patterns, maps environment suffixes, and calls out inconsistencies that should not be copied into new work. |
| [Tagging Standard](docs/TAGGING_STANDARD.md) | **Required for ARM-tagged modules.** Defines root ownership, standard inheritance inputs, merge precedence, Azure Policy interaction, Entra exceptions, and the validation checklist. |
| [Shared Runner Hygiene Standard](docs/SHARED-RUNNER-HYGIENE-STANDARD.md) | **Critical for self-hosted agents.** Defines isolation and cleanup controls that prevent credential leakage and cross-job state contamination. |
| [Shared Runner Git `extraheader` Issue](docs/GIT-EXTRAHEADER-RUNNER-ISSUE.md) | Troubleshooting record for Azure DevOps checkout failures caused by stale, URL-scoped Git authentication headers. It explains why cleanup must happen before checkout and remove all matching `extraheader` keys. |

### Architecture and service-specific notes

| Document | Scope and when to use it |
| --- | --- |
| [Private Endpoint and Private DNS Lookup Pattern](docs/PRIVATE_ENDPOINT_PRIVATE_DNS_LOOKUP_PATTERN.md) | **Critical for private connectivity changes.** Defines cross-subscription subnet and private DNS lookup through the aliased `azurerm.prod` provider, optional ID-versus-name inputs, validation rules, modules already updated, and the rollout checklist for future modules. |
| [AKS Authentication with `kubelogin`](docs/AKS_AUTHENTICATION_KUBELOGIN.md) | Explains local access to Entra-enabled AKS clusters, installation and PATH troubleshooting, Azure CLI kubeconfig conversion, the distinction between authentication and authorization, and AKS RBAC support in the module. |
| [App Service Plan Notes for Function App](docs/APP_SERVICE_PLAN_FUNCTION_APP_NOTES.md) | Short guidance on binding a Function App to the root-created App Service Plan, matching operating systems, selecting an appropriate SKU, and enabling autoscale only on a suitable tier. |

## Using a module

Modules migrated to the current documentation standard provide:

- `README.md` as the canonical usage and maintenance guide;
- executable `examples/basic`, `examples/complete`, and focused scenario directories;
- a generated Terraform requirements, providers, resources, inputs, and outputs reference in the README;
- `tests/unit.tftest.hcl` for mock-provider tests and/or `tests/integration.tftest.hcl` for real-provider tests;
- focused architecture, security, operations, troubleshooting, or migration docs only when needed.

All 44 modules are current reference implementations of the [Terraform Module Documentation Standard](docs/documentation.md). Legacy module indexes, quick references, completion reports, validation reports, monolithic example documents, and ambiguous `live.tftest.hcl` filenames have been retired.

A typical consumer workflow is:

```hcl
module "example" {
  source = "./modules/<module_name>"

  # Required inputs...
}
```

`unit.tftest.hcl` files use mocked providers and do not create cloud resources. Review every `integration.tftest.hcl` provider and `run` block before execution because real-provider tests can access or change Azure. Examples are starting points and must be adapted for the correct subscription, tenant, region, network, naming, tags, security policy, and environment.

## Validation and testing

Run formatting and static validation from the repository root:

```powershell
terraform fmt -check -recursive
terraform init -backend=false -input=false -no-color
terraform validate -no-color
git diff --check
```

Backend-free initialization is suitable for formatting and configuration validation. A real root plan requires the configured AzureRM backend and valid Azure credentials:

```powershell
terraform init -input=false -no-color -reconfigure `
  -backend-config="environments/<environment>/backend.hcl"

terraform plan -input=false -no-color `
  -var-file="<path-to-environment-values.tfvars>"
```

Before running a module test:

1. Read the module's test file and documentation.
2. Determine whether it uses mock or real providers.
3. Confirm credentials, subscription, naming, quotas, and cleanup expectations.
4. Use an isolated non-production subscription for any live integration test.

CI remains the authoritative integration check because it exercises repository wiring, security scanning, changed-module selection, and the configured backend path.

## CI/CD and publishing

### GitHub Actions

`.github/workflows/terraform.yml` provides:

- credential-free formatting, initialization, Terraform validation, and HIGH/CRITICAL Trivy scanning, enabled unless `ENABLE_IAC_SECRET_SCAN` is explicitly `false`;
- preflight checks for required secrets and repository variables;
- backend-aware root and focused module planning when `TF_BACKEND_READY` is `true`;
- changed-module targeting so affected modules and required dependencies are validated;
- an optional apply gated by `ENABLE_GITHUB_APPLY`, backend readiness, credentials, and environment controls;
- semantic release tagging based on conventional commit signals;
- publication to a clean GitHub stage snapshot and synchronization to configured Azure DevOps repositories.

Pull requests do not run publish jobs. Apply must use the binary plan produced by the validated workflow rather than generating a new unreviewed plan.

### Azure DevOps

`azure-pipelines.yml` provides validation, plan, changed-module detection, focused module validation, and an optional gated apply. It:

- reads shared runner settings from the `iac-shared-vars` variable group;
- can skip agent-backed stages when `ADO_AGENT_ENABLED` is `false`;
- uses `environments/$(ENVIRONMENT)/backend.hcl`;
- publishes the binary plan and human-readable plan output;
- uses repository scripts under `scripts/azure-pipelines/`;
- limits the module matrix to the changed modules and related dependencies;
- runs apply only when `ENABLE_ADO_APPLY` is exactly `true`;
- shares release-tag logic with GitHub Actions.

Actual parallelism depends on the Azure DevOps organization's parallel-job entitlement even when the matrix allows multiple concurrent jobs.

## Secrets and configuration

Never commit credentials, backend secrets, generated authentication files, or Terraform state.

GitHub Azure validation uses:

- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

Important GitHub repository variables include:

- `TF_BACKEND_READY`
- `ENABLE_GITHUB_APPLY`
- `ENABLE_IAC_SECRET_SCAN` (set to `false` to skip the Trivy IaC and repository-secret scan; unset or any other value keeps it enabled)
- `STAGE_REPOSITORY`
- `ADO_DEV_REPOSITORY`
- `ADO_PROD_REPOSITORY`

Publishing may additionally require:

- `STAGE_REPO_TOKEN`
- `ADO_REPO_DEV_PAT`
- `ADO_PROD_REPO_PAT`

Missing values should cause their dependent validation, apply, or publish path to skip through workflow conditions; they must not be replaced with hardcoded credentials.

## Contributing

Before opening a pull request:

1. Follow the [Terraform Module Documentation Standard](docs/documentation.md).
2. Check dependencies and examples in [Module Usage and Dependencies](docs/MODULE_USAGE_AND_DEPENDENCIES.md).
3. Apply the [Naming Convention](docs/NAMING_CONVENTION.md) and [Tagging Standard](docs/TAGGING_STANDARD.md).
4. Update the module README, examples, quick reference, and tests as appropriate.
5. Update [Modules Index](docs/MODULES_INDEX.md) and this README if navigation or repository-wide behavior changes.
6. Run formatting, validation, and whitespace checks locally.
7. Review the plan and security results in CI before approval or apply.

For supplemental contributor procedures, see `references/`, including the new-resource, resource-destruction, pre-commit, code-standard, naming, and tagging guides.
