# Azure AI Service Module

Provision an Azure AI Services account with optional identity, network ACLs, private endpoint, RBAC, storage attachments, and diagnostics.

## Overview

- Providers: `azurerm`, `azuread`, `random`
- Use case: AI services foundation, shared AI endpoint, document intelligence, vision, speech, and multi-service AI workloads
- Terraform tests: `tests/live.tftest.hcl`

## Basic Usage

```hcl
module "azure_ai_service" {
  source = "./modules/azure_ai_service"

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  name                = "ais-example-prod-001"
  sku_name            = "S0"
}
```

## Dependencies

- Required: existing resource group
- Common upstream: `rg`, `vnet`, `keyvault`, `managedidentity`
- Common downstream: application platforms, AI apps, document processing workloads

## Testing

```powershell
terraform test -filter='tests\live.tftest.hcl'
```
