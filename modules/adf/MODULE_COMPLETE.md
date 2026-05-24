# Azure Data Factory Module Complete

The `adf` module now follows the repository's hardened module pattern.

Included artifacts:

- `terraform.tf`
- `variables.tf`
- `locals.tf`
- `data.tf`
- `main.tf`
- `managed_endpoints.tf`
- `monitoring.tf`
- `outputs.tf`
- `readme.md`
- `EXAMPLES.md`
- `QUICK_REFERENCE.md`
- `VALIDATION_REPORT.md`

Current highlights:

- environment-aware naming and standardized tags
- optional location fallback from the target resource group
- managed identity modes including `None`
- customer-managed key support with explicit user-assigned identity validation
- GitHub and Azure DevOps source control with publishing controls
- optional default Azure Integration Runtime and SHIR support
- optional ADF private endpoint using direct subnet ID or lookup inputs
- managed private endpoints with managed VNet validation
- diagnostics to one or more Log Analytics workspaces with optional category overrides
- conditional IaC, Key Vault, storage, and network lookups
- Terraform tests covering baseline, private endpoint, and managed network plan paths
