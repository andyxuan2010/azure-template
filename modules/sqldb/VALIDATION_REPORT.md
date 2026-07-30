# SQL Database Validation Report

Date: 2026-05-20

## Summary

The `sqldb` module has been standardized and validated against the installed Terraform providers:

- `hashicorp/azurerm` v4.73.0
- `hashicorp/azuread` v3.8.0
- `hashicorp/random` v3.9.0

Validation status:

- `terraform -chdir=modules\sqldb validate`: pass
- `terraform -chdir=modules\sqldb test`: pass, 5 plan tests

## Test Coverage

The module test file uses mock providers and validates:

- Secure defaults with explicit names.
- Deterministic generated names.
- Private endpoint, private DNS, diagnostics, LTR, threat detection, and RBAC.
- Microsoft Entra-only authentication, CMK identities, database CMK rotation, and failover group configuration.
- Public demo access, firewall rules, Azure services firewall rule, and BACPAC import configuration.

## Input Validation

The module validates:

- SQL server and database name formats.
- Resource group, location, Key Vault, subnet, private DNS zone, workspace, elastic pool, and managed identity IDs.
- Environment values.
- TLS version.
- Backup and long-term retention bounds.
- Basic SKU maximum database size.
- Firewall IPv4 address ranges.
- Diagnostic destination consistency.
- Private endpoint subnet consistency.
- Microsoft Entra administrator consistency.
- Production LTR diagnostics requirement.
- Audit destination consistency.
- Database TDE rotation consistency.

## Secure Defaults Checked

- Public network access disabled.
- System-assigned managed identity enabled.
- Microsoft Entra administrator enabled.
- Transparent Data Encryption enabled.
- Private endpoint enabled by default.
- Diagnostics require an explicit destination.

## Compatibility Notes

- Existing resource addresses were preserved for the main SQL server, database, firewall rules, server audit, server threat policy, diagnostics, private endpoint, and app group role assignments.
- Existing callers that pass `server_name`, `database_name`, SQL admin credentials, Entra admin values, and `private_endpoint_subnet_id` remain compatible.
- New generated naming is opt-in by leaving `server_name` or `database_name` empty.
