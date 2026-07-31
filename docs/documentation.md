# Terraform Module Documentation Standard

| Attribute | Value |
| --- | --- |
| Status | Active |
| Applies to | Every reusable module under `modules/` |
| Canonical document | `docs/documentation.md` |
| Reference implementations | `modules/acr`, `modules/adf`, `modules/aks`, `modules/applicationgateway`, `modules/appregistration`, `modules/appservice`, `modules/appserviceplan`, `modules/automationaccount`, `modules/availabilityset`, `modules/azure_ai_service`, `modules/azure_ai_search`, `modules/containerapp`, `modules/cosmosdb`, `modules/databricks`, `modules/enterpriseapplication`, `modules/eventhub`, `modules/firewall`, `modules/fortigate`, `modules/functionapp`, `modules/keyvault`, `modules/linuxvm`, `modules/loadbalancer`, `modules/loganalytics`, `modules/logicapp`, `modules/managedidentity`, `modules/managementgroups`, `modules/nsg`, and `modules/openai` |

This guideline defines how Terraform module files, documentation, executable examples, tests, diagrams, and generated reference content must be organized in this repository.

The goals are to make every module:

- easy to discover and understand;
- safe to evaluate before deployment;
- consistent across teams and services;
- testable from executable examples;
- resistant to documentation drift;
- suitable for future publication through a private module registry.

This repository is a monorepo, so the examples use local module source paths to validate the current checkout. If a module is later published independently, its consumer examples must use the published source address and a pinned version.

## Requirement Language

The terms in this document have the following meanings:

- **MUST**: required for a module to conform to the standard.
- **SHOULD**: recommended unless there is a documented reason not to follow it.
- **MAY**: optional and dependent on module complexity.

## Design Principles

### One canonical entry point

`README.md` is the authoritative entry point for a module. Users should not need to open an index, quick reference, completion report, or implementation summary to understand how to use it.

### Document durable behavior

Module documentation describes what the module does now:

- resources and behavior;
- prerequisites and dependencies;
- security and operational characteristics;
- inputs, outputs, and provider requirements;
- examples, tests, and limitations.

Pull-request commentary, temporary validation results, enhancement summaries, and “complete” status belong in Git history, CI artifacts, issues, or release notes.

### Prefer executable examples

An HCL block inside Markdown can become stale without detection. Important examples must be Terraform configurations under `examples/` so formatting and validation can run automatically.

### Generate mechanical reference content

Provider requirements, resources, inputs, and outputs must be generated from Terraform source. Human-authored documentation should explain intent, interactions, risks, and operating decisions.

### Keep the module tree shallow

Modules should accept dependency IDs and values from callers and expose useful outputs for composition. Avoid deeply nested module trees when the caller can compose independent modules directly.

## Standard Module Structure

```text
modules/<module-name>/
├── README.md                         # Required canonical guide
├── main.tf                           # Primary resources and module calls
├── variables.tf                      # Input declarations
├── outputs.tf                        # Output declarations
├── terraform.tf                      # Terraform and provider requirements
├── locals.tf                         # Optional local-value logic
├── data.tf                           # Optional data sources
├── <capability>.tf                   # Optional logical resource grouping
│
├── examples/
│   ├── basic/
│   │   ├── README.md
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── complete/
│   │   ├── README.md
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── <scenario-name>/
│       ├── README.md
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── tests/
│   ├── unit.tftest.hcl
│   ├── integration.tftest.hcl
│   └── fixtures/                     # Optional test-only configurations
│
└── docs/                             # Optional deep-dive documentation
    ├── architecture.md
    ├── security.md
    ├── operations.md
    ├── troubleshooting.md
    ├── migration.md
    ├── images/
    │   ├── architecture.svg
    │   └── architecture-source.drawio
    └── decisions/
        └── ADR-0001-<decision-name>.md
```

Do not add empty directories or placeholder documents. Add an optional file only when it contains durable, module-specific information.

## Required and Conditional Artifacts

