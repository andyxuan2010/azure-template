# OpenAI Validation Report

## Scope

- Module structure aligned with the hardened module pattern used across this repository.
- Supports account-level networking, identity, RBAC, diagnostics, and model deployments.

## Validation Status

- `terraform validate`: expected to pass after provider initialization
- `terraform test`: uses a plan-based test to validate the module interface without provisioning a live Azure OpenAI account by default

## Notes

- Azure OpenAI model availability and quota are region- and subscription-specific, so the default test avoids live deployment creation.
