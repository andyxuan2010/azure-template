# Managed Identity Module

Provision an Azure user-assigned managed identity with optional federated identity credentials and role assignments.

## Overview

- Providers: `azurerm`
- Use case: workload identities for GitHub Actions, Azure DevOps, AKS workload identity, and application runtime access
- Terraform tests: `tests/live.tftest.hcl`

## Basic Usage

```hcl
module "uami" {
  source = "./modules/managedidentity"

  name                = "id-app-prod-001"
  resource_group_name = "rg-example-prod"
  location            = "eastus"
}
```

## Proper Usage

- Create the identity before `functionapp`, `appservice`, or `aks` consumers that reference it.
- Add role assignments here only if this module should own authorization lifecycle.
- Add federated credentials when the identity is used by GitHub OIDC, Azure DevOps workload identity federation, or AKS workload identity.

## Dependencies

- Required: existing resource group
- Common upstream: `rg`
- Common downstream: `functionapp`, `appservice`, `aks`, `automationaccount`

## Testing

```powershell
terraform test -filter='tests\live.tftest.hcl'
```
