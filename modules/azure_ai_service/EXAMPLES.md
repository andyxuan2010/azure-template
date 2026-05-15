# Azure AI Service Examples

## Basic Account

```hcl
module "azure_ai_service" {
  source = "./modules/azure_ai_service"

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  name                = "ais-example-prod-001"
  sku_name            = "S0"
}
```

## Private Account With Network ACLs

```hcl
module "azure_ai_service" {
  source = "./modules/azure_ai_service"

  resource_group_name           = "rg-example-prod"
  location                      = "eastus"
  name                          = "ais-example-prod-001"
  sku_name                      = "S0"
  public_network_access_enabled = false

  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = []
    virtual_network_rules = [
      {
        subnet_id = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>"
      }
    ]
  }

  enable_private_endpoint    = true
  private_endpoint_subnet_id = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<pep-subnet>"
  private_dns_zone_ids = [
    "/subscriptions/<subscription-id>/resourceGroups/<dns-rg>/providers/Microsoft.Network/privateDnsZones/privatelink.cognitiveservices.azure.com"
  ]
}
```

## Customer-Managed Key With User-Assigned Identity

```hcl
module "azure_ai_service" {
  source = "./modules/azure_ai_service"

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  name                = "ais-example-prod-001"
  sku_name            = "S0"

  identity = {
    type         = "UserAssigned"
    identity_ids = ["/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uai-ais-prod-001"]
  }

  customer_managed_key = {
    key_vault_key_id = "https://<keyvault-name>.vault.azure.net/keys/<key-name>/<key-version>"
  }
}
```
