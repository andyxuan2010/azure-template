# OpenAI Examples

## Basic Azure OpenAI Account

```hcl
module "openai" {
  source = "./modules/openai"

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  name                = "oai-example-prod-001"
  sku_name            = "S0"
}
```

## Account With Model Deployments

```hcl
module "openai" {
  source = "./modules/openai"

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  name                = "oai-example-prod-001"
  sku_name            = "S0"

  deployments = {
    gpt4o-mini = {
      model_format  = "OpenAI"
      model_name    = "gpt-4o-mini"
      model_version = "2024-07-18"
      sku_name      = "Standard"
      sku_capacity  = 10
      version_upgrade_option = "OnceNewDefaultVersionAvailable"
    }
    text-embedding-3-large = {
      model_format = "OpenAI"
      model_name   = "text-embedding-3-large"
      sku_name     = "Standard"
      sku_capacity = 10
    }
  }
}
```

## Private Azure OpenAI Account

```hcl
module "openai" {
  source = "./modules/openai"

  resource_group_name           = "rg-example-prod"
  location                      = "eastus"
  name                          = "oai-example-prod-001"
  public_network_access_enabled = false
  enable_private_endpoint       = true
  private_endpoint_subnet_id    = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<pep-subnet>"
  private_dns_zone_ids = [
    "/subscriptions/<subscription-id>/resourceGroups/<dns-rg>/providers/Microsoft.Network/privateDnsZones/privatelink.openai.azure.com"
  ]

  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}
```

## Customer-Managed Key With User-Assigned Identity

```hcl
module "openai" {
  source = "./modules/openai"

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  name                = "oai-example-prod-001"
  sku_name            = "S0"

  identity = {
    type         = "UserAssigned"
    identity_ids = ["/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uai-openai-prod-001"]
  }

  customer_managed_key = {
    key_vault_key_id = "https://<keyvault-name>.vault.azure.net/keys/<key-name>/<key-version>"
  }
}
```
