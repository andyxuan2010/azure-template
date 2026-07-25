# Availability Set Validation Report

## Coverage

- `terraform test` uses a mocked AzureRM provider for deterministic plan checks.
- Tests cover explicit naming, generated naming, default managed mode, custom domain counts, PPG pass-through, and tag merging.
- Variable validation covers name shape, generated naming controls, domain count ranges, tag values, and proximity placement group resource ID format.

## Commands

```powershell
terraform fmt -check -recursive
terraform validate
terraform test
```

## Notes

- Live Azure capacity and regional fault-domain limits are not asserted by mocked tests.
- Availability Set membership is intentionally handled by caller VM resources or VM modules.
