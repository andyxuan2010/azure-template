# OpenAI Validation Report

## Scope

- Module structure aligned with the hardened module pattern used across this repository.
- Supports Azure OpenAI account networking, identity, customer-managed keys, RBAC, diagnostics, private endpoint, and model deployments.
- Adds secure defaults for public access, local key authentication, custom subdomain, managed identity, diagnostics, and tagging.

## Validation Status

- `terraform validate`: passes after provider initialization.
- `terraform test`: uses mock providers and plan-only scenarios to validate secure defaults, generated naming, private endpoint, deployments, diagnostics, RBAC, and CMK identity.

## Notes

- Azure OpenAI model availability and quota are region- and subscription-specific, so tests avoid live deployment creation.
- `custom_subdomain_name` defaults to the account name because it is required for private endpoint and Microsoft Entra ID scenarios.
