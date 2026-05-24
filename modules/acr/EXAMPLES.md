# Azure Container Registry Examples

## Example 1: Minimal Secure Default

```hcl
module "acr" {
  source = "./modules/acr"
  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name = "rg-example-prod"
  app_env             = "prod"
}
```

## Example 2: Premium Hardened Registry

```hcl
module "acr" {
  source = "./modules/acr"
  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name           = "rg-example-prod"
  location                      = "eastus"
  name                          = "platformimages"
  app_env                       = "prod"
  sku                           = "Premium"
  public_network_access_enabled = false
  export_policy_enabled         = false
  quarantine_policy_enabled     = true
  retention_policy_in_days      = 14
  trust_policy_enabled          = true
  zone_redundancy_enabled       = true

  enable_network_rule_set     = true
  network_rule_default_action = "Deny"
  network_rule_ip_rules       = ["203.0.113.10", "203.0.113.11/32"]

  tags = {
    Owner = "Platform"
  }
}
```

## Example 3: System-Assigned Identity with Role Assignments

```hcl
module "acr" {
  source = "./modules/acr"
  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name = "rg-example-prod"
  location            = "canadacentral"
  app_env             = "prod"
  name                = "platformimages"
  sku                 = "Premium"
  identity_type       = "SystemAssigned"

  managed_identity_role_assignments = {
    kv_crypto = {
      scope                = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.KeyVault/vaults/<kv-name>"
      role_definition_name = "Key Vault Crypto Service Encryption User"
    }
  }
}
```

## Example 4: User-Assigned Identity with CMK and Geo-Replication

```hcl
module "acr" {
  source = "./modules/acr"
  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name = "rg-example-prod"
  location            = "canadacentral"
  app_env             = "prod"
  name                = "platformimages"
  sku                 = "Premium"
  identity_type       = "UserAssigned"
  identity_ids = [
    "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uai-acr"
  ]

  customer_managed_key_id                 = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.KeyVault/vaults/<vault-name>/keys/<key-name>/<key-version>"
  customer_managed_key_identity_client_id = "00000000-0000-0000-0000-000000000000"

  georeplications = [
    {
      location                  = "canadaeast"
      regional_endpoint_enabled = true
      zone_redundancy_enabled   = true
      tags = {
        Region = "Secondary"
      }
    }
  ]
}
```

## Example 5: Private Endpoint with DNS Lookup

```hcl
module "acr" {
  source = "./modules/acr"
  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  app_env             = "prod"
  name                = "platformimages"
  sku                 = "Premium"

  enable_private_endpoint                      = true
  private_endpoint_subnet_name                 = "snet-example-private-endpoints"
  private_endpoint_vnet_name                   = "vnet-example-prod"
  private_endpoint_network_resource_group_name = "rg-example-network-prod"
  private_dns_zone_name                        = "privatelink.azurecr.io"
  private_dns_zone_resource_group_name         = "rg-example-network-prod"
}
```

## Notes

- Replace placeholder IDs, names, and scopes with environment-specific values.
- Prefer Entra object IDs over display names when group names are not unique.
- `export_policy_enabled = false` requires `public_network_access_enabled = false`.
- Customer-managed keys require `identity_type` to include `UserAssigned`.
- Geo-replications must use distinct locations and cannot include the primary registry location.
