# Azure AI Service Validation Report

## Scope

- Module structure aligned with the hardened module pattern used across this repository.
- Supports identity, customer-managed keys, network ACLs, storage attachments, private endpoint, RBAC, and diagnostics.
- Adds validation and safer defaults for private endpoint and identity-driven configurations.

## Validation Status

- `terraform validate`: expected to pass after provider initialization
- `terraform test`: uses a plan-based test to validate the module interface without provisioning a live AI account by default

## Notes

- Azure AI Services deployments can have SKU and networking constraints that vary by service and region, so the default test remains plan-based.
- The module now auto-derives `custom_subdomain_name` from the account name when a private endpoint is enabled because Azure Cognitive Services private endpoints require a custom subdomain.
