# Normalization Pass 4: Interface Migration

Date: 2026-10-30

## Baseline

All 52 Azure modules have `variables.tf`. The common metadata interface is partial: 49 modules expose `workload` and `app_env`, 41 expose `instance`, and 47 expose `tags`. None expose `environment` today. Some modules also accept `environment` in their examples but map it to the module's `app_env` input.

## Migration policy

- Use `environment` as the preferred name for environment metadata in future module interfaces. Keep `app_env` as a compatibility input during migration.
- Do not remove or change the meaning of an existing input in a patch release. If a legacy input is eventually removed, treat it as a major interface change and document a migration window.
- Keep resource-specific inputs and Azure resource naming behavior provider-native.
- Keep Azure `tags`, AWS `tags`, GCP `labels`, and OCI `freeform_tags`/`defined_tags` provider-native; they are not interchangeable contracts.
- Keep module-specific outputs stable. Additive outputs are preferred; changing a resource address or output meaning requires a separately reviewed migration.
- Update tests, examples, module READMEs, generated docs, and pipeline checks together whenever a public interface changes.

## Findings across the templates

- Azure has 49 of 52 modules using `app_env`; 49 use `workload`; 41 use `instance`.
- AWS has 33 of 37 modules using each of `workload`, `environment`, and `instance`; 31 use `region_code`.
- GCP has all 29 modules using `workload`, `environment`, `region_code`, and `instance`.
- OCI's modules use tenancy and compartment concepts and provider-native tags; imposing the AWS/Azure/GCP metadata interface there would add invented inputs without a consistent OCI meaning.

## Decision

Standardize shared metadata naming incrementally where semantics match. For Azure, add `environment` as an additive alias backed by the existing `app_env` behavior, update examples to use the preferred name, and retain `app_env` until a major-version removal is approved. For AWS and GCP, retain their existing common names and document module-specific exceptions. Keep OCI provider-native.

This pass records the compatibility contract and inventory. No public variable has been renamed or removed in this documentation step. No infrastructure plan or apply is part of the interface migration.

## Migration sequence

1. Implement Azure's additive `environment` alias consistently in the 49 affected modules.
2. Add API-focused mocked tests for canonical and legacy inputs, and migrate examples and READMEs to the canonical name.
3. Inventory the four AWS exceptions and add only metadata inputs that are genuinely used by those modules.
4. Keep GCP stable and OCI provider-native; publish the resulting cross-template contract in each pipeline/module guide.
