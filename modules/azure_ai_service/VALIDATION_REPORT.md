# Azure AI Service Validation Report

## Scope

- Module structure aligned with the hardened module pattern used across this repository.
- Supports identity, network ACLs, storage attachments, private endpoint, RBAC, and diagnostics.

## Validation Status

- `terraform validate`: expected to pass after provider initialization
- `terraform test`: uses a plan-based test to validate the module interface without provisioning a live AI account by default

## Notes

- Azure AI Services deployments can have SKU and networking constraints that vary by service and region, so the default test remains plan-based.
