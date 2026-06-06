# Changelog for `acr` Module

This document summarizes the changes, bug fixes, and features added to the Azure Container Registry (`acr`) module.

## [2026-05-16]
### Changed
- Standardized ACR module to align with the modernized and hardened module patterns used across the repository.
- Expanded examples for Premium hardened registries, mixed managed identity, customer-managed keys (CMK), and geo-replication.
- Added comprehensive Premium-only controls for export policy, quarantine policy, retention, trust policy, and zone redundancy.
- Updated `MODULE_COMPLETE.md` to reflect new artifacts and features.

## [2026-05-14]
### Changed
- Refreshed ACR module documentation and added minor features to align with updated usage patterns.

## [2026-05-08]
### Removed
- Removed the ACR resource group data source, streamlining resource lookups.

## [2026-04-29]
### Changed
- Updated module documentation to clarify inputs and usage.

## [2026-04-18]
### Changed
- General repository update including subscription module adjustments affecting the `acr` module tree.

## [2026-04-17]
### Added
- Initial commit of the `acr` module with basic secure-by-default registry configuration, RBAC inputs, and private endpoint support.
