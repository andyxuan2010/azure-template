# Normalization Pass 3: Shared Tooling

Date: 2026-10-30

## Scope

This pass audits and documents tooling that should behave consistently across the Azure, AWS, OCI, and GCP Terraform template repositories. It establishes the shared-tooling boundary before refactoring automation.

## Findings

- Azure has a richer changed-module helper at `scripts/azure-pipelines/module-harness-targets.sh`. It supports Git refs and changed-file lists, emits GitHub Actions and Azure Pipelines matrices, and generates provider-specific harness overrides.
- The override generation is Azure-specific and should remain separate from cross-provider module selection.
- Azure's module test runner supports module selection, configurable test file, init skipping, timeouts, and failure summaries.
- Module documentation and manifest generation are repository-specific and should retain their current module inventories and provider terminology.

## Shared contract

- Changed-module selection should use the same path classification and output semantics across the four repositories: module changes target that module; shared Terraform, scripts, pipeline, or module-catalog changes target all modules; unrelated documentation changes target none.
- The selector should support both Git base/head refs and a newline-delimited changed-file list, and emit newline, JSON-array, and CI matrix formats.
- CI must fail clearly when explicitly requested module names are unknown; an empty change set should produce an empty selection without being mistaken for successful test coverage.
- Azure harness override generation remains a provider-specific extension.
- Validation entry points should preserve backend-free init, format, validate, and asserted module tests, with example validation where examples exist.

## Next implementation

1. Consolidate the duplicated AWS/GCP selector behind the shared contract.
2. Add the same selector interface to OCI and Azure while keeping Azure's override command.
3. Align runner failure semantics and CI invocation, then update each pipeline guide and decision record with the implemented behavior.

No infrastructure plan or apply is part of this tooling pass.
