# Storage Account Module - Validation Report

## Checks Performed

1. Added the module using the same sibling pattern used by `automationaccount` and other hardened modules.
2. Validated Terraform syntax and AzureRM schema locally with `terraform init -backend=false` and `terraform validate`.

## Scope

- Storage account resource
- Optional storage firewall rules
- Optional managed identity RBAC assignments
- Optional private endpoints
- Optional Log Analytics diagnostics
- Secure authentication defaults and private endpoint DNS outputs
