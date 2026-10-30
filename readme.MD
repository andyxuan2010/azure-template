# Azure Terraform Template

This repository is the shared source of truth for reusable Azure Terraform modules, a root-level validation and composition harness, and the CI/CD controls used to validate and distribute the code.

It is primarily a **module development, validation, and distribution repository**. The root Terraform configuration is a harness that can compose selected capabilities or plan one module at a time; it is not intended to represent one permanently deployed environment.

## Security and maintenance baseline

The root harness uses bounded provider versions and a committed dependency lock file. Affected service modules reject TLS below 1.2. SQL deployments require an explicit password or Key Vault secret unless Entra-only authentication is enabled; no shared fallback password is supplied. FortiGate uses SSH key authentication by default. Existing password-only FortiGate callers must supply a key or explicitly opt into password authentication; authentication changes can replace VMs.

The module standards gate defaults to failure on findings. Static CI runs the root mocked harness without Azure credentials. The cross-platform module test runner rejects empty selections, and Pages publishes only staged documentation and assets. See [Code Standards](docs/60-security-governance/code-standards.md) and [Validation Summary](docs/70-validation/validation-summary.md).

## Executive summary

This repository provides a governed catalog of reusable Azure infrastructure components and the engineering controls used to review, validate, and distribute changes. It contains **52 modules** spanning identity and governance, networking, compute and application hosting, data and AI, and operations. Each module has a canonical README, examples, and a classified Terraform test file; focused design documents cover cross-module or service-specific behavior.

The root Terraform configuration is a **composition and validation harness**, not a production deployment. It supports high-level feature selection and exact module-by-module plans. Backend files exist for `dev`, `sandbox`, and `prod`; the `prod` file still contains placeholders and is not ready for use. Changes are intended to move through pull-request review, automated checks, a reviewed plan, and gated apply or publication steps.

| Leadership view | Repository position |
| --- | --- |
| Infrastructure portfolio | 52 reusable modules across five capability areas; see the linked module map below. |
| Deployment model | Terraform modules can be composed through the root harness or consumed by downstream configurations. The repository itself does not declare one always-on target environment. |
| Change controls | GitHub Actions and Azure DevOps pipelines support formatting, validation, security scanning, changed-module selection, plan review, and optional gated apply. Publishing is separated from pull-request validation. |
| Security boundaries | Credentials and state must stay out of source control. Apply should use the same reviewed plan produced by CI. Integration tests may access or change Azure and require an isolated non-production subscription. |
| Governance | Current Azure naming and tagging standards, protected-branch expectations, promotion controls, and shared-runner hygiene are documented. Existing naming patterns still contain known inconsistencies. |
| Operating considerations | Backend readiness, Azure credentials, CI variables, environment approvals, and Azure DevOps parallel-job entitlement determine which deployment stages can run. |

### Portfolio at a glance

| Capability area | Modules | Scope |
| --- | ---: | --- |
| Foundation & Identity | 10 | Resource groups, management groups, subscription vending, policy, role assignments, application registrations, managed identities, and Key Vault. |
| Network & Edge | 13 | Virtual networks, subnets, private DNS and endpoints, routing, firewalls, NAT, load balancing, application gateways, Bastion, and Front Door. |
| Compute & Apps | 13 | AKS, App Service, Functions, Container Apps, Logic Apps, automation, virtual machines, and Static Web Apps. |
| Data & AI | 14 | Storage, SQL services, Cosmos DB, Databricks, Data Factory, messaging, container registry, Azure AI, and OpenAI. |
| Operations & Backup | 2 | Log Analytics and Recovery Services Vault. |

### Delivery and control model

1. Contributors change a module, its examples and tests, or repository wiring through a reviewed pull request.
2. CI runs credential-free static checks and security scanning, then can run backend-aware plans and changed-module validation when the required environment is configured.
3. Optional apply stages are gated by explicit settings and environment controls. Apply should use the binary plan produced by the successful validation workflow.
4. Release and publishing workflows create a clean stage snapshot and can synchronize to configured Azure DevOps repositories.

These are workflow capabilities and guardrails defined in code; their execution depends on repository configuration, credentials, branch protections, approvals, and available CI capacity. This README does not claim that a particular Azure environment is deployed or currently healthy.