| Artifact | Requirement | Purpose |
| --- | --- | --- |
| `README.md` | MUST | Canonical consumer and maintainer guide. |
| `main.tf` | MUST | Primary module resources and child-module calls. |
| `variables.tf` | MUST | Typed and documented module inputs. |
| `outputs.tf` | MUST | Documented values exposed to callers. |
| `terraform.tf` | MUST | Terraform version and provider requirements. |
| `examples/basic/` | MUST | Smallest realistic executable composition. |
| `tests/unit.tftest.hcl` or `tests/integration.tftest.hcl` | MUST | Automated behavior and validation coverage. |
| `examples/complete/` | SHOULD for complex modules | Production-oriented composition of major features. |
| `examples/<scenario>/` | MAY | Materially different operating model. |
| `docs/architecture.md` | SHOULD for complex modules | Resource relationships, boundaries, and lifecycle. |
| Other files under `docs/` | MAY | Durable security, operations, migration, or troubleshooting guidance. |
| Module-local `LICENSE` | Normally MUST NOT in this monorepo | Licensing belongs at repository level unless a module is distributed separately. |

## Canonical README Standard

Every module README MUST begin with the module name and a concise statement of what it provisions. Avoid generic introductions such as “This module is used to create resources.”

Use the following section order.

### 1. Title and purpose

```markdown
# Azure <Service or Capability>

Provisions <resource/capability> with <important behavior and controls>.
```

The opening paragraph must identify:

- the abstraction the module provides;
- the primary Azure service or capability;
- major security, networking, or operational characteristics.

### 2. Features

Summarize supported capabilities. Describe behavior, not every variable.

Good:

```markdown
- Supports private endpoints and private DNS association.
- Supports system-assigned and user-assigned managed identities.
```

Avoid:

```markdown
- Has an `enable_private_endpoint` variable.
- Has an `identity_type` variable.
```

### 3. Resources Created

Identify resources that are:

- always created;
- conditionally created;
- created indirectly by Azure;
- looked up but not managed.

Call out resources with separate cost, lifecycle, or permission implications.

### 4. Prerequisites and Dependencies

Document everything that must already exist, including:

- resource groups;
- virtual networks and subnets;
- private DNS zones;
- managed identities and Key Vault keys;
- monitoring destinations;
- Microsoft Entra groups;
- subscription features, quotas, permissions, and provider aliases.

Prefer accepting dependency outputs from other modules instead of copying IDs into static `.tfvars` files.

### 5. Provider Configuration

Document:

- required providers;
- required configuration aliases;
- which subscription or tenant each alias represents;
- permissions required by the Terraform execution identity.

Reusable modules MUST declare provider requirements but MUST NOT contain `provider` configuration blocks. Provider configuration belongs to the calling root module.

### 6. Basic Usage

Include one concise HCL example showing the normal secure path. It should link to `examples/basic/` for the complete executable configuration.

Do not copy the entire complete example into the README.

### 7. Important Behavior and Secure Defaults

Explain:

- default security posture;
- destructive or replacement-sensitive inputs;
- mutually exclusive settings;
- SKU or region restrictions;
- behavior that may be changed by Azure Policy;
- cost-sensitive features;
- conditions that can cause plan-time unknown values or recurring drift.

Defaults must not be described as secure unless the Terraform implementation and tests demonstrate that claim.

### 8. Networking and Private Connectivity

Include this section when the module has network behavior. Cover:

- public network access defaults;
- subnet requirements and delegation;
- private endpoint behavior;
- private DNS zone requirements;
- cross-subscription lookup behavior;
- routing, firewall, NSG, outbound, and name-resolution dependencies.

### 9. Identity and RBAC

Include this section when the module creates or consumes identities. Cover:

- identity type and ownership;
- role assignments created by the module;
- expected scopes;
- Microsoft Entra lookup behavior;
- control-plane versus data-plane permissions;
- least-privilege recommendations.

Prefer immutable object IDs over display names when duplicate names are possible.

### 10. Naming and Tagging

Describe:

- whether names are explicit or generated;
- the inputs used to construct names;
- Azure naming restrictions and global uniqueness;
- tag inheritance and override behavior;
- resources that do not support ARM tags;
- Microsoft Entra metadata tags when applicable.

Link to the repository [naming convention](./NAMING_CONVENTION.md) and [tagging standard](./TAGGING_STANDARD.md).

### 11. Testing

State:

- the test filename;
- whether providers are mocked or real;
- whether authentication and private network access are required;
- whether tests run `plan` or `apply`;
- whether resources can be created;
- likely costs and cleanup requirements;
- the exact command to run.

### 12. Known Limitations

Document unsupported configurations, provider limitations, region constraints, migration concerns, or operational gaps. Do not hide known limitations in validation reports or issue comments.

### 13. Terraform Reference

