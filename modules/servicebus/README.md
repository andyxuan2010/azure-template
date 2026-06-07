# Service Bus Module

Provision an Azure Service Bus namespace with optional queues, topics, subscriptions, authorization rules, network rules, private endpoint, RBAC, and diagnostics.

## Overview

- Providers: `azurerm`, `azuread`, `random`
- Use case: enterprise messaging, queues, pub/sub topics, decoupled application integration
- Terraform tests: `tests/live.tftest.hcl`

## Basic Usage

```hcl
module "servicebus" {
  source = "./modules/servicebus"

  resource_group_name = "rg-example-prod"
  location            = "canadacentral"
  name                = "sb-example-prod-001"

  queues = {
    orders = {
      max_size_in_megabytes = 1024
    }
  }
}
```

## Dependencies

- Required: existing resource group
- Common upstream: `rg`, `vnet`
- Common downstream: integration, application, and event-driven workloads

## Testing

```powershell
terraform test -filter='tests\live.tftest.hcl'
```