### Leadership review path

| Review question | Start here |
| --- | --- |
| What can this repository provision? | [Portfolio map and linked modules](#what-is-in-this-repository) |
| How are modules composed and sequenced? | [Module Usage and Dependencies](docs/20-repository/module-usage-and-dependencies.md) and [Root-Level Module Guide](docs/20-repository/root-level-modules-guide.md) |
| What protects changes and deployments? | [DevSecOps and GitOps Controls](docs/60-security-governance/devsecops-gitops.md), [GitHub Actions pipeline](docs/40-pipelines/github-actions-pipeline.md), and [Shared Runner Hygiene](docs/40-pipelines/shared-runner-hygiene.md) |
| What are the known standards and exceptions? | [Naming Convention](docs/60-security-governance/naming-convention.md), [Tagging Standard](docs/60-security-governance/tagging-standard.md), and [Validation Summary](docs/70-validation/validation-summary.md) |
| Where is detailed implementation guidance? | The [documentation catalog](#documentation-catalog), [Modules Index](docs/20-repository/modules-index.md), and each module README. |

**Review limits:** CI configuration describes checks and deployment gates, but it is not evidence of a successful deployment. Read each module's prerequisites and limitations and review a fresh plan before any apply. Live integration tests and destroy workflows can change cloud resources. Current Azure engineering requirements are defined in the Code Standards; review security behavior changes before upgrading modules.

## Contents

- [Executive summary](#executive-summary)
- [Portfolio at a glance](#portfolio-at-a-glance)
- [Delivery and control model](#delivery-and-control-model)
- [Leadership review path](#leadership-review-path)
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
| `environments/` | Backend configuration for `dev` and `sandbox`; `prod` is a placeholder and must be completed and approved before use. |
| `docs/` | Repository-wide architecture, standards, deployment and operations guidance, pipeline controls, and validation documentation. |
| `docs-manifest.json` | Generated Markdown-document inventory used by GitHub workflows and documentation publication. |
| `templates/` | Reusable Azure DevOps templates, including shared-runner hygiene controls. |
| `scripts/` | Pipeline, validation, release, and repository synchronization helpers. |
| `.github/workflows/terraform.yml` | GitHub Actions validation, optional apply, release tagging, and publishing workflow. |
| `azure-pipelines.yml` | Azure DevOps validation, plan, optional apply, and module-targeting pipeline. |
| `references/` | Supplemental PDFs and a Visio pipeline diagram; current Markdown guides are the preferred source where subjects overlap. |

The repository currently contains 52 module directories. Use the [Modules Index](docs/20-repository/modules-index.md) for direct links to each canonical README, executable examples, and classified Terraform tests.

### Azure Terraform module map

**52 reusable modules · five capability areas.** Select any module to open its README.

| Capability area | Modules | Module READMEs |
| --- | ---: | --- |
| 🟦 Foundation & Identity | 10 | [rg](modules/rg/README.md) · [managementgroups](modules/managementgroups/README.md) · [subscription_vending](modules/subscription_vending/README.md) · [policy](modules/policy/README.md) · [customrole](modules/customrole/README.md) · [roleassignments](modules/roleassignments/README.md) · [appregistration](modules/appregistration/README.md) · [enterpriseapplication](modules/enterpriseapplication/README.md) · [managedidentity](modules/managedidentity/README.md) · [keyvault](modules/keyvault/README.md) |
| 🟩 Network & Edge | 13 | [applicationgateway](modules/applicationgateway/README.md) · [bastion](modules/bastion/README.md) · [firewall](modules/firewall/README.md) · [fortigate](modules/fortigate/README.md) · [frontdoor](modules/frontdoor/README.md) · [loadbalancer](modules/loadbalancer/README.md) · [nat_gateway](modules/nat_gateway/README.md) · [nsg](modules/nsg/README.md) · [private_dns](modules/private_dns/README.md) · [private_endpoint](modules/private_endpoint/README.md) · [route_table](modules/route_table/README.md) · [subnet](modules/subnet/README.md) · [vnet](modules/vnet/README.md) |
| 🟪 Compute & Apps | 13 | [aks](modules/aks/README.md) · [appservice](modules/appservice/README.md) · [appserviceplan](modules/appserviceplan/README.md) · [automationaccount](modules/automationaccount/README.md) · [availabilityset](modules/availabilityset/README.md) · [containerapp](modules/containerapp/README.md) · [functionapp](modules/functionapp/README.md) · [functionappflex](modules/functionappflex/README.md) · [linuxvm](modules/linuxvm/README.md) · [logicapp](modules/logicapp/README.md) · [sqlvm](modules/sqlvm/README.md) · [staticwebapp](modules/staticwebapp/README.md) · [winvm](modules/winvm/README.md) |
| 🟨 Data & AI | 14 | [acr](modules/acr/README.md) · [adf](modules/adf/README.md) · [azure_ai_search](modules/azure_ai_search/README.md) · [azure_ai_service](modules/azure_ai_service/README.md) · [cosmosdb](modules/cosmosdb/README.md) · [databricks](modules/databricks/README.md) · [eventgridsystemtopic](modules/eventgridsystemtopic/README.md) · [eventhub](modules/eventhub/README.md) · [openai](modules/openai/README.md) · [servicebus](modules/servicebus/README.md) · [sqldb](modules/sqldb/README.md) · [sqlmi](modules/sqlmi/README.md) · [sqlmi_db](modules/sqlmi_db/README.md) · [storageaccount](modules/storageaccount/README.md) |
| 🟧 Operations & Backup | 2 | [loganalytics](modules/loganalytics/README.md) · [recovery_services_vault](modules/recovery_services_vault/README.md) |

## Start here

Choose the path that matches what you are trying to do:

| If you want to... | Read first |
| --- | --- |
| Understand the repo as a new contributor | [Repository Map and Glossary](docs/00-start-here/repo-map.md) |
| Make your first safe change | [First Change Walkthrough](docs/00-start-here/first-change.md) |
| Find guidance for your role | [Stakeholder Reading Guide](docs/00-start-here/stakeholder-guide.md) |
| Understand environment and deployment flow | [Environment and Deployment Lifecycle](docs/30-deployment/environment-lifecycle.md) |
| Operate the repository and its pipelines | [Operations Handbook](docs/50-operations/operations-handbook.md) |
| Understand cost planning | [Cost and Budget Guide](docs/50-operations/cost-and-budget-guide.md) |
| Find a module and its examples | [Modules Index](docs/20-repository/modules-index.md) |
| Understand what a module needs and which order to deploy dependencies | [Module Usage and Dependencies](docs/20-repository/module-usage-and-dependencies.md) |
| Understand the repository architecture and backend readiness | [Repository Architecture](docs/10-architecture/repository-architecture.md) |
| Enable or plan modules from the repository root | [Root-Level Module Guide](docs/20-repository/root-level-modules-guide.md) |
| Contribute or change a module | [Terraform Module Documentation Standard](docs/20-repository/module-documentation-standard.md) |
| Understand the delivery and security controls | [DevSecOps and GitOps Controls](docs/60-security-governance/devsecops-gitops.md) |
| Apply the repository naming and tagging rules | [Naming Convention](docs/60-security-governance/naming-convention.md) and [Tagging Standard](docs/60-security-governance/tagging-standard.md) |
| Review current validation coverage and known gaps | [Validation Summary](docs/70-validation/validation-summary.md) |

For a first visit, the recommended reading order is:

1. Read this README for the repository model and safety boundaries.
2. Use the [Repository Map and Glossary](docs/00-start-here/repo-map.md) to learn the folder layout and terms.
3. Follow the [First Change Walkthrough](docs/00-start-here/first-change.md) before editing shared Terraform.
4. Select a module in the [Modules Index](docs/20-repository/modules-index.md) and check its prerequisites in [Module Usage and Dependencies](docs/20-repository/module-usage-and-dependencies.md).
5. Read the module's own `README.md` and executable `examples/` scenarios.
6. Review [Naming Convention](docs/60-security-governance/naming-convention.md), [Tagging Standard](docs/60-security-governance/tagging-standard.md), and any relevant focused design note.
7. Validate through the root harness before proposing the change.

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

Prefer connecting modules through Terraform outputs rather than copying resource IDs. Deploy shared foundations first, platform or hosting resources second, and dependent workloads last. The detailed dependency chains are maintained in [Module Usage and Dependencies](docs/20-repository/module-usage-and-dependencies.md).

## Standards and required controls

These documents describe repository-wide behavior and should be treated as required guidance for new work.

### Delivery and security

[DevSecOps and GitOps Controls](docs/60-security-governance/devsecops-gitops.md) defines pull-request validation, protected-branch expectations, security scanning, environment approvals, immutable Terraform plan application, secret handling, and promotion. Changes should be reviewed and the exact plan produced by CI should be the plan applied.

### Naming

[Resource Naming Convention](docs/60-security-governance/naming-convention.md) defines the target naming shape:

```text
<resource-type>-<workload>-<region-code>-<environment>-<instance>
```

Use deterministic lowercase names where Azure permits them. The guide also inventories existing module patterns and known gaps, because the repository has not yet reached one universal convention.

### Tagging

[Tagging Standard](docs/60-security-governance/tagging-standard.md) makes the root composition the owner of enterprise ARM tag normalization. Child modules receive canonical resource-group tags through `inherited_resource_group_tags`, merge resource-specific tags over that baseline, and avoid redefining reserved `Environment` or `Workload` behavior. Microsoft Entra object tags are metadata sets and must not be treated as Azure Resource Manager tags.

### Shared runners

[Shared Self-Hosted Runner Hygiene Standard](docs/40-pipelines/shared-runner-hygiene.md) treats a long-lived runner as a stateful, partially untrusted environment. The minimum controls are pre- and post-job Git authentication cleanup, non-persistent checkout credentials, job-scoped temporary/configuration directories, deterministic tool setup, and cleanup that runs even after failure. Use [`templates/shared-runner-hygiene.yml`](templates/shared-runner-hygiene.yml) as the implementation starting point.

## Documentation catalog

This catalog summarizes the repository-wide guides under `docs/` and supplemental reference files; the linked module map appears above. Critical repository-wide documents have expanded summaries; focused notes are summarized briefly. The module documentation section below explains how module READMEs, example guides, and focused design notes are organized.

### Core repository guides

| Document | Scope and when to use it |
| --- | --- |
| [Module Usage and Dependencies](docs/20-repository/module-usage-and-dependencies.md) | **Critical.** Explains how to consume modules, the dependency matrix, common deployment chains, module-by-module use cases, example entry points, and testing cautions. Consult it before composing an environment or changing module wiring. |
| [Modules Index](docs/20-repository/modules-index.md) | The complete navigation map for module READMEs, executable examples, and classified Terraform tests. |
| [Repository Architecture](docs/10-architecture/repository-architecture.md) | Describes the module catalog, root harness, dependency layers, backend readiness, and delivery boundaries. |
| [Root-Level Module Guide](docs/20-repository/root-level-modules-guide.md) | **Critical for root plans and CI.** Describes root wiring, module order, `features`, `module_plan_enabled`, pass-through inputs, focused planning, and CI matrix behavior. |
| [Terraform Module Documentation Standard](docs/20-repository/module-documentation-standard.md) | Canonical module folder structure, README requirements, executable example rules, generated reference ownership, test safety classifications, documentation style, migration guidance, and definition of done. |
| [Validation Summary](docs/70-validation/validation-summary.md) | Inventory of canonical documentation, examples, and test classification for all modules. CI remains the source of current commit validation results. |
| [Validation Summary (PDF)](docs/80-reference/VALIDATION_SUMMARY_legacy.pdf) | **Historical report from an earlier hardening pass.** It references retired report files and does not reflect today's full module inventory. Use the Markdown [Validation Summary](docs/70-validation/validation-summary.md) for current documentation, examples, and test classification. |

### Governance, security, and operations

| Document | Scope and when to use it |
| --- | --- |
| [DevSecOps and GitOps Controls](docs/60-security-governance/devsecops-gitops.md) | **Critical.** Defines required branch protections, pull-request checks, plan/apply safety, local validation, secrets handling, approvals, and promotion expectations. |
| [Naming Convention](docs/60-security-governance/naming-convention.md) | **Required for new resources.** Defines the target naming model, records current patterns, maps environment suffixes, and calls out inconsistencies that should not be copied into new work. |
| [Tagging Standard](docs/60-security-governance/tagging-standard.md) | **Required for ARM-tagged modules.** Defines root ownership, standard inheritance inputs, merge precedence, Azure Policy interaction, Entra exceptions, and the validation checklist. |
| [Azure DevOps Terraform Pipeline](docs/40-pipelines/azure-devops-pipeline.md) | Current YAML triggers, stages, variables, plan artifacts, apply gates, and operational dependencies. |
| [Entra Identity and Azure RBAC](docs/60-security-governance/entra-identity-and-rbac.md) | Separates application objects, service principals, workload federation, Entra consent, custom roles, and ARM assignments. |
| [Terraform State and Recovery](docs/50-operations/terraform-state-and-recovery.md) | Backend readiness, state handling, recovery workflow, locking, and safe deletion guidance. |
| [Shared Runner Hygiene Standard](docs/40-pipelines/shared-runner-hygiene.md) | **Critical for self-hosted agents.** Defines isolation and cleanup controls that prevent credential leakage and cross-job state contamination. |
| [Shared Runner Git `extraheader` Issue](docs/40-pipelines/git-extraheader-runner-issue.md) | Troubleshooting record for Azure DevOps checkout failures caused by stale, URL-scoped Git authentication headers. It explains why cleanup must happen before checkout and remove all matching `extraheader` keys. |
| [Code Standards](docs/60-security-governance/code-standards.md) | Current Azure Terraform engineering, credential, validation, and publication requirements. |
| [Contributor Naming Convention](docs/60-security-governance/contributor-naming-convention.md) | Historical mixed-cloud resource naming proposal with AWS and Azure examples. Use the current [Resource Naming Convention](docs/60-security-governance/naming-convention.md) for Azure work. |
| [Pre-commit Setup](docs/60-security-governance/pre-commit-setup.md) | Setup steps for repository pre-commit hooks. |
| [Pre-commit Hooks](docs/60-security-governance/pre-commit.md) | Hook configuration and expected local checks. |
| [Legacy AWS Tagging Convention](docs/60-security-governance/tagging-convention.md) | Historical AWS tagging reference retained for context. Use the Azure [Tagging Standard](docs/60-security-governance/tagging-standard.md) for current work. |

### Deployment, operations, and pipelines

| Document | Scope and when to use it |
| --- | --- |
| [Create or Extend a Terraform Module](docs/30-deployment/create-a-new-resource.md) | Current contributor workflow for assessing, implementing, documenting, validating, and wiring a reusable module. |
| [Remove a Terraform-Managed Resource](docs/50-operations/destroy-a-resource.md) | Safe removal through the owning root state, fresh reviewed plan, and approved apply workflow. |
| [GitHub Actions Terraform Pipeline](docs/40-pipelines/github-actions-pipeline.md) | Job flow, configuration, security controls, and troubleshooting for GitHub Actions. |

### Architecture and service-specific notes

| Document | Scope and when to use it |
| --- | --- |
| [Private Endpoint and Private DNS Lookup Pattern](docs/10-architecture/private-endpoint-private-dns.md) | **Critical for private connectivity changes.** Defines cross-subscription subnet and private DNS lookup through the aliased `azurerm.prod` provider, optional ID-versus-name inputs, validation rules, modules already updated, and the rollout checklist for future modules. |
| [AKS Authentication with `kubelogin`](docs/30-deployment/aks-authentication-kubelogin.md) | Explains local access to Entra-enabled AKS clusters, installation and PATH troubleshooting, Azure CLI kubeconfig conversion, the distinction between authentication and authorization, and AKS RBAC support in the module. |
| [App Service Plan Notes for Function App](docs/30-deployment/app-service-plan-function-app-notes.md) | Short guidance on binding a Function App to the root-created App Service Plan, matching operating systems, selecting an appropriate SKU, and enabling autoscale only on a suitable tier. |

### Module-level documentation and examples

42 modules include focused design notes under `modules/<name>/docs/`, for example [ADF](modules/adf/docs/architecture.md), [AKS](modules/aks/docs/architecture.md), [Application Gateway](modules/applicationgateway/docs/architecture.md), [App Service](modules/appservice/docs/architecture.md), and [Container Apps](modules/containerapp/docs/architecture.md); the ten simpler modules (`acr`, `appregistration`, `appserviceplan`, `availabilityset`, `customrole`, `enterpriseapplication`, `loadbalancer`, `loganalytics`, `managedidentity`, `nsg`) are fully described by their README. The 52 linked module READMEs are the canonical source for each module's purpose, inputs, outputs, prerequisites, security behavior, limitations, and usage. Each module also provides executable basic and complete examples, focused scenarios where applicable, and a unit or integration Terraform test. The [Modules Index](docs/20-repository/modules-index.md) links to module entry points and examples; the [Validation Summary](docs/70-validation/validation-summary.md) records each module's focused docs, example scenarios, and test classification. Architecture, authentication, operations, pipeline, and idempotency notes live beside the module they describe, keeping implementation-specific guidance with its module. The [repository architecture overview](docs/10-architecture/repository-architecture.md), [Azure DevOps guide](docs/40-pipelines/azure-devops-pipeline.md), [state recovery guide](docs/50-operations/terraform-state-and-recovery.md), and [Entra/RBAC guide](docs/60-security-governance/entra-identity-and-rbac.md) cover cross-cutting concerns.

### Supplemental reference artifacts

| Artifact | Scope and status |
| --- | --- |
| [Repository setup snapshot (PDF)](readme.pdf) | Historical layout and setup notes, including example backend and pre-commit configuration. Do not copy embedded environment values; use the current files under `environments/`, `docs/`, and this README instead. |
| [Naming convention proposal (PDF)](references/naming-convention.pdf) | Legacy proposal focused primarily on AWS naming. The current Azure standard is [Resource Naming Convention](docs/60-security-governance/naming-convention.md). |
| [Pre-commit quick reference (PDF)](references/pre-commit.pdf) | Short historical hook note. Use [Pre-commit Setup](docs/60-security-governance/pre-commit-setup.md) and [Pre-commit Hooks](docs/60-security-governance/pre-commit.md) for current guidance. |
| [Azure DevOps CI/CD architecture diagram (Visio)](references/azure-devops-ci-cd-architecture.vsdx) | Supplemental pipeline architecture diagram. Current job and control descriptions are in [GitHub Actions Terraform Pipeline](docs/40-pipelines/github-actions-pipeline.md) and `azure-pipelines.yml`. |

## Using a module

Modules migrated to the current documentation standard provide:

- `README.md` as the canonical usage and maintenance guide;
- executable `examples/basic`, `examples/complete`, and focused scenario directories;
- a generated Terraform requirements, providers, resources, inputs, and outputs reference in the README;
- `tests/unit.tftest.hcl` for mock-provider tests and/or `tests/integration.tftest.hcl` for real-provider tests;
- focused architecture, security, operations, troubleshooting, or migration docs only when needed.

All 52 modules are current reference implementations of the [Terraform Module Documentation Standard](docs/20-repository/module-documentation-standard.md). Legacy module indexes, quick references, completion reports, validation reports, monolithic example documents, and ambiguous `live.tftest.hcl` filenames have been retired.

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

See [GitHub Actions Terraform Pipeline](docs/40-pipelines/github-actions-pipeline.md) for the complete job flow, configuration reference, security controls, and troubleshooting guidance.

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
- `ADO_DEV_REPO_PAT`
- `ADO_PROD_REPO_PAT`

Missing values should cause their dependent validation, apply, or publish path to skip through workflow conditions; they must not be replaced with hardcoded credentials.

## Contributing

Before opening a pull request:

1. Follow the [Terraform Module Documentation Standard](docs/20-repository/module-documentation-standard.md).
2. Check dependencies and examples in [Module Usage and Dependencies](docs/20-repository/module-usage-and-dependencies.md).
3. Apply the [Naming Convention](docs/60-security-governance/naming-convention.md) and [Tagging Standard](docs/60-security-governance/tagging-standard.md).
4. Update the module README, executable examples, tests, and focused module docs as appropriate.
5. Update [Modules Index](docs/20-repository/modules-index.md) and this README if navigation or repository-wide behavior changes.
6. Run formatting, validation, and whitespace checks locally.
7. Review the plan and security results in CI before approval or apply.

For supplemental contributor procedures, see the categorized guides under `docs/30-deployment/`, `docs/50-operations/`, and `docs/60-security-governance/`.
