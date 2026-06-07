Module Hardened: winvm

This module has been hardened and prepared for production use according to the project's module-hardening pattern.

What was done:
- Environment-aware `locals` and tag merging.
- Input validations and diagnostics flags added.
- Consistent tagging applied across resources.
- Outputs added for important IDs and final tags.
- `terraform validate` completed successfully.

Notes:
- Automated diagnostics were deferred due to azurerm provider schema differences; see `VALIDATION_REPORT.md` for details.

If you want, I can now add docs (`QUICK_REFERENCE.md`, `EXAMPLES.md`) and re-add the diagnostics resource tailored to your provider version.
