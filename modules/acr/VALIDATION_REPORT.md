# Validation Report

## Checks Performed

- `terraform init -backend=false`
- `terraform fmt`
- `terraform validate`
- `terraform test -filter="tests/live.tftest.hcl"`

## Result

Validation was refreshed after standardizing the `acr` module around the repo's hardened module pattern. The module now includes stronger input validation, premium ACR feature support, system-assigned identity role assignments, corrected cross-provider private endpoint lookups, updated examples, and aligned outputs.
