# Azure Data Factory Examples

## Example 1: Minimal Secure Factory

```hcl
module "adf" {
  source = "./modules/adf"

  name           = "platformdata"
  app_env        = "prod"
  location       = "canadacentral"
  resource_group = "rg-example-prod"

  public_network_enabled          = false
  managed_virtual_network_enabled = true

  tags = {
    Owner = "CCOE"
  }
}
```

## Example 2: Private Endpoint and Diagnostics

```hcl
module "adf" {
  source = "./modules/adf"

  name           = "platformdata"
  app_env        = "prod"
  location       = "canadacentral"
  resource_group = "rg-example-prod"

  enable_private_endpoint    = true
  private_endpoint_subnet_id = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>"
  private_dns_zone_id        = "/subscriptions/<subscription-id>/resourceGroups/<dns-rg>/providers/Microsoft.Network/privateDnsZones/privatelink.datafactory.azure.net"

  enable_diagnostics = true
  log_analytics_workspace = {
    platform = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.OperationalInsights/workspaces/<workspace-name>"
  }
}
```

## Example 3: Managed VNet with Managed Private Endpoint

```hcl
module "adf" {
  source = "./modules/adf"

  name                           = "platformdata"
  app_env                        = "prod"
  location                       = "canadacentral"
  resource_group                 = "rg-example-prod"
  managed_virtual_network_enabled = true

  managed_private_endpoint = [
    {
      name               = "storage-blob"
      target_resource_id = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/<storage-name>"
      subresource_name   = "blob"
    }
  ]

  global_parameter = [
    {
      name  = "environment"
      type  = "String"
      value = "prod"
    }
  ]
}
```

## Example 4: GitHub Source Control

```hcl
module "adf" {
  source = "./modules/adf"

  name           = "platformdata"
  app_env        = "dev"
  location       = "canadacentral"
  resource_group = "rg-example-dev"

  github_configuration = {
    account_name       = "CCOE-Azure-Terraform"
    repository_name    = "azure-template"
    branch_name        = "main"
    git_url            = "https://github.com/CCOE-Azure-Terraform/azure-template"
    root_folder        = "/"
    publishing_enabled = true
  }
}
```

## Example 5: CMK with User-Assigned Identity

```hcl
module "adf" {
  source = "./modules/adf"

  name           = "platformdata"
  app_env        = "prod"
  location       = "canadacentral"
  resource_group = "rg-example-prod"

  identity_type = "SystemAssigned, UserAssigned"
  identity_ids = [
    "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uai-adf-cmk"
  ]

  customer_managed_key_id          = "https://<vault-name>.vault.azure.net/keys/<key-name>/<key-version>"
  customer_managed_key_identity_id = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uai-adf-cmk"
}
```

## Example 6: Self-Hosted Integration Runtime

```hcl
module "adf" {
  source = "./modules/adf"

  name           = "platformdata"
  app_env        = "prod"
  location       = "canadacentral"
  resource_group = "rg-example-prod"

  self_hosted_integration_runtime_enabled = true
  app_vm                                  = "vm-adf-shir-01"
  app_rg                                  = "rg-app-prod"
  app_vnet_rg                             = "rg-network-prod"
  app_vnet                                = "vnet-app-prod"
  app_snet                                = "snet-shir"
  iac_rg                                  = "rg-iac-prod"
  iac_kv                                  = "kv-iac-prod"
  iac_st                                  = "stiacprod001"
}
```

## Notes

- Configure either `vsts_configuration` or `github_configuration`, not both.
- Use `private_endpoint_subnet_id` when possible; lookup inputs remain available for shared network patterns.
- Customer-managed keys require the CMK identity to be included in `identity_ids`.
- Managed private endpoints require `managed_virtual_network_enabled = true`.
- Each `permissions` entry must use a unique object ID and role combination.
