# Databricks Module

Provision an Azure Databricks workspace with optional VNet injection, enhanced security settings, RBAC, and diagnostics.

## Overview

- Providers: `azurerm`, `azuread`, `random`
- Use case: lakehouse platforms, data engineering, notebooks, ML workloads, and shared analytics workspaces
- Terraform tests: `tests/live.tftest.hcl`

## Basic Usage

```hcl
module "databricks" {
  source = "./modules/databricks"

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  name                = "dbw-example-prod-001"
  sku                 = "premium"
}
```

## Dependencies

- Required: existing resource group
- Common upstream: `rg`, `vnet`, `nsg`, `managedidentity`
- Common downstream: ADF, data engineering pipelines, analytics workloads, ML consumers

## Testing

```powershell
terraform test -filter='tests\live.tftest.hcl'
```
