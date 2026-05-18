# Azure AI Search Validation Report

## Scope

- Module structure aligned with the hardened module pattern used across this repository.
- Supports identity, firewall rules, private endpoint, RBAC, diagnostics, and key outputs for search access.
- Adds validation and safer defaults for free SKU limitations and high-density hosting constraints.

## Validation Status

- `terraform validate`: expected to pass after provider initialization
- `terraform test`: uses a plan-based test to validate the module interface without provisioning a live search service by default

## Notes

- Azure AI Search capabilities can vary by SKU and region, so the default test remains plan-based.
- The module keeps both `private_dns_zone_id` and `private_dns_zone_ids` for consistency with sibling modules while preferring the plural input for new configurations.
