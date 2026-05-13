# Azure Data Factory Module

Provision Azure Data Factory with optional SHIR, managed private endpoints, Azure DevOps repository settings, RBAC, and diagnostics.

## Overview

- Providers: `azuread` `3.8.0`, `azurerm` `4.61.0`
- Inputs: 38
- Outputs: 9
- Nested modules: 1
- Terraform tests: `tests/live.tftest.hcl`

## Features

- Creates managed resources including `azurerm_data_factory`, `azurerm_data_factory_integration_runtime_azure`, `azurerm_data_factory_integration_runtime_self_hosted`, `azurerm_data_factory_managed_private_endpoint`, `azurerm_key_vault_secret`.
- Uses nested modules: `shir` -> `../winvm`.
- Supports resource-level RBAC inputs for administrative and read-only access patterns.
- Supports private endpoint configuration using either direct IDs or lookup inputs where exposed.
- Supports optional diagnostic settings to Log Analytics.
- Includes SHIR-related wiring for Data Factory scenarios.

## Basic Usage

```hcl
module "adf" {
  source = "./modules/adf"

  app_env = "<app_env>"
  app_rg = "<app_rg>"
  app_snet = "<app_snet>"
  app_vm = "<app_vm>"
  app_vnet = "<app_vnet>"
  app_vnet_rg = "<app_vnet_rg>"
  iac_kv = "<iac_kv>"
  iac_rg = "<iac_rg>"
  iac_st = "<iac_st>"
  project = "iactest"
  resource_group = "rg-example-prod"

  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Key Inputs

- `app_env`: No description in `variables.tf`. `string` (required)
- `app_rg`: No description in `variables.tf`. `string` (required)
- `app_snet`: No description in `variables.tf`. `string` (required)
- `app_vm`: No description in `variables.tf`. `string` (required)
- `app_vnet`: No description in `variables.tf`. `string` (required)
- `app_vnet_rg`: No description in `variables.tf`. `string` (required)
- `iac_kv`: No description in `variables.tf`. `string` (required)
- `iac_rg`: to define tfvars `string` (required)
- `iac_st`: No description in `variables.tf`. `string` (required)
- `project`: Default prefix of the resource group name that will be created. `string` (required)
- `resource_group`: No description in `variables.tf`. `string` (required)
- `app_admin_group`: The list of groups that will have administrative access to the resources. `list(string)` (default: ["BA-G-Azure-Owner-F"])
- `app_user_group`: The list of groups that will have Reader access to the Azure Data Factory resource and remote access to the SHIR VM. `list(string)` (default: [])
- `enable_private_endpoint`: Whether to create the ADF control-plane private endpoint. `bool` (default: false)
- `log_analytics_workspace`: Log Analytics Workspace Name to ID map `map(string)` (default: {})
- `vsts_configuration`: Azure DevOps repo settings for ADF `object({...})`
- `tags`: customized tags `map(any)` (default: {})

## Notable Outputs

- `app_admin_group_role_assignment_ids`: Map of Contributor role assignment IDs keyed by app_admin_group principal ID.
- `app_user_group_role_assignment_ids`: Map of Reader role assignment IDs keyed by app_user_group principal ID.
- `default_integration_runtime_name`: Data Factory Default Integration Runtime Name
- `diagnostics_enabled`: True when log analytics workspace mapping provided
- `id`: Data Factory ID
- `identity`: Data Factory Managed Identity
- `merged_tags`: Final merged tags applied to resources
- `name`: Data Factory Name
- `self_hosted_integration_runtime_key`: Self hosted integration runtime primary authorization key

## Testing

Run module tests from the module directory:

```powershell
terraform test
```

- `terraform test -filter='tests\live.tftest.hcl'`
