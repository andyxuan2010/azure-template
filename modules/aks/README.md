# Azure Kubernetes Service Module

Provision Azure Kubernetes Service with RBAC, networking, private cluster options, and diagnostics.

## Overview

- Providers: `azuread` `3.8.0`, `azurerm` `4.65.0`, `random` `3.8.1`
- Inputs: 29
- Outputs: 17
- Nested modules: 0
- Terraform tests: `tests/live.tftest.hcl`

## Features

- Creates managed resources including `azurerm_kubernetes_cluster`, `azurerm_monitor_diagnostic_setting`, `azurerm_role_assignment`, `azurerm_string`.
- Supports resource-level RBAC inputs for administrative and read-only access patterns.
- Supports optional diagnostic settings to Log Analytics.
- Supports Azure Key Vault secrets provider add-on.
- Includes Terraform test coverage files: `tests/live.tftest.hcl`.

## Basic Usage

```hcl
module "aks" {
  source = "./modules/aks"

  resource_group_name = "rg-example-prod"
  app_env             = "prod"

  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Key Inputs

- `resource_group_name`: The name of the resource group where the AKS cluster will be deployed. `string` (required)
- `app_env`: Deployment environment used for standardisation and naming (dev, staging, prod, sbx, test, qa). `string` (default: "dev")
- `app_admin_group`: List of Microsoft Entra group display names or object IDs that should receive AKS cluster admin access. `list(string)` (default: null)
- `app_user_group`: List of Microsoft Entra group display names or object IDs that should receive Reader access on the AKS cluster resource. `list(string)` (default: null)
- `terraform_execution_aks_role`: Optional AKS Kubernetes RBAC role for the current Terraform execution identity. Supported values: `Azure Kubernetes Service RBAC Cluster Admin`, `Azure Kubernetes Service RBAC Cluster Writer`. `string` (default: `""`)
- `enable_diagnostics`: Whether to create a diagnostic setting for the AKS cluster. `bool` (default: false)
- `log_analytics_workspace_id`: Log Analytics workspace resource ID for diagnostics. Required when enable_diagnostics is true. `string` (default: "")
- `tags`: A mapping of tags to assign to the AKS resources. `map(string)` (default: {})

## Notable Outputs

- `app_admin_group_role_assignment_ids`: Map of Contributor role assignment IDs keyed by app_admin_group principal ID.
- `app_user_group_role_assignment_ids`: Map of Reader role assignment IDs keyed by app_user_group principal ID.
- `diagnostic_setting_id`: The ID of the AKS diagnostic setting, if created.
- `fqdn`: The public FQDN of the AKS API server when available.
- `id`: The ID of the AKS cluster.
- `identity_principal_id`: The principal ID of the AKS system-assigned managed identity.
- `identity_tenant_id`: The tenant ID of the AKS system-assigned managed identity.
- `key_vault_secrets_provider_identity`: The Key Vault Secrets Provider identity block when the addon is enabled.
- `kubelet_identity`: The kubelet identity block exposed by AKS.
- `kubernetes_version`: The resolved Kubernetes version of the AKS cluster.
- `location`: The location of the AKS cluster.
- `terraform_execution_identity_cluster_access_role_assignment_id`: AKS Kubernetes RBAC role assignment ID for the Terraform execution identity, if enabled.

## Testing

Run module tests from the module directory:

```powershell
terraform test
```

- `terraform test -filter='tests\live.tftest.hcl'`
