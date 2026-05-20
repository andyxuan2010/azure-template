# OpenAI Validation Report

## Scope

- Module structure aligned with the hardened module pattern used across this repository.
- Supports account-level networking, identity, customer-managed keys, RBAC, diagnostics, and model deployments.
- Adds validation and safer defaults for private endpoint, CMK, and deployment-driven configurations.

## Validation Status

- `terraform validate`: expected to pass after provider initialization
- `terraform test`: uses a plan-based test to validate the module interface without provisioning a live Azure OpenAI account by default

## Notes

- Azure OpenAI model availability and quota are region- and subscription-specific, so the default test avoids live deployment creation.
- The module now auto-derives `custom_subdomain_name` from the account name when a private endpoint is enabled because Azure OpenAI private endpoints require a custom subdomain.
