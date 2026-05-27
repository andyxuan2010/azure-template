# Key Vault Module - Validation Report

## Checks Performed

1. Added the module using the same sibling pattern used by `storageaccount` and `automationaccount`.
2. Validated Terraform syntax and AzureRM schema locally with `terraform init -backend=false` and `terraform validate`.

## Scope

- Key Vault resource
- Entra group RBAC assignments
- Network ACLs enabled by default with secure deny-first behavior
- Optional private endpoint
- Optional diagnostics
- RBAC mode guardrails and current caller role-assignment control