The final README section MUST be generated with `terraform-docs`:

```markdown
## Terraform Reference

The content below is generated from the module source. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
```

The generated reference contains requirements, providers, child modules, resources, inputs, and outputs. Do not manually duplicate these complete tables elsewhere in the README.

## Generated Documentation

The repository `.terraform-docs.yml` is the shared source of formatting and section behavior.

Generate or refresh one module:

```powershell
terraform-docs -c .terraform-docs.yml modules/<module-name>
```

Check for drift without changing the README:

```powershell
terraform-docs -c .terraform-docs.yml --output-check modules/<module-name>
```

The descriptions in the generated tables come from Terraform source:

- every variable MUST have a meaningful `description` and explicit `type`;
- every output MUST have a meaningful `description`;
- secret outputs MUST set `sensitive = true`;
- provider and Terraform constraints MUST be declared in `terraform.tf`;
- major provider versions SHOULD be bounded to prevent an unreviewed breaking upgrade.

Generated content between the `BEGIN_TF_DOCS` and `END_TF_DOCS` markers MUST NOT be edited manually.

## Executable Example Standard

Each example is an independent Terraform root configuration.

### Common requirements

Every example MUST:

- contain valid, formatted Terraform;
- initialize with `terraform init -backend=false`;
- pass `terraform validate`;
- declare its required providers;
- configure provider aliases required by the module;
- use variables for environment-specific dependency IDs;
- avoid credentials, secrets, real tenant IDs, and organization-specific object IDs;
- use reserved documentation IP ranges when an IP example is necessary;
- include a README explaining purpose, prerequisites, commands, costs, and risks;
- expose only outputs that help a user verify the scenario.

Examples MUST NOT create real dependencies merely to make the module example self-contained when those dependencies have substantial cost or complexity. Accept their IDs as variables and describe where they come from.

### Module source

For executable examples in this monorepo, use:

```hcl
module "example" {
  source = "../.."
}
```

This validates the module in the current checkout. Documentation copied into a consuming repository must use that consumer's approved source and version. If the module is published to a registry, published examples should use the registry source and a version constraint.

### Basic example

`examples/basic/` MUST demonstrate:

- the minimum practical inputs;
- the normal secure configuration;
- the lowest reasonable cost and complexity;
- no optional feature that obscures the primary use case.

If the smallest configuration is not operationally complete—for example, public access is disabled but no private endpoint is created—the example README must state what remains required.

### Complete example

`examples/complete/` SHOULD demonstrate a production-oriented composition, including applicable:

- private networking;
- managed identity and least-privilege RBAC;
- diagnostics;
- resiliency and zones;
- secure authentication;
- maintenance or lifecycle controls;
- tags required by the organization.

“Complete” does not mean every variable. It means a coherent operating model.

### Scenario examples

Use lowercase kebab-case names:

```text
examples/customer-managed-key/
examples/private-endpoint/
examples/self-hosted-integration-runtime/
examples/public-api-nonproduction/
```

Create a scenario only when it represents a materially different configuration. Do not create one example per input variable.

## Test Structure and Safety

Terraform loads `.tftest.hcl` files from the module root or the default `tests/` directory.

Use these repository classifications:

| Filename | Provider behavior | Expected impact |
| --- | --- | --- |
| `tests/unit.tftest.hcl` | Mocked providers | No cloud authentication and no cloud resources. |
| `tests/integration.tftest.hcl` | Real providers or cloud lookups | Authentication required; may be plan-only or may create resources. |

Mock-provider tests require Terraform 1.7 or newer. If a module uses them, its `required_version` must permit a compatible Terraform version.

Every integration test MUST begin with a comment stating whether its run blocks use `plan` or `apply`. If any run applies resources, the module README and test file MUST document:

- subscription and permission expectations;
- network access requirements;
- billable resources;
- expected duration;
- cleanup behavior;
- restrictions against production execution.

Avoid `live.tftest.hcl` because it does not distinguish plan-only real-provider tests from tests that deploy infrastructure.

## Optional Module Documentation

Use module-local `docs/` only for information too detailed for the README.

| File | Use |
| --- | --- |
| `architecture.md` | Resource topology, trust boundaries, flows, lifecycle, and design rationale. |
| `security.md` | Identities, RBAC, secrets, encryption, exposure, and security assumptions. |
| `operations.md` | Monitoring, alerts, backup, recovery, scaling, patching, and day-two procedures. |
| `troubleshooting.md` | Symptoms, likely causes, diagnostics, and verified resolutions. |
| `migration.md` | Breaking changes, imports, moved blocks, state operations, and upgrade steps. |
| `decisions/ADR-*.md` | A durable architectural decision, alternatives, and consequences. |

