# Event Hub Module

Provision an Azure Event Hubs namespace with optional Event Hubs, namespace authorization rules, private endpoint, RBAC, and diagnostics.

## Overview

- Providers: `azurerm`, `azuread`, `random`
- Use case: telemetry ingestion, streaming platforms, Kafka-compatible messaging, and event-driven integration
- Terraform tests: `tests/live.tftest.hcl`

## Basic Usage

```hcl
module "eventhub" {
  source = "./modules/eventhub"

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  name                = "evh-example-prod-001"

  eventhubs = {
    telemetry = {
      partition_count   = 2
      message_retention = 1
    }
  }
}
```

## Dependencies

- Required: existing resource group
- Common upstream: `rg`, `vnet`
- Common downstream: analytics, stream processing, integration workloads

## Testing

```powershell
terraform test -filter='tests\live.tftest.hcl'
```
