# Normalization Pass 1: Correctness

Date: 2026-10-30

This pass records correctness checks and repairs before expanding test and example coverage. The four repositories are reviewed as separate Terraform modules with cloud-specific runtime requirements.

## Changes

- No Terraform resource addresses, input names, or provider constraints were mass-renamed. Those changes can alter consumer plans or state addresses and belong in separately reviewed migrations.
- The existing Azure checks were retained: generated module standards run in fail mode in CI, and the workflow gates plans and publication on validation results.
- This repository remains the Azure contract reference for the cross-cloud follow-up; Pass 2 adds coverage gaps without changing its established resource interfaces.

## Validation

- Python module-standards checker and its unit tests were run during the repository audit.
- Hosted pipeline settings and cloud-backed applies are outside source validation; no apply was run for this pass.

## Follow-up

See `0004-normalization-pass-2-coverage.md` for the next coverage pass and its per-repository results.
