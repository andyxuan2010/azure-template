# SQL Database Enhancement Summary

Date: 2026-05-20

## What Changed

The `sqldb` module was standardized around the same patterns used by the newer modules in this repository:

- Added module-level provider requirements.
- Added generated naming with optional random suffix.
- Added conditional resource group tag inheritance.
- Added standardized environment tags.
- Preserved existing primary resource addresses.
- Replaced live test coverage with provider-mocked plan tests.

## Features Added

- Microsoft Entra-only authentication.
- Optional Entra admin tenant ID.
- Server system-assigned and user-assigned managed identities.
- Server-level and database-level customer-managed TDE keys.
- Database-level identity and automatic TDE key rotation.
- Server connection policy and outbound network restriction options.
- Express Vulnerability Assessment toggle.
- Serverless, elastic pool, ledger, read scale, read replica, restore, and import options.
- Short-term backup interval and immutable long-term retention options.
- Server and database threat detection configuration.
- Server and database audit policy configuration.
- Diagnostics to Log Analytics, Storage Account, or Event Hub, including category groups.
- Private endpoint subnet lookup, private DNS zone lookup, custom NIC name, manual approval, static IP configuration, and timeouts.
- Common and custom Azure RBAC role assignments.
- Optional SQL failover group.

## Files Updated

- `terraform.tf`
- `locals.tf`
- `data.tf`
- `main.tf`
- `variables.tf`
- `outputs.tf`
- `tests/live.tftest.hcl`
- `README.md`
- `EXAMPLES.md`
- `QUICK_REFERENCE.md`
- `INDEX.md`
- `VALIDATION_REPORT.md`
- `MODULE_COMPLETE.md`
- `README_UPDATED.md`
- `examples/complete/*`

## Validation

```powershell
terraform -chdir=modules\sqldb validate
terraform -chdir=modules\sqldb test
```

Both commands passed after the standardization.