Every optional document MUST:

- be linked from the module README;
- state its purpose near the top;
- remain focused on the module;
- use relative links for repository content;
- avoid copying generated inputs and outputs;
- be updated in the same pull request as the behavior it describes.

### Diagrams and images

Store visual assets under `docs/images/`.

- Prefer SVG for architecture diagrams.
- Keep the editable source, such as `.drawio`, beside the exported image.
- Use descriptive lowercase kebab-case filenames.
- Include useful alt text in Markdown.
- Do not use an image as the only explanation of a critical relationship.
- Do not maintain PDF exports as a parallel canonical source.

## Naming and Style

### Filenames

- Use `README.md` exactly for entry points.
- Use lowercase kebab-case for directories and specialized documents.
- Use the standard Terraform filenames `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tf`, `locals.tf`, and `data.tf`.
- Split large configurations by capability, such as `networking.tf` or `diagnostics.tf`.
- Do not use filenames such as `README_UPDATED.md`, `feature.md`, `change.md`, or `final.md`.

### Writing style

- Write for a module consumer first and a maintainer second.
- Use plain, direct language and present tense.
- Define acronyms on first use.
- Use exact Terraform names in backticks.
- Prefer short paragraphs, tables for mappings, and lists for checks.
- Use one H1 heading per document.
- Use sentence-style headings consistently.
- State facts that can be verified from the code.
- Avoid promises such as “fully secure,” “production ready,” or “complete” without explicit criteria.
- Use placeholders such as `<subscription-id>` only in prose snippets; executable examples should use typed variables.
- Never include credentials, tokens, private endpoints, real tenant IDs, or sensitive organization data.

## Content Ownership

| Information | Canonical source |
| --- | --- |
| Module purpose, behavior, and risks | Module `README.md` |
| Input and output schema | `variables.tf`, `outputs.tf`, and generated README reference |
| Executable usage | `examples/` |
| Test behavior | `tests/` and README Testing section |
| Deep architecture and operations | Module `docs/` |
| Cross-module dependencies | Root `docs/MODULE_USAGE_AND_DEPENDENCIES.md` |
| Module navigation | Root `docs/MODULES_INDEX.md` |
| Validation execution evidence | CI logs and artifacts |
| Change history | Git commits, pull requests, release notes, and issues |
| Enterprise naming and tagging | Root naming and tagging standards |

Do not maintain the same information manually in multiple locations.

## Documents to Retire During Migration

| Legacy artifact | Migration treatment |
| --- | --- |
| `EXAMPLES.md` | Convert durable scenarios into executable `examples/`, then remove. |
| `QUICK_REFERENCE.md` | Merge operational guidance into README; use generated reference for schema. |
| `INDEX.md` | Replace with README navigation and the root Modules Index. |
| `MODULE_COMPLETE.md` | Remove after preserving any durable behavior description. |
| `VALIDATION_REPORT.md` | Move current status to CI evidence or the repository validation summary. |
| `README_UPDATED.md` | Merge into `README.md`, then remove. |
| `ENHANCEMENT_SUMMARY.md` | Move durable design decisions to README, architecture, or an ADR. |
| `change.md` | Use Git and release notes unless modules are independently versioned. |
| `feature.md` | Rename for its durable purpose or merge into a canonical document. |
| Generated PDFs | Publish as release artifacts only when required. |

Remove a legacy file only after confirming that its unique, still-correct information has a canonical destination. Deleted files remain recoverable through Git history.

## Documentation Workflow

When adding or changing a module:

1. Update Terraform behavior and descriptions.
2. Update the README's human-authored sections.
3. Add or update executable examples.
4. Add or update tests and classify their safety.
5. Update specialized documentation if architecture or operations changed.
6. Regenerate the Terraform reference.
7. Validate the module through an executable caller.
8. Validate every changed example.
9. Run module tests appropriate to the change.
10. Check Markdown links and repository navigation.
11. Update the root Modules Index and dependency guide when needed.
12. Submit code, tests, and documentation in the same pull request.

Documentation changes must not be deferred to an unspecified later task when the corresponding behavior has already changed.

