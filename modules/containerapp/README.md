# Container App Module

Creates an Azure Container App in an existing Container Apps managed environment with standardized naming, managed identity, container template settings, optional ingress, registry references, secrets, Dapr, volumes, and KEDA scale rules.

## Overview

- Providers: `azurerm`
- Use case: deploy a containerized workload to Azure Container Apps
- Naming: `ca-<workload>-<region-code>-<environment>-<instance>` when `name` is empty
- Terraform tests: `tests/live.tftest.hcl`

## Basic Usage

```hcl
module "containerapp" {
  source = "./modules/containerapp"

  resource_group_name          = "rg-platform-dev"
  location                     = "canadacentral"
  container_app_environment_id = module.containerapp_environment.id

  ingress = {
    external_enabled = true
    target_port      = 8080
  }

  containers = [{
    name   = "api"
    image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
    cpu    = 0.25
    memory = "0.5Gi"
  }]

  tags = {
    Owner = "CCOE"
  }
}
```

## Private Registry

```hcl
module "containerapp" {
  source = "./modules/containerapp"

  name                         = "ca-orders-cc-prod-001"
  resource_group_name          = "rg-orders-prod"
  location                     = "canadacentral"
  container_app_environment_id = module.containerapp_environment.id

  secrets = [{
    name                = "acr-password"
    key_vault_secret_id = module.keyvault.secret_ids["acr-password"]
    identity            = "System"
  }]

  registries = [{
    server               = "contoso.azurecr.io"
    username             = "contoso"
    password_secret_name = "acr-password"
  }]

  containers = [{
    name   = "api"
    image  = "contoso.azurecr.io/orders-api:1.0.0"
    cpu    = 0.5
    memory = "1Gi"
  }]
}
```

## Proper Usage

- Create or provide the Container Apps managed environment outside this module and pass its resource ID.
- Use `name` only when you need an explicit override; otherwise use `workload`, `location`, `app_env`, and `instance`.
- Prefer managed identity or Key Vault-backed secrets for registry and app secrets.
- Keep ingress null for worker/background apps.
- Use `revision_mode = "Multiple"` only when traffic splitting across revisions is required.

## Dependencies

- Required: existing resource group and existing Azure Container Apps managed environment
- Common upstream: `rg`, `loganalytics`, `vnet`, `managedidentity`, `keyvault`, `acr`
- Common downstream: application gateway, private endpoint to supporting PaaS resources, diagnostics and workload-specific RBAC

## Testing

```powershell
terraform test -filter='tests\live.tftest.hcl'
```

Tests use a mocked AzureRM provider and cover name overrides, generated naming, tag inheritance, identity defaults, registry/secret/scale inputs, and invalid replica bounds.
