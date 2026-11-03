# Normalization Pass 2: Coverage

Date: 2026-10-30

Pass 2 closes executable-example and test gaps identified in the four-repository audit.

## Changes

- Azure retains its existing per-module examples and asserted unit/integration suites (52 module examples; 350 unit assertions at the audit baseline).
- AWS now has a standalone `modules/<module>/examples/basic` root configuration for all 37 modules. Six modules that lacked a Terraform test suite now have mocked plan tests with assertions and negative cases where the module exposes a relevant guard.
- OCI now has a standalone `modules/<module>/examples/basic` root configuration for all 26 modules. Each module test suite now checks planned output or security configuration with two assertions.
- GCP retains its existing examples and mocked tests for all 29 modules.
- All new examples use the module's representative mocked-test inputs and warn that illustrative identifiers must be replaced before planning or applying.

## Validation

- Each example is formatted and its module-call inputs match the existing or newly added test case.
- Mocked module tests are run in the corresponding repository. Examples use `terraform init -backend=false` and `terraform validate`; no apply is part of this coverage pass.

## Results

- Standalone examples: AWS 37/37, OCI 26/26, Azure 52/52, GCP 29/29.
- AWS test suites: all 37 modules covered; the six audit gaps are closed.
- OCI test suites: all 26 modules have asserted plan checks instead of zero-assertion smoke runs.
