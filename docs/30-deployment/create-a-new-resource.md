# Create or Extend a Terraform Module

Use this workflow when adding a reusable Azure capability or extending an existing module. The repository is a module catalog with a root composition and validation harness; a new module does not automatically belong in every root deployment.

## Before coding

1. Search the [Modules Index](../20-repository/modules-index.md), module directories, and [dependency guide](../20-repository/module-usage-and-dependencies.md) for an existing capability to extend.
2. Confirm the module owns a clear resource boundary and identify caller-owned prerequisites, provider requirements, permissions, network dependencies, and security-sensitive inputs.
3. Read the [Terraform Module Documentation Standard](../20-repository/module-documentation-standard.md), [Naming Convention](../60-security-governance/naming-convention.md), and [Tagging Standard](../60-security-governance/tagging-standard.md).

## Implement

1. Create or update `modules/<module-name>/` with Terraform source, `terraform.tf`, variables, outputs, examples, and `tests/unit.tftest.hcl` as required by the standard. Keep provider configuration and credentials in the calling root.
2. Add executable `examples/basic` and `examples/complete`; add focused examples for meaningful feature combinations. Document prerequisites, created resources, identity behavior, networking, limitations, and sensitive state values in `README.md`.
3. Add a focused `docs/` note only where architecture, operations, security, or troubleshooting details need more room than the README.
4. If the module must be consumable through the repository root harness, wire it deliberately in root `main.tf`, variables, locals, and sample tfvars. Update focused-plan overrides and related scripts where needed. Do not wire every catalog module by default.
5. Update the Modules Index, dependency guide, root README, validation summary, and other affected guides. Regenerate `docs-manifest.json` with `scripts/generate-docs-manifest.ps1`.

## Validate and submit

Run the module-standard checks locally: formatting, backend-free initialization, validation, generated docs check, and mocked unit tests. Review any integration test before running it because it may access or change Azure resources. For root-wired changes, validate a focused root plan using the approved backend and inputs; review all data lookups and proposed changes.

Commit the complete module, tests, examples, and documentation on a feature branch and submit it for review. Follow repository branch protections and apply controls described in [DevSecOps and GitOps Controls](../60-security-governance/devsecops-gitops.md).