## Validation Commands

From the repository root:

```powershell
terraform fmt -check -recursive
terraform-docs -c .terraform-docs.yml --output-check modules/<module-name>
git diff --check
```

Validate a basic example:

```powershell
terraform -chdir="modules/<module-name>/examples/basic" init -backend=false -input=false
terraform -chdir="modules/<module-name>/examples/basic" validate
```

Run module tests:

```powershell
terraform -chdir="modules/<module-name>" test
```

Run a root-harness plan when provider aliases, caller wiring, cross-module dependencies, or root defaults are involved.

CI SHOULD enforce:

- required module files and README sections;
- `terraform fmt -check`;
- example initialization and validation;
- generated-reference freshness;
- test execution according to safety classification;
- broken-link detection;
- absence of prohibited duplicate documentation.

## Pull-Request Review Checklist

### Structure

- [ ] The module follows the standard directory structure.
- [ ] `README.md` is the canonical entry point.
- [ ] Optional documents have a clear, durable purpose.
- [ ] No new duplicate index, quick reference, or completion report was added.

### README

- [ ] Purpose, features, resources, dependencies, providers, and limitations are accurate.
- [ ] Networking, identity, RBAC, naming, tagging, security, and costs are covered when applicable.
- [ ] Basic usage is concise and links to an executable example.
- [ ] Test authentication and resource impact are explicit.

### Source reference

- [ ] Every variable has a type and meaningful description.
- [ ] Every output has a meaningful description.
- [ ] Sensitive outputs are marked sensitive.
- [ ] Provider and Terraform constraints are intentional.
- [ ] `terraform-docs` output is current.

### Examples and tests

- [ ] The basic example initializes and validates.
- [ ] Complete and scenario examples validate when present.
- [ ] Examples contain no secrets or real organization identifiers.
- [ ] Tests are named `unit` or `integration` according to provider behavior.
- [ ] Apply tests document cost and cleanup.

### Navigation

- [ ] All local links resolve.
- [ ] Specialized docs are linked from the README.
- [ ] Root module index and dependency documentation are updated when required.

## Definition of Done

A module conforms to this standard when:

- its directory structure is consistent and contains no redundant documentation;
- its README explains the current behavior, dependencies, security posture, and limitations;
- its Terraform reference is generated and current;
- its basic example is executable and validates;
- complex production behavior is represented by a coherent complete or scenario example;
- its tests are accurately classified and their impact is documented;
- all inputs and outputs are meaningfully described;
- all links resolve;
- root navigation points to the canonical files;
- documentation, tests, and code were reviewed together.

## Reference Implementations

Use these modules as examples of the standard:

- [`modules/acr`](../modules/acr/)
- [`modules/adf`](../modules/adf/)
- [`modules/aks`](../modules/aks/)
- [`modules/applicationgateway`](../modules/applicationgateway/)
- [`modules/appregistration`](../modules/appregistration/)
- [`modules/appservice`](../modules/appservice/)
- [`modules/appserviceplan`](../modules/appserviceplan/)
- [`modules/automationaccount`](../modules/automationaccount/)
- [`modules/availabilityset`](../modules/availabilityset/)
- [`modules/azure_ai_service`](../modules/azure_ai_service/)
- [`modules/azure_ai_search`](../modules/azure_ai_search/)
- [`modules/containerapp`](../modules/containerapp/)
- [`modules/cosmosdb`](../modules/cosmosdb/)
- [`modules/databricks`](../modules/databricks/)
- [`modules/enterpriseapplication`](../modules/enterpriseapplication/)
- [`modules/eventhub`](../modules/eventhub/)
- [`modules/firewall`](../modules/firewall/)
- [`modules/fortigate`](../modules/fortigate/)

## Authoritative References

- [HashiCorp: Standard Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure)
- [HashiCorp: Terraform Style Guide](https://developer.hashicorp.com/terraform/language/style)
- [HashiCorp: Creating Modules](https://developer.hashicorp.com/terraform/language/modules/develop)
- [HashiCorp: Terraform Test Files](https://developer.hashicorp.com/terraform/language/files/tests)
- [HashiCorp: Mock Providers](https://developer.hashicorp.com/terraform/language/tests/mocking)
- [terraform-docs: Configuration](https://terraform-docs.io/user-guide/configuration/)
- [terraform-docs: Output Injection](https://terraform-docs.io/user-guide/configuration/output/)
