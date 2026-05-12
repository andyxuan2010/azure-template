# OpenAI Module

Provision an Azure OpenAI account with optional deployments, identity, network ACLs, private endpoint, RBAC, and diagnostics.

## Overview

- Providers: `azurerm`, `azuread`, `random`
- Use case: generative AI platform foundation, model deployments, chat/completions, embeddings, and private AI endpoints
- Terraform tests: `tests/live.tftest.hcl`

## Basic Usage

```hcl
module "openai" {
  source = "./modules/openai"

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  name                = "oai-example-prod-001"
  sku_name            = "S0"
}
```

## Dependencies

- Required: existing resource group
- Common upstream: `rg`, `vnet`, `keyvault`, `managedidentity`
- Common downstream: application APIs, copilots, AI gateways, integration services

## Testing

```powershell
terraform test -filter='tests\live.tftest.hcl'
```
